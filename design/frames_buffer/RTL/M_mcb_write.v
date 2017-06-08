
`timescale 1 ns / 1 ps

module M_mcb_write 
	#(
		// Users to add parameters here
		parameter  C_DATA_WIDTH          = 16,
		parameter  C_ADDR_WIDTH          = 30,
		parameter  ADDR_NUM              = 8,
		// User parameters ends

		// MCB parameters
		parameter C_MCB_BURST_LEN	       = 32,
   	parameter Px_DATA_PORT_SIZE      = 32,
   	parameter Px_MASK_SIZE           = 4
	)
	(
		// Users to add ports here
		// data input                  
		input  wire                              reset                  , 
		input  wire                              mcb_clk                , 
  	input  wire                              pix_clk                ,        
  	input  wire                              data_in_VS             , 
  	input  wire                              data_in_HS             , 
  	input  wire                              data_in_DE             , 
  	input  wire [C_DATA_WIDTH-1:0]           data_in                ,
  	output wire [31:0]                       image_high_width       ,
  	output reg  [C_ADDR_WIDTH-1:0]           mcb_current_waddr      ,
  	output reg                               mcb_current_waddr_valid,
  	output wire                              mcb_read_en            ,
		// User ports ends
		
		// MCB ports
		output	wire 	                           px_cmd_clk      ,
		output	wire	                           px_cmd_en       ,
		output  wire [2:0]	                     px_cmd_instr    ,
		output  wire [5:0]	                     px_cmd_bl       ,
		output  wire [C_ADDR_WIDTH-1:0]	         px_cmd_byte_addr,
		input   wire		                         px_cmd_empty    ,
		input   wire		                         px_cmd_full     ,
		output	wire	                           px_wr_clk       ,
		output	wire	                           px_wr_en        ,
		output  wire [Px_MASK_SIZE-1:0]	         px_wr_mask      ,
		output  wire [Px_DATA_PORT_SIZE-1:0]	   px_wr_data      ,
		input   wire		                         px_wr_full      ,
		input   wire		                         px_wr_empty     ,
		input   wire [6:0]	                     px_wr_count     ,
		input   wire		                         px_wr_underrun  ,
		input   wire		                         px_wr_error
	);	 
	
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
	localparam  ADDR_LENGTH = 8192;
	localparam  ADDR_HIGH   = 2048;
	localparam  C_DATA_WIDTH_I = Px_DATA_PORT_SIZE;
	//localparam  Px_MASK_SIZE   = clogb2(Px_DATA_PORT_SIZE)-1;
	localparam  BURST_LEN_HBIT = clogb2(C_MCB_BURST_LEN);
	
	reg                              mcb_read_en_t;
	reg  [31:0]                      image_high_width_t;
	
	// Add cmd signal here
	reg  [clogb2(ADDR_LENGTH)-1:0]   line_pix_cnt;//13bits
	reg  [clogb2(ADDR_HIGH)-1:0]     line_cnt;    //11bits
	reg  [clogb2(ADDR_NUM)-1:0]      frame_cnt;   //3bits
	wire [C_ADDR_WIDTH-1:0]	         cmd_byte_addr;
	
	// Add user signal here
	wire                             fifo_rd_en;
	wire [C_DATA_WIDTH_I-1+4:0]      fifo_dout;
	wire                             fifo_full;
	wire                             fifo_empty;
	//wire                             fifo_valid;
	//wire                             fifo_prog_full;
	wire                             fifo_wr_en;
  wire [C_DATA_WIDTH_I-1+4:0]      fifo_din;
	reg  [1:0]                       DE_div      ;
	reg  [C_DATA_WIDTH_I-1:0]        shift_datain;
	reg	                             vs_d ; 
  reg	                             de_d ; 
  wire                             vs_ns;
  wire                             vs_ps;
  wire                             de_ps;
  wire                             de_ns;
  reg  [3:0]                       de_ps_d;
  reg  [15:0]                      image_high;
	reg  [15:0]                      image_width;
	reg                              mcb_current_waddr_valid_t;	
	wire                             mcb_vs_ns;
  wire                             mcb_vs_ps;
  wire                             mcb_de_ps;
  wire                             mcb_de_ns;
  wire                             mcb_data_valid;
  wire [C_DATA_WIDTH_I-1:0]        mcb_data;
	
	// =============================================================================
	// RTL logic
	// =============================================================================
	assign px_cmd_clk = mcb_clk;
	assign px_wr_clk  = mcb_clk;
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_current_waddr_valid_t <= 1'b0;
		end
		else if(mcb_vs_ps)
		begin
			mcb_current_waddr_valid_t <= 1'b1;
		end
		else
		begin
			mcb_current_waddr_valid_t <= 1'b0;
		end
	end
	
	//assign mcb_current_waddr_valid = mcb_current_waddr_valid_t;
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_current_waddr_valid <= 1'b0;
		end
		else
		begin
			mcb_current_waddr_valid <= mcb_current_waddr_valid_t;
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_current_waddr <= 30'h00000000;
		end
		else if(mcb_current_waddr_valid_t)
		begin
			mcb_current_waddr <= cmd_byte_addr;
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_read_en_t <= 1'b0;
		end
		else if(frame_cnt == 'd3 & mcb_vs_ps)
		begin
			mcb_read_en_t <= 1'b1;
		end
	end
	
	assign mcb_read_en = mcb_read_en_t;//~reset;//
	
	// =============================================================================
	// MCB cmd logic
	// =============================================================================
	assign px_cmd_en        = (&line_pix_cnt[BURST_LEN_HBIT-1:0] & mcb_data_valid) | mcb_de_ns;
	assign px_cmd_instr     = 3'b000;
	assign px_cmd_bl        = line_pix_cnt[BURST_LEN_HBIT-1:0];
	assign cmd_byte_addr    = {{(C_ADDR_WIDTH-clogb2(ADDR_LENGTH)-clogb2(ADDR_HIGH)-clogb2(ADDR_NUM)){1'b0}},
														 frame_cnt,line_cnt,line_pix_cnt[clogb2(ADDR_LENGTH)-1-2:BURST_LEN_HBIT],2'b00,{BURST_LEN_HBIT{1'b0}}};   
	assign px_cmd_byte_addr = cmd_byte_addr;   

	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			line_pix_cnt <= 0;
		end
		else if(mcb_de_ns | mcb_vs_ns | mcb_vs_ps)
		begin
			line_pix_cnt <= 0;
		end
		else if(mcb_data_valid)
		begin
			line_pix_cnt <= line_pix_cnt + 1'b1;
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			line_cnt <= 0;
		end
		else if(mcb_vs_ns | mcb_vs_ps)
		begin
			line_cnt <= 0;
		end
		else if(mcb_de_ns)
		begin
			line_cnt <= line_cnt + 1'b1;
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			frame_cnt <= 0;
		end
		else if(frame_cnt == (ADDR_NUM-1) & mcb_vs_ps)
		begin
			frame_cnt <= 0;
		end
		else if(mcb_vs_ps)
		begin
			frame_cnt <= frame_cnt + 1'b1;
		end
	end
	
	
	// =============================================================================
	// MCB write logic
	// =============================================================================
	assign px_wr_mask = {Px_MASK_SIZE{1'b0}};
	assign px_wr_en   = mcb_data_valid;
	assign px_wr_data = mcb_data;
	
	//===================================================================
	// Add user logic here
	//===================================================================
	//timing                 _______________________________________
	//de _________..._______|                                       |_____...________
	//                                                                        _
	//vs_ns_______...________________________________________________________| |_____
	//         _
	//vs_ps___| |________________________________________________________..._________
	//                       _
	//de_ps_________________| |__________________________________________..._________
	//                                                             _
	//de_ns_______________________________________________________| |____..._________
	
	//----------------------------
	//read/write fifo
	//----------------------------
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			DE_div <= 0;
		end
		else if(DE_div == ((C_DATA_WIDTH_I/C_DATA_WIDTH)-1))
		begin
			DE_div <= 0;
		end
		else if(data_in_DE)
		begin
			DE_div <= DE_div + 1'b1;
		end
		else
		begin
			DE_div <= 0;
		end
	end
	
	generate
		if (C_DATA_WIDTH == C_DATA_WIDTH_I) 
		begin : shift_data_sel
			always@(posedge pix_clk or posedge reset)
			begin
				if(reset)	
				begin
					shift_datain <= 0;
				end
				else if(data_in_DE)
				begin
					shift_datain <= data_in;
				end
			end
		end
		else 
		begin
			always@(posedge pix_clk or posedge reset)
			begin
				if(reset)	
				begin
					shift_datain <= 0;
				end
				else if(data_in_DE)
				begin
					shift_datain <= {shift_datain[((C_DATA_WIDTH_I/C_DATA_WIDTH)-1)*C_DATA_WIDTH-1:0],data_in};
				end
			end
		end
	endgenerate
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			vs_d <= 1'b1;
			de_d <= 1'b0;
		end
		else
		begin
			vs_d <= data_in_VS;
			de_d <= data_in_DE;
		end
	end
	
	assign vs_ns = ~data_in_VS & vs_d;
  assign vs_ps = data_in_VS & ~vs_d;
  assign de_ps = data_in_DE & ~de_d;
  assign de_ns = ~data_in_DE & de_d;
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			de_ps_d <= 0;
		end
		else
		begin
			de_ps_d <= {de_ps_d[2:0],de_ps};
		end
	end
  
  assign fifo_rd_en = ~(fifo_empty | px_cmd_full | px_wr_full);
  assign fifo_din   = {vs_ns,de_ps_d[(C_DATA_WIDTH_I/C_DATA_WIDTH)-1],de_ns,vs_ps,shift_datain};
  assign fifo_wr_en = ~fifo_full & ((de_d & ~(|DE_div)) | vs_ns | vs_ps | de_ns);// | de_ps_d[1]
	
	mcb_wr_fifo_36x2048 
	u_mcb_wr_fifo_36x2048 
	(
  	.rst      (reset         ), // input rst
  	.wr_clk   (pix_clk       ), // input wr_clk
  	.rd_clk   (mcb_clk       ), // input rd_clk
  	.din      (fifo_din      ), // input [35 : 0] din
  	.wr_en    (fifo_wr_en    ), // input wr_en
  	.rd_en    (fifo_rd_en    ), // input rd_en
  	.dout     (fifo_dout     ), // output [35 : 0] dout
  	.full     (fifo_full     ), // output full
  	.empty    (fifo_empty    )  // output empty
  	//.valid    (fifo_valid    )  // output valid
	);
	
	assign mcb_vs_ns      = fifo_rd_en & fifo_dout[C_DATA_WIDTH_I-1+4];     
	assign mcb_vs_ps      = fifo_rd_en & fifo_dout[C_DATA_WIDTH_I-1+1];     
	assign mcb_de_ps      = fifo_rd_en & fifo_dout[C_DATA_WIDTH_I-1+3];     
	assign mcb_de_ns      = fifo_rd_en & fifo_dout[C_DATA_WIDTH_I-1+2];     
	assign mcb_data_valid = fifo_rd_en & ~(fifo_dout[C_DATA_WIDTH_I-1+4] | fifo_dout[C_DATA_WIDTH_I-1+1]);
	assign mcb_data       = fifo_dout[C_DATA_WIDTH_I-1:0];
	
	//----------------------------
	//counter image high and width
	//----------------------------
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			image_width <= 'd0;
		end
		else if(de_ns)
		begin
			image_width <= 'd0;
		end
		else if(data_in_DE)
		begin
			image_width <= image_width + 1'b1;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			image_high_width_t[15:0] <= 16'd1280;
		end
		else if(de_ns)
		begin
			image_high_width_t[15:0] <= image_width;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			image_high <= 'd0;
		end
		else if(vs_ns)
		begin
			image_high <= 'd0;
		end
		else if(de_ns)
		begin
			image_high <= image_high + 1'b1;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			image_high_width_t[31:16] <= 16'd720;
		end
		else if(vs_ps)
		begin
			image_high_width_t[31:16] <= image_high;
		end
	end
	
	assign image_high_width = image_high_width_t;
	
	
	
	//===================================================================
	// User logic ends
	//===================================================================
	


endmodule	 