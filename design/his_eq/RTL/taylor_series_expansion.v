
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : taylor_series_expansion.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : taylor_series_expansion
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : y=(1-1.m)/(1+1.m),1.m=(1-y)/(1+y)     -1<y<=1
//                  $=ÀÛ¼Ó·ûºÅ£¬È¡n=0~8
//                  log(1.m)=log(1-y)-log(1+y)=-2y$y^2n/(2n+1)
//                 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================
module taylor_series_expansion
#(
  parameter  C_DATA_WIDTH  = 32
)
(
  // system signal
  input  wire                    clk  , //
  input  wire                    reset, //
  // data input
  input  wire                    y_valid, 
  input  wire [C_DATA_WIDTH-1:0] y_in,
	input  wire                    nxloge2_valid, 
  input  wire [C_DATA_WIDTH-1:0] nxloge2_in,
  // data output
  output reg                     dataf_out_valid, 
  output reg  [C_DATA_WIDTH-1:0] dataf_out      ,
  //add
  output reg  [C_DATA_WIDTH-1:0] add_a      ,
  output reg  [C_DATA_WIDTH-1:0] add_b      ,
	output reg                     add_valid  ,
	input  wire [C_DATA_WIDTH-1:0] add_result ,
	input  wire                    add_rdy    ,
	//mult
  output reg  [C_DATA_WIDTH-1:0] mult_a     ,
  output reg  [C_DATA_WIDTH-1:0] mult_b     ,
	output reg                     mult_valid ,
	input  wire [C_DATA_WIDTH-1:0] mult_result,
	input  wire                    mult_rdy   ,
	output wire                    db
);
	
	/*
	0.6931471805599453f
	00111111001100010111001000011000(Bf)
	00111111101100010111001000011000(*2)
	10111111101100010111001000011000(*-2)
	
	10.1234567890123456f
	01000001001000011111100110101110(Bf)
	01000001101000011111100110101110(*2)
	11000001101000011111100110101110(*-2)
	*/
	
	//----------------------------------------------------
	//series_expansion,-2   =Hf(C0000000),-2/ 3=Hf(BF2AAAAB),-2/ 5=Hf(BECCCCCD),
	//                 -2/ 7=Hf(BE924925),-2/ 9=Hf(BE638E39),-2/11=Hf(BE3A2E8C),
	//                 -2/13=Hf(BE1D89D9),-2/15=Hf(BE088889),
	//----------------------------------------------------
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg                     mult_rdy_d1;
	wire                    mult_rdy_ns;
	
	reg  [2:0]              mult_process_cnt;
	reg  [3:0]              mult_cnt;
	wire                    mult_cnt_nz;
	
	reg                     add_rdy_d1;
	wire                    add_rdy_ns;
	reg  [2:0]              sum_process_cnt;
	reg  [2:0]              sum_cnt      ;
	
	reg  [C_DATA_WIDTH-1:0] yn0          ;
	reg  [C_DATA_WIDTH-1:0] yn1          ;
	reg  [C_DATA_WIDTH-1:0] yn2          ;
	reg  [C_DATA_WIDTH-1:0] yn3          ;
	reg  [C_DATA_WIDTH-1:0] yn4          ;
	reg  [C_DATA_WIDTH-1:0] yn5          ;
	reg  [C_DATA_WIDTH-1:0] yn6          ;
	reg  [C_DATA_WIDTH-1:0] yn7          ;
	reg  [C_DATA_WIDTH-1:0] y20          ;
	reg  [C_DATA_WIDTH-1:0] y21          ;
	reg  [C_DATA_WIDTH-1:0] y22          ;
	reg  [C_DATA_WIDTH-1:0] y23          ;
	reg  [C_DATA_WIDTH-1:0] y24          ;
	reg  [C_DATA_WIDTH-1:0] y25          ;
	reg  [C_DATA_WIDTH-1:0] y26          ;
	reg  [C_DATA_WIDTH-1:0] y27          ;
	reg  [C_DATA_WIDTH-1:0] sum0         ;
	reg  [C_DATA_WIDTH-1:0] sum1         ;
	reg  [C_DATA_WIDTH-1:0] sum2         ;
	reg  [C_DATA_WIDTH-1:0] sum3         ;
	reg  [C_DATA_WIDTH-1:0] sum4         ;
	reg  [C_DATA_WIDTH-1:0] sum5         ;
	reg  [C_DATA_WIDTH-1:0] sum6         ;
	reg  [C_DATA_WIDTH-1:0] sum7         ;
	
	
	
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	reg        y_valid_d;
	reg  [7:0] y_cnt;
  reg  [7:0] y_cnt_r;
  always @(posedge clk or posedge reset)
  begin
  	if(reset)
  	begin
  		y_valid_d <= 1'b0;
  	end
  	else
  	begin
  		y_valid_d <= y_valid;
  	end
  end
  
  always @(posedge clk or posedge reset)
  begin
  	if(reset)
  	begin
  		y_cnt <= 0;
  	end
  	else if(y_valid_d)
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
  	else if(~y_valid & y_valid_d)
  	begin
  		y_cnt_r <= y_cnt;
  	end
  end
  
  assign db = &y_cnt_r;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			mult_rdy_d1 <= 1'b0;
			add_rdy_d1  <= 1'b0;
		end
		else
		begin
			mult_rdy_d1 <= mult_rdy;
			add_rdy_d1  <= add_rdy;
		end
	end
	
	assign mult_rdy_ns = ~mult_rdy & mult_rdy_d1;
	assign add_rdy_ns  = ~add_rdy & add_rdy_d1;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			mult_process_cnt <= 0;
		end
		else if(y_valid | mult_rdy)
		begin
			mult_process_cnt <= mult_process_cnt + 1'b1;
		end
		else
		begin
			mult_process_cnt <= 0;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			mult_cnt <= 0;
		end
		else if((mult_rdy & &mult_process_cnt) | mult_rdy_ns & mult_process_cnt[0])//(mult_rdy_ns)//
		begin
			mult_cnt <= mult_cnt + 1'b1;
		end
	end
	
	assign mult_cnt_nz = (|mult_cnt);
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sum_process_cnt <= 0;
		end
		else if(nxloge2_valid | add_rdy)
		begin
			sum_process_cnt <= sum_process_cnt + 1'b1;
		end
		else
		begin
			sum_process_cnt <= 0;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sum_cnt <= 0;
		end
		else if(sum_process_cnt[0] & add_rdy_ns | add_rdy & &sum_process_cnt)
		begin
			sum_cnt <= sum_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			y20    <= 0;
			y21    <= 0;
			y22    <= 0;
			y23    <= 0;
			y24    <= 0;
			y25    <= 0;
			y26    <= 0;
			y27    <= 0;
		end
		else if(~mult_cnt_nz & mult_rdy)
		begin
			case(mult_process_cnt)
				3'd0:y20 <= mult_result;
				3'd1:y21 <= mult_result;
				3'd2:y22 <= mult_result;
				3'd3:y23 <= mult_result;
				3'd4:y24 <= mult_result;
				3'd5:y25 <= mult_result;
				3'd6:y26 <= mult_result;
				3'd7:y27 <= mult_result;
			endcase
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			yn0  <= 0;
			yn1  <= 0;
			yn2  <= 0;
			yn3  <= 0;
			yn4  <= 0;
			yn5  <= 0;
			yn6  <= 0;
			yn7  <= 0;			
			sum0 <= 0;
			sum1 <= 0;
			sum2 <= 0;
			sum3 <= 0;
			sum4 <= 0;
			sum5 <= 0;
			sum6 <= 0;
			sum7 <= 0;
		end
		else
		begin
			case(mult_process_cnt)
				3'd0:
				begin
					if(y_valid)
					begin
						yn0  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn0  <= mult_result;
					end
				end
				
				3'd1:
				begin
					if(y_valid)
					begin
						yn1  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn1  <= mult_result;
					end
				end
					
				3'd2:
				begin
					if(y_valid)
					begin
						yn2  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn2  <= mult_result;
					end
				end
				
				3'd3:
				begin
					if(y_valid)
					begin
						yn3  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn3  <= mult_result;
					end
				end
				
				3'd4:
				begin
					if(y_valid)
					begin
						yn4  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn4  <= mult_result;
					end
				end
				
				3'd5:
				begin
					if(y_valid)
					begin
						yn5  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn5  <= mult_result;
					end
				end
				
				3'd6:
				begin
					if(y_valid)
					begin
						yn6  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn6  <= mult_result;
					end
				end
				
				3'd7:
				begin
					if(y_valid)
					begin
						yn7  <= y_in;
					end
					else if(mult_rdy & mult_cnt_nz & ~mult_cnt[0])
					begin
						yn7  <= mult_result;
					end
				end
			endcase
			
			case(sum_process_cnt)
				3'd0:
				begin
					if(nxloge2_valid)
					begin
						sum0 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum0 <= add_result;
					end
				end
				
				3'd1:
				begin
					if(nxloge2_valid)
					begin
						sum1 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum1 <= add_result;
					end
				end
				
				3'd2:
				begin
					if(nxloge2_valid)
					begin
						sum2 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum2 <= add_result;
					end
				end
				
				3'd3:
				begin
					if(nxloge2_valid)
					begin
						sum3 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum3 <= add_result;
					end
				end
				
				3'd4:
				begin
					if(nxloge2_valid)
					begin
						sum4 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum4 <= add_result;
					end
				end
				
				3'd5:
				begin
					if(nxloge2_valid)
					begin
						sum5 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum5 <= add_result;
					end
				end
				
				3'd6:
				begin
					if(nxloge2_valid)
					begin
						sum6 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum6 <= add_result;
					end
				end
				
				3'd7:
				begin
					if(nxloge2_valid)
					begin
						sum7 <= nxloge2_in;
					end
					else if(add_rdy)
					begin
						sum7 <= add_result;
					end
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			mult_a     <= 0;
			mult_b     <= 0;
			mult_valid <= 0;
		end
		else
		begin
			mult_valid <= y_valid | mult_rdy;//(mult_rdy & mult_cnt_nz);
			case(mult_cnt)
				4'd0:
				begin
					if(y_valid)
					begin
						mult_a <= y_in;
						mult_b <= y_in;
					end
					else
					begin
						mult_a <= 32'hC0000000;//-2
						case(mult_process_cnt)
							3'd0:mult_b <= yn0;
							3'd1:mult_b <= yn1;
							3'd2:mult_b <= yn2;
							3'd3:mult_b <= yn3;
							3'd4:mult_b <= yn4;
							3'd5:mult_b <= yn5;
							3'd6:mult_b <= yn6;
							3'd7:mult_b <= yn7;
						endcase	
					end
				end
				
				4'd1:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase							
				end
				
				4'd2:
				begin
					mult_a <= 32'hBF2AAAAB;//-(2/3)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd3:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase		
				end
				
				4'd4:
				begin
					mult_a <= 32'hBECCCCCD;//-(2/5)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd5:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase
				end
				
				4'd6:
				begin
					mult_a <= 32'hBE924925;//-(2/7)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd7:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase
				end
				
				4'd8:
				begin
					mult_a <= 32'hBE638E39;//-(2/9)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd9:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase
				end
				
				4'd10:
				begin
					mult_a <= 32'hBE3A2E8C;//-(2/11)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd11:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase
				end
				
				4'd12:
				begin
					mult_a <= 32'hBE1D89D9;//-(2/13)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				4'd13:
				begin
					case(mult_process_cnt)
						3'd0:
						begin
							mult_a <= y20;
							mult_b <= yn0;
						end
						
						3'd1:
						begin
							mult_a <= y21;
							mult_b <= yn1;
						end
						
						3'd2:
						begin
							mult_a <= y22;
							mult_b <= yn2;
						end
						
						3'd3:
						begin
							mult_a <= y23;
							mult_b <= yn3;
						end
						
						3'd4:
						begin
							mult_a <= y24;
							mult_b <= yn4;
						end
						
						3'd5:
						begin
							mult_a <= y25;
							mult_b <= yn5;
						end
						
						3'd6:
						begin
							mult_a <= y26;
							mult_b <= yn6;
						end
						
						3'd7:
						begin
							mult_a <= y27;
							mult_b <= yn7;
						end
					endcase
				end
				
				4'd14:
				begin
					mult_a <= 32'hBE088889;//-(2/15)
					case(mult_process_cnt)
						3'd0:mult_b <= mult_result;
						3'd1:mult_b <= mult_result;
						3'd2:mult_b <= mult_result;
						3'd3:mult_b <= mult_result;
						3'd4:mult_b <= mult_result;
						3'd5:mult_b <= mult_result;
						3'd6:mult_b <= mult_result;
						3'd7:mult_b <= mult_result;
					endcase	
				end
				
				default:
				begin
					mult_a     <= 0;
					mult_b     <= 0;
					mult_valid <= 0;
				end
			endcase
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
			add_valid <= mult_rdy & mult_cnt[0];
			add_a     <= mult_result;
			case(mult_process_cnt)
				3'd0:add_b <= sum0;
				3'd1:add_b <= sum1;
				3'd2:add_b <= sum2;
				3'd3:add_b <= sum3;
				3'd4:add_b <= sum4;
				3'd5:add_b <= sum5;
				3'd6:add_b <= sum6;
				3'd7:add_b <= sum7;
			endcase			
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataf_out_valid <= 0;
			dataf_out       <= 0;
		end
		else if(&sum_cnt)
		begin
			dataf_out_valid <= add_rdy;
			dataf_out       <= add_result;
		end
		else
		begin
			dataf_out_valid <= 0;
			dataf_out       <= 0;
		end
	end
	
endmodule
