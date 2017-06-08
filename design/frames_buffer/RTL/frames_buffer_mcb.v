`timescale 1ps / 1ps
//================================================================================ 
// File Name      : BMD_detect.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : BMD_detect
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
module frames_buffer_mcb
#(
  // Users to add parameters here
		parameter  C_DATA_WIDTH          = 16,
		parameter  C_ADDR_WIDTH          = 30,
		parameter  ADDR_NUM              = 6,
		// User parameters ends

		// MCB parameters
		parameter C_MCB_W_BURST_LEN      = 64,
		parameter C_MCB_R_BURST_LEN      = 64,
		parameter Px_MASK_SIZE           = 4,
   	parameter Px_DATA_PORT_SIZE      = 32
)
(
  // system signal
  input  wire                          reset       , 
  input  wire                          mcb_clk     ,  
  // data input                               
  input  wire                          pix_clk_wr  ,
  input  wire                          data_in_VS  , 
  input  wire                          data_in_HS  , 
  input  wire                          data_in_DE  , 
  input  wire [C_DATA_WIDTH-1:0]       data_in     ,  
  // data output                       
  input  wire [4:0]                    rd_port_en  ,
  input  wire                          pix_clk_rd  ,
  input  wire                          rd_VS_in    , 
  input  wire                          rd_HS_in    , 
  input  wire                          rd_DE_in    , 
  output wire                          data_out_VS , 
  output wire                          data_out_HS , 
  output wire                          data_out_DE , 
  output wire [C_DATA_WIDTH-1:0]       data_out_1  ,
  output wire [C_DATA_WIDTH-1:0]       data_out_2  ,
  output wire [C_DATA_WIDTH-1:0]       data_out_3  ,
  output wire [C_DATA_WIDTH-1:0]       data_out_4  ,
  output wire [C_DATA_WIDTH-1:0]       data_out_5  ,
  
  // MCB ports
	output	wire 	                       p0_cmd_clk      ,
	output	wire	                       p0_cmd_en       ,
	output  wire [2:0]	                 p0_cmd_instr    ,
	output  wire [5:0]	                 p0_cmd_bl       ,
	output  wire [C_ADDR_WIDTH-1:0]	     p0_cmd_byte_addr,
	input   wire		                     p0_cmd_empty    ,
	input   wire		                     p0_cmd_full     ,
	output	wire	                       p0_wr_clk       ,
	output	wire	                       p0_wr_en        ,
	output  wire [Px_MASK_SIZE-1:0]	     p0_wr_mask      ,
	output  wire [Px_DATA_PORT_SIZE-1:0] p0_wr_data      ,
	input   wire		                     p0_wr_full      ,
	input   wire		                     p0_wr_empty     ,
	input   wire [6:0]	                 p0_wr_count     ,
	input   wire		                     p0_wr_underrun  ,
	input   wire		                     p0_wr_error     ,
	                                     
	output wire 	                       p1_cmd_clk      ,
	output wire 	                       p1_cmd_en       ,
	output wire [2:0]	                   p1_cmd_instr    ,
	output wire [5:0]	                   p1_cmd_bl       ,
	output wire [C_ADDR_WIDTH-1:0]	     p1_cmd_byte_addr,
	input	 wire                          p1_cmd_empty    ,
	input	 wire                          p1_cmd_full     ,
	output wire 	                       p1_rd_clk       ,
	output wire 	                       p1_rd_en        ,                    
	input  wire [Px_DATA_PORT_SIZE-1:0]	 p1_rd_data      ,
	input	 wire                          p1_rd_full      ,
	input	 wire                          p1_rd_empty     ,
	input  wire [6:0]	                   p1_rd_count     ,
	input	 wire                          p1_rd_overflow  ,
	input	 wire                          p1_rd_error     ,
	                                     
	output wire 	                       p2_cmd_clk      ,
	output wire 	                       p2_cmd_en       ,
	output wire [2:0]	                   p2_cmd_instr    ,
	output wire [5:0]	                   p2_cmd_bl       ,
	output wire [C_ADDR_WIDTH-1:0]	     p2_cmd_byte_addr,
	input	 wire                          p2_cmd_empty    ,
	input	 wire                          p2_cmd_full     ,
	output wire 	                       p2_rd_clk       ,
	output wire 	                       p2_rd_en        ,                    
	input  wire [Px_DATA_PORT_SIZE-1:0]	 p2_rd_data      ,
	input	 wire                          p2_rd_full      ,
	input	 wire                          p2_rd_empty     ,
	input  wire [6:0]	                   p2_rd_count     ,
	input	 wire                          p2_rd_overflow  ,
	input	 wire                          p2_rd_error     ,
	                                     
	output wire 	                       p3_cmd_clk      ,
	output wire 	                       p3_cmd_en       ,
	output wire [2:0]	                   p3_cmd_instr    ,
	output wire [5:0]	                   p3_cmd_bl       ,
	output wire [C_ADDR_WIDTH-1:0]	     p3_cmd_byte_addr,
	input	 wire                          p3_cmd_empty    ,
	input	 wire                          p3_cmd_full     ,
	output wire 	                       p3_rd_clk       ,
	output wire 	                       p3_rd_en        ,                    
	input  wire [Px_DATA_PORT_SIZE-1:0]	 p3_rd_data      ,
	input	 wire                          p3_rd_full      ,
	input	 wire                          p3_rd_empty     ,
	input  wire [6:0]	                   p3_rd_count     ,
	input	 wire                          p3_rd_overflow  ,
	input	 wire                          p3_rd_error     ,
	
	output wire 	                       p4_cmd_clk      ,
	output wire 	                       p4_cmd_en       ,
	output wire [2:0]	                   p4_cmd_instr    ,
	output wire [5:0]	                   p4_cmd_bl       ,
	output wire [C_ADDR_WIDTH-1:0]	     p4_cmd_byte_addr,
	input	 wire                          p4_cmd_empty    ,
	input	 wire                          p4_cmd_full     ,
	output wire 	                       p4_rd_clk       ,
	output wire 	                       p4_rd_en        ,                    
	input  wire [Px_DATA_PORT_SIZE-1:0]	 p4_rd_data      ,
	input	 wire                          p4_rd_full      ,
	input	 wire                          p4_rd_empty     ,
	input  wire [6:0]	                   p4_rd_count     ,
	input	 wire                          p4_rd_overflow  ,
	input	 wire                          p4_rd_error     ,
	
	output wire 	                       p5_cmd_clk      ,
	output wire 	                       p5_cmd_en       ,
	output wire [2:0]	                   p5_cmd_instr    ,
	output wire [5:0]	                   p5_cmd_bl       ,
	output wire [C_ADDR_WIDTH-1:0]	     p5_cmd_byte_addr,
	input	 wire                          p5_cmd_empty    ,
	input	 wire                          p5_cmd_full     ,
	output wire 	                       p5_rd_clk       ,
	output wire 	                       p5_rd_en        ,                    
	input  wire [Px_DATA_PORT_SIZE-1:0]	 p5_rd_data      ,
	input	 wire                          p5_rd_full      ,
	input	 wire                          p5_rd_empty     ,
	input  wire [6:0]	                   p5_rd_count     ,
	input	 wire                          p5_rd_overflow  ,
	input	 wire                          p5_rd_error     
  
) ;

	// =============================================================================
	// Internal signal
	// =============================================================================
	
	wire [31:0]                  image_high_width       ;
  wire [C_ADDR_WIDTH-1 : 0]    mcb_current_waddr      ;
  wire                         mcb_current_waddr_valid;
  wire                         mcb_read_en_t          ;
  wire                         mcb_read_en1           ;
  wire                         mcb_read_en2           ;
  wire                         mcb_read_en3           ;
  wire                         mcb_read_en4           ;
  wire                         mcb_read_en5           ;
  
  reg                          mcb_raddr_valid;
  reg  [C_ADDR_WIDTH-1 : 0]    mcb_raddr1;
  reg  [C_ADDR_WIDTH-1 : 0]    mcb_raddr2;
  reg  [C_ADDR_WIDTH-1 : 0]    mcb_raddr3;
  reg  [C_ADDR_WIDTH-1 : 0]    mcb_raddr4;
  reg  [C_ADDR_WIDTH-1 : 0]    mcb_raddr5;
  reg                          mcb_rd_VS;
	reg                          mcb_rd_HS;
	reg                          mcb_rd_DE;   


	// =============================================================================
	// RTL Body
	// =============================================================================
	M_mcb_write 
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		.ADDR_NUM              (ADDR_NUM         ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN       (C_MCB_W_BURST_LEN),
		.Px_MASK_SIZE          (Px_MASK_SIZE     ),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u_M_mcb_write
	(
		// Users to add ports here
		// data input                  
		.reset                  (reset                  ), 
		.mcb_clk                (mcb_clk                ), 
  	.pix_clk                (pix_clk_wr             ),        
  	.data_in_VS             (data_in_VS             ), 
  	.data_in_HS             (data_in_HS             ), 
  	.data_in_DE             (data_in_DE             ), 
  	.data_in                (data_in                ),
  	.image_high_width       (       ),//image_high_width
  	.mcb_current_waddr      (mcb_current_waddr      ),
  	.mcb_current_waddr_valid(mcb_current_waddr_valid),
  	.mcb_read_en            (mcb_read_en_t          ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p0_cmd_clk      ),
		.px_cmd_en              (p0_cmd_en       ),
		.px_cmd_instr           (p0_cmd_instr    ),
		.px_cmd_bl              (p0_cmd_bl       ),
		.px_cmd_byte_addr       (p0_cmd_byte_addr),
		.px_cmd_empty           (p0_cmd_empty    ),
		.px_cmd_full            (p0_cmd_full     ),
		.px_wr_clk              (p0_wr_clk       ),
		.px_wr_en               (p0_wr_en        ),
		.px_wr_mask             (p0_wr_mask      ),
		.px_wr_data             (p0_wr_data      ),
		.px_wr_full             (p0_wr_full      ),
		.px_wr_empty            (p0_wr_empty     ),
		.px_wr_count            (p0_wr_count     ),
		.px_wr_underrun         (p0_wr_underrun  ),
		.px_wr_error            (p0_wr_error     )
	);	 
	
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)
		begin
			mcb_raddr_valid <= 0;
		end
		else
		begin
			mcb_raddr_valid <= mcb_current_waddr_valid;
		end
	end
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			mcb_raddr1 <= 30'h00000000;//C_M_TARGET_SLAVE_BASE_ADDR;
			mcb_raddr2 <= 30'h01000000;//C_M_TARGET_SLAVE_BASE_ADDR;
			mcb_raddr3 <= 30'h02000000;//C_M_TARGET_SLAVE_BASE_ADDR;
			mcb_raddr4 <= 30'h03000000;//C_M_TARGET_SLAVE_BASE_ADDR;
			mcb_raddr5 <= 30'h04000000;//C_M_TARGET_SLAVE_BASE_ADDR;
		end
		else if(mcb_current_waddr_valid)
		begin
			case(mcb_current_waddr)
				30'h00000000:
				begin
					mcb_raddr1 <= 30'h02000000;//30'h05000000;//
					mcb_raddr2 <= 30'h03000000;//30'h00000000;//
					mcb_raddr3 <= 30'h04000000;//30'h01000000;//
					mcb_raddr4 <= 30'h05000000;//30'h00000000;//
					mcb_raddr5 <= 30'h00000000;//30'h01000000;//
				end                          //               
				                             //               
				30'h01000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h03000000;//30'h05000000;//
					mcb_raddr2 <= 30'h04000000;//30'h00000000;//
					mcb_raddr3 <= 30'h05000000;//30'h01000000;//
					mcb_raddr4 <= 30'h00000000;//30'h00000000;//
					mcb_raddr5 <= 30'h01000000;//30'h01000000;//
				end                          //               
				                             //               
				30'h02000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h04000000;//30'h05000000;//
					mcb_raddr2 <= 30'h05000000;//30'h00000000;//
					mcb_raddr3 <= 30'h00000000;//30'h01000000;//
					mcb_raddr4 <= 30'h01000000;//30'h00000000;//
					mcb_raddr5 <= 30'h02000000;//30'h01000000;//
				end                          //               
				                             //               
				30'h03000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h05000000;//30'h05000000;//
					mcb_raddr2 <= 30'h00000000;//30'h00000000;//
					mcb_raddr3 <= 30'h01000000;//30'h01000000;//
					mcb_raddr4 <= 30'h02000000;//30'h00000000;//
					mcb_raddr5 <= 30'h03000000;//30'h01000000;//
				end                          //               
				                             //               
				30'h04000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h00000000;//30'h05000000;//
					mcb_raddr2 <= 30'h01000000;//30'h00000000;//
					mcb_raddr3 <= 30'h02000000;//30'h01000000;//
					mcb_raddr4 <= 30'h03000000;//30'h00000000;//
					mcb_raddr5 <= 30'h04000000;//30'h01000000;//
				end                          //               
				                             //               
				30'h05000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h01000000;//30'h05000000;//
					mcb_raddr2 <= 30'h02000000;//30'h00000000;//
					mcb_raddr3 <= 30'h03000000;//30'h01000000;//
					mcb_raddr4 <= 30'h04000000;//30'h00000000;//
					mcb_raddr5 <= 30'h05000000;//30'h01000000;//
				end
				
				30'h06000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h02000000;//30'h05000000;//
					mcb_raddr2 <= 30'h03000000;//30'h00000000;//
					mcb_raddr3 <= 30'h04000000;//30'h01000000;//
					mcb_raddr4 <= 30'h05000000;//30'h00000000;//
					mcb_raddr5 <= 30'h00000000;//30'h01000000;//
				end
				
				30'h07000000:                //               
				begin                        //               
					mcb_raddr1 <= 30'h03000000;//30'h05000000;//
					mcb_raddr2 <= 30'h04000000;//30'h00000000;//
					mcb_raddr3 <= 30'h05000000;//30'h01000000;//
					mcb_raddr4 <= 30'h00000000;//30'h00000000;//
					mcb_raddr5 <= 30'h01000000;//30'h01000000;//
				end
				
				default:
				begin
					
				end
			endcase
		end
	end
	     
	always@(posedge pix_clk_rd or posedge reset)
	begin
		if(reset)
		begin
			mcb_rd_VS <= 1'b1;
			mcb_rd_HS <= 1'b1;
			mcb_rd_DE <= 1'b0;
		end
		else
		begin
			mcb_rd_VS <= rd_VS_in;
			mcb_rd_HS <= rd_HS_in;
			mcb_rd_DE <= rd_DE_in;
		end
	end
	
	assign mcb_read_en1 = mcb_read_en_t & rd_port_en[0];
	assign mcb_read_en2 = mcb_read_en_t & rd_port_en[1];
	assign mcb_read_en3 = mcb_read_en_t & rd_port_en[2];
	assign mcb_read_en4 = mcb_read_en_t & rd_port_en[3];
	assign mcb_read_en5 = mcb_read_en_t & rd_port_en[4];
	
	//----------------------------
	//counter image high and width
	//----------------------------
	reg  [15:0]                      image_high;
	reg  [15:0]                      image_width;
	reg  [31:0]                      image_high_width_t;
	wire                             vs_ns;
  wire                             vs_ps;
  wire                             de_ps;
  wire                             de_ns;
  
  assign vs_ps = rd_VS_in & ~mcb_rd_VS;
  assign vs_ns = ~rd_VS_in & mcb_rd_VS;
  assign de_ps = rd_DE_in & ~mcb_rd_DE;
  assign de_ns = ~rd_DE_in & mcb_rd_DE;
	
	always@(posedge pix_clk_rd or posedge reset)
	begin
		if(reset)	
		begin
			image_width <= 'd0;
		end
		else if(de_ns)
		begin
			image_width <= 'd0;
		end
		else if(rd_DE_in)
		begin
			image_width <= image_width + 1'b1;
		end
	end
	
	always@(posedge pix_clk_rd or posedge reset)
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
	
	always@(posedge pix_clk_rd or posedge reset)
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
	
	always@(posedge pix_clk_rd or posedge reset)
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
	
	/*
	SHIFT_X_TOP 
	#(
	  .C_RAM_ADDR_BITS (4'd10), 
	  .C_DATA_WIDTH    (10'd4) 
	)
	u_SHIFT_X_TOP
	(
	  .reset           (reset      ),
	  .clk             (pix_clk    ),
	  .delay           (10'd825    ),//delay_cnt
	  .data_in         ({data_in_VS,data_in_HS,data_in_DE,mcb_read_en_t}),//
	  .data_out        ({mcb_rd_VS,mcb_rd_HS,mcb_rd_DE,mcb_read_en})//
	);	
	*/
	
	M_mcb_read
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN	     (C_MCB_R_BURST_LEN),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u1_M_mcb_read
	(
		// Users to add ports here            
		.reset                  (reset           ), 
		.mcb_clk                (mcb_clk         ), 
  	.pix_clk                (pix_clk_rd      ),    
  	.image_high_width       (image_high_width),
  	.mcb_current_raddr      (mcb_raddr1      ),
  	.mcb_current_raddr_valid(mcb_raddr_valid ),
  	.mcb_read_en            (mcb_read_en1    ),
  	.data_in_VS             (mcb_rd_VS       ), 
  	.data_in_HS             (mcb_rd_HS       ), 
  	.data_in_DE             (mcb_rd_DE       ), 
  	.data_out_VS            (data_out_VS     ), 
  	.data_out_HS            (data_out_HS     ), 
  	.data_out_DE            (data_out_DE     ), 
  	.data_out               (data_out_1      ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p1_cmd_clk      ),
		.px_cmd_en              (p1_cmd_en       ),
		.px_cmd_instr           (p1_cmd_instr    ),
		.px_cmd_bl              (p1_cmd_bl       ),
		.px_cmd_byte_addr       (p1_cmd_byte_addr),
		.px_cmd_empty           (p1_cmd_empty    ),
		.px_cmd_full            (p1_cmd_full     ),
		.px_rd_clk              (p1_rd_clk       ),
		.px_rd_en               (p1_rd_en        ),                    
		.px_rd_data             (p1_rd_data      ),
		.px_rd_full             (p1_rd_full      ),
		.px_rd_empty            (p1_rd_empty     ),
		.px_rd_count            (p1_rd_count     ),
		.px_rd_overflow         (p1_rd_overflow  ),
		.px_rd_error            (p1_rd_error     )
	);
	
	M_mcb_read
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN	     (C_MCB_R_BURST_LEN),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u2_M_mcb_read
	(
		// Users to add ports here            
		.reset                  (reset           ), 
		.mcb_clk                (mcb_clk         ), 
  	.pix_clk                (pix_clk_rd      ),    
  	.image_high_width       (image_high_width),
  	.mcb_current_raddr      (mcb_raddr2      ),
  	.mcb_current_raddr_valid(mcb_raddr_valid ),
  	.mcb_read_en            (mcb_read_en2    ),
  	.data_in_VS             (mcb_rd_VS       ), 
  	.data_in_HS             (mcb_rd_HS       ), 
  	.data_in_DE             (mcb_rd_DE       ), 
  	.data_out_VS            (     ), 
  	.data_out_HS            (     ), 
  	.data_out_DE            (     ), 
  	.data_out               (data_out_2      ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p2_cmd_clk      ),
		.px_cmd_en              (p2_cmd_en       ),
		.px_cmd_instr           (p2_cmd_instr    ),
		.px_cmd_bl              (p2_cmd_bl       ),
		.px_cmd_byte_addr       (p2_cmd_byte_addr),
		.px_cmd_empty           (p2_cmd_empty    ),
		.px_cmd_full            (p2_cmd_full     ),
		.px_rd_clk              (p2_rd_clk       ),
		.px_rd_en               (p2_rd_en        ),                    
		.px_rd_data             (p2_rd_data      ),
		.px_rd_full             (p2_rd_full      ),
		.px_rd_empty            (p2_rd_empty     ),
		.px_rd_count            (p2_rd_count     ),
		.px_rd_overflow         (p2_rd_overflow  ),
		.px_rd_error            (p2_rd_error     )
	);
	
	M_mcb_read
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN	     (C_MCB_R_BURST_LEN),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u3_M_mcb_read
	(
		// Users to add ports here            
		.reset                  (reset           ), 
		.mcb_clk                (mcb_clk         ), 
  	.pix_clk                (pix_clk_rd      ),    
  	.image_high_width       (image_high_width),
  	.mcb_current_raddr      (mcb_raddr3      ),
  	.mcb_current_raddr_valid(mcb_raddr_valid ),
  	.mcb_read_en            (mcb_read_en3    ),
  	.data_in_VS             (mcb_rd_VS       ), 
  	.data_in_HS             (mcb_rd_HS       ), 
  	.data_in_DE             (mcb_rd_DE       ), 
  	.data_out_VS            (     ), 
  	.data_out_HS            (     ), 
  	.data_out_DE            (     ), 
  	.data_out               (data_out_3      ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p3_cmd_clk      ),
		.px_cmd_en              (p3_cmd_en       ),
		.px_cmd_instr           (p3_cmd_instr    ),
		.px_cmd_bl              (p3_cmd_bl       ),
		.px_cmd_byte_addr       (p3_cmd_byte_addr),
		.px_cmd_empty           (p3_cmd_empty    ),
		.px_cmd_full            (p3_cmd_full     ),
		.px_rd_clk              (p3_rd_clk       ),
		.px_rd_en               (p3_rd_en        ),                    
		.px_rd_data             (p3_rd_data      ),
		.px_rd_full             (p3_rd_full      ),
		.px_rd_empty            (p3_rd_empty     ),
		.px_rd_count            (p3_rd_count     ),
		.px_rd_overflow         (p3_rd_overflow  ),
		.px_rd_error            (p3_rd_error     )
	);
	
	M_mcb_read
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN	     (C_MCB_R_BURST_LEN),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u4_M_mcb_read
	(
		// Users to add ports here            
		.reset                  (reset           ), 
		.mcb_clk                (mcb_clk         ), 
  	.pix_clk                (pix_clk_rd      ),    
  	.image_high_width       (image_high_width),
  	.mcb_current_raddr      (mcb_raddr4      ),
  	.mcb_current_raddr_valid(mcb_raddr_valid ),
  	.mcb_read_en            (mcb_read_en4    ),
  	.data_in_VS             (mcb_rd_VS       ), 
  	.data_in_HS             (mcb_rd_HS       ), 
  	.data_in_DE             (mcb_rd_DE       ), 
  	.data_out_VS            (     ), 
  	.data_out_HS            (     ), 
  	.data_out_DE            (     ), 
  	.data_out               (data_out_4      ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p4_cmd_clk      ),
		.px_cmd_en              (p4_cmd_en       ),
		.px_cmd_instr           (p4_cmd_instr    ),
		.px_cmd_bl              (p4_cmd_bl       ),
		.px_cmd_byte_addr       (p4_cmd_byte_addr),
		.px_cmd_empty           (p4_cmd_empty    ),
		.px_cmd_full            (p4_cmd_full     ),
		.px_rd_clk              (p4_rd_clk       ),
		.px_rd_en               (p4_rd_en        ),                    
		.px_rd_data             (p4_rd_data      ),
		.px_rd_full             (p4_rd_full      ),
		.px_rd_empty            (p4_rd_empty     ),
		.px_rd_count            (p4_rd_count     ),
		.px_rd_overflow         (p4_rd_overflow  ),
		.px_rd_error            (p4_rd_error     )
	);
	
	M_mcb_read
	#(
		// Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		// User parameters ends
                           
		// MCB parameters      
		.C_MCB_BURST_LEN	     (C_MCB_R_BURST_LEN),
   	.Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u5_M_mcb_read
	(
		// Users to add ports here            
		.reset                  (reset           ), 
		.mcb_clk                (mcb_clk         ), 
  	.pix_clk                (pix_clk_rd      ),    
  	.image_high_width       (image_high_width),
  	.mcb_current_raddr      (mcb_raddr5      ),
  	.mcb_current_raddr_valid(mcb_raddr_valid ),
  	.mcb_read_en            (mcb_read_en5    ),
  	.data_in_VS             (mcb_rd_VS       ), 
  	.data_in_HS             (mcb_rd_HS       ), 
  	.data_in_DE             (mcb_rd_DE       ), 
  	.data_out_VS            (     ), 
  	.data_out_HS            (     ), 
  	.data_out_DE            (     ), 
  	.data_out               (data_out_5      ),
		// User ports ends
		
		// MCB ports
		.px_cmd_clk             (p5_cmd_clk      ),
		.px_cmd_en              (p5_cmd_en       ),
		.px_cmd_instr           (p5_cmd_instr    ),
		.px_cmd_bl              (p5_cmd_bl       ),
		.px_cmd_byte_addr       (p5_cmd_byte_addr),
		.px_cmd_empty           (p5_cmd_empty    ),
		.px_cmd_full            (p5_cmd_full     ),
		.px_rd_clk              (p5_rd_clk       ),
		.px_rd_en               (p5_rd_en        ),                    
		.px_rd_data             (p5_rd_data      ),
		.px_rd_full             (p5_rd_full      ),
		.px_rd_empty            (p5_rd_empty     ),
		.px_rd_count            (p5_rd_count     ),
		.px_rd_overflow         (p5_rd_overflow  ),
		.px_rd_error            (p5_rd_error     )
	);
	 




endmodule
