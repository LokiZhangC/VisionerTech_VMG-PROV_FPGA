`timescale 1ps / 1ps
//================================================================================ 
// File Name      : ROLLINGBUFF.v
//--------------------------------------------------------------------------------
// Create Date    : 06/05/2015 
// Project Name   : ROLLINGBUFF
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
module ROLLINGBUFF_bayerRGB
#(
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
    output wire                     vs_out   , // (o) Vertical Sync Pulse    
    output wire                     hs_out   , // (o) Horizontal Sync Pulse
    output wire                     de_out   , // (o) Pixel Data Video Enable  
    output reg                      X_div_out,
    output reg                      Y_div_out,
		output reg  [C_DATA_WIDTH-1:0]  buff0_data_out,
		output reg  [C_DATA_WIDTH-1:0]  buff1_data_out,
		output reg  [C_DATA_WIDTH-1:0]  buff2_data_out
);    

	function integer clog2;
	input integer value;
	begin 
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
		value = value>>1;
	end 
	endfunction
	
	localparam                 delay_cycles = 4 ;
	reg   [delay_cycles-1:0]   vs_d             ;
	reg   [delay_cycles-1:0]   hs_d             ;
	reg   [delay_cycles-1:0]   de_d             ;
	wire                       vs_ps            ;
	wire                       vs_ns            ;
	wire                       de_ps            ;
	wire                       de_ns            ;
	
	//reg                        first_de_ps_flag ;
	//
	//reg                        sync_delay_flag  ;
	//reg                        sync_delay_flag_d;
	//reg  [C_RAM_ADDR_BITS-1:0] sync_delay_cnt   ;
	//reg  [C_RAM_ADDR_BITS-1:0] sync_delay_cycles;
	
	reg  [C_RAM_ADDR_BITS-1:0] de_cnt           ;
	//reg  [C_RAM_ADDR_BITS-1:0] buff_used_deep   ;
	
	wire                       vs_t             ;
	wire                       hs_t             ;
	wire                       de_t             ;
	
	reg                        X_div_t          ;
	reg                        Y_div_t          ;
	
	assign vs_out   = vs_t;
	assign hs_out   = hs_t;
	assign de_out   = de_t;
	
	////////////////////////////////////////////////////////////////////////////////	
	//vs delay
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d <= {delay_cycles {1'b1}};
			hs_d <= {delay_cycles {1'b1}};
			de_d <= {delay_cycles {1'b0}};
		end
		else
		begin
			vs_d <= {vs_d[delay_cycles-2:0],vs_in};
			hs_d <= {hs_d[delay_cycles-2:0],hs_in};
			de_d <= {de_d[delay_cycles-2:0],de_in};
		end
	end
	
	//vs rising/falling pulse
	assign vs_ps = ~vs_d[0] & vs_in;
	assign vs_ns = vs_d[0] & ~vs_in;
	//assign hs_ps = ~hs_d & hs_in;
	//assign hs_ns = hs_d & ~hs_in;
	assign de_ps = ~de_d[0] & de_in;
	assign de_ns = de_d[0] & ~de_in;
	
	assign vs_t = vs_d[delay_cycles-1];
	assign hs_t = hs_d[delay_cycles-1];
	assign de_t = de_d[delay_cycles-1];
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			de_cnt <= 0;
		end
		else if(~de_in | vs_in)
		begin
			de_cnt <= 0;
		end
		else
		begin
			de_cnt <= de_cnt + 1'b1;
		end
	end
	
	////////////////////////////////////////////////////////////////////////////////
	//write buff
	reg  [C_DATA_WIDTH-1:0]          wbuff_data;
	reg  [clog2(C_LINEBUFF_NUM)-1:0] buff_y_waddr;
	reg  [C_RAM_ADDR_BITS-1:0]       buff_x_waddr;
	wire                             buff0_wen;
	wire                             buff1_wen;
	wire                             buff2_wen;
	reg                              init_flag;
	reg                              init_flag_d;
	reg  [C_RAM_ADDR_BITS-1:0]       init_buff_cnt;
	
	//init_buff_cnt
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			init_flag <= 0;
		end
		else if(init_buff_cnt == (2**C_RAM_ADDR_BITS)-1)
		begin
			init_flag <= 0;
		end
		else if(vs_ps)
		begin
			init_flag <= 1'b1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			init_buff_cnt <= 0;
		end
		else if(~init_flag)
		begin
			init_buff_cnt <= 0;
		end
		else
		begin
			init_buff_cnt <= init_buff_cnt + 1'b1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			init_flag_d <= 0;
		end
		else
		begin
			init_flag_d <= init_flag;
		end
	end
	
	//write data addr
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff_y_waddr <= 0;
		end
		else if((buff_y_waddr == (C_LINEBUFF_NUM-1) & de_ns) | (vs_in))
		begin
			buff_y_waddr <= 0;
		end
		else if(de_ns & ~vs_in)
		begin
			buff_y_waddr <= buff_y_waddr + 1'b1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			wbuff_data <= 0;
		end
		else if(~vs_in)
		begin
			wbuff_data <= data_in;
		end
		else
		begin
			wbuff_data <= 0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff_x_waddr <= 0;
		end
		else if(init_flag)
		begin
			buff_x_waddr <= init_buff_cnt;
		end
		else
		begin
			buff_x_waddr <= de_cnt;
		end
	end
	
	//assign buff_x_waddr = de_cnt;
	assign buff0_wen    = ((buff_y_waddr == 'd0) & de_d[0]);// | init_flag_d
	assign buff1_wen    = ((buff_y_waddr == 'd1) & de_d[0]);// | init_flag_d
	assign buff2_wen    = ((buff_y_waddr == 'd2) & de_d[0]);// | init_flag_d
	
	////////////////////////////////////////////////////////////////////////////////
	//read buff
	reg  [clog2(C_LINEBUFF_NUM)-1:0] buff_y_raddr_d1;
	reg  [clog2(C_LINEBUFF_NUM)-1:0] buff_y_raddr;
	reg  [C_RAM_ADDR_BITS-1:0]       buff_x_raddr;
	//reg                              buff0_ren;
	//reg                              buff1_ren;
	wire [C_DATA_WIDTH-1:0]          buff0_rdata;
	wire [C_DATA_WIDTH-1:0]          buff1_rdata;
	wire [C_DATA_WIDTH-1:0]          buff2_rdata;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff_x_raddr <= 0;
			buff_y_raddr_d1 <= 0;
			buff_y_raddr <= 0;
		end
		else
		begin
			buff_x_raddr <= buff_x_waddr;
			buff_y_raddr_d1 <= buff_y_waddr;
			buff_y_raddr <= buff_y_raddr_d1;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff0_data_out <= 0;
			buff1_data_out <= 0;
			buff2_data_out <= 0;
		end
		else
		begin
			case(buff_y_raddr)
				2'd0:
				begin
					buff0_data_out <= buff1_rdata;
					buff1_data_out <= buff2_rdata;
					buff2_data_out <= buff0_rdata;
				end
				
				2'd1:
				begin
					buff0_data_out <= buff2_rdata;
					buff1_data_out <= buff0_rdata;
					buff2_data_out <= buff1_rdata;
				end
				
				2'd2:
				begin
					buff0_data_out <= buff0_rdata;
					buff1_data_out <= buff1_rdata;
					buff2_data_out <= buff2_rdata;
				end
				
				default:
				begin
					buff0_data_out <= buff0_rdata;
					buff1_data_out <= buff1_rdata;
					buff2_data_out <= buff2_rdata;
				end
			endcase
			
			/*
			case(buff_y_raddr)
				1'b0:
				begin
					buff0_data_out <= buff1_rdata;
					buff1_data_out <= buff0_rdata;
				end
				1'b1:
				begin
					buff0_data_out <= buff0_rdata;
					buff1_data_out <= buff1_rdata;
				end
				default:
				begin
					buff0_data_out <= buff0_rdata;
					buff1_data_out <= buff1_rdata;
				end
			endcase
			*/
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			X_div_t   <= 1'b0;
			Y_div_t   <= 1'b0;
		end
		else
		begin
			X_div_t   <= buff_x_raddr[0];
			if(~de_d[delay_cycles-2] & de_d[delay_cycles-1])
			begin
				Y_div_t   <= ~Y_div_t;
			end
			else if(vs_d[delay_cycles-2])
			begin
				Y_div_t   <= 1'b0;
			end			
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			X_div_out <= 1'b0;
			Y_div_out <= 1'b0;
		end
		else
		begin
			X_div_out <= X_div_t        ;
			Y_div_out <= Y_div_t        ;
		end
	end
	
	
	////////////////////////////////////////////////////////////////////////////////
	//instantiation buff
	/*
	linebuff 
	#(
	  .C_RAM_ADDR_BITS  (C_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_DATA_WIDTH   )  
	)
	u_linebuff0
	(
	  .clk              (clk          ),
	  .w_en             (buff0_wen    ),
	  .addr_w           (buff_x_waddr ),
	  .addr_r           (buff_x_raddr ),
	  .data_in          (wbuff_data   ),
	  .data_out         (buff0_rdata  )	
	);
	*/
	double_port_ram_bayer2rgb 
	u0_double_port_ram_bayer2rgb 
	(
  	.clka (clk         ), // input clka
  	.wea  (buff0_wen   ), // input [0 : 0] wea
  	.addra(buff_x_waddr), // input [10 : 0] addra
  	.dina (wbuff_data  ), // input [11 : 0] dina
  	.clkb (clk         ), // input clkb
  	.addrb(buff_x_raddr), // input [10 : 0] addrb
  	.doutb(buff0_rdata ) // output [11 : 0] doutb
	);
	/*
	linebuff 
	#(
	  .C_RAM_ADDR_BITS  (C_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_DATA_WIDTH   )  
	)
	u_linebuff1
	(
	  .clk              (clk          ),
	  .w_en             (buff1_wen    ),
	  .addr_w           (buff_x_waddr ),
	  .addr_r           (buff_x_raddr ),
	  .data_in          (wbuff_data   ),
	  .data_out         (buff1_rdata  )	
	);
	*/
	double_port_ram_bayer2rgb 
	u1_double_port_ram_bayer2rgb 
	(
  	.clka (clk         ), // input clka
  	.wea  (buff1_wen   ), // input [0 : 0] wea
  	.addra(buff_x_waddr), // input [10 : 0] addra
  	.dina (wbuff_data  ), // input [11 : 0] dina
  	.clkb (clk         ), // input clkb
  	.addrb(buff_x_raddr), // input [10 : 0] addrb
  	.doutb(buff1_rdata ) // output [11 : 0] doutb
	);
	/*
	linebuff 
	#(
	  .C_RAM_ADDR_BITS  (C_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_DATA_WIDTH   )  
	)
	u_linebuff2
	(
	  .clk              (clk          ),
	  .w_en             (buff2_wen    ),
	  .addr_w           (buff_x_waddr ),
	  .addr_r           (buff_x_raddr ),
	  .data_in          (wbuff_data   ),
	  .data_out         (buff2_rdata  )	
	);
	*/
	double_port_ram_bayer2rgb 
	u2_double_port_ram_bayer2rgb 
	(
  	.clka (clk         ), // input clka
  	.wea  (buff2_wen   ), // input [0 : 0] wea
  	.addra(buff_x_waddr), // input [10 : 0] addra
  	.dina (wbuff_data  ), // input [11 : 0] dina
  	.clkb (clk         ), // input clkb
  	.addrb(buff_x_raddr), // input [10 : 0] addrb
  	.doutb(buff2_rdata ) // output [11 : 0] doutb
	);
	
	/////////////////////////////////////////////////////////////////////////////////////
	/*
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			first_de_ps_flag <= 1'b0;	
		end
		else if(vs_in)
		begin
			first_de_ps_flag <= 1'b0;	
		end
		else if(de_ps)
		begin
			first_de_ps_flag <= 1'b1;	
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff0_ren <= 1'b0;	
		end
		else
		begin
			buff0_ren <= (~buff_y_waddr) & de_d;	
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			buff1_ren <= 1'b0;	
		end
		else
		begin
			buff1_ren <= (buff_y_waddr) & de_d;	
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			sync_delay_flag <= 1'b0;	
		end
		else if(buff1_ren)
		begin
			sync_delay_flag <= 1'b0;	
		end
		else if(~first_de_ps_flag & de_ps)
		begin
			sync_delay_flag <= 1'b1;	
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			sync_delay_flag_d <= 1'b0;	
		end
		else
		begin
			sync_delay_flag_d <= sync_delay_flag;	
		end
	end
	
	assign sync_delay_flag_ns = ~sync_delay_flag & sync_delay_flag_d;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			sync_delay_cnt <= 'd0;
		end
		else if(sync_delay_flag)
		begin
			sync_delay_cnt <= sync_delay_cnt + 1'b1;
		end
		else
		begin
			sync_delay_cnt <= 'd0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			sync_delay_cycles <= 0;
		end
		else if(sync_delay_flag_ns)
		begin
			sync_delay_cycles <= sync_delay_cnt;
		end
	end
	
	
	SHIFT_X_TOP 
	#(
	  .C_RAM_ADDR_BITS (C_RAM_ADDR_BITS    ), 
	  .C_DATA_WIDTH    (10'd3              )  
	)
	u_SHIFT_X_TOP
	(
	  .reset           (reset              ),
	  .clk             (clk                ),
	  .delay           (sync_delay_cycles  ),
	  .data_in         ({vs_in,hs_in,de_in}),
	  .data_out        ({vs_t,hs_t,de_t}   )
	
	);	
	*/
    
endmodule
