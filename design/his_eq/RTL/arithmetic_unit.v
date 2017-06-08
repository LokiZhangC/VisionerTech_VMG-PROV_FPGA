
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : arithmetic_unit.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : arithmetic_unit
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : arithmetic_unit,
//                 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================

module arithmetic_unit //delay ?
#(
  parameter  C_DATA_WIDTH  = 32
)
(
  // system signal
  input  wire                    clk  ,
  input  wire                    reset,
  //fixed2float
  input  wire [C_DATA_WIDTH-1:0] fixed2float_a     ,
	input  wire                    fixed2float_valid ,
	output wire                    fixed2float_rfd   ,          
	output wire [C_DATA_WIDTH-1:0] fixed2float_result,
	output wire                    fixed2float_rdy   ,
	//add
  input  wire [C_DATA_WIDTH-1:0] add_a      ,
  input  wire [C_DATA_WIDTH-1:0] add_b      ,
	input  wire                    add_valid  ,
	output wire                    add_rfd    ,
	output wire [C_DATA_WIDTH-1:0] add_result ,
	output wire                    add_rdy    ,
	//sub                                     
  input  wire [C_DATA_WIDTH-1:0] sub_a      ,
  input  wire [C_DATA_WIDTH-1:0] sub_b      ,
	input  wire                    sub_valid  ,
	output wire                    sub_rfd    ,
	output wire [C_DATA_WIDTH-1:0] sub_result ,
	output wire                    sub_rdy    ,
	//mult
  input  wire [C_DATA_WIDTH-1:0] mult_a     ,
  input  wire [C_DATA_WIDTH-1:0] mult_b     ,
	input  wire                    mult_valid ,
	output wire                    mult_rfd   ,
	output wire [C_DATA_WIDTH-1:0] mult_result,
	output wire                    mult_rdy   ,
	//div
  input  wire [C_DATA_WIDTH-1:0] div_a      ,
  input  wire [C_DATA_WIDTH-1:0] div_b      ,
	input  wire                    div_valid  ,
	output wire                    div_rfd    ,
	output wire [C_DATA_WIDTH-1:0] div_result ,
	output wire                    div_rdy    ,
	//float2fixed
  input  wire [C_DATA_WIDTH-1:0] float2fixed_a     ,
	input  wire                    float2fixed_valid ,
	output wire                    float2fixed_rfd   ,
	output wire [C_DATA_WIDTH-1:0] float2fixed_result,
	output wire                    float2fixed_rdy   
	
);


	// =============================================================================
	// Internal signal
	// =============================================================================

	
	// =============================================================================
	// RTL Body
	// =============================================================================
	fixed_to_float //delay 4
	u_fixed_to_float 
	(
	  .a            (fixed2float_a     ), // input [31 : 0] a
	  .operation_nd (fixed2float_valid ), // input operation_nd
	  .operation_rfd(fixed2float_rfd   ), // output operation_rfd
	  .clk          (clk               ), // input clk
	  //.sclr         (reset             ),
	  .result       (fixed2float_result), // output [31 : 0] result
	  .rdy          (fixed2float_rdy   )  // output rdy
	);
	
	float_add //delay 6
	u_float_add 
	(
	  .a            (add_a         ), // input [31 : 0] a
	  .b            (add_b         ), // input [31 : 0] b
	  .operation_nd (add_valid     ), // input operation_nd
	  .operation_rfd(add_rfd       ), // output operation_rfd
	  .clk          (clk           ), // input clk
	  //.sclr         (reset         ),
	  .result       (add_result    ), // output [31 : 0] result
	  .rdy          (add_rdy       )  // output rdy
	);
	
	float_sub //delay 6
	u_float_sub 
	(
	  .a            (sub_a         ), // input [31 : 0] a
	  .b            (sub_b         ), // input [31 : 0] b
	  .operation_nd (sub_valid     ), // input operation_nd
	  .operation_rfd(sub_rfd       ), // output operation_rfd
	  .clk          (clk           ), // input clk
	  //.sclr         (reset         ),
	  .result       (sub_result    ), // output [31 : 0] result
	  .rdy          (sub_rdy       )  // output rdy
	);
	
	float_mult //delay 6
	u_float_mult 
	(
	  .a            (mult_a        ), // input [31 : 0] a
	  .b            (mult_b        ), // input [31 : 0] b
	  .operation_nd (mult_valid    ), // input operation_nd
	  .operation_rfd(mult_rfd      ), // output operation_rfd
	  .clk          (clk           ), // input clk
	  //.sclr         (reset         ),
	  .result       (mult_result   ), // output [31 : 0] result
	  .rdy          (mult_rdy      )  // output rdy
	);
	
	float_div //delay 14
	u_float_div 
	(
	  .a            (div_a        ), // input [31 : 0] a
	  .b            (div_b        ), // input [31 : 0] b
	  .operation_nd (div_valid    ), // input operation_nd
	  .operation_rfd(div_rfd      ), // output operation_rfd
	  .clk          (clk          ), // input clk
	  //.sclr         (reset        ),
	  .result       (div_result   ), // output [31 : 0] result
	  .rdy          (div_rdy      )  // output rdy
	);
	
	float_to_fixed //delay 4
	u_float_to_fixed
	(
	  .a            (float2fixed_a     ), // input [31 : 0] a
	  .operation_nd (float2fixed_valid ), // input operation_nd
	  .operation_rfd(float2fixed_rfd   ), // output operation_rfd
	  .clk          (clk               ), // input clk
	  //.sclr         (reset             ),
	  .result       (float2fixed_result), // output [31 : 0] result
	  .rdy          (float2fixed_rdy   )  // output rdy
	);
	
endmodule