
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : cumulative_sum.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : cumulative_sum
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : cumulative_sum,C(0) = M(0), C(i) = C(i-1) + M(i) for i > 0
//                 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================

module cumulative_sum
#(
  parameter  C_DATA_WIDTH  = 32,
  parameter  C_VDATA_WIDTH = 8
)
(
  //system signal
  input  wire                    clk  , //
  input  wire                    reset, //
  //data input
  input  wire                    dataf_in_valid,
  input  wire [C_DATA_WIDTH-1:0] dataf_in,
  //data output
  output reg                     cal_eq_done,
  output reg                     cal_eq_part_done,
  //ram
  output wire                    ram_wea,
  output wire [C_VDATA_WIDTH-1:0]ram_addra,
  output wire [C_DATA_WIDTH-1:0] ram_dina,
  output wire                    ram_rdb,
  output wire [C_VDATA_WIDTH-1:0]ram_addrb,
	input  wire [C_DATA_WIDTH-1:0] ram_doutb,
  //add
  output reg  [C_DATA_WIDTH-1:0] add_a      ,
  output reg  [C_DATA_WIDTH-1:0] add_b      ,
	output reg                     add_valid  ,
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
  output wire [C_DATA_WIDTH-1:0] div_a     ,
  output wire [C_DATA_WIDTH-1:0] div_b     ,
	output wire                    div_valid ,
	input  wire [C_DATA_WIDTH-1:0] div_result,
	input  wire                    div_rdy   ,
	//float2fixed
  output wire [C_DATA_WIDTH-1:0] float2fixed_a     ,
	output wire                    float2fixed_valid ,
	input  wire [C_DATA_WIDTH-1:0] float2fixed_result,
	input  wire                    float2fixed_rdy   
);


	// =============================================================================
	// Internal signal
	// =============================================================================
	//
	reg  [C_DATA_WIDTH*7-1:0] dataf_in_r;
	reg                       dataf_in_valid_d1;
	wire                      dataf_in_valid_ps;
	reg  [C_VDATA_WIDTH-1:0]  cnt_data;
	
	reg                       c0_valid; 
  reg  [C_DATA_WIDTH-1:0]   c0_data ;
	reg                       c_valid;
  reg  [C_DATA_WIDTH-1:0]   c_data ;
  reg                       cn_0_valid; 
  reg  [C_DATA_WIDTH-1:0]   cn_0_data ;
  
  reg  [C_VDATA_WIDTH-1:0]  sub_cnt;
  reg  [C_VDATA_WIDTH-1:0]  mult_cnt;
  
  reg                       div_in_flag;
  reg                       div_in_flag_d;
  reg  [C_VDATA_WIDTH-1:0]  div_in_cnt;
  reg  [C_VDATA_WIDTH-1:0]  div_out_cnt;
  
  reg  [C_VDATA_WIDTH-1:0]  float2fixed_cnt;
  
	// =============================================================================
	// RTL Body
	// =============================================================================
	//---------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataf_in_valid_d1 <= 1'b0;
		end
		else
		begin
			dataf_in_valid_d1 <= dataf_in_valid;
		end
	end
	
	assign dataf_in_valid_ps = dataf_in_valid & ~dataf_in_valid_d1;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataf_in_r <= 1'b0;
		end
		else if(dataf_in_valid & dataf_in_valid_d1)
		begin
			dataf_in_r <= {dataf_in_r[C_DATA_WIDTH*6-1:0],dataf_in};
		end
		else if(add_rdy)
		begin
			dataf_in_r <= {dataf_in_r[C_DATA_WIDTH*6-1:0],dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6]};
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			cnt_data <= 0;
		end
		else if(add_rdy)
		begin
			cnt_data <= cnt_data + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			add_a     <= 0;
			add_b     <= 0;
			add_valid <= 0;
		end
		else
		begin
			case(cnt_data[2:0])
				3'd0:
				begin
					add_valid <= dataf_in_valid_ps | add_rdy;
					if(dataf_in_valid_ps)
					begin
						add_a     <= dataf_in;
						add_b     <= c_data;
					end
					else
					begin
						add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
						add_b     <= add_result;
					end					
				end
				
				3'd1:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd2:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd3:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd4:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd5:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd6:
				begin
					add_a     <= dataf_in_r[C_DATA_WIDTH*7-1:C_DATA_WIDTH*6];
					add_b     <= add_result;
					add_valid <= add_rdy;
				end
				
				3'd7:
				begin
					add_a     <= 0;
					add_b     <= 0;
					add_valid <= 1'b0;
				end
			endcase			
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			c0_valid <= 1'b0;
			c0_data   <= 0;
		end
		else if(~(|cnt_data) & add_rdy)
		begin
			c0_valid <= 1'b1;
			c0_data   <= add_result;
		end
		else
		begin
			c0_valid <= 1'b0;
		end		
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			c_data <= 0;
		end
		else if(add_rdy)
		begin
			c_data <= add_result;
		end
		else if(~(|cnt_data))
		begin
			c_data <= 0;	
		end		
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			c_valid <= 0;
		end
		else
		begin
			c_valid <= add_rdy;
		end
	end
	
	assign sub_a     = c_data;
	assign sub_b     = c0_data;
	assign sub_valid = c_valid;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sub_cnt <= 0;
		end
		else if(sub_rdy)
		begin
			sub_cnt <= sub_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			cn_0_data   <= 0;
			cn_0_valid <= 1'b0;
		end
		else if(sub_rdy & (&sub_cnt))
		begin
			cn_0_data   <= sub_result;
			cn_0_valid <= 1'b1;
		end
		else
		begin
			cn_0_valid <= 1'b0;
		end		
	end
	
	assign mult_a     = 32'h437f0000;//255
	assign mult_b     = sub_result;
	assign mult_valid = sub_rdy;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			mult_cnt <= 0;
		end
		else if(mult_rdy)
		begin
			mult_cnt <= mult_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			div_in_flag <= 1'b0;
		end
		else if(&div_in_cnt)
		begin
			div_in_flag <= 1'b0;
		end
		else if(mult_rdy & &mult_cnt)
		begin
			div_in_flag <= 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			div_in_flag_d <= 1'b0;
		end
		else
		begin
			div_in_flag_d <= div_in_flag;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			div_in_cnt <= 0;
		end
		else if(div_in_flag)
		begin
			div_in_cnt <= div_in_cnt + 1'b1;
		end
		else
		begin
			div_in_cnt <= 0;
		end
	end
	
	assign div_a     = ram_doutb;
	assign div_b     = cn_0_data;
	assign div_valid = div_in_flag_d;
	
	assign float2fixed_a     = div_result;
	assign float2fixed_valid = div_rdy;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			float2fixed_cnt <= 0;
		end
		else if(float2fixed_rdy)
		begin
			float2fixed_cnt <= float2fixed_cnt + 1'b1;
		end
	end
	
	assign ram_wea   = mult_rdy | float2fixed_rdy;
	assign ram_dina  = (mult_rdy) ? mult_result : float2fixed_result;
	assign ram_addra = (mult_rdy) ? mult_cnt : float2fixed_cnt;
	assign ram_addrb = div_in_cnt;
	assign ram_rdb   = div_in_flag;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			cal_eq_part_done <= 1'b0;
			cal_eq_done      <= 1'b0;
		end
		else if(mult_rdy & (&mult_cnt[2:0]) & ~(&mult_cnt[C_VDATA_WIDTH-1:3]))
		begin
			cal_eq_part_done <= 1'b1;
			cal_eq_done      <= 1'b0;
		end
		else if(&float2fixed_cnt)
		begin
			cal_eq_part_done <= 1'b1;
			cal_eq_done      <= 1'b1;
		end
		else
		begin
			cal_eq_part_done <= 1'b0;
			cal_eq_done      <= 1'b0;
		end
	end
	
endmodule