//
// Generated by Bluespec Compiler, version 2017.07.A (build 1da80f1, 2017-07-21)
//
// On Mon Jul  9 19:01:39 EDT 2018
//
//
// Ports:
// Name                         I/O  size props
// RDY_put_args                   O     1
// get_result                     O   128
// RDY_get_result                 O     1
// CLK                            I     1 clock
// RST_N                          I     1 reset
// put_args_x_is_signed           I     1
// put_args_x                     I    64
// put_args_y_is_signed           I     1
// put_args_y                     I    64
// EN_put_args                    I     1
// EN_get_result                  I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkIntMul_64(CLK,
		   RST_N,

		   put_args_x_is_signed,
		   put_args_x,
		   put_args_y_is_signed,
		   put_args_y,
		   EN_put_args,
		   RDY_put_args,

		   EN_get_result,
		   get_result,
		   RDY_get_result);
  input  CLK;
  input  RST_N;

  // action method put_args
  input  put_args_x_is_signed;
  input  [63 : 0] put_args_x;
  input  put_args_y_is_signed;
  input  [63 : 0] put_args_y;
  input  EN_put_args;
  output RDY_put_args;

  // actionvalue method get_result
  input  EN_get_result;
  output [127 : 0] get_result;
  output RDY_get_result;

  // signals for module outputs
  wire [127 : 0] get_result;
  wire RDY_get_result, RDY_put_args;

  // register m_rg_busy
  reg m_rg_busy;
  wire m_rg_busy$D_IN, m_rg_busy$EN;

  // register m_rg_isNeg
  reg m_rg_isNeg;
  wire m_rg_isNeg$D_IN, m_rg_isNeg$EN;

  // register m_rg_signed
  reg m_rg_signed;
  wire m_rg_signed$D_IN, m_rg_signed$EN;

  // register m_rg_x
  reg [127 : 0] m_rg_x;
  wire [127 : 0] m_rg_x$D_IN;
  wire m_rg_x$EN;

  // register m_rg_xy
  reg [127 : 0] m_rg_xy;
  wire [127 : 0] m_rg_xy$D_IN;
  wire m_rg_xy$EN;

  // register m_rg_y
  reg [63 : 0] m_rg_y;
  wire [63 : 0] m_rg_y$D_IN;
  wire m_rg_y$EN;

  // rule scheduling signals
  wire CAN_FIRE_RL_m_compute,
       CAN_FIRE_get_result,
       CAN_FIRE_put_args,
       WILL_FIRE_RL_m_compute,
       WILL_FIRE_get_result,
       WILL_FIRE_put_args;

  // inputs to muxes for submodule ports
  wire [127 : 0] MUX_m_rg_x$write_1__VAL_1,
		 MUX_m_rg_x$write_1__VAL_2,
		 MUX_m_rg_xy$write_1__VAL_1;
  wire [63 : 0] MUX_m_rg_y$write_1__VAL_1, MUX_m_rg_y$write_1__VAL_2;
  wire MUX_m_rg_xy$write_1__SEL_1;

  // remaining internal signals
  wire [127 : 0] xy___1__h666;
  wire [63 : 0] _theResult___fst__h479,
		_theResult___fst__h482,
		_theResult___fst__h524,
		_theResult___fst__h527,
		_theResult___snd_fst__h519;
  wire IF_put_args_x_is_signed_THEN_put_args_x_BIT_63_ETC___d29;

  // action method put_args
  assign RDY_put_args = !m_rg_busy ;
  assign CAN_FIRE_put_args = !m_rg_busy ;
  assign WILL_FIRE_put_args = EN_put_args ;

  // actionvalue method get_result
  assign get_result = m_rg_isNeg ? xy___1__h666 : m_rg_xy ;
  assign RDY_get_result = m_rg_busy && m_rg_y == 64'd0 ;
  assign CAN_FIRE_get_result = m_rg_busy && m_rg_y == 64'd0 ;
  assign WILL_FIRE_get_result = EN_get_result ;

  // rule RL_m_compute
  assign CAN_FIRE_RL_m_compute = m_rg_y != 64'd0 && m_rg_busy ;
  assign WILL_FIRE_RL_m_compute = CAN_FIRE_RL_m_compute ;

  // inputs to muxes for submodule ports
  assign MUX_m_rg_xy$write_1__SEL_1 = WILL_FIRE_RL_m_compute && m_rg_y[0] ;
  assign MUX_m_rg_x$write_1__VAL_1 = { 64'd0, _theResult___fst__h479 } ;
  assign MUX_m_rg_x$write_1__VAL_2 = { m_rg_x[126:0], 1'd0 } ;
  assign MUX_m_rg_xy$write_1__VAL_1 = m_rg_xy + m_rg_x ;
  assign MUX_m_rg_y$write_1__VAL_1 = { 1'd0, m_rg_y[63:1] } ;
  assign MUX_m_rg_y$write_1__VAL_2 =
	     (put_args_x_is_signed && put_args_y_is_signed) ?
	       _theResult___fst__h527 :
	       _theResult___snd_fst__h519 ;

  // register m_rg_busy
  assign m_rg_busy$D_IN = !EN_get_result ;
  assign m_rg_busy$EN = EN_get_result || EN_put_args ;

  // register m_rg_isNeg
  assign m_rg_isNeg$D_IN =
	     (put_args_x_is_signed && put_args_y_is_signed) ?
	       put_args_x[63] != put_args_y[63] :
	       IF_put_args_x_is_signed_THEN_put_args_x_BIT_63_ETC___d29 ;
  assign m_rg_isNeg$EN = EN_put_args ;

  // register m_rg_signed
  assign m_rg_signed$D_IN = 1'b0 ;
  assign m_rg_signed$EN = 1'b0 ;

  // register m_rg_x
  assign m_rg_x$D_IN =
	     EN_put_args ?
	       MUX_m_rg_x$write_1__VAL_1 :
	       MUX_m_rg_x$write_1__VAL_2 ;
  assign m_rg_x$EN = EN_put_args || WILL_FIRE_RL_m_compute ;

  // register m_rg_xy
  assign m_rg_xy$D_IN =
	     MUX_m_rg_xy$write_1__SEL_1 ?
	       MUX_m_rg_xy$write_1__VAL_1 :
	       128'd0 ;
  assign m_rg_xy$EN = WILL_FIRE_RL_m_compute && m_rg_y[0] || EN_put_args ;

  // register m_rg_y
  assign m_rg_y$D_IN =
	     WILL_FIRE_RL_m_compute ?
	       MUX_m_rg_y$write_1__VAL_1 :
	       MUX_m_rg_y$write_1__VAL_2 ;
  assign m_rg_y$EN = WILL_FIRE_RL_m_compute || EN_put_args ;

  // remaining internal signals
  assign IF_put_args_x_is_signed_THEN_put_args_x_BIT_63_ETC___d29 =
	     put_args_x_is_signed ?
	       put_args_x[63] :
	       put_args_y_is_signed && put_args_y[63] ;
  assign _theResult___fst__h479 =
	     put_args_x_is_signed ? _theResult___fst__h482 : put_args_x ;
  assign _theResult___fst__h482 = put_args_x[63] ? -put_args_x : put_args_x ;
  assign _theResult___fst__h524 =
	     put_args_y_is_signed ? _theResult___fst__h527 : put_args_y ;
  assign _theResult___fst__h527 = put_args_y[63] ? -put_args_y : put_args_y ;
  assign _theResult___snd_fst__h519 =
	     put_args_x_is_signed ? put_args_y : _theResult___fst__h524 ;
  assign xy___1__h666 = -m_rg_xy ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        m_rg_busy <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (m_rg_busy$EN) m_rg_busy <= `BSV_ASSIGNMENT_DELAY m_rg_busy$D_IN;
      end
    if (m_rg_isNeg$EN) m_rg_isNeg <= `BSV_ASSIGNMENT_DELAY m_rg_isNeg$D_IN;
    if (m_rg_signed$EN) m_rg_signed <= `BSV_ASSIGNMENT_DELAY m_rg_signed$D_IN;
    if (m_rg_x$EN) m_rg_x <= `BSV_ASSIGNMENT_DELAY m_rg_x$D_IN;
    if (m_rg_xy$EN) m_rg_xy <= `BSV_ASSIGNMENT_DELAY m_rg_xy$D_IN;
    if (m_rg_y$EN) m_rg_y <= `BSV_ASSIGNMENT_DELAY m_rg_y$D_IN;
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    m_rg_busy = 1'h0;
    m_rg_isNeg = 1'h0;
    m_rg_signed = 1'h0;
    m_rg_x = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    m_rg_xy = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    m_rg_y = 64'hAAAAAAAAAAAAAAAA;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkIntMul_64

