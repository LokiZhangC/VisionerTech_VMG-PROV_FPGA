
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : auto_exposure.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : auto_exposure
// Target Devices : XC7K325T-2FFG900
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : Fractal Memoryless Comparametric LUT
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================
module output_mux
#(
  parameter  C_DATA_WIDTH  = 20
)
(
  // system signal
  input   wire                    pix_clk , //
  input   wire                    reset   , //
  input   wire                    hdr_sel ,
  // data input
  input   wire                    hdr_vs_in   , 
  input   wire                    hdr_hs_in   , 
  input   wire                    hdr_de_in   , 
  input   wire [C_DATA_WIDTH-1:0] hdr_data_in ,
  
  input   wire                    nhdr_vs_in  , 
  input   wire                    nhdr_hs_in  , 
  input   wire                    nhdr_de_in  , 
  input   wire [C_DATA_WIDTH-1:0] nhdr_data_in,    
  // data output
  output  wire                    vs_o  , 
  output  wire                    hs_o  , 
  output  wire                    de_o  , 
  output  wire [C_DATA_WIDTH-1:0] data_o
) ;
	
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg [4:0]   state;
	localparam  IDLE           = 4'd0;
	localparam  HDR_MODE       = 4'd1;
	localparam  WAIT_HDR_END   = 4'd2;
	localparam  HDR_TO_NHDR    = 4'd3;
	localparam  NHDR_MODE      = 4'd4;
	localparam  WAIT_NHDR_END  = 4'd5;
	localparam  NHDR_TO_HDR    = 4'd6;
	localparam  WAIT_HDR_END_P = 4'd7;
	localparam  WAIT_NHDR_END_P= 4'd8;
	
	reg         hdr_vs_d;
	reg         hdr_hs_d;
	reg         hdr_de_d;
	
	reg         nhdr_vs_d;
	reg         nhdr_hs_d;
	reg         nhdr_de_d;
	
	wire        hdr_vs_ps;
	wire        hdr_vs_ns;
	
	wire        nhdr_vs_ps;
	wire        nhdr_vs_ns;
	
	reg  [2:0]  hdr_sel_d;
	
	wire        hdr_sel_ps;
	wire        hdr_sel_ns;
	
	reg                     vs_ot  ;
	reg                     hs_ot  ;
	reg                     de_ot  ;
	reg  [C_DATA_WIDTH-1:0] data_ot;


	// =============================================================================
	// RTL Body
	// =============================================================================
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			hdr_vs_d <= 1'b1;   
			hdr_hs_d <= 1'b1;   
			hdr_de_d <= 1'b0;
			
			nhdr_vs_d <= 1'b1;   
			nhdr_hs_d <= 1'b1;   
			nhdr_de_d <= 1'b0;
			
			hdr_sel_d <= {3{1'b1}};
		end
		else
		begin
			hdr_vs_d <= hdr_vs_in;   
			hdr_hs_d <= hdr_hs_in;   
			hdr_de_d <= hdr_de_in;
			
			nhdr_vs_d <= nhdr_vs_in;   
			nhdr_hs_d <= nhdr_hs_in;   
			nhdr_de_d <= nhdr_de_in;
			
			hdr_sel_d <= {hdr_sel_d[1:0],hdr_sel};
		end
	end
	
	assign hdr_vs_ps = ~hdr_vs_d & hdr_vs_in;
	assign hdr_vs_ns = hdr_vs_d & ~hdr_vs_in;
	
	assign nhdr_vs_ps = ~nhdr_vs_d & nhdr_vs_in;
	assign nhdr_vs_ns = nhdr_vs_d & ~nhdr_vs_in;
	
	assign hdr_sel_ps = ~hdr_sel_d[2] & hdr_sel_d[1];
	assign hdr_sel_ns = hdr_sel_d[2] & ~hdr_sel_d[1];
	
	//------------------------------------------------------------------------------
	//FSM
	//------------------------------------------------------------------------------
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			state <= IDLE;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(hdr_sel_d[1])
					begin
						state <= HDR_MODE;
					end
					else
					begin
						state <= NHDR_MODE;
					end
				end
				
				HDR_MODE:
				begin
					if(hdr_sel_ns)
					begin
						state <= WAIT_HDR_END;
					end
				end
				
				WAIT_HDR_END:
				begin
					if(hdr_sel_ps)
					begin
						state <= HDR_MODE;
					end
					else if(hdr_vs_ps)
					begin
						state <= HDR_TO_NHDR;
					end
				end
				
				HDR_TO_NHDR:
				begin
					if(hdr_sel_ps)
					begin
						state <= WAIT_HDR_END_P;
					end
					else if(nhdr_vs_ps)
					begin
						state <= NHDR_MODE;
					end
				end
				
				WAIT_HDR_END_P:
				begin
					if(hdr_sel_ns)
					begin
						state <= HDR_TO_NHDR;
					end
					else if(hdr_vs_ps)
					begin
						state <= HDR_MODE;
					end
				end
				
				NHDR_MODE:
				begin
					if(hdr_sel_ps)
					begin
						state <= WAIT_NHDR_END;
					end
				end
				
				WAIT_NHDR_END:
				begin
					if(hdr_sel_ns)
					begin
						state <= NHDR_MODE;
					end
					else if(nhdr_vs_ps)
					begin
						state <= NHDR_TO_HDR;
					end
				end
				
				NHDR_TO_HDR:
				begin
					if(hdr_sel_ns)
					begin
						state <= WAIT_NHDR_END_P;
					end
					else if(hdr_vs_ps)
					begin
						state <= HDR_MODE;
					end
				end
				
				WAIT_NHDR_END_P:
				begin
					if(hdr_sel_ps)
					begin
						state <= NHDR_TO_HDR;
					end
					else if(nhdr_vs_ps)
					begin
						state <= NHDR_MODE;
					end
				end
				
				default:
				begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			vs_ot   <= 1'b1;
			hs_ot   <= 1'b1;
			de_ot   <= 1'b0;
			data_ot <= 0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(hdr_sel_d[1])
					begin
						vs_ot   <= hdr_vs_in  ;
						hs_ot   <= hdr_hs_in  ;
						de_ot   <= hdr_de_in  ;
						data_ot <= hdr_data_in;
					end
					else
					begin
						vs_ot   <= nhdr_vs_in  ;
						hs_ot   <= nhdr_hs_in  ;
						de_ot   <= nhdr_de_in  ;
						data_ot <= nhdr_data_in;
					end
				end
				
				HDR_MODE:
				begin
					vs_ot   <= hdr_vs_in  ;
					hs_ot   <= hdr_hs_in  ;
					de_ot   <= hdr_de_in  ;
					data_ot <= hdr_data_in;
				end
				
				WAIT_HDR_END:
				begin
					vs_ot   <= hdr_vs_in  ;
					hs_ot   <= hdr_hs_in  ;
					de_ot   <= hdr_de_in  ;
					data_ot <= hdr_data_in;
				end
				
				HDR_TO_NHDR:
				begin
					vs_ot   <= 1'b1;
					hs_ot   <= 1'b1;
					de_ot   <= 1'b0;
					data_ot <= 0;
				end
				
				WAIT_HDR_END_P:
				begin
					vs_ot   <= 1'b1;
					hs_ot   <= 1'b1;
					de_ot   <= 1'b0;
					data_ot <= 0;
				end
				
				NHDR_MODE:
				begin
					vs_ot   <= nhdr_vs_in  ;
					hs_ot   <= nhdr_hs_in  ;
					de_ot   <= nhdr_de_in  ;
					data_ot <= nhdr_data_in;
				end
				
				WAIT_NHDR_END:
				begin
					vs_ot   <= nhdr_vs_in  ;
					hs_ot   <= nhdr_hs_in  ;
					de_ot   <= nhdr_de_in  ;
					data_ot <= nhdr_data_in;
				end
				
				NHDR_TO_HDR:
				begin
					vs_ot   <= 1'b1;
					hs_ot   <= 1'b1;
					de_ot   <= 1'b0;
					data_ot <= 0;
				end
				
				WAIT_NHDR_END_P:
				begin
					vs_ot   <= 1'b1;
					hs_ot   <= 1'b1;
					de_ot   <= 1'b0;
					data_ot <= 0;
				end
				
			endcase
		end
	end                
	
	assign vs_o   = vs_ot  ;
	assign hs_o   = hs_ot  ;
	assign de_o   = de_ot  ;
	assign data_o = data_ot;
  
	
endmodule
