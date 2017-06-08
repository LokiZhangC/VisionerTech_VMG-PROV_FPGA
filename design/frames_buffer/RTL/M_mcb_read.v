
`timescale 1 ns / 1 ps

module M_mcb_read
	#(
		// Users to add parameters here
		parameter  C_DATA_WIDTH          = 16,
		parameter  C_ADDR_WIDTH          = 30,
		// User parameters ends

		// MCB parameters
		parameter C_MCB_BURST_LEN	       = 64,
   	parameter Px_DATA_PORT_SIZE      = 32
	)
	(
		// Users to add ports here            
		input  wire                              reset        , 
		input  wire                              mcb_clk      , 
  	input  wire                              pix_clk      ,    
  	input  wire [31:0]                       image_high_width ,
  	input  wire [C_ADDR_WIDTH-1 : 0]         mcb_current_raddr,
  	input  wire                              mcb_current_raddr_valid,
  	input  wire                              mcb_read_en  ,
  	input  wire                              data_in_VS   , 
  	input  wire                              data_in_HS   , 
  	input  wire                              data_in_DE   , 
  	output reg                               data_out_VS  , 
  	output reg                               data_out_HS  , 
  	output reg                               data_out_DE  , 
  	output wire [C_DATA_WIDTH-1:0]           data_out     ,
		// User ports ends
		
		// MCB ports
		output wire 	                           px_cmd_clk,
		output wire 	                           px_cmd_en,
		output wire [2:0]	                       px_cmd_instr,
		output wire [5:0]	                       px_cmd_bl,
		output wire [C_ADDR_WIDTH-1:0]	         px_cmd_byte_addr,
		input	 wire                              px_cmd_empty,
		input	 wire                              px_cmd_full,
		output wire 	                           px_rd_clk,
		output wire  	                           px_rd_en,                    
		input  wire [Px_DATA_PORT_SIZE-1:0]		   px_rd_data,
		input	 wire                              px_rd_full,
		input	 wire                              px_rd_empty,
		input  wire [6:0]	                       px_rd_count,
		input	 wire                              px_rd_overflow,
		input	 wire                              px_rd_error
	);

	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2
	function integer clogb2;
	input integer value;
	begin 
		value = value-1;
		for (clogb2=0; value>0; clogb2=clogb2+1)
		value = value>>1;
	end 
	endfunction   
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	localparam  ADDR_LENGTH    = 8192;
	localparam  ADDR_HIGH      = 2048;
	localparam  C_DATA_WIDTH_I = Px_DATA_PORT_SIZE;
	localparam  BURST_LEN_HBIT = clogb2(C_MCB_BURST_LEN)+1;
	localparam  BURST_LEN_LBIT = Px_DATA_PORT_SIZE/C_DATA_WIDTH;

	// Add cmd signal here
	reg  [clogb2(ADDR_LENGTH)-1:0]  line_pix_cnt;
	reg  [clogb2(ADDR_LENGTH)-1:0]  line_pix_addr_cnt;
	reg  [clogb2(ADDR_HIGH)-1:0]    line_cnt;
	reg  [C_ADDR_WIDTH-1:0]         mcb_base_raddr;
	reg  [C_ADDR_WIDTH-1:0]	        cmd_byte_addr;
	reg  [5:0]	                    cmd_bl;
	
	reg                             mcb_burst_busy;
	
	wire [35:0]                     fifo_addr_din        ;
	reg                             fifo_addr_wr_en      ;
	wire                            fifo_addr_rd_en      ;
	wire [35:0]                     fifo_addr_dout       ;
	wire                            fifo_addr_full       ;
	wire                            fifo_addr_almost_full;
	wire                            fifo_addr_empty      ;
	
	// Add read data signal here
	wire [Px_DATA_PORT_SIZE-1:0]    fifo_din;
	wire                            fifo_wr_en;
	wire                            fifo_rd_en;
	wire [Px_DATA_PORT_SIZE-1:0]    fifo_dout;
	wire                            fifo_full;
	wire                            fifo_empty;
	wire                            fifo_valid;
	wire                            fifo_prog_full;
	wire                            fifo_prog_empty;
	                                
	// Add user signal here        
	reg                             VS_d;
	reg                             HS_d;
	reg                             DE_d;	                          
	wire                            vs_ns;
  wire                            vs_ps;
  wire                            de_ps;
  wire                            de_ns;     
	reg                             mcb_i_read_en;
	reg                             VS_in;
	reg                             HS_in;
	reg                             DE_in;
	reg                             VS_in_d;
	reg                             HS_in_d;
	reg                             DE_in_d;
	wire                            vs_in_ns;
  wire                            vs_in_ps;
  wire                            de_in_ps;
  wire                            de_in_ns; 		                          
	reg  [1:0]                      DE_in_div;
	reg  [C_DATA_WIDTH_I-1:0]       data_out_t;
	reg  [2:0]                      frame_end_reset_cnt;
  reg                             frame_end_reset;
  
  reg                             mcb_vs_d1;
	reg                             mcb_hs_d1;
	reg                             mcb_de_d1;
	reg                             mcb_vs_d2;
	reg                             mcb_hs_d2;
	reg                             mcb_de_d2;	   	   
  reg                             mcb_vs;
	reg                             mcb_hs;
	reg                             mcb_de;	   
	reg                             mcb_vs_d3;
	reg                             mcb_hs_d3;
	reg                             mcb_de_d3;
	
	wire                            mcb_vs_ns;
  wire                            mcb_vs_ps;
  wire                            mcb_de_ps;
  wire                            mcb_de_ns; 		 
	
	
	// =============================================================================
	// RTL logic
	// =============================================================================
	assign px_cmd_clk = mcb_clk;
	assign px_rd_clk  = mcb_clk;

	// =============================================================================
	// MCB cmd logic
	// =============================================================================
	assign px_cmd_en        = fifo_addr_rd_en;
	assign px_cmd_instr     = 3'b001;
	assign px_cmd_bl        = fifo_addr_dout[35:30];
	assign px_cmd_byte_addr = fifo_addr_dout[29:0];
	
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_base_raddr <= 30'b00000000;
		end
		else if(mcb_vs)
		begin
			mcb_base_raddr <= mcb_current_raddr;
		end
	end
	
	generate
		if (C_DATA_WIDTH == C_DATA_WIDTH_I) 
		begin : cmd_bl_sel
			always@(posedge mcb_clk or posedge reset)
			begin
				if(reset)
				begin
					line_pix_cnt <= 0;
					line_pix_addr_cnt<= 0;
					cmd_bl <= C_MCB_BURST_LEN-1;
				end
				else if(mcb_i_read_en)
				begin
					if(mcb_vs)
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
					else if((line_pix_cnt <= BURST_LEN_LBIT*C_MCB_BURST_LEN) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						cmd_bl <= line_pix_cnt[BURST_LEN_HBIT:BURST_LEN_LBIT-1]-1'b1;
					end
					else if((line_cnt != image_high_width[clogb2(ADDR_HIGH)-1+16:16]) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= line_pix_cnt - (BURST_LEN_LBIT*C_MCB_BURST_LEN);
						line_pix_addr_cnt<= line_pix_addr_cnt + (4*C_MCB_BURST_LEN);
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
				end
			end
		end
		else if(C_DATA_WIDTH == C_DATA_WIDTH_I/2)
		begin
			always@(posedge mcb_clk or posedge reset)
			begin
				if(reset)
				begin
					line_pix_cnt <= 0;
					line_pix_addr_cnt<= 0;
					cmd_bl <= C_MCB_BURST_LEN-1;
				end
				else if(mcb_i_read_en)
				begin
					if(mcb_vs)
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
					else if((line_pix_cnt <= BURST_LEN_LBIT*C_MCB_BURST_LEN) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						if(line_pix_cnt[0])
						begin
							cmd_bl <= line_pix_cnt[BURST_LEN_HBIT:BURST_LEN_LBIT-1];
						end
						else
						begin
							cmd_bl <= line_pix_cnt[BURST_LEN_HBIT:BURST_LEN_LBIT-1]-1'b1;
						end
					end
					else if((line_cnt != image_high_width[clogb2(ADDR_HIGH)-1+16:16]) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= line_pix_cnt - (BURST_LEN_LBIT*C_MCB_BURST_LEN);
						line_pix_addr_cnt<= line_pix_addr_cnt + (4*C_MCB_BURST_LEN);
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
				end
			end
		end
		else 
		begin
			always@(posedge mcb_clk or posedge reset)
			begin
				if(reset)
				begin
					line_pix_cnt <= 0;
					line_pix_addr_cnt<= 0;
					cmd_bl <= C_MCB_BURST_LEN-1;
				end
				else if(mcb_i_read_en)
				begin
					if(mcb_vs)
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
					else if((line_pix_cnt <= BURST_LEN_LBIT*C_MCB_BURST_LEN) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= image_high_width[clogb2(ADDR_LENGTH)-1:0];
						line_pix_addr_cnt<= 0;
						if(|line_pix_cnt[1:0])
						begin
							cmd_bl <= line_pix_cnt[BURST_LEN_HBIT:BURST_LEN_LBIT-2];
						end
						else
						begin
							cmd_bl <= line_pix_cnt[BURST_LEN_HBIT:BURST_LEN_LBIT-2]-1'b1;
						end
					end
					else if((line_cnt != image_high_width[clogb2(ADDR_HIGH)-1+16:16]) & (~fifo_addr_almost_full))
					begin
						line_pix_cnt <= line_pix_cnt - (BURST_LEN_LBIT*C_MCB_BURST_LEN);
						line_pix_addr_cnt<= line_pix_addr_cnt + (4*C_MCB_BURST_LEN);
						cmd_bl <= C_MCB_BURST_LEN-1;
					end
				end
			end
		end
	endgenerate
	
	
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)
		begin
			line_cnt <= 0;
		end
		else if(mcb_i_read_en)
		begin
			if(mcb_vs)
			begin
				line_cnt <= 0;
			end
			else if((~fifo_addr_almost_full) & line_pix_cnt <= BURST_LEN_LBIT*C_MCB_BURST_LEN & line_cnt != image_high_width[clogb2(ADDR_HIGH)-1+16:16])
			begin
				line_cnt <= line_cnt + 1'b1;
			end
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			cmd_byte_addr <= 30'b00000000;
		end
		else
		begin
			cmd_byte_addr <= {mcb_base_raddr[C_ADDR_WIDTH-1:24],line_cnt,line_pix_addr_cnt};
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)
		begin
			fifo_addr_wr_en <= 1'b0;
		end
		else if(mcb_i_read_en)
		begin
			if(mcb_vs)
			begin
				fifo_addr_wr_en <= 1'b0;
			end
			else if((line_cnt != image_high_width[clogb2(ADDR_HIGH)-1+16:16]) & (~fifo_addr_almost_full))
			begin
				fifo_addr_wr_en <= 1'b1;
			end
			else
			begin
				fifo_addr_wr_en <= 1'b0;
			end
		end
	end
	
	assign fifo_addr_din   = {cmd_bl,cmd_byte_addr};
	assign fifo_addr_rd_en = ~fifo_addr_empty & ~px_cmd_full & px_rd_empty & ~mcb_burst_busy;//(px_rd_count <= 7'd16);
	
	mcb_rd_addr_fifo_36x256 //FWFT
	u_mcb_rd_addr_fifo_36x256 
	(
  .clk        (mcb_clk              ), // input clk
  .rst        (reset                ), // input rst
  .din        (fifo_addr_din        ), // input [35 : 0] din
  .wr_en      (fifo_addr_wr_en      ), // input wr_en
  .rd_en      (fifo_addr_rd_en      ), // input rd_en
  .dout       (fifo_addr_dout       ), // output [35 : 0] dout
  .full       (fifo_addr_full       ), // output full
  .almost_full(fifo_addr_almost_full), // output almost_full
  .empty      (fifo_addr_empty      )  // output empty
	);
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_burst_busy <= 1'b0;
		end
		else if(fifo_addr_rd_en)
		begin
			mcb_burst_busy <= 1'b1;
		end
		else if(~px_rd_empty)
		begin
			mcb_burst_busy <= 1'b0;
		end
	end
	
	// =============================================================================
	// MCB read logic
	// =============================================================================
	
	mcb_rd_fifo_32x2048 
	u_mcb_rd_fifo_32x2048 
	(
  	.rst       (reset          ), // input rst | frame_end_reset
  	.wr_clk    (mcb_clk        ), // input wr_clk
  	.rd_clk    (pix_clk        ), // input rd_clk
  	.din       (fifo_din       ), // input [33 : 0] din
  	.wr_en     (fifo_wr_en     ), // input wr_en
  	.rd_en     (fifo_rd_en     ), // input rd_en
  	.dout      (fifo_dout      ), // output [33 : 0] dout
  	.full      (fifo_full      ), // output full
  	.empty     (fifo_empty     ), // output empty
  	.valid     (fifo_valid     ),
  	.prog_full (fifo_prog_full )  // output prog_full
	);
	
	/*
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			px_rd_en   <= 1'b0;
			fifo_wr_en <= 1'b0;
			//fifo_din   <= 0;
		end
		else
		begin
			px_rd_en   <= ~(fifo_prog_full | px_rd_empty);//fifo_wr_en;
			fifo_wr_en <= ~(fifo_prog_full | px_rd_empty);
			//fifo_din   <= px_rd_data;
		end
	end
	*/
	assign px_rd_en   = ~fifo_prog_full;//fifo_wr_en;1'b1;//
	assign fifo_wr_en = ~(fifo_prog_full | px_rd_empty);
	assign fifo_din   = px_rd_data;
	assign fifo_rd_en = ~fifo_empty & (DE_in & ~(|DE_in_div));
	                                                                                                   
	//===================================================================
	// Add user logic here
	//===================================================================
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			VS_d <= 1'b1;
			HS_d <= 1'b1;
			DE_d <= 1'b0;
		end
		else
		begin
			VS_d <= data_in_VS;
			HS_d <= data_in_HS;
			DE_d <= data_in_DE;
		end
	end
	
	assign vs_ns = ~data_in_VS & VS_d;
  assign vs_ps = data_in_VS & ~VS_d;
  assign de_ps = data_in_DE & ~DE_d;
  assign de_ns = ~data_in_DE & DE_d;
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			VS_in <= 1'b1;
			HS_in <= 1'b1;
			DE_in <= 1'b0;
		end
		else //if(mcb_i_read_en)
		begin
			VS_in <= VS_d;
			HS_in <= HS_d;
			DE_in <= DE_d;
		end
	end
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			VS_in_d     <= 1'b1;
			HS_in_d     <= 1'b1;
			DE_in_d     <= 1'b0;
			data_out_VS <= 1'b1;
			data_out_HS <= 1'b1;
			data_out_DE <= 1'b0;
		end
		else
		begin
			VS_in_d     <= VS_in;
			HS_in_d     <= HS_in;
			DE_in_d     <= DE_in;
			data_out_VS <= VS_in_d;
			data_out_HS <= HS_in_d;
			data_out_DE <= DE_in_d;
		end
	end
	
	assign vs_in_ns = ~VS_in & VS_in_d;
  assign vs_in_ps = VS_in & ~VS_in_d;
  assign de_in_ps = DE_in & ~DE_in_d;
  assign de_in_ns = ~DE_in & DE_in_d;
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			DE_in_div <= 0;
		end
		else if(DE_in_div == BURST_LEN_LBIT-1)
		begin
			DE_in_div <= 0;
		end
		else if(DE_in)
		begin
			DE_in_div <= DE_in_div + 1'b1;
		end
		else
		begin
			DE_in_div <= 0;
		end
	end
	
	generate
		if (C_DATA_WIDTH == C_DATA_WIDTH_I) 
		begin : data_out_shift
			always@(posedge pix_clk or posedge reset)
			begin
				if(reset)	
				begin
					data_out_t <= 0;
				end
				else if(fifo_valid)
				begin
					data_out_t <= fifo_dout[C_DATA_WIDTH_I-1:0];
				end
			end
		end
		else 
		begin
			always@(posedge pix_clk or posedge reset)
			begin
				if(reset)	
				begin
					data_out_t <= 0;
				end
				else if(fifo_valid)
				begin
					data_out_t <= fifo_dout[C_DATA_WIDTH_I-1:0];
				end
				else
				begin
					data_out_t <= {data_out_t[C_DATA_WIDTH_I-C_DATA_WIDTH-1:0],data_out_t[C_DATA_WIDTH_I-1:C_DATA_WIDTH_I-C_DATA_WIDTH]};
				end
			end
		end
	endgenerate
	
	assign data_out = data_out_t[C_DATA_WIDTH_I-1:C_DATA_WIDTH_I-C_DATA_WIDTH];
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_vs_d1 <= 1'b1;
			mcb_hs_d1 <= 1'b1;
			mcb_de_d1 <= 1'b0;
			mcb_vs_d2 <= 1'b1;
			mcb_hs_d2 <= 1'b1;
			mcb_de_d2 <= 1'b0;	 	   
  		mcb_vs    <= 1'b1;
			mcb_hs    <= 1'b1;
			mcb_de    <= 1'b0;	   
			mcb_vs_d3 <= 1'b1;
			mcb_hs_d3 <= 1'b1;
			mcb_de_d3 <= 1'b0;	 
		end
		else
		begin
			mcb_vs_d1 <= data_in_VS;
			mcb_hs_d1 <= data_in_HS;
			mcb_de_d1 <= data_in_DE;
			mcb_vs_d2 <= mcb_vs_d1;
			mcb_hs_d2 <= mcb_hs_d1;
			mcb_de_d2 <= mcb_de_d1;	 	   
  		mcb_vs    <= mcb_vs_d2;
			mcb_hs    <= mcb_hs_d2;
			mcb_de    <= mcb_de_d2;	  
			mcb_vs_d3 <= mcb_vs   ;
			mcb_hs_d3 <= mcb_hs   ;
			mcb_de_d3 <= mcb_de   ;	 	  
		end
	end
	
	assign mcb_vs_ns = ~mcb_vs & mcb_vs_d3;
	assign mcb_vs_ps = mcb_vs & ~mcb_vs_d3;
	assign mcb_de_ps = mcb_de & ~mcb_de_d3;
	assign mcb_de_ns = ~mcb_de & mcb_de_d3;

	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_i_read_en <= 1'b0;
		end
		else if(mcb_read_en & mcb_vs_ps)
		begin
			mcb_i_read_en <= 1'b1;
		end
		else if(~mcb_read_en & mcb_vs_ps)
		begin
			mcb_i_read_en <= 1'b0;
		end
	end
	
  
	//===================================================================
	// User logic ends
	//===================================================================

endmodule
