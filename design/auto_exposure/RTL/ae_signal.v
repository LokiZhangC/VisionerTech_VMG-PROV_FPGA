
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : ae_signal.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : ae_signal
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
module ae_signal
#(
  parameter  C_DATA_WIDTH   = 8
)
(
  // system signal
  input   wire                    reset   ,
  input   wire                    pix_clk ,
  // data input
  input   wire                    vs_in   ,
  input   wire                    hs_in   ,
  input   wire                    de_in   ,
  input   wire [C_DATA_WIDTH-1:0] data_in , 
  // data output
  output  reg                     vs_out  ,
  output  reg                     hs_out  ,
  output  reg                     de_out  ,
  output  reg  [C_DATA_WIDTH-1:0] data_out
) ;
	
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg  [1:0]              vs_d; 
  reg  [1:0]              hs_d; 
  reg  [1:0]              de_d; 
  reg  [C_DATA_WIDTH-1:0] data_d1;
  reg  [C_DATA_WIDTH-1:0] data_t;
  reg  [C_DATA_WIDTH-1:0] data_t_d;
  
  wire                    vs_ps;
  reg                     vs_div;
  wire                    de_ns;
  reg                     de_div;
  reg                     line_div;
  

	// =============================================================================
	// RTL Body
	// =============================================================================
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d   <= {2{1'b1}}; 
  		hs_d   <= {2{1'b1}}; 
  		de_d   <= {2{1'b0}};
  		data_d1<= 0;
		end
		else
		begin
			vs_d   <= {vs_d[0],vs_in}; 
  		hs_d   <= {hs_d[0],hs_in}; 
  		de_d   <= {de_d[0],de_in};
  		data_d1<= data_in;
		end
	end
  
  assign de_ns = ~de_d[0] & de_d[1];
  assign vs_ps = vs_d[0] & ~vs_d[1];
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_div <= 1'b0; 
		end
		else if(vs_ps)
		begin
			vs_div <= ~vs_div;
		end
	end
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			de_div <= 1'b0; 
		end
		else if(de_in)
		begin
			de_div <= ~de_div;
		end
		else
		begin
			de_div <= 1'b0; 
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			line_div <= 1'b0; 
		end
		else if(de_ns)
		begin
			line_div <= ~line_div;
		end
		else if(vs_in)
		begin
			line_div <= 1'b0; 
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			data_t   <= 0;
			data_t_d <= 0;
		end
		else
		begin
			data_t_d <= data_t;
			case({line_div,de_div})
				2'b00: data_t <= data_in;
				2'b01: data_t <= data_d1;
				2'b10: data_t <= data_d1;
				2'b11: data_t <= data_in;
			endcase
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_out   <= 1'b1;
			hs_out   <= 1'b1;
			de_out   <= 1'b0;
			data_out <= 0;
		end
		else
		begin
			vs_out   <= vs_d[1];
			hs_out   <= hs_d[1];
			de_out   <= de_d[1];
			if(line_div)
			begin
				data_out <= data_t;
			end
			else
			begin
				data_out <= data_t_d;
			end			
		end
	end
	
endmodule
