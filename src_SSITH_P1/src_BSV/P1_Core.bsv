// Copyright (c) 2018-2019 Bluespec, Inc. All Rights Reserved.

package P1_Core;

// ================================================================
// This package defines the interface and implementation of the 'P1 Core'
// for the DARPA SSITH project.
// This P1 core contains:
//    - Piccolo CPU, including
//        - Near_Mem (ICache and DCache)
//        - Near_Mem_IO (Timer, Software-interrupt, and other mem-mapped-locations)
//        - External interrupt request line
//        - 2 x AXI4-Lite Master interfaces (from ICache, DCache and DM)
//    - RISC-V Debug Module (DM)
//    - JTAG TAP interface for DM
//    - Optional Tandem Verification trace stream output interface

// ================================================================
// BSV library imports

import FIFO          :: *;
import GetPut        :: *;
import ClientServer  :: *;
import Connectable   :: *;
import Bus           :: *;

// ----------------
// BSV additional libs

import GetPut_Aux :: *;

// ================================================================
// Project imports

// The basic core
import Core_IFC :: *;
import Core     :: *;

// Main fabric
import AXI4_Lite_Types  :: *;
import AXI4_Lite_Fabric :: *;
import Fabric_Defs      :: *;

`ifdef INCLUDE_TANDEM_VERIF
import TV_Info :: *;
`endif

`ifdef INCLUDE_GDB_CONTROL
import Debug_Module :: *;
import JtagTap      :: *;
import Giraffe_IFC  :: *;
`endif

// ================================================================
// The P1_Core interface

interface P1_Core_IFC;

   // ----------------------------------------------------------------
   // Core CPU interfaces

   // CPU IMem and DM to Fabric master interface
   interface AXI4_Lite_Master_IFC #(Wd_Addr, Wd_Data, Wd_User) master0;

   // CPU DMem to Fabric master interface
   interface AXI4_Lite_Master_IFC #(Wd_Addr, Wd_Data, Wd_User) master1;

   // External interrupts
   (* always_ready, always_enabled *)
   method Action cpu_external_interrupt (Bool req);

`ifdef INCLUDE_TANDEM_VERIF
   // ----------------------------------------------------------------
   // Optional Tandem Verifier interface output tuples (n,vb),
   // where 'vb' is a vector of bytes
   // with relevant bytes in locations [0]..[n-1]

   interface Get #(Info_CPU_to_Verifier)  tv_verifier_info_get;
`endif

`ifdef INCLUDE_GDB_CONTROL
   // ----------------
   // JTAG interface

`ifdef JTAG_TAP
   interface JTAG_IFC jtag;
`endif
`endif
endinterface

// ================================================================
// PC reset value

// Entry point for Boot ROM used in Spike/Rocket
// (boot code jumps later to 'h_8000_0000)
Bit #(64)  pc_reset_value    = 'h_0000_1000;

// Entry point for code generated for Spike/Rocket
// Bit #(64)  pc_reset_value    = 'h_8000_0000;

// ================================================================

(* synthesize *)
module mkP1_Core (P1_Core_IFC);

   // CPU + Debug module
   Core_IFC::Core_IFC  core <- mkCore (pc_reset_value);

   // ================================================================
   // Tie-offs (not used in SSITH GFE)

   // Soft reset
   Client #(Bit #(0), Bit #(0)) reset_client_stub = client_stub;
   mkConnection (reset_client_stub, core.cpu_reset_server);

   // CPU Back-door slave interface from fabric
   AXI4_Lite_Master_IFC #(Wd_Addr, Wd_Data, Wd_User) axi_master_stub = dummy_AXI4_Lite_Master_ifc;
   mkConnection (axi_master_stub, core.cpu_slave);

   // Set core's verbosity
   rule rl_never (False);
      core.set_verbosity (?, ?);
   endrule

`ifdef INCLUDE_GDB_CONTROL
   // Non-Debug-Module Reset (reset all except DM)
   rule rl_always;
      let x <- core.dm_ndm_reset_req_get.get;
   endrule
`endif

   // ================================================================
`ifdef INCLUDE_GDB_CONTROL

   // Merge IMem and Debug Module AXI4-Lite Masters
   // since Piccolo uses 3 masters (IMem, DMem and Debug Module)
   // but SSITH GFE only has 2 masters

   // TODO: core.dm_master is temporarily stubbed off.
   // Need to instantiate a 2x1 fabric; connect, on the master side:
   //     core.cpu_imem_master
   //     core.dm_master
   // and export slave side.

   // Read/Write RISC-V memory
   // interface AXI4_Lite_Master_IFC #(Wd_Addr, Wd_Data, Wd_User) dm_master;

   AXI4_Lite_Slave_IFC #(Wd_Addr, Wd_Data, Wd_User) axi_slave_stub = dummy_AXI4_Lite_Slave_ifc;
   mkConnection (core.dm_master, axi_slave_stub);
`endif

   // ================================================================
