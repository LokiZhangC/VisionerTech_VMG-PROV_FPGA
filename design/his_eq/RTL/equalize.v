
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : equalize.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : equalize
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : equalize,
//                 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================

module equalize //delay 1
#(
  parameter  C_DATA_WIDTH  = 32,
  parameter  C_VDATA_WIDTH = 8
)
(
  // system signal
  input  wire                    clk  , //
  input  wire                    reset, //
  //ram
  input  wire                    ram_wea  ,
  input  wire [C_VDATA_WIDTH-1:0]ram_addra,
  input  wire [C_DATA_WIDTH-1:0] ram_dina ,
  input  wire                    ram_rdb,
  input  wire [C_VDATA_WIDTH-1:0]ram_addrb,
	output wire [C_DATA_WIDTH-1:0] ram_doutb,
	//data input
  input  wire                    video_in_valid,
  input  wire [C_VDATA_WIDTH-1:0]video_in,
  //data output
  output reg                     video_out_valid, 
  output wire [C_DATA_WIDTH-1:0] video_out
);


	// =============================================================================
	// Internal signal
	// =============================================================================
	//
	wire [C_VDATA_WIDTH-1:0]ram_addrb_t;
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	assign ram_addrb_t = ram_rdb ? ram_addrb : video_in;
	
	equalize_ram
	u_equalize_ram
	(
	  .clka  (clk        ), // input clka
	  .wea   (ram_wea    ), // input [0 : 0] wea
	  .addra (ram_addra  ), // input [7 : 0] addra
	  .dina  (ram_dina   ), // input [31 : 0] dina
	  .clkb  (clk        ), // input clkb
	  .rstb  (reset      ),
	  .addrb (ram_addrb_t), // input [7 : 0] addrb
	  .doutb (ram_doutb  )  // output [31 : 0] doutb
	);
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			video_out_valid <= 1'b0;
		end
		else
		begin
			video_out_valid <= video_in_valid;
		end
	end
	
	assign video_out  = ram_doutb;//video_in;//
	
	
endmodule