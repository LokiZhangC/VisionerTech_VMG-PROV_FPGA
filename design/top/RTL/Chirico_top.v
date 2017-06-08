`timescale 1ps / 1ps
//================================================================================ 
// File Name      : Chirico_top.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : Chirico_top
// Target Devices : XC6SLX45-2CSG324
// Tool versions  : ISE 13.4 (64-bit)
//--------------------------------------------------------------------------------
// Description    : 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================
module Chirico_top
#(
  parameter  C_BAYER_FORMAT            = 2'b00  ,//'00'=GR,'01'=RG,'10'=BG,'11'=GB
	parameter  C_BAYER2RGB_RAM_ADDR_BITS = 4'd11  ,	
	parameter  C_SENSOR_DATA_WIDTH       = 10'd12 ,
	parameter  C_HDMI_DATA_WIDTH         = 10'd30 ,
	parameter  C_DATA_WIDTH              = 3*C_SENSOR_DATA_WIDTH,
	
	//DDR3
  parameter  C3_P0_MASK_SIZE                 = 4                ,
  parameter  C3_P0_DATA_PORT_SIZE            = 32               ,
  parameter  C3_P1_MASK_SIZE                 = 4                ,
  parameter  C3_P1_DATA_PORT_SIZE            = 32               ,
  parameter  DEBUG_EN                        = 0                ,
  parameter  C3_MEMCLK_PERIOD                = 3000             ,
  parameter  C3_CALIB_SOFT_IP                = "TRUE"           ,
  parameter  C3_SIMULATION                   = "FALSE"          ,
  parameter  C3_RST_ACT_LOW                  = 0                ,
  parameter  C3_INPUT_CLK_TYPE               = "SINGLE_ENDED"   ,
  parameter  C3_MEM_ADDR_ORDER               = "ROW_BANK_COLUMN",
  parameter  C3_NUM_DQ_PINS                  = 16               ,
  parameter  C3_MEM_ADDR_WIDTH               = 13               ,
  parameter  C3_MEM_BANKADDR_WIDTH           = 3                ,
  parameter  C3_S0_AXI_STRICT_COHERENCY      = 0                ,
  parameter  C3_S0_AXI_ENABLE_AP             = 1                ,
  parameter  C3_S0_AXI_DATA_WIDTH            = 32               ,
  parameter  C3_S0_AXI_SUPPORTS_NARROW_BURST = 1                ,
  parameter  C3_S0_AXI_ADDR_WIDTH            = 32               ,
  parameter  C3_S0_AXI_ID_WIDTH              = 1                ,
  parameter  C3_S1_AXI_STRICT_COHERENCY      = 0                ,
  parameter  C3_S1_AXI_ENABLE_AP             = 1                ,
  parameter  C3_S1_AXI_DATA_WIDTH            = 32               ,
  parameter  C3_S1_AXI_SUPPORTS_NARROW_BURST = 1                ,
  parameter  C3_S1_AXI_ADDR_WIDTH            = 32               ,
  parameter  C3_S1_AXI_ID_WIDTH              = 1                ,
  parameter  C3_S2_AXI_STRICT_COHERENCY      = 0                ,
  parameter  C3_S2_AXI_ENABLE_AP             = 1                ,
  parameter  C3_S2_AXI_DATA_WIDTH            = 32               ,
  parameter  C3_S2_AXI_SUPPORTS_NARROW_BURST = 1                ,
  parameter  C3_S2_AXI_ADDR_WIDTH            = 32               ,
  parameter  C3_S2_AXI_ID_WIDTH              = 1                ,
  parameter  C3_S3_AXI_STRICT_COHERENCY      = 0                ,
  parameter  C3_S3_AXI_ENABLE_AP             = 1                ,
  parameter  C3_S3_AXI_DATA_WIDTH            = 32               ,
  parameter  C3_S3_AXI_SUPPORTS_NARROW_BURST = 1                ,
  parameter  C3_S3_AXI_ADDR_WIDTH            = 32               ,
  parameter  C3_S3_AXI_ID_WIDTH              = 1                
	
)
(
  // system signal
  input  wire                           OCS_CLK       ,
  input  wire [ 4:0]                    BNT           ,
  output wire [ 1:0]                    LED           ,
  output wire [ 5:0]                    test_pin      ,
  
  // sensor rx                          
	output wire                           SENSOR_RESET_N,
	output wire			                      SCL           ,
	inout	 wire		                        SDA           ,
	
	input  wire                           SENSOR_PCLK   ,
	input  wire                           SENSOR_VS     ,
	input  wire                           SENSOR_HS     ,
	input  wire [C_SENSOR_DATA_WIDTH-1:0] SENSOR_D      ,
	
	input  wire                           sensor_clk_p,
	input  wire                           sensor_clk_n,
	input  wire [3:0]                     sensor_d_p ,
	input  wire [3:0]                     sensor_d_n ,
	
	//uart_rx
	input  wire                           uart_rx,
	
  // cy3014
  input  wire                           cy3014_reset  , 
  output wire [31:0]                    fdata         , 
  output wire [1:0]                     faddr         , 
  output wire                           slrd          ,  
  output wire                           slwr          ,  
  input  wire                           flagb         , 
  input  wire                           flaga         , 
  output wire                           clk_out       , 
  output wire                           sloe          ,
  output wire                           slcs          ,
  output wire                           pktend        ,
                                        
  //DDR3                                
  inout  [C3_NUM_DQ_PINS-1:0]           mcb3_dram_dq     ,
  output [C3_MEM_ADDR_WIDTH-1:0]        mcb3_dram_a      ,
  output [C3_MEM_BANKADDR_WIDTH-1:0]    mcb3_dram_ba     ,
  output                                mcb3_dram_ras_n  ,
  output                                mcb3_dram_cas_n  ,
  output                                mcb3_dram_we_n   ,
  output                                mcb3_dram_odt    ,
  output                                mcb3_dram_reset_n,
  output                                mcb3_dram_cke    ,
  output                                mcb3_dram_dm     ,
  inout                                 mcb3_dram_udqs   ,
  inout                                 mcb3_dram_udqs_n ,
  output                                mcb3_dram_udm    ,
  inout                                 mcb3_dram_dqs    ,
  inout                                 mcb3_dram_dqs_n  ,
  output                                mcb3_dram_ck     ,
  output                                mcb3_dram_ck_n   ,
  inout                                 mcb3_rzq         ,
  inout                                 mcb3_zio         
  
) ;

	// =============================================================================
	// Internal signal
	// =============================================================================
	
	localparam   C_I2C_CLK_FREQ           = 100_000;//KHz
	localparam   C_I2C_FREQ               = 200    ;//KHz
	localparam   C_I2C_HDMI_DATA_WIDTH    = 10'd8  ;
	localparam   C_I2C_HDMI_ADDR_WIDTH    = 10'd8  ;
	localparam   C_I2C_SENSOR_DATA_WIDTH  = 10'd16 ;
	localparam   C_I2C_SENSOR_SADDR_WIDTH = 10'd8  ;
	localparam   C_I2C_SENSOR_BADDR_WIDTH = 10'd16 ;
	
	reg                                 hdmi_vs ; 
	reg                                 hdmi_hs ; 
	reg                                 hdmi_de ;
	reg  [15:0]                         hdmi_d  ; 
	                                    
	wire                                powerup_wait_done;
	                                    
	wire                                clk_333m;
	wire                                clk_100m;
	wire                                clk_75m;
	wire                                clk_75m_o;
	wire                                sensor_pclk_in;
	wire                                sensor_pclk_in_2;
	wire                                sensor_pclk_148_5m;
	wire                                mcb_clk_150m;
	
	wire                                pix_clk;
	wire                                pix_clk_sensor;
	wire                                pix_clk_2;
	wire                                mcb_port_clk;
	                                    
	wire                                pll0_locked;
	wire                                pll1_locked;
	wire                                pll2_locked;
	wire                                reset      ;
	
	reg  [15:0]                         reset_t;
	reg  [15:0]                         c3_sys_rst_t;
	reg  [15:0]                         init_sensor_reset_t;
	wire                                init_sensor_reset;
	
	wire                                db_data_addr_in_value ;
	wire[C_I2C_SENSOR_DATA_WIDTH -1:0]  db_data_in            ;
	wire[C_I2C_SENSOR_SADDR_WIDTH-1:0]  db_slave_addr_in      ;
	wire[C_I2C_SENSOR_BADDR_WIDTH-1:0]  db_base_addr_in       ;
                                                
	wire                                db_data_addr_out_value;
	wire[C_I2C_SENSOR_DATA_WIDTH -1:0]  db_data_out           ;
	wire[C_I2C_SENSOR_SADDR_WIDTH-1:0]  db_slave_addr_out     ;
	wire[C_I2C_SENSOR_BADDR_WIDTH-1:0]  db_base_addr_out      ;
                                                
	wire                                db_i2c_busy           ;
	wire                                db_i2c_done           ;
	wire                                db_error              ;
	wire[2:0]                           db_error_code         ;       
                                                            
	wire                                db_sda_sa             ;
	wire                                db_sda_ba             ;
	wire                                db_sda_d              ;
	wire                                db_sda_t_acko         ;
	wire                                db_sda_t_reado        ;
	wire                                Chip_Revision_get     ;
	wire                                avd7511_HPD           ;
	                                    
	wire                                reset_n_5ms;
	                                    
	wire                                sda_i;
	wire                                sda_o;
	wire                                sda_t;
	wire                                sensor_sda_i;
	wire                                sensor_sda_o;
	wire                                sensor_sda_t;
	wire			                          SENSOR_SCL;
	                                    
	wire                                sensor_cfg_done;
	wire [1:0]                          bmd_flag;
	
	wire                                vcm_sda_i;
	wire                                vcm_sda_o;
	wire                                vcm_sda_t;
	                                    
	wire                                c3_sys_clk    ;
  wire                                c3_sys_rst_i  ;
  wire                                c3_calib_done ;
  
	wire                                sensor_vs_out     ;
	wire                                sensor_hs_out     ;
	wire                                sensor_de_out     ;
	wire [C_SENSOR_DATA_WIDTH-1:0]      sensor_data_out   ;
  
  reg                                 fb_VS_in  ;
	reg                                 fb_HS_in  ;
	reg                                 fb_DE_in  ;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_in;
	
	wire                                fb_rd_VS_in ;
	wire                                fb_rd_HS_in ;
	wire                                fb_rd_DE_in ;
	wire                                fb_VS_out   ;
	wire                                fb_HS_out   ;
	wire                                fb_DE_out   ;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_out1;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_out2;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_out3;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_out4;
	wire [C_SENSOR_DATA_WIDTH+4-1:0]    fb_data_out5;
	
	wire                                bmd_VS_in   ;
	wire                                bmd_HS_in   ;
	wire                                bmd_DE_in   ;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_data1_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_data2_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_data3_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_data4_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_data5_in;
	
	wire                                bmd_VS_out   ;
	wire                                bmd_HS_out   ;
	wire                                bmd_DE_out   ;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_dataBH_out;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_dataBL_out;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_dataM_out ;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_dataDH_out;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bmd_dataDL_out;
	
	wire                                bayer2rgb_VS_out_t  ;
	wire                                bayer2rgb_HS_out_t  ;
	wire                                bayer2rgb_DE_out_t  ;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_data_out_t;
	
	wire                                wb0_VS_in  ;
	wire                                wb0_HS_in  ;
	wire                                wb0_DE_in  ;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb0_data_in;

	reg                                 wb0_VS_out  ;
	reg                                 wb0_HS_out  ;
	reg                                 wb0_DE_out  ;
	wire [7:0]                          wb0_dataR_out;
	reg  [7:0]                          wb0_dataG_out;
	wire [7:0]                          wb0_dataB_out;
	wire [29:0]                         wb0_data_out;
	
	wire                                bayer2rgb_VS_in   ;
	wire                                bayer2rgb_HS_in   ;
	wire                                bayer2rgb_DE_in   ;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bayer2rgb_dataBH_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bayer2rgb_dataBL_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bayer2rgb_dataM_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bayer2rgb_dataDH_in;
	wire [C_SENSOR_DATA_WIDTH-1-2:0]    bayer2rgb_dataDL_in;
	
	wire                                bayer2rgb_VS_out   ;
	wire                                bayer2rgb_HS_out   ;
	wire                                bayer2rgb_DE_out   ;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_dataBH_out;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_dataBL_out;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_dataM_out;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_dataDH_out;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]bayer2rgb_dataDL_out;
	
	wire                                wb_VS_in   ;
	wire                                wb_HS_in   ;
	wire                                wb_DE_in   ;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb_dataBH_in;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb_dataBL_in;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb_dataM_in;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb_dataDH_in;
	wire [3*(C_SENSOR_DATA_WIDTH-2)-1:0]wb_dataDL_in;
	
	reg                                 wb_VS_out   ;
	reg                                 wb_HS_out   ;
	reg                                 wb_DE_out   ;
	wire [7:0]                          wb_dataBHR_out;
	reg  [7:0]                          wb_dataBHG_out;
	wire [7:0]                          wb_dataBHB_out;
	wire [29:0]                         wb_dataBH_out;
	
	wire [7:0]                          wb_dataBLR_out;
	reg  [7:0]                          wb_dataBLG_out;
	wire [7:0]                          wb_dataBLB_out;
	wire [29:0]                         wb_dataBL_out;
	
	wire [7:0]                          wb_dataMR_out;
	reg  [7:0]                          wb_dataMG_out;
	wire [7:0]                          wb_dataMB_out;
	wire [29:0]                         wb_dataM_out;
	
	wire [7:0]                          wb_dataDHR_out;
	reg  [7:0]                          wb_dataDHG_out;
	wire [7:0]                          wb_dataDHB_out;
	wire [29:0]                         wb_dataDH_out;
	
	wire [7:0]                          wb_dataDLR_out;
	reg  [7:0]                          wb_dataDLG_out;
	wire [7:0]                          wb_dataDLB_out;
	wire [29:0]                         wb_dataDL_out;
	
	wire                                rgb2hsv_VS_in   ;
	wire                                rgb2hsv_HS_in   ;
	wire                                rgb2hsv_DE_in   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        rgb2hsv_data_in ;
	
	wire                                rgb2hsv_VS_out   ;
	wire                                rgb2hsv_HS_out   ;
	wire                                rgb2hsv_DE_out   ;
	wire [40:0]                         rgb2hsv_data_out ;
	
	reg                                 hsv2rgb_VS_in   ;
	reg                                 hsv2rgb_HS_in   ;
	reg                                 hsv2rgb_DE_in   ;
	reg  [40:0]                         hsv2rgb_data_in ;
	
	wire                                hsv2rgb_VS_out   ;
	wire                                hsv2rgb_HS_out   ;
	wire                                hsv2rgb_DE_out   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        hsv2rgb_data_out ;
	
	wire                                his_VS_in   ;
	wire                                his_HS_in   ;
	wire                                his_DE_in   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataB_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataM_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataD_in;
	
	wire                                his_VS_out   ;
	wire                                his_HS_out   ;
	wire                                his_DE_out   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataB_out;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataM_out;
	wire [C_HDMI_DATA_WIDTH-1:0]        his_dataD_out;
	
	wire                                hdr_VS_in   ;
	wire                                hdr_HS_in   ;
	wire                                hdr_DE_in   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_dataBH_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_dataBL_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_dataM_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_dataDH_in;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_dataDL_in;
	
	wire                                hdr_VS_out   ;
	wire                                hdr_HS_out   ;
	wire                                hdr_DE_out   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_data1_out;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_data2_out;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_data3_out;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_data4_out;
	
	wire                                hdr_F4f_VS_out   ;
	wire                                hdr_F4f_HS_out   ;
	wire                                hdr_F4f_DE_out   ;
	wire [C_HDMI_DATA_WIDTH-1:0]        hdr_F4f_data_out ;
	
	wire                                front_bnt_star ;
	wire                                front_bnt_end  ;
	wire                                front_bnt_valid;
	wire                                back_bnt_star;
	wire                                back_bnt_end;
	wire                                back_bnt_valid;
	wire                                middle_bnt_star;
	wire                                middle_bnt_end;
	wire                                middle_bnt_valid;
	wire                                up_bnt_star;
	wire                                up_bnt_end;
	wire                                up_bnt_valid;
	wire                                down_bnt_star;
	wire                                down_bnt_end;
	wire                                down_bnt_valid;
	reg                                 mid_bnt_inversion;
	reg                                 up_bnt_inversion;
	reg                                 down_bnt_inversion;
	reg                                 front_bnt_inversion;
	reg                                 back_bnt_inversion;
	
	wire [63:0]                         key_code;
	
	wire                                hdr_sel;
	
	wire                                ae_vs_out ;
	wire                                ae_vs_in  ;
	wire                                ae_hs_in  ;
	wire                                ae_de_in  ;
	wire [7:0]                          ae_data_in;
	wire                                hdr_ae_vs_in  ;
	wire                                hdr_ae_hs_in  ;
	wire                                hdr_ae_de_in  ;
	wire [7:0]                          hdr_ae_data_in;
	
	wire                                cfg0_data_valid_o;
	wire [15:0]                         cfg0_data_IT_o   ;
	wire [15:0]                         cfg0_data_AG_o   ;
	wire                                cfg1_data_valid_o;
	wire [15:0]                         cfg1_data_IT_o   ;
	wire [15:0]                         cfg1_data_AG_o   ;
	wire                                cfg2_data_valid_o;
	wire [15:0]                         cfg2_data_IT_o   ;
	wire [15:0]                         cfg2_data_AG_o   ;
	wire                                cfg3_data_valid_o;
	wire [15:0]                         cfg3_data_IT_o   ;
	wire [15:0]                         cfg3_data_AG_o   ;
	
	wire                                cfg0_data_valid;
	wire [15:0]                         cfg0_data_IT  ;
	wire [15:0]                         cfg0_data_AG  ;
	wire                                cfg1_data_valid;
	wire [15:0]                         cfg1_data_IT  ;
	wire [15:0]                         cfg1_data_AG  ;
	wire                                cfg2_data_valid;
	wire [15:0]                         cfg2_data_IT  ;
	wire [15:0]                         cfg2_data_AG  ;
	wire                                cfg3_data_valid;
	wire [15:0]                         cfg3_data_IT  ;
	wire [15:0]                         cfg3_data_AG  ;
	                                    
	wire [9:0]                          douta;
  reg  [4:0]                          rd_port_en;
	wire                                hdr4f_VS_in    ;
	wire                                hdr4f_HS_in    ;
	wire                                hdr4f_DE_in    ;
	wire [23:0]                         hdr4f_dataBH_in;
	wire [23:0]                         hdr4f_dataBL_in;
	wire [23:0]                         hdr4f_dataM_in ;
	wire [23:0]                         hdr4f_dataDH_in;
	                                    
	wire                                rgb2ycbcr_VS_in   ;
	wire                                rgb2ycbcr_HS_in   ;
	wire                                rgb2ycbcr_DE_in   ;
	wire [29:0]                         rgb2ycbcr_data_in ;
	                                    
	wire                                rgb2ycbcr_VS_out   ;
	wire                                rgb2ycbcr_HS_out   ;
	wire                                rgb2ycbcr_DE_out   ;
	wire [29:0]                         rgb2ycbcr_data_out ;   
	                                    
	wire                                nr_VS_in   ;
	wire                                nr_HS_in   ;
	wire                                nr_DE_in   ;
	wire [23:0]                         nr_data_in ;
	                                    
	wire                                nr_VS_out   ;
	wire                                nr_HS_out   ;
	wire                                nr_DE_out   ;
	wire [23:0]                         nr_data_out ;
	                                    
	wire                                YCbCr2YC_VS_in   ;
	wire                                YCbCr2YC_HS_in   ;
	wire                                YCbCr2YC_DE_in   ;
	wire [29:0]                         YCbCr2YC_data_in ;
	                                    
	wire                                YCbCr2YC_VS_out   ;
	wire                                YCbCr2YC_HS_out   ;
	wire                                YCbCr2YC_DE_out   ;
	wire [19:0]                         YCbCr2YC_data_out ;
	                                    
	wire                                wb0_VS_t1  ; 
	wire                                wb0_HS_t1  ; 
	wire                                wb0_DE_t1  ; 
	wire [19:0]                         wb0_data_t1;
	
	wire                                wb0_VS_t2  ; 
	wire                                wb0_HS_t2  ; 
	wire                                wb0_DE_t2  ; 
	wire [19:0]                         wb0_data_t2;
	                                    
	wire                                mux_vs_o  ;
	wire                                mux_hs_o  ;
	wire                                mux_de_o  ;
	wire [19:0]                         mux_data_o;
	
	wire                                hs_pix_clk ;
	wire                                hs_pix_clk_2;
	wire                                hs_reset;
	wire                                hs_ae_vs_out;
	wire                                hs_vs_out  ;
	wire                                hs_hs_out  ;
	wire                                hs_de_out  ;
	wire [11:0]                         hs_data_out;
	
	wire                                imu_vs  ; 
	wire                                imu_hs  ; 
	wire                                imu_de  ; 
	wire [15:0]                         imu_data;
	
	wire  [5:0]                         hs_db1  ;
	wire                                hs_db2  ;
	
	wire [6:0]                          his_db;

	// =============================================================================
	// RTL Body
	// =============================================================================
	mcb_clk 
	u_mcb_clk
  (
  	// Clock in ports
    .CLK_IN1 (OCS_CLK    ),
    // Clock out ports   
    .CLK_OUT1(clk_333m   ),
    .CLK_OUT2(clk_100m   ),
    // Status and control signals
    .LOCKED  (pll0_locked)
  );
  
  sensor_clk 
  u_sensor_clk
  (	
  	// Clock in ports
    .CLK_IN1 (SENSOR_PCLK     ),
    .RESET   (~pll0_locked    ),
    // Clock out ports
    .CLK_OUT1(sensor_pclk_in  ),
    .CLK_OUT2(sensor_pclk_in_2 ),
    // Status and control signals
    .LOCKED  (pll1_locked     )
  );
  
  assign sensor_sda_i = sda_i;
	assign sda_t        = sensor_sda_t;
	assign sda_o        = sensor_sda_o;
	
	assign sda_i = SDA;
	assign SDA   = (sda_t) ? 1'bz : sda_o;
	assign SCL   = SENSOR_SCL;
	
	assign c3_sys_clk     = clk_333m;
	assign pix_clk_sensor = sensor_pclk_in;  
	assign pix_clk        = sensor_pclk_in;  
	assign pix_clk_2      = sensor_pclk_in_2;
	assign mcb_port_clk   = sensor_pclk_in;  
	assign LED[0] = c3_calib_done;
	assign LED[1] = pll1_locked;
	assign test_pin[5] = hs_db1[5];
	assign test_pin[0] = his_db[0];
	assign test_pin[1] = his_db[1];
	assign test_pin[2] = his_db[4];
	assign test_pin[3] = his_db[5];
	assign test_pin[4] = his_db[6];
	
	assign c3_sys_rst_i = c3_sys_rst_t[15];
	assign reset        = reset_t[15];
	assign init_sensor_reset = init_sensor_reset_t[15];
	
	always@(posedge mcb_port_clk)
	begin
		c3_sys_rst_t        <= {c3_sys_rst_t[14:0],~sensor_cfg_done | ~cy3014_reset};
	end
	
	always@(posedge clk_100m)
	begin
		reset_t             <= {reset_t[14:0],~sensor_cfg_done | ~c3_calib_done | ~cy3014_reset};
		init_sensor_reset_t <= {init_sensor_reset_t[14:0],~powerup_wait_done | ~cy3014_reset};
	end
	
	assign key_code = {24'd0,{8{back_bnt_valid}},{8{front_bnt_valid}},
	                  {8{middle_bnt_valid}},{8{down_bnt_valid}},{8{up_bnt_valid}}};
	
	bnt_process
	#(
		.C_CLK_FREQ    (100_000),//KHz
		.C_SAMPLE_TIME (300    ) //ms
	)
	u_bnt_front
	(
	  // system signal
	  .clk           (clk_100m ),//
	  .reset         (~pll0_locked),
	  .bnt           (BNT[0]   ),
	  .bnt_star      (front_bnt_star ),
		.bnt_end       (front_bnt_end  ),
		.bnt_valid     (front_bnt_valid)
	);
	
	bnt_process
	#(
		.C_CLK_FREQ    (100_000),//KHz
		.C_SAMPLE_TIME (300    ) //ms
	)
	u_bnt_back
	(
	  // system signal
	  .clk           (clk_100m ),//
	  .reset         (~pll0_locked),
	  .bnt           (BNT[1]   ),
	  .bnt_star      (back_bnt_star ),
		.bnt_end       (back_bnt_end  ),
		.bnt_valid     (back_bnt_valid)
	);
	
	bnt_process
	#(
		.C_CLK_FREQ    (100_000),//KHz
		.C_SAMPLE_TIME (300    ) //ms
	)
	u_bnt_middle
	(
	  // system signal
	  .clk           (clk_100m ),//
	  .reset         (~pll0_locked),
	  .bnt           (BNT[2]   ),
	  .bnt_star      (middle_bnt_star ),
		.bnt_end       (middle_bnt_end  ),
		.bnt_valid     (middle_bnt_valid)
	);
	
	bnt_process
	#(
		.C_CLK_FREQ    (100_000),//KHz
		.C_SAMPLE_TIME (300    ) //ms
	)
	u_bnt_up 
	(
	  // system signal
	  .clk           (clk_100m ),//
	  .reset         (~pll0_locked),
	  .bnt           (BNT[3]   ),
	  .bnt_star      (up_bnt_star ),
		.bnt_end       (up_bnt_end  ),
		.bnt_valid     (up_bnt_valid)
	);
	
	bnt_process
	#(
		.C_CLK_FREQ    (100_000),//KHz
		.C_SAMPLE_TIME (300    ) //ms
	)
	u_bnt_down
	(
	  // system signal
	  .clk           (clk_100m ),//
	  .reset         (~pll0_locked),
	  .bnt           (BNT[4]   ),
	  .bnt_star      (down_bnt_star ),
		.bnt_end       (down_bnt_end  ),
		.bnt_valid     (down_bnt_valid)
	);
	
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			mid_bnt_inversion <= 1'b0;
		end
		else if(middle_bnt_star)
		begin
			mid_bnt_inversion <= ~mid_bnt_inversion;
		end
	end
	
	reg [1:0] middle_bnt_star_cnt;
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			middle_bnt_star_cnt <= 2'b00;
		end
		else if(middle_bnt_star)
		begin
			if(middle_bnt_star_cnt == 2'b10)
			begin
				middle_bnt_star_cnt <= 2'b00;
			end
			else
			begin
				middle_bnt_star_cnt <= middle_bnt_star_cnt + 1'b1;
			end			
		end
	end
	
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			up_bnt_inversion <= 0;
		end
		else if(up_bnt_star)
		begin
			up_bnt_inversion <= ~up_bnt_inversion;
		end
	end
	
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			down_bnt_inversion <= 0;
		end
		else if(down_bnt_star)
		begin
			down_bnt_inversion <= ~down_bnt_inversion;
		end
	end
	
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			front_bnt_inversion <= 1'b0;
		end
		else if(front_bnt_star)
		begin
			front_bnt_inversion <= ~front_bnt_inversion;
		end
	end
	
	always@(posedge clk_100m or negedge pll0_locked)
	begin
		if(~pll0_locked)	
		begin
			back_bnt_inversion <= 0;
		end
		else if(back_bnt_star)
		begin
			back_bnt_inversion <= ~back_bnt_inversion;
		end
	end
	
	powerUp_sequence
	#(
		.C_CLK_FREQ        (100_000          ) //KHz
	)
	u_powerUp_sequence
	(
		.clk               (clk_100m         ),//100MHz
		.reset             (~pll0_locked     ),

		.reset_1           (powerup_wait_done),//210ms
		.reset_2           (reset_n_5ms      ) //5ms

	);
	
	ae_signal
	#(
	  .C_DATA_WIDTH   (8)
	)
  u_ae_signal
  (
		.reset    (reset                ), 
		.pix_clk  (pix_clk              ), 
		.vs_in    (ae_vs_out            ), 
		.hs_in    (sensor_hs_out        ), 
		.de_in    (sensor_de_out        ), 
		.data_in  (sensor_data_out[11:4]), 
		.vs_out   (ae_vs_in             ), 
		.hs_out   (ae_hs_in             ), 
		.de_out   (ae_de_in             ), 
		.data_out (ae_data_in           )
	);
	
	hdr_ae_signal
	#(
	  .C_DATA_WIDTH   (8)
	)
	u_hdr_ae_signal
	(
	  // system signal
	  .reset          (reset  ),
	  .pix_clk        (pix_clk),
	  // data input
	  .vs_in          (ae_vs_in  ),
	  .hs_in          (ae_hs_in  ),
	  .de_in          (ae_de_in  ),
	  .data_in        (ae_data_in), 
	  // data output
	  .vs_out         (hdr_ae_vs_in  ),
	  .hs_out         (hdr_ae_hs_in  ),
	  .de_out         (hdr_ae_de_in  ),
	  .data_out       (hdr_ae_data_in)
	);
	
	auto_exposure
	#(
		.C_DATA_WIDTH     (8)
	)
  u_auto_exposure
  (
		.reset          (reset          ), 
		.clk            (clk_100m       ), 
		.pix_clk        (pix_clk        ), 
		.vs_in          (hdr_ae_vs_in   ), 
		.hs_in          (hdr_ae_hs_in   ), 
		.de_in          (hdr_ae_de_in   ), 
		.data_in        (hdr_ae_data_in ),
		.ref_bri_up     (up_bnt_valid   ),
		.ref_bri_down   (down_bnt_valid   ),
		.cfg0_data_valid(cfg0_data_valid_o), 
		.cfg0_data_IT   (cfg0_data_IT_o   ), 
		.cfg0_data_AG   (cfg0_data_AG_o   ), 
		.cfg1_data_valid(cfg1_data_valid_o), 
		.cfg1_data_IT   (cfg1_data_IT_o   ), 
		.cfg1_data_AG   (cfg1_data_AG_o   ), 
		.cfg2_data_valid(cfg2_data_valid_o), 
		.cfg2_data_IT   (cfg2_data_IT_o   ), 
		.cfg2_data_AG   (cfg2_data_AG_o   ), 
		.cfg3_data_valid(cfg3_data_valid_o), 
		.cfg3_data_IT   (cfg3_data_IT_o   ), 
		.cfg3_data_AG   (cfg3_data_AG_o   )
	);
	
	assign cfg0_data_valid = (hdr_sel) ? cfg0_data_valid_o: cfg1_data_valid_o;
	assign cfg0_data_IT    = (hdr_sel) ? cfg0_data_IT_o   : cfg1_data_IT_o   ;
	assign cfg0_data_AG    = (hdr_sel) ? cfg0_data_AG_o   : cfg1_data_AG_o   ;
	assign cfg1_data_valid = cfg1_data_valid_o;
	assign cfg1_data_IT    = cfg1_data_IT_o   ;
	assign cfg1_data_AG    = cfg1_data_AG_o   ;
	assign cfg2_data_valid = (hdr_sel) ? cfg2_data_valid_o: cfg1_data_valid_o;
	assign cfg2_data_IT    = (hdr_sel) ? cfg2_data_IT_o   : cfg1_data_IT_o   ;
	assign cfg2_data_AG    = (hdr_sel) ? cfg2_data_AG_o   : cfg1_data_AG_o   ;
	assign cfg3_data_valid = (hdr_sel) ? cfg3_data_valid_o: cfg1_data_valid_o;
	assign cfg3_data_IT    = (hdr_sel) ? cfg3_data_IT_o   : cfg1_data_IT_o   ;
	assign cfg3_data_AG    = (hdr_sel) ? cfg3_data_AG_o   : cfg1_data_AG_o   ;
	
	init_sensor_phy
	#
	(
		.C_CLK_FREQ             (C_I2C_CLK_FREQ          ),//KHz
		.C_I2C_FREQ             (C_I2C_FREQ              ),//KHz
		.C_DATA_WIDTH           (C_I2C_SENSOR_DATA_WIDTH ),
		.C_SADDR_WIDTH          (C_I2C_SENSOR_SADDR_WIDTH),
		.C_BADDR_WIDTH          (C_I2C_SENSOR_BADDR_WIDTH)
	)
	u_init_sensor_phy
	(
		.clk                    (clk_100m         ),
		.reset                  (init_sensor_reset),

		.SCL                    (SENSOR_SCL      ),
		.sda_i                  (sensor_sda_i    ),
		.sda_o                  (sensor_sda_o    ),
		.sda_t                  (sensor_sda_t    ),
		
		.sensor_vs              (sensor_vs_out   ),
		.BNT_valid              (BNT_valid_middle),
		.sensor_cfg_done        (sensor_cfg_done ),
		.bmd_flag               (bmd_flag        ),
		
		.cfg0_data_valid        (cfg0_data_valid ), 
		.cfg0_data_IT           (cfg0_data_IT    ), 
		.cfg0_data_AG           (cfg0_data_AG    ), 
		.cfg1_data_valid        (cfg1_data_valid ), 
		.cfg1_data_IT           (cfg1_data_IT    ), 
		.cfg1_data_AG           (cfg1_data_AG    ), 
		.cfg2_data_valid        (cfg2_data_valid ), 
		.cfg2_data_IT           (cfg2_data_IT    ), 
		.cfg2_data_AG           (cfg2_data_AG    ), 
		.cfg3_data_valid        (cfg3_data_valid ), 
		.cfg3_data_IT           (cfg3_data_IT    ), 
		.cfg3_data_AG           (cfg3_data_AG    ),


	  .db_data_addr_in_value  (db_data_addr_in_value  ),
	  .db_data_in             (db_data_in             ),
	  .db_slave_addr_in       (db_slave_addr_in       ),
	  .db_base_addr_in        (db_base_addr_in        ),
                                                    
	  .db_data_addr_out_value (db_data_addr_out_value ),
	  .db_data_out            (db_data_out            ),
	  .db_slave_addr_out      (db_slave_addr_out      ),
	  .db_base_addr_out       (db_base_addr_out       ),
                                                    
	  .db_i2c_busy            (db_i2c_busy            ),
	  .db_i2c_done            (db_i2c_done            ),
	  .db_error               (db_error               ),
	  .db_error_code          (db_error_code          ),       
                                                    
	  .db_sda_sa              (db_sda_sa              ),
	  .db_sda_ba              (db_sda_ba              ),
	  .db_sda_d               (db_sda_d               ),
	  .db_sda_t_acko          (db_sda_t_acko          ),
	  .db_sda_t_reado         (db_sda_t_reado         )
		
	);
	
	assign SENSOR_RESET_N = 1'b1;
	
	sensor_sync_signal_regen
	#(
	  .C_DATA_WIDTH     (C_SENSOR_DATA_WIDTH)
	)
	u_sensor_sync_signal_regen
	(
	  // System Signal
	  .reset            (reset           ),
	  .clk              (pix_clk_sensor  ), 
	  // video input                     
	  .vs_in            (SENSOR_VS       ),   
	  .hs_in            (SENSOR_HS       ), 
	  .data_in          (SENSOR_D        ), 
	                                     
	  // data out
	  .ae_vs_out        (ae_vs_out       ),
	  .vs_out           (sensor_vs_out   ), 
	  .hs_out           (sensor_hs_out   ), 
	  .de_out           (sensor_de_out   ), 
		.data_out         (sensor_data_out )  
	);  
	
	always @(posedge pix_clk_sensor or posedge reset)
  begin
  	if(reset)
  	begin
  		fb_VS_in <= 1'b1;
			fb_HS_in <= 1'b1;
			fb_DE_in <= 1'b0;
  	end
  	else
  	begin
  		fb_VS_in <= sensor_vs_out;
			fb_HS_in <= sensor_hs_out;
			fb_DE_in <= sensor_de_out;
  	end              
  end
	
	width_conv_12to10_rom 
	u_width_conv_12to10_rom 
	(
  	.clka (pix_clk_sensor ), // input clka
  	.addra(sensor_data_out), // input [11 : 0] addra
  	.douta(douta          )  // output [9 : 0] douta
	);
	
	assign fb_data_in = {douta,6'd0};
	
	assign fb_rd_VS_in = fb_VS_in;
	assign fb_rd_HS_in = fb_HS_in;
	assign fb_rd_DE_in = fb_DE_in;
	
	frames_buffer_mcb_top
	#(
	  // Users to add parameters here
		.C_DATA_WIDTH           (16               ),
		.C_ADDR_WIDTH           (30               ),
		.ADDR_NUM               (6                ),
		// User parameters ends
		// MCB parameters
		.C_MCB_W_BURST_LEN	    (32               ),
		.C_MCB_R_BURST_LEN	    (32               ),
		.Px_MASK_SIZE           (4                ),
		.Px_DATA_PORT_SIZE      (32               ),
		
		.C3_P0_MASK_SIZE        (4                ),
  	.C3_P0_DATA_PORT_SIZE   (32               ),
  	.C3_P1_MASK_SIZE        (4                ),
  	.C3_P1_DATA_PORT_SIZE   (32               ),
  	.DEBUG_EN               (0                ),       
  	.C3_MEMCLK_PERIOD       (3000             ),       
  	.C3_CALIB_SOFT_IP       ("TRUE"           ),       
  	.C3_SIMULATION          ("FALSE"          ),       
  	.C3_RST_ACT_LOW         (0                ),       
  	.C3_INPUT_CLK_TYPE      ("SINGLE_ENDED"   ),       
  	.C3_MEM_ADDR_ORDER      ("ROW_BANK_COLUMN"),       
  	.C3_NUM_DQ_PINS         (16               ),       
  	.C3_MEM_ADDR_WIDTH      (13               ),       
  	.C3_MEM_BANKADDR_WIDTH  (3                )       	  
	)            
	u_frames_buffer_mcb_top
	(
	  // system signal
	  .reset                  (reset            ),
	  .mcb_clk                (mcb_port_clk     ),
	  // data input
	  .pix_clk_wr             (pix_clk_sensor   ),
	  .data_in_VS             (fb_VS_in         ), 
	  .data_in_HS             (fb_HS_in         ), 
	  .data_in_DE             (fb_DE_in         ), 
	  .data_in                (fb_data_in       ),  
	  // data output
	  .rd_port_en             (5'b01111         ),
	  .pix_clk_rd             (pix_clk          ),
  	.rd_VS_in               (fb_rd_VS_in      ), 
  	.rd_HS_in               (fb_rd_HS_in      ), 
  	.rd_DE_in               (fb_rd_DE_in      ), 
	  .data_out_VS            (fb_VS_out        ), 
	  .data_out_HS            (fb_HS_out        ), 
	  .data_out_DE            (fb_DE_out        ), 
	  .data_out_1             (fb_data_out1     ),
	  .data_out_2             (fb_data_out2     ),
	  .data_out_3             (fb_data_out3     ),
	  .data_out_4             (fb_data_out4     ),
	  .data_out_5             (fb_data_out5     ),
	  
	  //DDR3
	  .c3_sys_clk             (c3_sys_clk       ),
	  .c3_sys_rst_i           (c3_sys_rst_i     ),
	  .c3_calib_done          (c3_calib_done    ),
	  .mcb3_dram_dq           (mcb3_dram_dq     ),
	  .mcb3_dram_a            (mcb3_dram_a      ),
	  .mcb3_dram_ba           (mcb3_dram_ba     ),
	  .mcb3_dram_ras_n        (mcb3_dram_ras_n  ),
	  .mcb3_dram_cas_n        (mcb3_dram_cas_n  ),
	  .mcb3_dram_we_n         (mcb3_dram_we_n   ),
	  .mcb3_dram_odt          (mcb3_dram_odt    ),
	  .mcb3_dram_reset_n      (mcb3_dram_reset_n),
	  .mcb3_dram_cke          (mcb3_dram_cke    ),
	  .mcb3_dram_dm           (mcb3_dram_dm     ),
	  .mcb3_dram_udqs         (mcb3_dram_udqs   ),
	  .mcb3_dram_udqs_n       (mcb3_dram_udqs_n ),
	  .mcb3_dram_udm          (mcb3_dram_udm    ),
	  .mcb3_dram_dqs          (mcb3_dram_dqs    ),
	  .mcb3_dram_dqs_n        (mcb3_dram_dqs_n  ),
	  .mcb3_dram_ck           (mcb3_dram_ck     ),
	  .mcb3_dram_ck_n         (mcb3_dram_ck_n   ),
	  .mcb3_rzq               (mcb3_rzq         ),
	  .mcb3_zio               (mcb3_zio         )
	) ;
	
	assign bmd_VS_in    = fb_VS_out   ;                           
	assign bmd_HS_in    = fb_HS_out   ;                           
	assign bmd_DE_in    = fb_DE_out   ;  
	assign bmd_data1_in = fb_data_out1[C_SENSOR_DATA_WIDTH+4-1:6];
	assign bmd_data2_in = fb_data_out2[C_SENSOR_DATA_WIDTH+4-1:6];
	assign bmd_data3_in = fb_data_out3[C_SENSOR_DATA_WIDTH+4-1:6];
	assign bmd_data4_in = fb_data_out4[C_SENSOR_DATA_WIDTH+4-1:6];
	assign bmd_data5_in = fb_data_out5[C_SENSOR_DATA_WIDTH+4-1:6];                  
	//assign bmd_data1_in = {fb_data_out1,2'b00};
	//assign bmd_data2_in = {fb_data_out2,2'b00};
	//assign bmd_data3_in = {fb_data_out3,2'b00};
	//assign bmd_data4_in = {fb_data_out4,2'b00};
	//assign bmd_data5_in = {fb_data_out5,2'b00};
	
	assign bayer2rgb_VS_in     = bmd_VS_in   ;//bmd_VS_out    ;//
	assign bayer2rgb_HS_in     = bmd_HS_in   ;//bmd_HS_out    ;//
	assign bayer2rgb_DE_in     = bmd_DE_in   ;//bmd_DE_out    ;//
	assign bayer2rgb_dataBH_in = bmd_data1_in;//bmd_dataBH_out;//
	assign bayer2rgb_dataBL_in = bmd_data2_in;//bmd_dataBL_out;//
	assign bayer2rgb_dataM_in  = bmd_data3_in;//bmd_dataM_out ;//
	assign bayer2rgb_dataDH_in = bmd_data4_in;//bmd_dataDH_out;//
	assign bayer2rgb_dataDL_in = bmd_data5_in;//bmd_dataDL_out;//

	
	Bayer2RGB
	#(
		.C_BAYER_FORMAT   (C_BAYER_FORMAT           ),
	  .C_RAM_ADDR_BITS  (C_BAYER2RGB_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_SENSOR_DATA_WIDTH-2    )
	)
	uBH_Bayer2RGB
	(
	  // System Signal
	  .reset           (reset               ),
	  .clk             (pix_clk             ),
	  // video input                        
	  .vs_in           (bayer2rgb_VS_in     ), 
	  .hs_in           (bayer2rgb_HS_in     ),
	  .de_in           (bayer2rgb_DE_in     ),
	  .data_in         (bayer2rgb_dataBH_in ),
	  // buff data out                      
	  .vs_out          (bayer2rgb_VS_out    ),
	  .hs_out          (bayer2rgb_HS_out    ),
	  .de_out          (bayer2rgb_DE_out    ),
		.data_out        (bayer2rgb_dataBH_out) 
	);
	
	Bayer2RGB
	#(
		.C_BAYER_FORMAT   (C_BAYER_FORMAT           ),
	  .C_RAM_ADDR_BITS  (C_BAYER2RGB_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_SENSOR_DATA_WIDTH-2    )
	)
	uBL_Bayer2RGB
	(
	  // System Signal
	  .reset           (reset               ),
	  .clk             (pix_clk             ),
	  // video input                        
	  .vs_in           (bayer2rgb_VS_in     ), 
	  .hs_in           (bayer2rgb_HS_in     ),
	  .de_in           (bayer2rgb_DE_in     ),
	  .data_in         (bayer2rgb_dataBL_in ),
	  // buff data out
	  .vs_out          (                    ),
	  .hs_out          (                    ),
	  .de_out          (                    ),
		.data_out        (bayer2rgb_dataBL_out) 
	);
	
	Bayer2RGB
	#(
		.C_BAYER_FORMAT   (C_BAYER_FORMAT           ),
	  .C_RAM_ADDR_BITS  (C_BAYER2RGB_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_SENSOR_DATA_WIDTH-2    )
	)
	uM_Bayer2RGB
	(
	  // System Signal
	  .reset           (reset              ),
	  .clk             (pix_clk            ),
	  // video input                       
	  .vs_in           (bayer2rgb_VS_in    ),  
	  .hs_in           (bayer2rgb_HS_in    ),
	  .de_in           (bayer2rgb_DE_in    ),
	  .data_in         (bayer2rgb_dataM_in ),
	  // buff data out
	  .vs_out          (                   ),
	  .hs_out          (                   ),
	  .de_out          (                   ),
		.data_out        (bayer2rgb_dataM_out) 
	);
	
	Bayer2RGB
	#(
		.C_BAYER_FORMAT   (C_BAYER_FORMAT           ),
	  .C_RAM_ADDR_BITS  (C_BAYER2RGB_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH     (C_SENSOR_DATA_WIDTH-2    )
	)
	uDH_Bayer2RGB
	(
	  // System Signal
	  .reset           (reset              ),
	  .clk             (pix_clk            ),
	  // video input                       
	  .vs_in           (bayer2rgb_VS_in    ),  
	  .hs_in           (bayer2rgb_HS_in    ),
	  .de_in           (bayer2rgb_DE_in    ),
	  .data_in         (bayer2rgb_dataDH_in),
	  // buff data out
	  .vs_out          (                   ),
	  .hs_out          (                   ),
	  .de_out          (                   ),
		.data_out        (bayer2rgb_dataDH_out) 
	);
	
	assign hdr_VS_in     = bayer2rgb_VS_out    ;//wb_VS_in    ;
	assign hdr_HS_in     = bayer2rgb_HS_out    ;//wb_HS_in    ;
	assign hdr_DE_in     = bayer2rgb_DE_out    ;//wb_DE_in    ;
	assign hdr_dataBH_in = bayer2rgb_dataBH_out;//wb_dataBH_in;
	assign hdr_dataBL_in = bayer2rgb_dataBL_out;//wb_dataBL_in;
	assign hdr_dataM_in  = bayer2rgb_dataM_out ;//wb_dataM_in ;
	assign hdr_dataDH_in = bayer2rgb_dataDH_out;//wb_dataDH_in;
	assign hdr_dataDL_in = bayer2rgb_dataDL_out;//wb_dataDL_in;
	
	assign hdr4f_VS_in     = hdr_VS_in    ;
	assign hdr4f_HS_in     = hdr_HS_in    ;
	assign hdr4f_DE_in     = hdr_DE_in    ;
	assign hdr4f_dataBH_in = {hdr_dataBH_in[29:22],hdr_dataBH_in[19:12],hdr_dataBH_in[9:2]};
	assign hdr4f_dataBL_in = {hdr_dataBL_in[29:22],hdr_dataBL_in[19:12],hdr_dataBL_in[9:2]};
	assign hdr4f_dataM_in  = {hdr_dataM_in[29:22],hdr_dataM_in[19:12],hdr_dataM_in[9:2]};
	assign hdr4f_dataDH_in = {hdr_dataDH_in[29:22],hdr_dataDH_in[19:12],hdr_dataDH_in[9:2]};

	
	HDR_4f //delay 40
	#(
	  .C_DATA_WIDTH  (24)
	)
	u_HDR_4f
	(
		.reset       (reset           ), 
		.clk         (pix_clk         ), 
		.data_in_VS  (hdr4f_VS_in     ), 
		.data_in_HS  (hdr4f_HS_in     ), 
		.data_in_DE  (hdr4f_DE_in     ), 
		.data_in_B   (hdr4f_dataBH_in ), 
		.data_in_MH  (hdr4f_dataBL_in ), 
		.data_in_ML  (hdr4f_dataM_in  ), 
		.data_in_D   (hdr4f_dataDH_in ), 
		.data_out_VS (hdr_F4f_VS_out  ), 
		.data_out_HS (hdr_F4f_HS_out  ), 
		.data_out_DE (hdr_F4f_DE_out  ), 
		.data_out    (hdr_F4f_data_out) 
	);
	
	Bayer2RGB
	#(
		.C_BAYER_FORMAT  (C_BAYER_FORMAT           ),
	  .C_RAM_ADDR_BITS (C_BAYER2RGB_RAM_ADDR_BITS), 
	  .C_DATA_WIDTH    (C_SENSOR_DATA_WIDTH-2    )
	)
	u0_Bayer2RGB
	(
	  // System Signal
	  .reset           (reset                    ),
	  .clk             (pix_clk                  ),
	  // video input                                      
	  .vs_in           (fb_VS_in                 ),    
	  .hs_in           (fb_HS_in                 ),  
	  .de_in           (fb_DE_in                 ),  
	  .data_in         (douta                    ),  
	  // buff data out                           
	  .vs_out          (bayer2rgb_VS_out_t       ),   
	  .hs_out          (bayer2rgb_HS_out_t       ),   
	  .de_out          (bayer2rgb_DE_out_t       ),   
		.data_out        (bayer2rgb_data_out_t     )    
	);
	
	assign hdr_sel = mid_bnt_inversion;
	
	wire                          mux_VS_out   ;
	wire                          mux_HS_out   ;
	wire                          mux_DE_out   ;
	wire [C_HDMI_DATA_WIDTH-1:0]  mux_data_out ;
	
	output_mux//delay 1
	#(
	  .C_DATA_WIDTH  (30              )
	)
	u_output_mux
	(
	  // system signal
	  .pix_clk      (pix_clk          ),
	  .reset        (reset            ),
	  .hdr_sel      (hdr_sel          ),
	  // data input
	  .hdr_vs_in    (hdr_F4f_VS_out  ),//      
	  .hdr_hs_in    (hdr_F4f_HS_out  ),//      
	  .hdr_de_in    (hdr_F4f_DE_out  ),//      
	  .hdr_data_in  (hdr_F4f_data_out),// 
	                
	  .nhdr_vs_in   (bayer2rgb_VS_out_t  ),//wb0_VS_t1   
	  .nhdr_hs_in   (bayer2rgb_HS_out_t  ),//wb0_HS_t1   
	  .nhdr_de_in   (bayer2rgb_DE_out_t  ),//wb0_DE_t1   
	  .nhdr_data_in (bayer2rgb_data_out_t),//wb0_data_t1    
	  // data output
	  .vs_o         (mux_VS_out         ),//mux_vs_o   
	  .hs_o         (mux_HS_out         ),//mux_hs_o   
	  .de_o         (mux_DE_out         ),//mux_de_o   
	  .data_o       (mux_data_out       ) //mux_data_o
	);
	
	wire         wb_vs_in  ;
	wire         wb_hs_in  ;
	wire         wb_de_in  ;
  wire  [23:0] wb_data_in;
  
  wire         wb_vs_out  ;
	wire         wb_hs_out  ;
	wire         wb_de_out  ;
  wire  [23:0] wb_data_out;
  
  assign wb_vs_in   = mux_VS_out                                                 ;
	assign wb_hs_in   = mux_HS_out                                                 ;
	assign wb_de_in   = mux_DE_out                                                 ;
	assign wb_data_in = {mux_data_out[29:22],mux_data_out[19:12],mux_data_out[9:2]};
	
	wire         his_eq_vs_out;
	wire         his_eq_hs_out;
	wire         his_eq_de_out;
  wire  [23:0] his_eq_d_out ;
	
	his_eq_nrt//top//delay 2
	#(
	  //.C_DATA_WIDTH      (32),
	  .C_Mu              (5 ), //range=0~10,recommend 2.0 < C_Mu < 10.0
	  .C_VDATA_WIDTH     (8 )
	)
	u_his_eq_top
	(
	  // system signal
	  .clk               (pix_clk      ),
	  .reset             (reset        ),
	  // data input
	  .vs_in             (wb_vs_in    ),//wb_vs_out                                                   
	  .hs_in             (wb_hs_in    ),//wb_hs_out                                                   
	  .de_in             (wb_de_in    ),//wb_de_out                                                   
	  .data_in           (wb_data_in  ),//wb_data_out
	  // data output
	  .vs_out            (his_eq_vs_out), 
	  .hs_out            (his_eq_hs_out),
	  .de_out            (his_eq_de_out), 
	  .data_out          (his_eq_d_out ),
	  .db                (his_db)
	);
	
	assign wb0_VS_in   = his_eq_vs_out;                                                               //mux_VS_out  ;//
	assign wb0_HS_in   = his_eq_hs_out;                                                               //mux_HS_out  ;//
	assign wb0_DE_in   = his_eq_de_out;                                                               //mux_DE_out  ;//
	assign wb0_data_in = {his_eq_d_out[23:16],2'b00,his_eq_d_out[15:8],2'b00,his_eq_d_out[7:0],2'b00};//mux_data_out;//
	
	RGB2YC //delay 5
	#(
	  .C_DATA_WIDTH (10)
	)
	u0_RGB2YC
	(
		 .clk         (pix_clk            ),
		 .reset       (reset              ),		  
		 .convert_std (2'b11              ),
		 .VS_in       (wb0_VS_in          ),// 
		 .HS_in       (wb0_HS_in          ),// 
		 .DE_in       (wb0_DE_in          ),// 
		 .R_in        (wb0_data_in[29:20] ),// 
		 .G_in        (wb0_data_in[19:10] ),// 
		 .B_in        (wb0_data_in[ 9: 0] ),// 
		 .VS_out      (wb0_VS_t1          ),
		 .HS_out      (wb0_HS_t1          ),
		 .DE_out      (wb0_DE_t1          ),
		 .Y_out       (wb0_data_t1[19:10] ),
		 .C_out       (wb0_data_t1[ 9: 0] )		  
	);
	
	IMU_PACKAGE_INSERT//delay 3
	#(
	    .DATA_WIDTH     (16      ),
	    .IMU_PKT_SIZE   (46      ), 
	    .IMU_PKT_HEADER (16'h5AA5),
	    .KEY_NUM        (8       )
	)
	u_IMU_PACKAGE_INSERT
	(
	    .key_code       (key_code),
	    .reset          (reset),
	    .sys_clk        (clk_100m),
	    .pix_clk        (pix_clk),
	    .sensor_vs_i    (wb0_VS_t1                            ),
	    .sensor_hs_i    (wb0_HS_t1                            ),
	    .sensor_de_i    (wb0_DE_t1                            ),
	    .sensor_data_i  ({wb0_data_t1[9:2],wb0_data_t1[19:12]}),
	    .sensor_vs_o    (imu_vs  ),
	    .sensor_hs_o    (imu_hs  ),
	    .sensor_de_o    (imu_de  ),
	    .sensor_data_o  (imu_data),
	
	    .uart_rx        (uart_rx)        
	);
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)	
		begin
			hdmi_vs <= 1'b1;
			hdmi_hs <= 1'b1;
			hdmi_de <= 1'b0;
			hdmi_d  <= 0;
		end
		else
		begin
			hdmi_vs <= imu_vs  ;  
			hdmi_hs <= imu_hs  ; 
			hdmi_de <= imu_de  ; 
			hdmi_d  <= imu_data;
		end
	end
	
	
	cy3014_master
	u_cy3014_master
	(                          
		.Last_packet     (16'd143 ),
		.Last_packet_size(16'd7988), 
		.fifo_full_led (    ),
   	.sync          (1'b1),
   	.reset         (reset  ),
   	.hdmit_clk     (pix_clk),
   	.hdmit_vs      (~hdmi_vs),
   	.hdmit_hs      (~hdmi_hs),
   	.hdmit_de      (hdmi_de ),
   	.hdmit_d       (hdmi_d  ),
   	.fdata         (fdata  ),
   	.faddr         (faddr  ),
   	.slrd          (slrd   ),
   	.slwr          (slwr   ),
   	.flagb         (flagb  ),
   	.flaga         (flaga  ),
   	.hdmit_halfclk (pix_clk_2),
   	.clk_out       (clk_out),
   	.sloe          (sloe   ),
   	.slcs          (slcs   ),
   	.pktend        (pktend )
	); 
	
	
endmodule
