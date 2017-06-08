`timescale 1ps / 1ps
//================================================================================ 
// File Name      : frames_buffer_top.v
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
module frames_buffer_mcb_top
#(
  // Users to add parameters here
	parameter  C_DATA_WIDTH          = 8,
	parameter  C_ADDR_WIDTH          = 30,
	parameter  ADDR_NUM              = 6,
	// User parameters ends
	// MCB parameters
	parameter C_MCB_W_BURST_LEN	     = 32,
	parameter C_MCB_R_BURST_LEN	     = 32,
	parameter Px_MASK_SIZE           = 4,
	parameter Px_DATA_PORT_SIZE      = 32,
	
	parameter C3_P0_MASK_SIZE        = 4,
  parameter C3_P0_DATA_PORT_SIZE   = 32,
  parameter C3_P1_MASK_SIZE        = 4,
  parameter C3_P1_DATA_PORT_SIZE   = 32,
  parameter DEBUG_EN               = 0,       
                                     // # = 1, Enable debug signals/controls,
                                     //   = 0, Disable debug signals/controls.
  parameter C3_MEMCLK_PERIOD       = 3000,       
                                     // Memory data transfer clock period
  parameter C3_CALIB_SOFT_IP       = "TRUE",       
                                     // # = TRUE, Enables the soft calibration logic,
                                     // # = FALSE, Disables the soft calibration logic.
  parameter C3_SIMULATION          = "FALSE",       
                                     // # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                     // # = FALSE, Implementing the design.
  parameter C3_RST_ACT_LOW         = 0,       
                                     // # = 1 for active low reset,
                                     // # = 0 for active high reset.
  parameter C3_INPUT_CLK_TYPE      = "SINGLE_ENDED",       
                                     // input clock type DIFFERENTIAL or SINGLE_ENDED
  parameter C3_MEM_ADDR_ORDER      = "BANK_ROW_COLUMN",       
                                     // The order in which user address is provided to the memory controller,
                                     // ROW_BANK_COLUMN or BANK_ROW_COLUMN
  parameter C3_NUM_DQ_PINS         = 16,       
                                     // External memory data width
  parameter C3_MEM_ADDR_WIDTH      = 13,       
                                     // External memory address width
  parameter C3_MEM_BANKADDR_WIDTH  = 3        
                                      // External memory bank address width
)
(
  // system signal
  input  wire                         reset       , 
  input  wire                         mcb_clk     , 
  // data input
  input  wire                         pix_clk_wr  ,
  input  wire                         data_in_VS  , 
  input  wire                         data_in_HS  , 
  input  wire                         data_in_DE  , 
  input  wire [C_DATA_WIDTH-1:0]      data_in     ,  
  // data output                      
  input  wire [4:0]                    rd_port_en  ,
  input  wire                          pix_clk_rd  ,
  input  wire                          rd_VS_in    , 
  input  wire                          rd_HS_in    , 
  input  wire                          rd_DE_in    , 
  output wire                         data_out_VS , 
  output wire                         data_out_HS , 
  output wire                         data_out_DE , 
  output wire [C_DATA_WIDTH-1:0]      data_out_1  ,
  output wire [C_DATA_WIDTH-1:0]      data_out_2  ,
  output wire [C_DATA_WIDTH-1:0]      data_out_3  ,
  output wire [C_DATA_WIDTH-1:0]      data_out_4  ,
  output wire [C_DATA_WIDTH-1:0]      data_out_5  ,
  
  //DDR3
  input                               c3_sys_clk       ,
  input                               c3_sys_rst_i     ,
  output                              c3_calib_done    ,
  inout  [C3_NUM_DQ_PINS-1:0]         mcb3_dram_dq     ,
  output [C3_MEM_ADDR_WIDTH-1:0]      mcb3_dram_a      ,
  output [C3_MEM_BANKADDR_WIDTH-1:0]  mcb3_dram_ba     ,
  output                              mcb3_dram_ras_n  ,
  output                              mcb3_dram_cas_n  ,
  output                              mcb3_dram_we_n   ,
  output                              mcb3_dram_odt    ,
  output                              mcb3_dram_reset_n,
  output                              mcb3_dram_cke    ,
  output                              mcb3_dram_dm     ,
  inout                               mcb3_dram_udqs   ,
  inout                               mcb3_dram_udqs_n ,
  output                              mcb3_dram_udm    ,
  inout                               mcb3_dram_dqs    ,
  inout                               mcb3_dram_dqs_n  ,
  output                              mcb3_dram_ck     ,
  output                              mcb3_dram_ck_n   ,
  inout                               mcb3_rzq         ,
  inout                               mcb3_zio         
  
) ;

	// =============================================================================
	// Internal signal
	// =============================================================================
	wire                         c3_clk0     ;
  wire                         c3_rst0     ;
  wire                         c3_calib_done_t;
  wire                         frames_buffer_reset;
  wire                         mcb_reset;
  wire                         mcb_port_error;
	
	// MCB ports
	wire 	                       p0_cmd_clk      ;
	wire	                       p0_cmd_en       ;
	wire [2:0]	                 p0_cmd_instr    ;
	wire [5:0]	                 p0_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p0_cmd_byte_addr;
	wire		                     p0_cmd_empty    ;
	wire		                     p0_cmd_full     ;
	wire	                       p0_wr_clk       ;
	wire	                       p0_wr_en        ;
	wire [Px_MASK_SIZE-1:0]	     p0_wr_mask      ;
	wire [Px_DATA_PORT_SIZE-1:0] p0_wr_data      ;
	wire		                     p0_wr_full      ;
	wire		                     p0_wr_empty     ;
	wire [6:0]	                 p0_wr_count     ;
	wire		                     p0_wr_underrun  ;
	wire		                     p0_wr_error     ;
	reg 		                     p0_wr_underrun_d;
	reg 		                     p0_wr_error_d   ;
	                                             
	wire 	                       p1_cmd_clk      ;
	wire 	                       p1_cmd_en       ;
	wire [2:0]	                 p1_cmd_instr    ;
	wire [5:0]	                 p1_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p1_cmd_byte_addr;
	wire                         p1_cmd_empty    ;
	wire                         p1_cmd_full     ;
	wire 	                       p1_rd_clk       ;
	wire 	                       p1_rd_en        ;                 
	wire [Px_DATA_PORT_SIZE-1:0] p1_rd_data      ;
	wire                         p1_rd_full      ;
	wire                         p1_rd_empty     ;
	wire [6:0]	                 p1_rd_count     ;
	wire                         p1_rd_overflow  ;
	wire                         p1_rd_error     ;
	reg                          p1_rd_overflow_d;
	reg                          p1_rd_error_d   ;
	                                             
	wire 	                       p2_cmd_clk      ;
	wire 	                       p2_cmd_en       ;
	wire [2:0]	                 p2_cmd_instr    ;
	wire [5:0]	                 p2_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p2_cmd_byte_addr;
	wire                         p2_cmd_empty    ;
	wire                         p2_cmd_full     ;
	wire 	                       p2_rd_clk       ;
	wire 	                       p2_rd_en        ;                 
	wire [Px_DATA_PORT_SIZE-1:0] p2_rd_data      ;
	wire                         p2_rd_full      ;
	wire                         p2_rd_empty     ;
	wire [6:0]	                 p2_rd_count     ;
	wire                         p2_rd_overflow  ;
	wire                         p2_rd_error     ;
	reg                          p2_rd_overflow_d;
	reg                          p2_rd_error_d   ;
	                              
	wire 	                       p3_cmd_clk      ;
	wire 	                       p3_cmd_en       ;
	wire [2:0]	                 p3_cmd_instr    ;
	wire [5:0]	                 p3_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p3_cmd_byte_addr;
	wire                         p3_cmd_empty    ;
	wire                         p3_cmd_full     ;
	wire 	                       p3_rd_clk       ;
	wire 	                       p3_rd_en        ;                    
	wire [Px_DATA_PORT_SIZE-1:0] p3_rd_data      ;
	wire                         p3_rd_full      ;
	wire                         p3_rd_empty     ;
	wire [6:0]	                 p3_rd_count     ;
	wire                         p3_rd_overflow  ;
	wire                         p3_rd_error     ;
	reg                          p3_rd_overflow_d;
	reg                          p3_rd_error_d   ;
	
	wire 	                       p4_cmd_clk      ;
	wire 	                       p4_cmd_en       ;
	wire [2:0]	                 p4_cmd_instr    ;
	wire [5:0]	                 p4_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p4_cmd_byte_addr;
	wire                         p4_cmd_empty    ;
	wire                         p4_cmd_full     ;
	wire 	                       p4_rd_clk       ;
	wire 	                       p4_rd_en        ;                    
	wire [Px_DATA_PORT_SIZE-1:0] p4_rd_data      ;
	wire                         p4_rd_full      ;
	wire                         p4_rd_empty     ;
	wire [6:0]	                 p4_rd_count     ;
	wire                         p4_rd_overflow  ;
	wire                         p4_rd_error     ;
	reg                          p4_rd_overflow_d;
	reg                          p4_rd_error_d   ;
	
	wire 	                       p5_cmd_clk      ;
	wire 	                       p5_cmd_en       ;
	wire [2:0]	                 p5_cmd_instr    ;
	wire [5:0]	                 p5_cmd_bl       ;
	wire [C_ADDR_WIDTH-1:0]	     p5_cmd_byte_addr;
	wire                         p5_cmd_empty    ;
	wire                         p5_cmd_full     ;
	wire 	                       p5_rd_clk       ;
	wire 	                       p5_rd_en        ;                    
	wire [Px_DATA_PORT_SIZE-1:0] p5_rd_data      ;
	wire                         p5_rd_full      ;
	wire                         p5_rd_empty     ;
	wire [6:0]	                 p5_rd_count     ;
	wire                         p5_rd_overflow  ;
	wire                         p5_rd_error     ;
	reg                          p5_rd_overflow_d;
	reg                          p5_rd_error_d   ;
	
	wire                         p0_wr_underrun_ps;
	wire                         p0_wr_error_ps   ;
	wire                         p1_rd_overflow_ps;
	wire                         p1_rd_error_ps   ;
	wire                         p2_rd_overflow_ps;
	wire                         p2_rd_error_ps   ;
	wire                         p3_rd_overflow_ps;
	wire                         p3_rd_error_ps   ;
	wire                         p4_rd_overflow_ps;
	wire                         p4_rd_error_ps   ;
	wire                         p5_rd_overflow_ps;
	wire                         p5_rd_error_ps   ;

	// =============================================================================
	// RTL Body
	// =============================================================================
	assign c3_calib_done       = c3_calib_done_t;
	assign mcb_port_error      = p0_wr_underrun_ps | p0_wr_error_ps | 
	                             p1_rd_overflow_ps | p1_rd_error_ps | 
	                             p2_rd_overflow_ps | p2_rd_error_ps | 
	                             p3_rd_overflow_ps | p3_rd_error_ps;
	assign frames_buffer_reset = reset;// | mcb_port_error | c3_rst0; | ~c3_calib_done_t
	assign mcb_reset           = c3_sys_rst_i;// | mcb_port_error;
	
	always@(posedge mcb_clk or posedge reset)
	begin
		if(reset)	
		begin
			p0_wr_underrun_d <= 1'b0;
			p0_wr_error_d    <= 1'b0;
			p1_rd_overflow_d <= 1'b0;
			p1_rd_error_d    <= 1'b0;
			p2_rd_overflow_d <= 1'b0;
			p2_rd_error_d    <= 1'b0;
			p3_rd_overflow_d <= 1'b0;
			p3_rd_error_d    <= 1'b0;
		end
		else
		begin
			p0_wr_underrun_d <= p0_wr_underrun;
			p0_wr_error_d    <= p0_wr_error   ;
			p1_rd_overflow_d <= p1_rd_overflow;
			p1_rd_error_d    <= p1_rd_error   ;
			p2_rd_overflow_d <= p2_rd_overflow;
			p2_rd_error_d    <= p2_rd_error   ;
			p3_rd_overflow_d <= p3_rd_overflow;
			p3_rd_error_d    <= p3_rd_error   ;
		end
	end
	
	assign p0_wr_underrun_ps = ~p0_wr_underrun_d & p0_wr_underrun;
	assign p0_wr_error_ps    = ~p0_wr_error_d    & p0_wr_error   ;
	assign p1_rd_overflow_ps = ~p1_rd_overflow_d & p1_rd_overflow;
	assign p1_rd_error_ps    = ~p1_rd_error_d    & p1_rd_error   ;
	assign p2_rd_overflow_ps = ~p2_rd_overflow_d & p2_rd_overflow;
	assign p2_rd_error_ps    = ~p2_rd_error_d    & p2_rd_error   ;
	assign p3_rd_overflow_ps = ~p3_rd_overflow_d & p3_rd_overflow;
	assign p3_rd_error_ps    = ~p3_rd_error_d    & p3_rd_error   ;
	
	frames_buffer_mcb
	#(
	  // Users to add parameters here
		.C_DATA_WIDTH          (C_DATA_WIDTH     ),
		.C_ADDR_WIDTH          (C_ADDR_WIDTH     ),
		.ADDR_NUM              (ADDR_NUM         ),
		// User parameters ends
	                         
		// MCB parameters
		.C_MCB_W_BURST_LEN     (C_MCB_W_BURST_LEN),
		.C_MCB_R_BURST_LEN     (C_MCB_R_BURST_LEN),
		.Px_MASK_SIZE          (Px_MASK_SIZE     ),
	  .Px_DATA_PORT_SIZE     (Px_DATA_PORT_SIZE)
	)
	u_frames_buffer_mcb
	(
	  // system signal
	  .reset                 (frames_buffer_reset), 
	  .mcb_clk               (mcb_clk            ), 
	  // data input
	  .pix_clk_wr            (pix_clk_wr         ), 
	  .data_in_VS            (data_in_VS         ), 
	  .data_in_HS            (data_in_HS         ), 
	  .data_in_DE            (data_in_DE         ), 
	  .data_in               (data_in            ),  
	  // data output
	  .rd_port_en            (rd_port_en         ),
	  .pix_clk_rd            (pix_clk_rd         ),
  	.rd_VS_in              (rd_VS_in           ), 
  	.rd_HS_in              (rd_HS_in           ), 
  	.rd_DE_in              (rd_DE_in           ), 
	  .data_out_VS           (data_out_VS        ), 
	  .data_out_HS           (data_out_HS        ), 
	  .data_out_DE           (data_out_DE        ), 
	  .data_out_1            (data_out_1         ),
	  .data_out_2            (data_out_2         ),
	  .data_out_3            (data_out_3         ),
	  .data_out_4            (data_out_4         ),
	  .data_out_5            (data_out_5         ),
	                         
	  // MCB ports           
		.p0_cmd_clk            (p0_cmd_clk      ),
		.p0_cmd_en             (p0_cmd_en       ),
		.p0_cmd_instr          (p0_cmd_instr    ),
		.p0_cmd_bl             (p0_cmd_bl       ),
		.p0_cmd_byte_addr      (p0_cmd_byte_addr),
		.p0_cmd_empty          (p0_cmd_empty    ),
		.p0_cmd_full           (p0_cmd_full     ),
		.p0_wr_clk             (p0_wr_clk       ),
		.p0_wr_en              (p0_wr_en        ),
		.p0_wr_mask            (p0_wr_mask      ),
		.p0_wr_data            (p0_wr_data      ),
		.p0_wr_full            (p0_wr_full      ),
		.p0_wr_empty           (p0_wr_empty     ),
		.p0_wr_count           (p0_wr_count     ),
		.p0_wr_underrun        (p0_wr_underrun  ),
		.p0_wr_error           (p0_wr_error     ),
                           
		.p1_cmd_clk            (p1_cmd_clk      ),
		.p1_cmd_en             (p1_cmd_en       ),
		.p1_cmd_instr          (p1_cmd_instr    ),
		.p1_cmd_bl             (p1_cmd_bl       ),
		.p1_cmd_byte_addr      (p1_cmd_byte_addr),
		.p1_cmd_empty          (p1_cmd_empty    ),
		.p1_cmd_full           (p1_cmd_full     ),
		.p1_rd_clk             (p1_rd_clk       ),
		.p1_rd_en              (p1_rd_en        ),                    
		.p1_rd_data            (p1_rd_data      ),
		.p1_rd_full            (p1_rd_full      ),
		.p1_rd_empty           (p1_rd_empty     ),
		.p1_rd_count           (p1_rd_count     ),
		.p1_rd_overflow        (p1_rd_overflow  ),
		.p1_rd_error           (p1_rd_error     ),
                           
		.p2_cmd_clk            (p2_cmd_clk      ),
		.p2_cmd_en             (p2_cmd_en       ),
		.p2_cmd_instr          (p2_cmd_instr    ),
		.p2_cmd_bl             (p2_cmd_bl       ),
		.p2_cmd_byte_addr      (p2_cmd_byte_addr),
		.p2_cmd_empty          (p2_cmd_empty    ),
		.p2_cmd_full           (p2_cmd_full     ),
		.p2_rd_clk             (p2_rd_clk       ),
		.p2_rd_en              (p2_rd_en        ),                    
		.p2_rd_data            (p2_rd_data      ),
		.p2_rd_full            (p2_rd_full      ),
		.p2_rd_empty           (p2_rd_empty     ),
		.p2_rd_count           (p2_rd_count     ),
		.p2_rd_overflow        (p2_rd_overflow  ),
		.p2_rd_error           (p2_rd_error     ),
                           
		.p3_cmd_clk            (p3_cmd_clk      ),
		.p3_cmd_en             (p3_cmd_en       ),
		.p3_cmd_instr          (p3_cmd_instr    ),
		.p3_cmd_bl             (p3_cmd_bl       ),
		.p3_cmd_byte_addr      (p3_cmd_byte_addr),
		.p3_cmd_empty          (p3_cmd_empty    ),
		.p3_cmd_full           (p3_cmd_full     ),
		.p3_rd_clk             (p3_rd_clk       ),
		.p3_rd_en              (p3_rd_en        ),                    
		.p3_rd_data            (p3_rd_data      ),
		.p3_rd_full            (p3_rd_full      ),
		.p3_rd_empty           (p3_rd_empty     ),
		.p3_rd_count           (p3_rd_count     ),
		.p3_rd_overflow        (p3_rd_overflow  ),
		.p3_rd_error           (p3_rd_error     ),
		
		.p4_cmd_clk            (p4_cmd_clk      ),
		.p4_cmd_en             (p4_cmd_en       ),
		.p4_cmd_instr          (p4_cmd_instr    ),
		.p4_cmd_bl             (p4_cmd_bl       ),
		.p4_cmd_byte_addr      (p4_cmd_byte_addr),
		.p4_cmd_empty          (p4_cmd_empty    ),
		.p4_cmd_full           (p4_cmd_full     ),
		.p4_rd_clk             (p4_rd_clk       ),
		.p4_rd_en              (p4_rd_en        ),                    
		.p4_rd_data            (p4_rd_data      ),
		.p4_rd_full            (p4_rd_full      ),
		.p4_rd_empty           (p4_rd_empty     ),
		.p4_rd_count           (p4_rd_count     ),
		.p4_rd_overflow        (p4_rd_overflow  ),
		.p4_rd_error           (p4_rd_error     ),
		
		.p5_cmd_clk            (p5_cmd_clk      ),
		.p5_cmd_en             (p5_cmd_en       ),
		.p5_cmd_instr          (p5_cmd_instr    ),
		.p5_cmd_bl             (p5_cmd_bl       ),
		.p5_cmd_byte_addr      (p5_cmd_byte_addr),
		.p5_cmd_empty          (p5_cmd_empty    ),
		.p5_cmd_full           (p5_cmd_full     ),
		.p5_rd_clk             (p5_rd_clk       ),
		.p5_rd_en              (p5_rd_en        ),                    
		.p5_rd_data            (p5_rd_data      ),
		.p5_rd_full            (p5_rd_full      ),
		.p5_rd_empty           (p5_rd_empty     ),
		.p5_rd_count           (p5_rd_count     ),
		.p5_rd_overflow        (p5_rd_overflow  ),
		.p5_rd_error           (p5_rd_error     )
	  
	) ;
	
	mcb_ctrl_NativePort 
	#(
    .C3_P0_MASK_SIZE      (C3_P0_MASK_SIZE      ),
    .C3_P0_DATA_PORT_SIZE (C3_P0_DATA_PORT_SIZE ),
    .C3_P1_MASK_SIZE      (C3_P1_MASK_SIZE      ),
    .C3_P1_DATA_PORT_SIZE (C3_P1_DATA_PORT_SIZE ),
    .DEBUG_EN             (DEBUG_EN             ),
    .C3_MEMCLK_PERIOD     (C3_MEMCLK_PERIOD     ),
    .C3_CALIB_SOFT_IP     (C3_CALIB_SOFT_IP     ),
    .C3_SIMULATION        (C3_SIMULATION        ),
    .C3_RST_ACT_LOW       (C3_RST_ACT_LOW       ),
    .C3_INPUT_CLK_TYPE    (C3_INPUT_CLK_TYPE    ),
    .C3_MEM_ADDR_ORDER    (C3_MEM_ADDR_ORDER    ),
    .C3_NUM_DQ_PINS       (C3_NUM_DQ_PINS       ),
    .C3_MEM_ADDR_WIDTH    (C3_MEM_ADDR_WIDTH    ),
    .C3_MEM_BANKADDR_WIDTH(C3_MEM_BANKADDR_WIDTH)
	)
	u_mcb_ctrl_NativePort 
	(
	  .c3_sys_clk           (c3_sys_clk       ),
	  .c3_sys_rst_i         (mcb_reset        ),                        	                                          
	  .mcb3_dram_dq         (mcb3_dram_dq     ),  
	  .mcb3_dram_a          (mcb3_dram_a      ),  
	  .mcb3_dram_ba         (mcb3_dram_ba     ),
	  .mcb3_dram_ras_n      (mcb3_dram_ras_n  ),                        
	  .mcb3_dram_cas_n      (mcb3_dram_cas_n  ),                        
	  .mcb3_dram_we_n       (mcb3_dram_we_n   ),                          
	  .mcb3_dram_odt        (mcb3_dram_odt    ),
	  .mcb3_dram_cke        (mcb3_dram_cke    ),                          
	  .mcb3_dram_ck         (mcb3_dram_ck     ),                          
	  .mcb3_dram_ck_n       (mcb3_dram_ck_n   ),       
	  .mcb3_dram_dqs        (mcb3_dram_dqs    ),                          
	  .mcb3_dram_dqs_n      (mcb3_dram_dqs_n  ),
	  .mcb3_dram_udqs       (mcb3_dram_udqs   ),    // for X16 parts                        
	  .mcb3_dram_udqs_n     (mcb3_dram_udqs_n ),  // for X16 parts
	  .mcb3_dram_udm        (mcb3_dram_udm    ),     // for X16 parts
	  .mcb3_dram_dm         (mcb3_dram_dm     ),
	  .mcb3_dram_reset_n    (mcb3_dram_reset_n),
	  .c3_clk0		          (c3_clk0          ),
	  .c3_rst0		          (c3_rst0          ),
	  .c3_calib_done        (c3_calib_done_t  ),
	  .mcb3_rzq             (mcb3_rzq         ),  	        
	  .mcb3_zio             (mcb3_zio         ),
		
	  .c3_p0_cmd_clk        (p0_cmd_clk      ),
	  .c3_p0_cmd_en         (p0_cmd_en       ),
	  .c3_p0_cmd_instr      (p0_cmd_instr    ),
	  .c3_p0_cmd_bl         (p0_cmd_bl       ),
	  .c3_p0_cmd_byte_addr  (p0_cmd_byte_addr),
	  .c3_p0_cmd_empty      (p0_cmd_empty    ),
	  .c3_p0_cmd_full       (p0_cmd_full     ),
	  .c3_p0_wr_clk         (p0_wr_clk       ),
	  .c3_p0_wr_en          (p0_wr_en        ),
	  .c3_p0_wr_mask        (p0_wr_mask      ),
	  .c3_p0_wr_data        (p0_wr_data      ),
	  .c3_p0_wr_full        (p0_wr_full      ),
	  .c3_p0_wr_empty       (p0_wr_empty     ),
	  .c3_p0_wr_count       (p0_wr_count     ),
	  .c3_p0_wr_underrun    (p0_wr_underrun  ),
	  .c3_p0_wr_error       (p0_wr_error     ),
	  .c3_p0_rd_clk         (1'b0  ),
	  .c3_p0_rd_en          (1'b0  ),
	  .c3_p0_rd_data        (      ),
	  .c3_p0_rd_full        (      ),
	  .c3_p0_rd_empty       (      ),
	  .c3_p0_rd_count       (      ),
	  .c3_p0_rd_overflow    (      ),
	  .c3_p0_rd_error       (      ),
	  
	  .c3_p1_cmd_clk        (p1_cmd_clk      ),
	  .c3_p1_cmd_en         (p1_cmd_en       ),
	  .c3_p1_cmd_instr      (p1_cmd_instr    ),
	  .c3_p1_cmd_bl         (p1_cmd_bl       ),
	  .c3_p1_cmd_byte_addr  (p1_cmd_byte_addr),
	  .c3_p1_cmd_empty      (p1_cmd_empty    ),
	  .c3_p1_cmd_full       (p1_cmd_full     ),
	  .c3_p1_wr_clk         (1'b0  ),
	  .c3_p1_wr_en          (1'b0  ),
	  .c3_p1_wr_mask        (4'd0  ),
	  .c3_p1_wr_data        (32'd0 ),
	  .c3_p1_wr_full        (      ),
	  .c3_p1_wr_empty       (      ),
	  .c3_p1_wr_count       (      ),
	  .c3_p1_wr_underrun    (      ),
	  .c3_p1_wr_error       (      ),
	  .c3_p1_rd_clk         (p1_rd_clk       ),
	  .c3_p1_rd_en          (p1_rd_en        ),
	  .c3_p1_rd_data        (p1_rd_data      ),
	  .c3_p1_rd_full        (p1_rd_full      ),
	  .c3_p1_rd_empty       (p1_rd_empty     ),
	  .c3_p1_rd_count       (p1_rd_count     ),
	  .c3_p1_rd_overflow    (p1_rd_overflow  ),
	  .c3_p1_rd_error       (p1_rd_error     ),
	  
	  .c3_p2_cmd_clk        (p2_cmd_clk      ),
	  .c3_p2_cmd_en         (p2_cmd_en       ),
	  .c3_p2_cmd_instr      (p2_cmd_instr    ),
	  .c3_p2_cmd_bl         (p2_cmd_bl       ),
	  .c3_p2_cmd_byte_addr  (p2_cmd_byte_addr),
	  .c3_p2_cmd_empty      (p2_cmd_empty    ),
	  .c3_p2_cmd_full       (p2_cmd_full     ),
	  //.c3_p2_wr_clk         (1'b0  ),
	  //.c3_p2_wr_en          (1'b0  ),
	  //.c3_p2_wr_mask        (4'd0  ),
	  //.c3_p2_wr_data        (32'd0 ),
	  //.c3_p2_wr_full        (      ),
	  //.c3_p2_wr_empty       (      ),
	  //.c3_p2_wr_count       (      ),
	  //.c3_p2_wr_underrun    (      ),
	  //.c3_p2_wr_error       (      ),
	  .c3_p2_rd_clk         (p2_rd_clk       ),
	  .c3_p2_rd_en          (p2_rd_en        ),
	  .c3_p2_rd_data        (p2_rd_data      ),
	  .c3_p2_rd_full        (p2_rd_full      ),
	  .c3_p2_rd_empty       (p2_rd_empty     ),
	  .c3_p2_rd_count       (p2_rd_count     ),
	  .c3_p2_rd_overflow    (p2_rd_overflow  ),
	  .c3_p2_rd_error       (p2_rd_error     ),
	  
	  .c3_p3_cmd_clk        (p3_cmd_clk      ),
	  .c3_p3_cmd_en         (p3_cmd_en       ),
	  .c3_p3_cmd_instr      (p3_cmd_instr    ),
	  .c3_p3_cmd_bl         (p3_cmd_bl       ),
	  .c3_p3_cmd_byte_addr  (p3_cmd_byte_addr),
	  .c3_p3_cmd_empty      (p3_cmd_empty    ),
	  .c3_p3_cmd_full       (p3_cmd_full     ),
	  //.c3_p3_wr_clk         (1'b0  ),
	  //.c3_p3_wr_en          (1'b0  ),
	  //.c3_p3_wr_mask        (4'd0  ),
	  //.c3_p3_wr_data        (32'd0 ),
	  //.c3_p3_wr_full        (      ),
	  //.c3_p3_wr_empty       (      ),
	  //.c3_p3_wr_count       (      ),
	  //.c3_p3_wr_underrun    (      ),
	  //.c3_p3_wr_error       (      ),
	  .c3_p3_rd_clk         (p3_rd_clk       ),
	  .c3_p3_rd_en          (p3_rd_en        ),
	  .c3_p3_rd_data        (p3_rd_data      ),
	  .c3_p3_rd_full        (p3_rd_full      ),
	  .c3_p3_rd_empty       (p3_rd_empty     ),
	  .c3_p3_rd_count       (p3_rd_count     ),
	  .c3_p3_rd_overflow    (p3_rd_overflow  ),
	  .c3_p3_rd_error       (p3_rd_error     ),
	  
	  .c3_p4_cmd_clk        (p4_cmd_clk      ),
	  .c3_p4_cmd_en         (p4_cmd_en       ),
	  .c3_p4_cmd_instr      (p4_cmd_instr    ),
	  .c3_p4_cmd_bl         (p4_cmd_bl       ),
	  .c3_p4_cmd_byte_addr  (p4_cmd_byte_addr),
	  .c3_p4_cmd_empty      (p4_cmd_empty    ),
	  .c3_p4_cmd_full       (p4_cmd_full     ),
	  //.c3_p4_wr_clk         (1'b0  ),
	  //.c3_p4_wr_en          (1'b0  ),
	  //.c3_p4_wr_mask        (4'd0  ),
	  //.c3_p4_wr_data        (32'd0 ),
	  //.c3_p4_wr_full        (      ),
	  //.c3_p4_wr_empty       (      ),
	  //.c3_p4_wr_count       (      ),
	  //.c3_p4_wr_underrun    (      ),
	  //.c3_p4_wr_error       (      ),
	  .c3_p4_rd_clk         (p4_rd_clk       ),
	  .c3_p4_rd_en          (p4_rd_en        ),
	  .c3_p4_rd_data        (p4_rd_data      ),
	  .c3_p4_rd_full        (p4_rd_full      ),
	  .c3_p4_rd_empty       (p4_rd_empty     ),
	  .c3_p4_rd_count       (p4_rd_count     ),
	  .c3_p4_rd_overflow    (p4_rd_overflow  ),
	  .c3_p4_rd_error       (p4_rd_error     ),
	  
	  .c3_p5_cmd_clk        (p5_cmd_clk      ),
	  .c3_p5_cmd_en         (p5_cmd_en       ),
	  .c3_p5_cmd_instr      (p5_cmd_instr    ),
	  .c3_p5_cmd_bl         (p5_cmd_bl       ),
	  .c3_p5_cmd_byte_addr  (p5_cmd_byte_addr),
	  .c3_p5_cmd_empty      (p5_cmd_empty    ),
	  .c3_p5_cmd_full       (p5_cmd_full     ),
	  //.c3_p5_wr_clk         (1'b0  ),
	  //.c3_p5_wr_en          (1'b0  ),
	  //.c3_p5_wr_mask        (4'd0  ),
	  //.c3_p5_wr_data        (32'd0 ),
	  //.c3_p5_wr_full        (      ),
	  //.c3_p5_wr_empty       (      ),
	  //.c3_p5_wr_count       (      ),
	  //.c3_p5_wr_underrun    (      ),
	  //.c3_p5_wr_error       (      ),
	  .c3_p5_rd_clk         (p5_rd_clk       ),
	  .c3_p5_rd_en          (p5_rd_en        ),
	  .c3_p5_rd_data        (p5_rd_data      ),
	  .c3_p5_rd_full        (p5_rd_full      ),
	  .c3_p5_rd_empty       (p5_rd_empty     ),
	  .c3_p5_rd_count       (p5_rd_count     ),
	  .c3_p5_rd_overflow    (p5_rd_overflow  ),
	  .c3_p5_rd_error       (p5_rd_error     )
	  
	);
	
	/*
	mcb_ctrl //DDR3 AXI
	#(
    .C3_P0_MASK_SIZE                 (C3_P0_MASK_SIZE                ),
    .C3_P0_DATA_PORT_SIZE            (C3_P0_DATA_PORT_SIZE           ),
    .C3_P1_MASK_SIZE                 (C3_P1_MASK_SIZE                ),
    .C3_P1_DATA_PORT_SIZE            (C3_P1_DATA_PORT_SIZE           ),
    .DEBUG_EN                        (DEBUG_EN                       ),
    .C3_MEMCLK_PERIOD                (C3_MEMCLK_PERIOD               ),
    .C3_CALIB_SOFT_IP                (C3_CALIB_SOFT_IP               ),
    .C3_SIMULATION                   (C3_SIMULATION                  ),
    .C3_RST_ACT_LOW                  (C3_RST_ACT_LOW                 ),
    .C3_INPUT_CLK_TYPE               (C3_INPUT_CLK_TYPE              ),
    .C3_MEM_ADDR_ORDER               (C3_MEM_ADDR_ORDER              ),
    .C3_NUM_DQ_PINS                  (C3_NUM_DQ_PINS                 ),
    .C3_MEM_ADDR_WIDTH               (C3_MEM_ADDR_WIDTH              ),
    .C3_MEM_BANKADDR_WIDTH           (C3_MEM_BANKADDR_WIDTH          ),
    .C3_S0_AXI_STRICT_COHERENCY      (C3_S0_AXI_STRICT_COHERENCY     ),
    .C3_S0_AXI_ENABLE_AP             (C3_S0_AXI_ENABLE_AP            ),
    .C3_S0_AXI_DATA_WIDTH            (C3_S0_AXI_DATA_WIDTH           ),
    .C3_S0_AXI_SUPPORTS_NARROW_BURST (C3_S0_AXI_SUPPORTS_NARROW_BURST),
    .C3_S0_AXI_ADDR_WIDTH            (C3_S0_AXI_ADDR_WIDTH           ),
    .C3_S0_AXI_ID_WIDTH              (C3_S0_AXI_ID_WIDTH             ),
    .C3_S1_AXI_STRICT_COHERENCY      (C3_S1_AXI_STRICT_COHERENCY     ),
    .C3_S1_AXI_ENABLE_AP             (C3_S1_AXI_ENABLE_AP            ),
    .C3_S1_AXI_DATA_WIDTH            (C3_S1_AXI_DATA_WIDTH           ),
    .C3_S1_AXI_SUPPORTS_NARROW_BURST (C3_S1_AXI_SUPPORTS_NARROW_BURST),
    .C3_S1_AXI_ADDR_WIDTH            (C3_S1_AXI_ADDR_WIDTH           ),
    .C3_S1_AXI_ID_WIDTH              (C3_S1_AXI_ID_WIDTH             ),
    .C3_S2_AXI_STRICT_COHERENCY      (C3_S2_AXI_STRICT_COHERENCY     ),
    .C3_S2_AXI_ENABLE_AP             (C3_S2_AXI_ENABLE_AP            ),
    .C3_S2_AXI_DATA_WIDTH            (C3_S2_AXI_DATA_WIDTH           ),
    .C3_S2_AXI_SUPPORTS_NARROW_BURST (C3_S2_AXI_SUPPORTS_NARROW_BURST),
    .C3_S2_AXI_ADDR_WIDTH            (C3_S2_AXI_ADDR_WIDTH           ),
    .C3_S2_AXI_ID_WIDTH              (C3_S2_AXI_ID_WIDTH             ),
    .C3_S3_AXI_STRICT_COHERENCY      (C3_S3_AXI_STRICT_COHERENCY     ),
    .C3_S3_AXI_ENABLE_AP             (C3_S3_AXI_ENABLE_AP            ),
    .C3_S3_AXI_DATA_WIDTH            (C3_S3_AXI_DATA_WIDTH           ),
    .C3_S3_AXI_SUPPORTS_NARROW_BURST (C3_S3_AXI_SUPPORTS_NARROW_BURST),
    .C3_S3_AXI_ADDR_WIDTH            (C3_S3_AXI_ADDR_WIDTH           ),
    .C3_S3_AXI_ID_WIDTH              (C3_S3_AXI_ID_WIDTH             )
	)
	u_mcb_ctrl 
	(
	  .c3_sys_clk                      (c3_sys_clk       ),
	  .c3_sys_rst_i                    (c3_sys_rst_i     ),                        
	                                                    
	  .mcb3_dram_dq                    (mcb3_dram_dq     ),  
	  .mcb3_dram_a                     (mcb3_dram_a      ),  
	  .mcb3_dram_ba                    (mcb3_dram_ba     ),
	  .mcb3_dram_ras_n                 (mcb3_dram_ras_n  ),                        
	  .mcb3_dram_cas_n                 (mcb3_dram_cas_n  ),                        
	  .mcb3_dram_we_n                  (mcb3_dram_we_n   ),                          
	  .mcb3_dram_odt                   (mcb3_dram_odt    ),
	  .mcb3_dram_cke                   (mcb3_dram_cke    ),                          
	  .mcb3_dram_ck                    (mcb3_dram_ck     ),                          
	  .mcb3_dram_ck_n                  (mcb3_dram_ck_n   ),       
	  .mcb3_dram_dqs                   (mcb3_dram_dqs    ),                          
	  .mcb3_dram_dqs_n                 (mcb3_dram_dqs_n  ),
	  .mcb3_dram_udqs                  (mcb3_dram_udqs   ),  // for X16 parts                        
	  .mcb3_dram_udqs_n                (mcb3_dram_udqs_n ),  // for X16 parts
	  .mcb3_dram_udm                   (mcb3_dram_udm    ),  // for X16 parts
	  .mcb3_dram_dm                    (mcb3_dram_dm     ),
	  .mcb3_dram_reset_n               (mcb3_dram_reset_n),
	  .c3_clk0		                     (c3_clk0          ),
	  .c3_rst0		                     (c3_rst0          ),
		                                 
	  .c3_calib_done                   (c3_calib_done_t  ),
	  .mcb3_rzq                        (mcb3_rzq         ),  
	  .mcb3_zio                        (mcb3_zio         ),
		                                 
	  .c3_s0_axi_aclk                  (m00_axi_waclk   ),
	  .c3_s0_axi_aresetn               (m00_axi_waresetn),  
	                                   
	  .c3_s0_axi_awid                  (m00_axi_awid    ),
	  .c3_s0_axi_awaddr                (m00_axi_awaddr  ),
	  .c3_s0_axi_awlen                 (m00_axi_awlen   ),
	  .c3_s0_axi_awsize                (m00_axi_awsize  ),
	  .c3_s0_axi_awburst               (m00_axi_awburst ),
	  .c3_s0_axi_awlock                (m00_axi_awlock  ),
	  .c3_s0_axi_awcache               (m00_axi_awcache ),
	  .c3_s0_axi_awprot                (m00_axi_awprot  ),
	  .c3_s0_axi_awqos                 (m00_axi_awqos   ),
	  .c3_s0_axi_awvalid               (m00_axi_awvalid ),
	  .c3_s0_axi_awready               (m00_axi_awready ),
	                                   
	  .c3_s0_axi_wdata                 (m00_axi_wdata   ),
	  .c3_s0_axi_wstrb                 (m00_axi_wstrb   ),
	  .c3_s0_axi_wlast                 (m00_axi_wlast   ),
	  .c3_s0_axi_wvalid                (m00_axi_wvalid  ),
	  .c3_s0_axi_wready                (m00_axi_wready  ),
	                                   
	  .c3_s0_axi_bid                   (m00_axi_bid     ),
	  .c3_s0_axi_bresp                 (m00_axi_bresp   ),
	  .c3_s0_axi_bvalid                (m00_axi_bvalid  ),
	  .c3_s0_axi_bready                (m00_axi_bready  ),
	                                   
	  .c3_s0_axi_wid                   (),
	                                   
	  .c3_s0_axi_arid                  (1'b0 ),
	  .c3_s0_axi_araddr                (32'b0),
	  .c3_s0_axi_arlen                 (8'b0 ),
	  .c3_s0_axi_arsize                (3'b0 ),
	  .c3_s0_axi_arburst               (2'b0 ),
	  .c3_s0_axi_arlock                (1'b0 ),
	  .c3_s0_axi_arcache               (4'b0 ),
	  .c3_s0_axi_arprot                (3'b0 ),
	  .c3_s0_axi_arqos                 (4'b0 ),
	  .c3_s0_axi_arvalid               (1'b0 ),
	  .c3_s0_axi_arready               (     ),
	                                         
	  .c3_s0_axi_rid                   (     ),
	  .c3_s0_axi_rdata                 (     ),
	  .c3_s0_axi_rresp                 (     ),
	  .c3_s0_axi_rlast                 (     ),
	  .c3_s0_axi_rvalid                (     ),
	  .c3_s0_axi_rready                (1'b0 ),
	                                   
	  .c3_s1_axi_aclk                  (m00_axi_raclk   ),
	  .c3_s1_axi_aresetn               (m00_axi_raresetn),
	                                   
	  .c3_s1_axi_awid                  (1'b0 ),
	  .c3_s1_axi_awaddr                (32'b0),
	  .c3_s1_axi_awlen                 (8'b0 ),
	  .c3_s1_axi_awsize                (3'b0 ),
	  .c3_s1_axi_awburst               (2'b0 ),
	  .c3_s1_axi_awlock                (1'b0 ),
	  .c3_s1_axi_awcache               (4'b0 ),
	  .c3_s1_axi_awprot                (3'b0 ),
	  .c3_s1_axi_awqos                 (4'b0 ),
	  .c3_s1_axi_awvalid               (1'b0 ),
	  .c3_s1_axi_awready               (     ),
	                                         
	  .c3_s1_axi_wdata                 (32'b0),
	  .c3_s1_axi_wstrb                 (4'b0 ),
	  .c3_s1_axi_wlast                 (1'b0 ),
	  .c3_s1_axi_wvalid                (1'b0 ),
	  .c3_s1_axi_wready                (     ),
	                                   
	  .c3_s1_axi_bid                   (     ),
	  .c3_s1_axi_bresp                 (     ),
	  .c3_s1_axi_bvalid                (     ),
	  .c3_s1_axi_bready                (1'b0 ),
	                                   
	  .c3_s1_axi_wid                   (),
	                                   
	  .c3_s1_axi_arid                  (m00_axi_arid    ),
	  .c3_s1_axi_araddr                (m00_axi_araddr  ),
	  .c3_s1_axi_arlen                 (m00_axi_arlen   ),
	  .c3_s1_axi_arsize                (m00_axi_arsize  ),
	  .c3_s1_axi_arburst               (m00_axi_arburst ),
	  .c3_s1_axi_arlock                (m00_axi_arlock  ),
	  .c3_s1_axi_arcache               (m00_axi_arcache ),
	  .c3_s1_axi_arprot                (m00_axi_arprot  ),
	  .c3_s1_axi_arqos                 (m00_axi_arqos   ),
	  .c3_s1_axi_arvalid               (m00_axi_arvalid ),
	  .c3_s1_axi_arready               (m00_axi_arready ),
	                                                    
	  .c3_s1_axi_rid                   (m00_axi_rid     ),
	  .c3_s1_axi_rdata                 (m00_axi_rdata   ),
	  .c3_s1_axi_rresp                 (m00_axi_rresp   ),
	  .c3_s1_axi_rlast                 (m00_axi_rlast   ),
	  .c3_s1_axi_rvalid                (m00_axi_rvalid  ),
	  .c3_s1_axi_rready                (m00_axi_rready  ),
	                                   
	  .c3_s2_axi_aclk                  (m01_axi_raclk   ),
	  .c3_s2_axi_aresetn               (m01_axi_raresetn),
	                                   
	  .c3_s2_axi_awid                  (1'b0 ),
	  .c3_s2_axi_awaddr                (32'b0),
	  .c3_s2_axi_awlen                 (8'b0 ),
	  .c3_s2_axi_awsize                (3'b0 ),
	  .c3_s2_axi_awburst               (2'b0 ),
	  .c3_s2_axi_awlock                (1'b0 ),
	  .c3_s2_axi_awcache               (4'b0 ),
	  .c3_s2_axi_awprot                (3'b0 ),
	  .c3_s2_axi_awqos                 (4'b0 ),
	  .c3_s2_axi_awvalid               (1'b0 ),
	  .c3_s2_axi_awready               (     ),
	                                         
	  .c3_s2_axi_wdata                 (32'b0),
	  .c3_s2_axi_wstrb                 (4'b0 ),
	  .c3_s2_axi_wlast                 (1'b0 ),
	  .c3_s2_axi_wvalid                (1'b0 ),
	  .c3_s2_axi_wready                (     ),
	                                         
	  .c3_s2_axi_bid                   (     ),
	  .c3_s2_axi_bresp                 (     ),
	  .c3_s2_axi_bvalid                (     ),
	  .c3_s2_axi_bready                (1'b0 ),
	                                   
	  .c3_s2_axi_wid                   (),
	                                   
	  .c3_s2_axi_arid                  (m01_axi_arid    ),
	  .c3_s2_axi_araddr                (m01_axi_araddr  ),
	  .c3_s2_axi_arlen                 (m01_axi_arlen   ),
	  .c3_s2_axi_arsize                (m01_axi_arsize  ),
	  .c3_s2_axi_arburst               (m01_axi_arburst ),
	  .c3_s2_axi_arlock                (m01_axi_arlock  ),
	  .c3_s2_axi_arcache               (m01_axi_arcache ),
	  .c3_s2_axi_arprot                (m01_axi_arprot  ),
	  .c3_s2_axi_arqos                 (m01_axi_arqos   ),
	  .c3_s2_axi_arvalid               (m01_axi_arvalid ),
	  .c3_s2_axi_arready               (m01_axi_arready ),
	                                   
	  .c3_s2_axi_rid                   (m01_axi_rid     ),
	  .c3_s2_axi_rdata                 (m01_axi_rdata   ),
	  .c3_s2_axi_rresp                 (m01_axi_rresp   ),
	  .c3_s2_axi_rlast                 (m01_axi_rlast   ),
	  .c3_s2_axi_rvalid                (m01_axi_rvalid  ),
	  .c3_s2_axi_rready                (m01_axi_rready  ),
	                                   
	  .c3_s3_axi_aclk                  (m02_axi_raclk   ),
	  .c3_s3_axi_aresetn               (m02_axi_raresetn),
	                                   
	  .c3_s3_axi_awid                  (1'b0 ),
	  .c3_s3_axi_awaddr                (32'b0),
	  .c3_s3_axi_awlen                 (8'b0 ),
	  .c3_s3_axi_awsize                (3'b0 ),
	  .c3_s3_axi_awburst               (2'b0 ),
	  .c3_s3_axi_awlock                (1'b0 ),
	  .c3_s3_axi_awcache               (4'b0 ),
	  .c3_s3_axi_awprot                (3'b0 ),
	  .c3_s3_axi_awqos                 (4'b0 ),
	  .c3_s3_axi_awvalid               (1'b0 ),
	  .c3_s3_axi_awready               (     ),
	                                         
	  .c3_s3_axi_wdata                 (32'b0),
	  .c3_s3_axi_wstrb                 (4'b0 ),
	  .c3_s3_axi_wlast                 (1'b0 ),
	  .c3_s3_axi_wvalid                (1'b0 ),
	  .c3_s3_axi_wready                (     ),
	                                         
	  .c3_s3_axi_bid                   (     ),
	  .c3_s3_axi_bresp                 (     ),
	  .c3_s3_axi_bvalid                (     ),
	  .c3_s3_axi_bready                (1'b0 ),
	                                   
	  .c3_s3_axi_wid                   (),
	                                   
	  .c3_s3_axi_arid                  (m02_axi_arid    ),
	  .c3_s3_axi_araddr                (m02_axi_araddr  ),
	  .c3_s3_axi_arlen                 (m02_axi_arlen   ),
	  .c3_s3_axi_arsize                (m02_axi_arsize  ),
	  .c3_s3_axi_arburst               (m02_axi_arburst ),
	  .c3_s3_axi_arlock                (m02_axi_arlock  ),
	  .c3_s3_axi_arcache               (m02_axi_arcache ),
	  .c3_s3_axi_arprot                (m02_axi_arprot  ),
	  .c3_s3_axi_arqos                 (m02_axi_arqos   ),
	  .c3_s3_axi_arvalid               (m02_axi_arvalid ),
	  .c3_s3_axi_arready               (m02_axi_arready ),
	                                   
	  .c3_s3_axi_rid                   (m02_axi_rid     ),
	  .c3_s3_axi_rdata                 (m02_axi_rdata   ),
	  .c3_s3_axi_rresp                 (m02_axi_rresp   ),
	  .c3_s3_axi_rlast                 (m02_axi_rlast   ),
	  .c3_s3_axi_rvalid                (m02_axi_rvalid  ),
	  .c3_s3_axi_rready                (m02_axi_rready  )
	);
	*/


endmodule
