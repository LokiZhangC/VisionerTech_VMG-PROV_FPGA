
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : maxuhp1.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : maxuhp1
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : x=1.m*2^n,so log(x)=log(1.m*2^n)=log(1.m)+log(2^n)=log(1.m)+n*log(2)
//                  y=(1-1.m)/(1+1.m),1.m=(1-y)/(1+y)
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================
module maxuhp1
#(
  parameter  C_DATA_WIDTH  = 32
)
(
  //system signal
  input  wire                    clk  , //
  input  wire                    reset, //
  //data input
  input  wire                    dataf_in_valid , 
  input  wire [C_DATA_WIDTH-1:0] dataf_in       ,
  input  wire [C_DATA_WIDTH-1:0] dataf_maxu_in  ,
  //data output
  output wire                    dataf_out_valid, 
  output wire [C_DATA_WIDTH-1:0] dataf_out      ,
  //add
  output wire [C_DATA_WIDTH-1:0] add_a      ,
  output wire [C_DATA_WIDTH-1:0] add_b      ,
	output wire                    add_valid  ,
	input  wire [C_DATA_WIDTH-1:0] add_result ,
	input  wire                    add_rdy    ,
	//mult
  output wire [C_DATA_WIDTH-1:0] mult_a     ,
  output wire [C_DATA_WIDTH-1:0] mult_b     ,
	output wire                    mult_valid ,
	input  wire [C_DATA_WIDTH-1:0] mult_result,
	input  wire                    mult_rdy
);
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	
	
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	assign mult_a     = dataf_maxu_in;
	assign mult_b     = dataf_in     ;
	assign mult_valid = dataf_in_valid;
	
	assign add_a      = mult_result ;
	assign add_b      = 32'h3F800000;
	assign add_valid  = mult_rdy;
	
	assign dataf_out_valid = add_rdy   ;
	assign dataf_out       = add_result;
	
endmodule
