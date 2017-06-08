`timescale 1ps / 1ps
//================================================================================ 
// File Name      : Bayer2RGB.v
//--------------------------------------------------------------------------------
// Create Date    : 06/05/2015 
// Project Name   : Bayer2RGB
// Target Devices : XC7K325T-2FFG900
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================
module Bayer2RGB
#(
	parameter  C_BAYER_FORMAT  = 2'b00,
  parameter  C_RAM_ADDR_BITS = 4'd11 , 
  parameter  C_DATA_WIDTH    = 10'd12,
  parameter  C_LINEBUFF_NUM  = 4'd3
)
(
    // System Signal
    input  wire                     reset    , // (i) Async. Reset (Low Active)   
    input  wire                     clk      , // (i) User Data Video Clock       
    // video input              
    input  wire                     vs_in    , // (i) Vertical Sync Pulse,active high    
    input  wire                     hs_in    , // (i) Horizontal Sync Pulse,active high
    input  wire                     de_in    , // (i) Pixel Data Video Enable  
    input  wire [C_DATA_WIDTH-1:0]  data_in  , // (i) Pixel Data    
    // buff data out
    output reg                      vs_out   , // (o) Vertical Sync Pulse    
    output reg                      hs_out   , // (o) Horizontal Sync Pulse
    output reg                      de_out   , // (o) Pixel Data Video Enable  
		output reg  [3*C_DATA_WIDTH-1:0]data_out     
);    

	function integer clog2;
	input integer value;
	begin 
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
		value = value>>1;
	end 
	endfunction
	
	wire                       vs_d0            ;
	wire                       hs_d0            ;
	wire                       de_d0            ;
	wire                       X_div_d0         ;
	wire                       Y_div_d0         ;
	wire [C_DATA_WIDTH-1:0]    data0_d0         ;
	wire [C_DATA_WIDTH-1:0]    data1_d0         ;
	wire [C_DATA_WIDTH-1:0]    data2_d0         ;
	
	reg                        vs_d1            ;
	reg                        hs_d1            ;
	reg                        de_d1            ;
	reg                        X_div_d1         ;
	reg                        Y_div_d1         ;
	reg  [C_DATA_WIDTH-1:0]    data0_d1         ;
	reg  [C_DATA_WIDTH-1:0]    data1_d1         ;
	reg  [C_DATA_WIDTH-1:0]    data2_d1         ;
	
	reg                        vs_d2            ;
	reg                        hs_d2            ;
	reg                        de_d2            ;  
	reg                        X_div_d2         ;
	reg                        Y_div_d2         ;   
	reg  [C_DATA_WIDTH-1:0]    data0_d2         ;
	reg  [C_DATA_WIDTH-1:0]    data1_d2         ;
	reg  [C_DATA_WIDTH-1:0]    data2_d2         ;
	
	reg                        vs_d3            ;
	reg                        hs_d3            ;
	reg                        de_d3            ;  
	reg                        X_div_d3         ;
	reg                        Y_div_d3         ;  
	
	reg  [C_DATA_WIDTH  :0]    data_R_t1        ;
	reg  [C_DATA_WIDTH  :0]    data_G_t1        ;
	reg  [C_DATA_WIDTH  :0]    data_B_t1        ;
	
	reg  [C_DATA_WIDTH  :0]    data_R_t2        ;
	reg  [C_DATA_WIDTH  :0]    data_G_t2        ;
	reg  [C_DATA_WIDTH  :0]    data_B_t2        ;
	
	reg  [C_DATA_WIDTH+1:0]    data_R           ;
	reg  [C_DATA_WIDTH+1:0]    data_G           ;
	reg  [C_DATA_WIDTH+1:0]    data_B           ;
	
	reg                        vs_t             ;
	reg                        hs_t             ;
	reg                        de_t             ;
	reg  [3*C_DATA_WIDTH-1:0]  data_t           ;
	
	wire                      vs_t1   ;
	wire                      hs_t1   ;
	wire                      de_t1   ;
	wire [3*C_DATA_WIDTH-1:0] data_t1 ;
	
	reg                       vs_t1_d  ;
	reg                       hs_t1_d  ;
	reg                       de_t1_d  ;
	reg  [3*C_DATA_WIDTH-1:0] data_t1_d;
	
	wire                      de_t1_ns ;
	reg  [1:0]                line_cnt;
	
	reg                       vs_t2   ;
	reg                       hs_t2   ;
	reg                       de_t2   ;
	reg  [3*C_DATA_WIDTH-1:0] data_t2 ;
	
	reg                       vs_t2_d1   ;
	reg                       hs_t2_d1   ;
	reg                       de_t2_d1   ;
	reg  [3*C_DATA_WIDTH-1:0] data_t2_d1 ;
	
	reg                       de_t2_d2   ;
	reg  [3*C_DATA_WIDTH-1:0] data_t2_d2 ;
	
	reg                       vs_t3   ;
	reg                       hs_t3   ;
	reg                       de_t3   ;
	
	////////////////////////////////////////////////////////////////////////////////	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d1    <= 1'b1;
			hs_d1    <= 1'b1;
			de_d1    <= 1'b0;
			X_div_d1 <= 1'b0;
			Y_div_d1 <= 1'b0;
			data0_d1 <= 0 ;
			data1_d1 <= 0 ;
			data2_d1 <= 0 ;
			
			vs_d2    <= 1'b1;
			hs_d2    <= 1'b1;
			de_d2    <= 1'b0;
			X_div_d2 <= 1'b0;
			Y_div_d2 <= 1'b0;
			data0_d2 <= 0 ;
			data1_d2 <= 0 ;
			data2_d2 <= 0 ;
			
			vs_d3    <= 1'b1;
			hs_d3    <= 1'b1;
			de_d3    <= 1'b0;
			X_div_d3 <= 1'b0;
			Y_div_d3 <= 1'b0;
		end
		else
		begin
			vs_d1    <= vs_d0   ;
			hs_d1    <= hs_d0   ;
			de_d1    <= de_d0   ;
			X_div_d1 <= X_div_d0;
			Y_div_d1 <= Y_div_d0;
			data0_d1 <= data0_d0;
			data1_d1 <= data1_d0;
			data2_d1 <= data2_d0;
			
			vs_d2    <= vs_d1   ;
			hs_d2    <= hs_d1   ;
			de_d2    <= de_d1   ;
			X_div_d2 <= X_div_d1;
			Y_div_d2 <= Y_div_d1;
			data0_d2 <= data0_d1;
			data1_d2 <= data1_d1;
			data2_d2 <= data2_d1;
			
			vs_d3    <= vs_d2   ;
			hs_d3    <= hs_d2   ;
			de_d3    <= de_d2   ;
			X_div_d3 <= X_div_d2;
			Y_div_d3 <= Y_div_d2;
		end
	end
	
	generate
		case(C_BAYER_FORMAT)
			2'b00://GR
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R_t1 <= 0;
						data_G_t1 <= 0;
						data_B_t1 <= 0;
						data_R_t2 <= 0;
						data_G_t2 <= 0;
						data_B_t2 <= 0;
					end
					else
					begin						
						case({Y_div_d1,X_div_d1})         
							2'b10:                          
							begin                           
								data_R_t1 <= data1_d0 + data1_d2;					
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data2_d1 + data0_d1;
								//data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};					
							end                             
							                                
							2'b01:                          
							begin                           
								data_R_t1 <= data0_d1 + data2_d1;           
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data1_d0 + data1_d2;       
								//data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b11:                          
							begin                           
								data_R_t1 <= {2'b00,data1_d1};
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= data0_d0 + data2_d0;
								data_B_t2 <= data0_d2 + data2_d2;
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b00:                          
							begin                           
								data_R_t1 <= data0_d0 + data2_d0;
								data_R_t2 <= data0_d2 + data2_d2;           
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= {2'b00,data1_d1};          					
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end							
						endcase
					end
				end
			end
			2'b01://RG
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R_t1 <= 0;
						data_G_t1 <= 0;
						data_B_t1 <= 0;
						data_R_t2 <= 0;
						data_G_t2 <= 0;
						data_B_t2 <= 0;
					end
					else
					begin						
						case({Y_div_d1,X_div_d1})         
							2'b11:                          
							begin                           
								data_R_t1 <= data1_d0 + data1_d2;
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data2_d1 + data0_d1;
								//data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};
								
							end                             
							                                
							2'b00:                          
							begin                           
								data_R_t1 <= data0_d1 + data2_d1;           
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data1_d0 + data1_d2;       
								//data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b10:                          
							begin                           
								data_R_t1 <= {2'b00,data1_d1};
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= data0_d0 + data2_d0;
								data_B_t2 <= data0_d2 + data2_d2;
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b01:                          
							begin                           
								data_R_t1 <= data0_d0 + data2_d0;
								data_R_t2 <= data0_d2 + data2_d2;           
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= {2'b00,data1_d1};          					
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end							
						endcase						
					end
				end
			end
			2'b10://BG
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R_t1 <= 0;
						data_G_t1 <= 0;
						data_B_t1 <= 0;
						data_R_t2 <= 0;
						data_G_t2 <= 0;
						data_B_t2 <= 0;
					end
					else
					begin										
						case({Y_div_d1,X_div_d1})         
							2'b00:                          
							begin                           
								data_R_t1 <= data1_d0 + data1_d2;
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data2_d1 + data0_d1;
								//data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};
								
							end                             
							                                
							2'b11:                          
							begin                           
								data_R_t1 <= data0_d1 + data2_d1;           
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data1_d0 + data1_d2;       
								//data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b01:                          
							begin                           
								data_R_t1 <= {2'b00,data1_d1};
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= data0_d0 + data2_d0;
								data_B_t2 <= data0_d2 + data2_d2;
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b10:                          
							begin                           
								data_R_t1 <= data0_d0 + data2_d0;
								data_R_t2 <= data0_d2 + data2_d2;                
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= {2'b00,data1_d1};          					
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end
						endcase
					end
				end
			end
			2'b11://GB
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R_t1 <= 0;
						data_G_t1 <= 0;
						data_B_t1 <= 0;
						data_R_t2 <= 0;
						data_G_t2 <= 0;
						data_B_t2 <= 0;
					end
					else
					begin												
						case({Y_div_d1,X_div_d1})         
							2'b01:                          
							begin                           
								data_R_t1 <= data1_d0 + data1_d2;
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data2_d1 + data0_d1;
								//data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};
								
							end                             
							                                
							2'b10:                          
							begin                           
								data_R_t1 <= data0_d1 + data2_d1;           
								data_G_t1 <= {2'b00,data1_d1}   ;
								data_B_t1 <= data1_d0 + data1_d2;       
								//data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b00:                          
							begin                           
								data_R_t1 <= {2'b00,data1_d1};
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= data0_d0 + data2_d0;
								data_B_t2 <= data0_d2 + data2_d2;
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b11:                          
							begin                           
								data_R_t1 <= data0_d0 + data2_d0;
								data_R_t2 <= data0_d2 + data2_d2;           
								data_G_t1 <= data1_d0 + data0_d1;
								data_G_t2 <= data2_d1 + data1_d2;
								data_B_t1 <= {2'b00,data1_d1};          					
								//data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end							
						endcase
					end
				end
			end
		endcase
	endgenerate
	
	generate
		case(C_BAYER_FORMAT)
			2'b00://GR
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R <= 0;
						data_G <= 0;
						data_B <= 0;
						data_t <= 0;
					end
					else
					begin						
						case({Y_div_d2,X_div_d2})         
							2'b10:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1;
								data_B <= data_B_t1;
								data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};					
							end                             
							                                
							2'b01:                          
							begin                           
								data_R <= data_R_t1;           
								data_G <= data_G_t1;
								data_B <= data_B_t1;       
								data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b11:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1 + data_B_t2;
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b00:                          
							begin                           
								data_R <= data_R_t1 + data_R_t2;           
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1;          					
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end
						endcase
					end
				end
			end
			2'b01://RG
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R <= 0;
						data_G <= 0;
						data_B <= 0;
						data_t <= 0;
					end
					else
					begin						
						case({Y_div_d2,X_div_d2})         
							2'b11:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1;
								data_B <= data_B_t1;
								data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};
								
							end                             
							                                
							2'b00:                          
							begin                           
								data_R <= data_R_t1;           
								data_G <= data_G_t1;
								data_B <= data_B_t1;       
								data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b10:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1 + data_B_t2;
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b01:                          
							begin                           
								data_R <= data_R_t1 + data_R_t2;           
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1;          					
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end
						endcase
					end
				end
			end
			2'b10://BG
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R <= 0;
						data_G <= 0;
						data_B <= 0;
						data_t <= 0;
					end
					else
					begin						
						case({Y_div_d2,X_div_d2})         
							2'b00:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1;
								data_B <= data_B_t1;
								data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};
								
							end                             
							                                
							2'b11:                          
							begin                           
								data_R <= data_R_t1;           
								data_G <= data_G_t1;
								data_B <= data_B_t1;       
								data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b01:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1 + data_B_t2;
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b10:                          
							begin                           
								data_R <= data_R_t1 + data_R_t2;           
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1;          					
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end
						endcase
					end
				end
			end
			2'b11://GB
			begin
				always @(posedge clk or posedge reset)
				begin
					if(reset)
					begin
						data_R <= 0;
						data_G <= 0;
						data_B <= 0;
						data_t <= 0;
					end
					else
					begin						
						case({Y_div_d2,X_div_d2})         
							2'b01:                          
							begin                           
								data_R <= data_R_t1;
								data_G <= data_G_t1;
								data_B <= data_B_t1;
								data_t <= {data_R[C_DATA_WIDTH-1:0],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH+1:2]};								
							end                             
							                                
							2'b10:                          
							begin                           
								data_R <= data_R_t1;           
								data_G <= data_G_t1;
								data_B <= data_B_t1;       
								data_t <= {data_R[C_DATA_WIDTH+1:2],data_G[C_DATA_WIDTH+1:2],data_B[C_DATA_WIDTH-1:0]};   
							end
							
							2'b00:                          
							begin                           
								data_R <= data_R_t1;           
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1 + data_B_t2;
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};
							end                             
							                                
							2'b11:                          
							begin                           
								data_R <= data_R_t1 + data_R_t2;           
								data_G <= data_G_t1 + data_G_t2;
								data_B <= data_B_t1;          	
								data_t <= {data_R[C_DATA_WIDTH:1],data_G[C_DATA_WIDTH-1:0],data_B[C_DATA_WIDTH:1]};  
							end
						endcase
					end
				end
			end
		endcase
	endgenerate
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t     <= 1'b1;
			hs_t     <= 1'b1;
			de_t     <= 1'b0;
			//vs_out   <= 1'b1;
			//hs_out   <= 1'b1;
			//de_out   <= 1'b0;
			//data_out <= 0;
		end
		else
		begin
			vs_t     <= vs_d3;
			hs_t     <= hs_d3;
			de_t     <= de_d3;
			//vs_out   <= vs_t3;                        //vs_t;  // 
			//hs_out   <= hs_t3;                        //hs_t;  // 
			//de_out   <= de_t3;                        //de_t;  // 
			//data_out <= data_t2;//data_t;//data_t2_d1;//data_t;// 
		end
	end
	
	//assign vs_out   = vs_t  ;//vs_in                    ;//
	//assign hs_out   = hs_t  ;//hs_in                    ;//
	//assign de_out   = de_t  ;//de_in                    ;//
	//assign data_out = data_t;//{data_in,data_in,data_in};//
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t1_d   <= 1'b1;
			hs_t1_d   <= 1'b1;
			de_t1_d   <= 1'b0;
			data_t1_d <= 0;
		end
		else
		begin
			vs_t1_d   <= vs_t  ;
			hs_t1_d   <= hs_t  ;
			de_t1_d   <= de_t  ;
			data_t1_d <= data_t;
		end
	end

	assign de_t1_ns = de_t1_d & ~de_t;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			line_cnt <= 0;
		end
		else if(vs_t)
		begin
			line_cnt <= 0;
		end
		else if(de_t1_ns & line_cnt != 2'b11)
		begin
			line_cnt <= line_cnt + 1'b1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t2   <= 1'b1;
			hs_t2   <= 1'b1;
			de_t2   <= 1'b0;
			data_t2 <= 0;   
		end
		else
		begin
			vs_t2   <= vs_t  ;
			hs_t2   <= hs_t  ;
			data_t2 <= data_t;  
			de_t2   <= de_t;
			/*
			if(&line_cnt)
			begin
				de_t2   <= de_t;
			end
			else
			begin
				de_t2   <= 1'b0;
			end
			*/
		end
	end
	
	//-----------------------------------------------------------------
	//delete first and last pixel
	//-----------------------------------------------------------------
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t2_d1   <= 1'b1;
			hs_t2_d1   <= 1'b1;
			de_t2_d1   <= 1'b0;
			data_t2_d1 <= 0;
			de_t2_d2   <= 1'b0;
			data_t2_d2 <= 0;
		end
		else
		begin
			vs_t2_d1   <= vs_t2  ;
			hs_t2_d1   <= hs_t2  ;
			de_t2_d1   <= de_t2  ;
			data_t2_d1 <= data_t2;
			de_t2_d2   <= de_t2_d1;
			data_t2_d2 <= data_t2_d1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t3   <= 1'b1;
			hs_t3   <= 1'b1;
			de_t3   <= 1'b0;
			vs_out   <= 1'b1;
			hs_out   <= 1'b1;
			de_out   <= 1'b0;
			data_out <= 0;
		end
		else
		begin
			vs_t3    <= vs_t2_d1;                   
			hs_t3    <= hs_t2_d1;                   
			de_t3    <= de_t2_d1;//de_t2 & de_t2_d1 & de_t2_d2;
			vs_out   <= vs_t2;     //vs_t3;                        //
			hs_out   <= hs_t2;     //hs_t3;                        //
			de_out   <= de_t2;     //de_t3;                        //
			data_out <= data_t2;   //data_t2_d2;//data_t;//data_t2;//                 
		end
	end
	
	////////////////////////////////////////////////////////////////////////////////
	ROLLINGBUFF_bayerRGB
	#(
	  .C_RAM_ADDR_BITS  (C_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_DATA_WIDTH   ),
	  .C_LINEBUFF_NUM   (C_LINEBUFF_NUM )
	)
	u_ROLLINGBUFF_bayerRGB
	(
	    // System Signal
	  .reset            (reset          ), 
	  .clk              (clk            ), 
	    // video input                  
	  .vs_in            (vs_in          ), 
	  .hs_in            (hs_in          ), 
	  .de_in            (de_in          ), 
	  .data_in          (data_in        ), 
	    // buff data out                
	  .vs_out           (vs_d0          ), 
	  .hs_out           (hs_d0          ), 
	  .de_out           (de_d0          ),
	  .X_div_out        (X_div_d0       ),
		.Y_div_out        (Y_div_d0       ),
		.buff0_data_out   (data0_d0       ),
		.buff1_data_out   (data1_d0       ),
		.buff2_data_out   (data2_d0       )
	);    
	
	/*
	gamma22_rom 
	#(
	  .C_RAM_ADDR_BITS (4'd10         ), 
	  .C_DATA_WIDTH    (C_DATA_WIDTH-2),
	  .init_file_name  ("E:/Xilinx/Project_Chirico_v1/design/config_sensor/sensor_signal_process/RTL/gamma22.coe") 
	)
	u_gamma22_rom_R
	(
	  .reset    (reset),
	  .clk      (clk  ),
	  .addr_a   (data_t2_d1[3*C_DATA_WIDTH-1:3*C_DATA_WIDTH-1-9]),//data_R[C_DATA_WIDTH-1:2]
	  .data_out (data_out[3*C_DATA_WIDTH-1:3*C_DATA_WIDTH-1-9])//data_t[35:26]
	);
	
	gamma22_rom 
	#(
	  .C_RAM_ADDR_BITS (4'd10         ), 
	  .C_DATA_WIDTH    (C_DATA_WIDTH-2),
	  .init_file_name  ("E:/Xilinx/Project_Chirico_v1/design/config_sensor/sensor_signal_process/RTL/gamma22.coe") 
	)
	u_gamma22_rom_G
	(
	  .reset    (reset),
	  .clk      (clk  ),
	  .addr_a   (data_t2_d1[3*C_DATA_WIDTH-1-12:3*C_DATA_WIDTH-1-12-9]),
	  .data_out (data_out[3*C_DATA_WIDTH-1-12:3*C_DATA_WIDTH-1-12-9])//data_t[23:14]
	);
	
	gamma22_rom 
	#(
	  .C_RAM_ADDR_BITS (4'd10         ), 
	  .C_DATA_WIDTH    (C_DATA_WIDTH-2),
	  .init_file_name  ("E:/Xilinx/Project_Chirico_v1/design/config_sensor/sensor_signal_process/RTL/gamma22.coe") 
	)
	u_gamma22_rom_B
	(
	  .reset    (reset),
	  .clk      (clk  ),
	  .addr_a   (data_t2_d1[3*C_DATA_WIDTH-1-24:3*C_DATA_WIDTH-1-24-9]),
	  .data_out (data_out[3*C_DATA_WIDTH-1-24:3*C_DATA_WIDTH-1-24-9])//data_t[11:2]
	);
	*/
    
endmodule