`ifdef INCLUDE_GDB_CONTROL

   // Instantiate JTAG TAP controller,
   // connect to core.dm_dmi;
   // and export its JTAG interface

   Wire#(Bit#(7)) w_dmi_req_addr <- mkDWire(0);
   Wire#(Bit#(32)) w_dmi_req_data <- mkDWire(0);
   Wire#(Bit#(2)) w_dmi_req_op <- mkDWire(0);

   Wire#(Bit#(32)) w_dmi_rsp_data <- mkDWire(0);
   Wire#(Bit#(2)) w_dmi_rsp_response <- mkDWire(0);

   BusReceiver#(Tuple3#(Bit#(7),Bit#(32),Bit#(2))) bus_dmi_req <- mkBusReceiver;
   BusSender#(Tuple2#(Bit#(32),Bit#(2))) bus_dmi_rsp <- mkBusSender(unpack(0));

`ifdef JTAG_TAP
   let jtagtap <- mkJtagTap;

   mkConnection(jtagtap.dmi.req_ready, pack(bus_dmi_req.in.ready));
   mkConnection(jtagtap.dmi.req_valid, compose(bus_dmi_req.in.valid, unpack));
   mkConnection(jtagtap.dmi.req_addr, w_dmi_req_addr._write);
   mkConnection(jtagtap.dmi.req_data, w_dmi_req_data._write);
   mkConnection(jtagtap.dmi.req_op, w_dmi_req_op._write);
   mkConnection(jtagtap.dmi.rsp_valid, pack(bus_dmi_rsp.out.valid));
   mkConnection(jtagtap.dmi.rsp_ready, compose(bus_dmi_rsp.out.ready, unpack));
   mkConnection(jtagtap.dmi.rsp_data, w_dmi_rsp_data);
   mkConnection(jtagtap.dmi.rsp_response, w_dmi_rsp_response);
`endif

   rule rl_dmi_req;
      bus_dmi_req.in.data(tuple3(w_dmi_req_addr, w_dmi_req_data, w_dmi_req_op));
   endrule

   rule rl_dmi_rsp;
      match {.data, .response} = bus_dmi_rsp.out.data;
      w_dmi_rsp_data <= data;
      w_dmi_rsp_response <= response;
   endrule

   (* preempts = "rl_dmi_req_cpu, rl_dmi_rsp_cpu" *)
   rule rl_dmi_req_cpu;
      match {.addr, .data, .op} = bus_dmi_req.out.first;
      bus_dmi_req.out.deq;
      case (op)
	 1: core.dm_dmi.read_addr(addr);
	 2: begin
	       core.dm_dmi.write(addr, data);
	       bus_dmi_rsp.in.enq(tuple2(?, 0));
	    end
	 default: bus_dmi_rsp.in.enq(tuple2(?, 2));
      endcase
   endrule

   rule rl_dmi_rsp_cpu;
      let data <- core.dm_dmi.read_data;
      bus_dmi_rsp.in.enq(tuple2(data, 0));
   endrule

`endif

   // ================================================================
   // INTERFACE

   // CPU IMem to Fabric master interface
   interface AXI4_Lite_Master_IFC master0 = core.cpu_imem_master;

   // CPU DMem to Fabric master interface
   interface AXI4_Lite_Master_IFC master1 = core.cpu_dmem_master;

   // External interrupts
   method Action cpu_external_interrupt (req) = core.cpu_external_interrupt_req (req);

`ifdef INCLUDE_TANDEM_VERIF
   // ----------------------------------------------------------------
   // Optional Tandem Verifier interface output tuples (n,vb),
   // where 'vb' is a vector of bytes
   // with relevant bytes in locations [0]..[n-1]

   interface Get tv_verifier_info_get = core.tv_verifier_info_get;
`endif

`ifdef INCLUDE_GDB_CONTROL
   // ----------------------------------------------------------------
   // Optional Debug Module interfaces

   // ----------------
   // TODO: JTAG interface

`ifdef JTAG_TAP
   interface JTAG_IFC jtag = jtagtap.jtag;
`endif

`endif
endmodule

// ================================================================

endpackage