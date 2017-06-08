
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : float_separate.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : float_separate
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
module float_separate
#(
  parameter  C_DATA_WIDTH  = 32
)
(
  //system signal
  input  wire                    clk  ,
  input  wire                    reset,
  //data input
  input  wire                    dataf_in_valid , 
  input  wire [C_DATA_WIDTH-1:0] dataf_in       ,
  //data output  
  output reg                     nxloge2_valid,
  output reg  [C_DATA_WIDTH-1:0] nxloge2_out,
  output reg                     y_valid,
  output reg  [C_DATA_WIDTH-1:0] y_out,
  //fixed2float
  output wire [C_DATA_WIDTH-1:0] fixed2float_a     ,
	output wire                    fixed2float_valid ,          
	input  wire [C_DATA_WIDTH-1:0] fixed2float_result,
	input  wire                    fixed2float_rdy   ,
	//add
  output wire [C_DATA_WIDTH-1:0] add_a      ,
  output wire [C_DATA_WIDTH-1:0] add_b      ,
	output wire                    add_valid  ,
	input  wire [C_DATA_WIDTH-1:0] add_result ,
	input  wire                    add_rdy    ,
	//sub                                     
  output wire [C_DATA_WIDTH-1:0] sub_a      ,
  output wire [C_DATA_WIDTH-1:0] sub_b      ,
	output wire                    sub_valid  ,
	input  wire [C_DATA_WIDTH-1:0] sub_result ,
	input  wire                    sub_rdy    ,
	//mult
  output wire [C_DATA_WIDTH-1:0] mult_a     ,
  output wire [C_DATA_WIDTH-1:0] mult_b     ,
	output wire                    mult_valid ,
	input  wire [C_DATA_WIDTH-1:0] mult_result,
	input  wire                    mult_rdy   ,
	//div
  output wire [C_DATA_WIDTH-1:0] div_a      ,
  output wire [C_DATA_WIDTH-1:0] div_b      ,
	output wire                    div_valid  ,
	input  wire [C_DATA_WIDTH-1:0] div_result ,
	input  wire                    div_rdy    ,
	
	output wire                    db
  
);
	
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg                              dataf_valid_t;
	reg  signed [C_DATA_WIDTH-1:0]   datafn_t   ;
	reg         [C_DATA_WIDTH-1:0]   datafm_t   ;
	wire signed [8:0]                datafe;
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	assign datafe = {1'b0,dataf_in[C_DATA_WIDTH-2:C_DATA_WIDTH-9]};
	
  always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataf_valid_t <= 0;
			datafn_t <= 0;
			datafm_t <= 0;
		end
		else
		begin
			dataf_valid_t <= dataf_in_valid;
			datafn_t <= datafe - 8'd127;
			datafm_t <= {dataf_in[C_DATA_WIDTH-1],8'd127,dataf_in[C_DATA_WIDTH-10:0]};
		end
	end
	
	//----------------------------------------------------
	//n*log(2),log(2)=Df(0.6931471805599453)=Bf(00111111001100010111001000011000)=Hf(3F317218)
	//----------------------------------------------------
	assign fixed2float_a     = datafn_t;
	assign fixed2float_valid = dataf_valid_t;
	
	assign mult_a     = fixed2float_result;
	assign mult_b     = 32'h3F317218;
	assign mult_valid = fixed2float_rdy;
	
	//----------------------------------------------------
	//y=(1-1.m)/(1+1.m),because inverse function 1.m=(1-y)/(1+y)
	//----------------------------------------------------
	assign sub_a     = 32'h3F800000;
	assign sub_b     = datafm_t;
	assign sub_valid = dataf_valid_t;
	
	assign add_a     = 32'h3F800000;
	assign add_b     = datafm_t;
	assign add_valid = dataf_valid_t;
	/*
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			div_a     <= 0;
			div_b     <= 0;
			div_valid <= 1'b0;
		end
		else
		begin
			div_a     <= sub_result;       
			div_b     <= add_result;       
			div_valid <= sub_rdy & add_rdy;
		end
	end
	*/
	assign div_a     = sub_result;
	assign div_b     = add_result;
	assign div_valid = sub_rdy & add_rdy;
	
	//----------------------------------------------------
	//
	//----------------------------------------------------
	always @(posedge clk or posedge reset)
  begin
  	if(reset)
  	begin
  		nxloge2_valid <= 1'b0;
  		nxloge2_out   <= 0;
  		y_valid       <= 1'b0;
  		y_out         <= 0;
  	end
  	else
  	begin
  		nxloge2_valid <= mult_rdy;
  		nxloge2_out   <= mult_result;
  		y_valid       <= div_rdy;
  		y_out         <= div_result;
  	end
  end
  
  reg  [7:0] y_cnt;
  reg  [7:0] y_cnt_r;
  always @(posedge clk or posedge reset)
  begin
  	if(reset)
  	begin
  		y_cnt <= 0;
  	end
  	else if(div_valid)
  	begin
  		y_cnt <= y_cnt + 1'b1;
  	end
  	else
  	begin
  		y_cnt <= 0;
  	end
  end
  
  always @(posedge clk or posedge reset)
  begin
  	if(reset)
  	begin
  		y_cnt_r <= 0;
  	end
  	else if(~(sub_rdy & add_rdy) & div_valid)
  	begin
  		y_cnt_r <= y_cnt;
  	end
  end
  
  assign db = &y_cnt_r;
	
endmodule
