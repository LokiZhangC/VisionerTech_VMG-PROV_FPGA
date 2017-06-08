`timescale 1ps / 1ps

module init_sensor_phy
	#
	(
		parameter                      C_CLK_FREQ    = 100_000 ,//KHz
		parameter                      C_I2C_FREQ    = 100     ,//KHz
		parameter                      C_DATA_WIDTH  = 10'd16 ,
		parameter                      C_SADDR_WIDTH = 10'd8  ,
		parameter                      C_BADDR_WIDTH = 10'd16
	)
	(
		input  wire                    clk                   ,
		input  wire                    reset                 ,

		output wire                    SCL                   ,
		//inout  wire                    SDA                 ,
		input  wire                    sda_i                 ,
		output wire                    sda_o                 ,
		output wire                    sda_t                 ,
		                                                     
		input  wire                    sensor_vs             ,
		input  wire                    BNT_valid             ,
		
		output wire                    sensor_cfg_done       ,
		output reg [1:0]               bmd_flag              ,
		
		input  wire                    cfg0_data_valid       ,
		input  wire[15:0]              cfg0_data_IT          ,
		input  wire[15:0]              cfg0_data_AG          ,
		input  wire                    cfg1_data_valid       ,
		input  wire[15:0]              cfg1_data_IT          ,
		input  wire[15:0]              cfg1_data_AG          ,
		input  wire                    cfg2_data_valid       ,
		input  wire[15:0]              cfg2_data_IT          ,
		input  wire[15:0]              cfg2_data_AG          ,
		input  wire                    cfg3_data_valid       ,
		input  wire[15:0]              cfg3_data_IT          ,
		input  wire[15:0]              cfg3_data_AG          ,
		
		//debug
	  output wire                    db_data_addr_in_value ,
	  output wire[C_DATA_WIDTH-1:0]  db_data_in            ,
	  output wire[C_SADDR_WIDTH-1:0] db_slave_addr_in      ,
	  output wire[C_BADDR_WIDTH-1:0] db_base_addr_in       ,

	  output wire                    db_data_addr_out_value,
	  output wire[C_DATA_WIDTH-1:0]  db_data_out           ,
	  output wire[C_SADDR_WIDTH-1:0] db_slave_addr_out     ,
	  output wire[C_BADDR_WIDTH-1:0] db_base_addr_out      ,

	  output wire                    db_i2c_busy           ,
	  output wire                    db_i2c_done           ,
	  output wire                    db_error              ,
	  output wire[2:0]               db_error_code         ,       

	  output wire                    db_sda_sa             ,
	  output wire                    db_sda_ba             ,
	  output wire                    db_sda_d              ,
	  output wire                    db_sda_t_acko         ,
	  output wire                    db_sda_t_reado        
		
	);
	
	function integer clog2;
	input integer value;
	begin 
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
		value = value>>1;
	end 
	endfunction
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	(* KEEP = "TRUE" *)reg [2:0] state;
	localparam CMD_IDLE                    = 3'd0;
	localparam CMD_START                   = 3'd1;
	localparam CMD_WRITE                   = 3'd2;
	localparam CMD_WAIT                    = 3'd3;
	localparam CMD_DONE                    = 3'd4;	
	localparam CMD_ERROR                   = 3'd5;
	
	(* KEEP = "TRUE" *)reg                     data_addr_in_value ;
	(* KEEP = "TRUE" *)reg [C_DATA_WIDTH-1:0]  data_in            ;
	(* KEEP = "TRUE" *)reg [C_SADDR_WIDTH-1:0] slave_addr_in      ;
	(* KEEP = "TRUE" *)reg [C_BADDR_WIDTH-1:0] base_addr_in       ;
	                                           
	(* KEEP = "TRUE" *)wire                    data_addr_out_value;
	(* KEEP = "TRUE" *)wire[C_DATA_WIDTH-1:0]  data_out           ;
	(* KEEP = "TRUE" *)wire[C_SADDR_WIDTH-1:0] slave_addr_out     ;
	(* KEEP = "TRUE" *)wire[C_BADDR_WIDTH-1:0] base_addr_out      ;

	(* KEEP = "TRUE" *)wire                    i2c_busy           ;
	(* KEEP = "TRUE" *)wire                    i2c_done           ;
	(* KEEP = "TRUE" *)wire                    error              ;
	(* KEEP = "TRUE" *)wire[2:0]               error_code         ;       	                                                      
                                  
	(* KEEP = "TRUE" *)wire                    sda_sa             ;
	(* KEEP = "TRUE" *)wire                    sda_ba             ;
	(* KEEP = "TRUE" *)wire                    sda_d              ;
	(* KEEP = "TRUE" *)wire                    sda_t_acko         ;
	(* KEEP = "TRUE" *)wire                    sda_t_reado        ;
	
	localparam RD = 1'b1;
	localparam WR = 1'b0;
	
	localparam AR0230CS_ADDR  = 7'b0011_000;//0x30,Saddr=1 //7'b0111100;//
	//localparam Chip_Revision = 8'b0001_0100;
	
	localparam ADDR_CMD   = 1'b1;
	localparam DELAY_CMD  = 1'b0;
	
	localparam INIT_VECTORS = 257;//256//257
	reg  [clog2(INIT_VECTORS)-1:0] init_vectors_cnt;
	
	localparam CMD_DELAY    = 1;//ms
	localparam CMD_DELAY_CYCLES = CMD_DELAY*C_CLK_FREQ;
	
	localparam RESET_DELAY  = 50;//*1000;//50ms
	localparam RESET_DELAY_CYCLES = RESET_DELAY*C_CLK_FREQ;///1000;
	
	localparam RESET_release_DELAY  = 200;//*1000;//200ms
	localparam RESET_release_DELAY_CYCLES = RESET_release_DELAY*C_CLK_FREQ;///1000;
	
	reg  [31:0] wait_cnt;
	
	(* ROM_STYLE="{AUTO | DISTRIBUTED | PIPE_DISTRIBUTED}" *)
	reg [2+C_BADDR_WIDTH+C_DATA_WIDTH-1:0] init_rom [0:INIT_VECTORS-1];
	
	(* RAM_STYLE="{AUTO | DISTRIBUTED | PIPE_DISTRIBUTED}" *)
	(* KEEP = "TRUE" *)
	reg [C_DATA_WIDTH-1:0] raed_back_ram [0:6-1];//256//257
	
	localparam CFG_VECTORS = 2;//6;//12+12;//
	reg  [clog2(4*CFG_VECTORS)-1:0] cfg_vectors_cnt;
	(* ROM_STYLE="{AUTO | DISTRIBUTED | PIPE_DISTRIBUTED}" *)
	reg [2+C_BADDR_WIDTH+C_DATA_WIDTH-1:0] cfg_rom [0:4*CFG_VECTORS-1];
	
	reg      init_done;
	
	reg      sensor_vs_d1;
	reg      sensor_vs_d2;
	reg      sensor_vs_d3;
	reg      sensor_vs_d4;
	wire     vs_ps;
	reg      cfg_valid;
	
	reg                                                      ar0230cs_cmd_valid;
	(* KEEP = "TRUE" *)wire [C_BADDR_WIDTH+C_DATA_WIDTH-1:0] init_rom_ba_da    ;
	(* KEEP = "TRUE" *)reg  [C_BADDR_WIDTH+C_DATA_WIDTH-1:0] init_rom_ba_da_t  ;
	
	initial 
	begin
		
		//--------------------------------------------------------------------------
		//AR0230CS
		//--------------------------------------------------------------------------
		
    init_rom[0  ] = {{ADDR_CMD, WR},16'h301A,16'h0001}; //RESET_REGISTER
		init_rom[1  ] = {{DELAY_CMD,1'b0},RESET_DELAY_CYCLES}; //DELAY=50ms
		init_rom[2  ] = {{ADDR_CMD, WR},16'h301A,16'h10D8}; //RESET_REGISTER
		init_rom[3  ] = {{DELAY_CMD,1'b0},RESET_release_DELAY_CYCLES}; //DELAY=200ms
		
		init_rom[4  ] = {{ADDR_CMD,WR},16'h3088,16'h8242}; //SEQ_CTRL_PORT
		init_rom[5  ] = {{ADDR_CMD,WR},16'h3086,16'h4558}; //SEQ_DATA_PORT
		init_rom[6  ] = {{ADDR_CMD,WR},16'h3086,16'h729B}; //SEQ_DATA_PORT
		init_rom[7  ] = {{ADDR_CMD,WR},16'h3086,16'h4A31}; //SEQ_DATA_PORT
		init_rom[8  ] = {{ADDR_CMD,WR},16'h3086,16'h4342}; //SEQ_DATA_PORT
		init_rom[9  ] = {{ADDR_CMD,WR},16'h3086,16'h8E03}; //SEQ_DATA_PORT
		init_rom[10 ] = {{ADDR_CMD,WR},16'h3086,16'h2A14}; //SEQ_DATA_PORT
		init_rom[11 ] = {{ADDR_CMD,WR},16'h3086,16'h4578}; //SEQ_DATA_PORT
		init_rom[12 ] = {{ADDR_CMD,WR},16'h3086,16'h7B3D}; //SEQ_DATA_PORT
		init_rom[13 ] = {{ADDR_CMD,WR},16'h3086,16'hFF3D}; //SEQ_DATA_PORT
		init_rom[14 ] = {{ADDR_CMD,WR},16'h3086,16'hFF3D}; //SEQ_DATA_PORT
		init_rom[15 ] = {{ADDR_CMD,WR},16'h3086,16'hEA2A}; //SEQ_DATA_PORT
		init_rom[16 ] = {{ADDR_CMD,WR},16'h3086,16'h043D}; //SEQ_DATA_PORT
		init_rom[17 ] = {{ADDR_CMD,WR},16'h3086,16'h102A}; //SEQ_DATA_PORT
		init_rom[18 ] = {{ADDR_CMD,WR},16'h3086,16'h052A}; //SEQ_DATA_PORT
		init_rom[19 ] = {{ADDR_CMD,WR},16'h3086,16'h1535}; //SEQ_DATA_PORT
		init_rom[20 ] = {{ADDR_CMD,WR},16'h3086,16'h2A05}; //SEQ_DATA_PORT
		init_rom[21 ] = {{ADDR_CMD,WR},16'h3086,16'h3D10}; //SEQ_DATA_PORT
		init_rom[22 ] = {{ADDR_CMD,WR},16'h3086,16'h4558}; //SEQ_DATA_PORT
		init_rom[23 ] = {{ADDR_CMD,WR},16'h3086,16'h2A04}; //SEQ_DATA_PORT
		init_rom[24 ] = {{ADDR_CMD,WR},16'h3086,16'h2A14}; //SEQ_DATA_PORT
		init_rom[25 ] = {{ADDR_CMD,WR},16'h3086,16'h3DFF}; //SEQ_DATA_PORT
		init_rom[26 ] = {{ADDR_CMD,WR},16'h3086,16'h3DFF}; //SEQ_DATA_PORT
		init_rom[27 ] = {{ADDR_CMD,WR},16'h3086,16'h3DEA}; //SEQ_DATA_PORT
		init_rom[28 ] = {{ADDR_CMD,WR},16'h3086,16'h2A04}; //SEQ_DATA_PORT
		init_rom[29 ] = {{ADDR_CMD,WR},16'h3086,16'h622A}; //SEQ_DATA_PORT
		init_rom[30 ] = {{ADDR_CMD,WR},16'h3086,16'h288E}; //SEQ_DATA_PORT
		init_rom[31 ] = {{ADDR_CMD,WR},16'h3086,16'h0036}; //SEQ_DATA_PORT
		init_rom[32 ] = {{ADDR_CMD,WR},16'h3086,16'h2A08}; //SEQ_DATA_PORT
		init_rom[33 ] = {{ADDR_CMD,WR},16'h3086,16'h3D64}; //SEQ_DATA_PORT
		init_rom[34 ] = {{ADDR_CMD,WR},16'h3086,16'h7A3D}; //SEQ_DATA_PORT
		init_rom[35 ] = {{ADDR_CMD,WR},16'h3086,16'h0444}; //SEQ_DATA_PORT
		init_rom[36 ] = {{ADDR_CMD,WR},16'h3086,16'h2C4B}; //SEQ_DATA_PORT
		init_rom[37 ] = {{ADDR_CMD,WR},16'h3086,16'h8F03}; //SEQ_DATA_PORT
		init_rom[38 ] = {{ADDR_CMD,WR},16'h3086,16'h430D}; //SEQ_DATA_PORT
		init_rom[39 ] = {{ADDR_CMD,WR},16'h3086,16'h2D46}; //SEQ_DATA_PORT
		init_rom[40 ] = {{ADDR_CMD,WR},16'h3086,16'h4316}; //SEQ_DATA_PORT
		init_rom[41 ] = {{ADDR_CMD,WR},16'h3086,16'h5F16}; //SEQ_DATA_PORT
		init_rom[42 ] = {{ADDR_CMD,WR},16'h3086,16'h530D}; //SEQ_DATA_PORT
		init_rom[43 ] = {{ADDR_CMD,WR},16'h3086,16'h1660}; //SEQ_DATA_PORT
		init_rom[44 ] = {{ADDR_CMD,WR},16'h3086,16'h3E4C}; //SEQ_DATA_PORT
		init_rom[45 ] = {{ADDR_CMD,WR},16'h3086,16'h2904}; //SEQ_DATA_PORT
		init_rom[46 ] = {{ADDR_CMD,WR},16'h3086,16'h2984}; //SEQ_DATA_PORT
		init_rom[47 ] = {{ADDR_CMD,WR},16'h3086,16'h8E03}; //SEQ_DATA_PORT
		init_rom[48 ] = {{ADDR_CMD,WR},16'h3086,16'h2AFC}; //SEQ_DATA_PORT
		init_rom[49 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1D}; //SEQ_DATA_PORT
		init_rom[50 ] = {{ADDR_CMD,WR},16'h3086,16'h5754}; //SEQ_DATA_PORT
		init_rom[51 ] = {{ADDR_CMD,WR},16'h3086,16'h495F}; //SEQ_DATA_PORT
		init_rom[52 ] = {{ADDR_CMD,WR},16'h3086,16'h5305}; //SEQ_DATA_PORT
		init_rom[53 ] = {{ADDR_CMD,WR},16'h3086,16'h5307}; //SEQ_DATA_PORT
		init_rom[54 ] = {{ADDR_CMD,WR},16'h3086,16'h4D2B}; //SEQ_DATA_PORT
		init_rom[55 ] = {{ADDR_CMD,WR},16'h3086,16'hF810}; //SEQ_DATA_PORT
		init_rom[56 ] = {{ADDR_CMD,WR},16'h3086,16'h164C}; //SEQ_DATA_PORT
		init_rom[57 ] = {{ADDR_CMD,WR},16'h3086,16'h0955}; //SEQ_DATA_PORT
		init_rom[58 ] = {{ADDR_CMD,WR},16'h3086,16'h562B}; //SEQ_DATA_PORT
		init_rom[59 ] = {{ADDR_CMD,WR},16'h3086,16'hB82B}; //SEQ_DATA_PORT
		init_rom[60 ] = {{ADDR_CMD,WR},16'h3086,16'h984E}; //SEQ_DATA_PORT
		init_rom[61 ] = {{ADDR_CMD,WR},16'h3086,16'h1129}; //SEQ_DATA_PORT
		init_rom[62 ] = {{ADDR_CMD,WR},16'h3086,16'h9460}; //SEQ_DATA_PORT
		init_rom[63 ] = {{ADDR_CMD,WR},16'h3086,16'h5C19}; //SEQ_DATA_PORT
		init_rom[64 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1B}; //SEQ_DATA_PORT
		init_rom[65 ] = {{ADDR_CMD,WR},16'h3086,16'h4548}; //SEQ_DATA_PORT
		init_rom[66 ] = {{ADDR_CMD,WR},16'h3086,16'h4508}; //SEQ_DATA_PORT
		init_rom[67 ] = {{ADDR_CMD,WR},16'h3086,16'h4588}; //SEQ_DATA_PORT
		init_rom[68 ] = {{ADDR_CMD,WR},16'h3086,16'h29B6}; //SEQ_DATA_PORT
		init_rom[69 ] = {{ADDR_CMD,WR},16'h3086,16'h8E01}; //SEQ_DATA_PORT
		init_rom[70 ] = {{ADDR_CMD,WR},16'h3086,16'h2AF8}; //SEQ_DATA_PORT
		init_rom[71 ] = {{ADDR_CMD,WR},16'h3086,16'h3E02}; //SEQ_DATA_PORT
		init_rom[72 ] = {{ADDR_CMD,WR},16'h3086,16'h2AFA}; //SEQ_DATA_PORT
		init_rom[73 ] = {{ADDR_CMD,WR},16'h3086,16'h3F09}; //SEQ_DATA_PORT
		init_rom[74 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1B}; //SEQ_DATA_PORT
		init_rom[75 ] = {{ADDR_CMD,WR},16'h3086,16'h29B2}; //SEQ_DATA_PORT
		init_rom[76 ] = {{ADDR_CMD,WR},16'h3086,16'h3F0C}; //SEQ_DATA_PORT
		init_rom[77 ] = {{ADDR_CMD,WR},16'h3086,16'h3E03}; //SEQ_DATA_PORT
		init_rom[78 ] = {{ADDR_CMD,WR},16'h3086,16'h3E15}; //SEQ_DATA_PORT
		init_rom[79 ] = {{ADDR_CMD,WR},16'h3086,16'h5C13}; //SEQ_DATA_PORT
		init_rom[80 ] = {{ADDR_CMD,WR},16'h3086,16'h3F11}; //SEQ_DATA_PORT
		init_rom[81 ] = {{ADDR_CMD,WR},16'h3086,16'h3E0F}; //SEQ_DATA_PORT
		init_rom[82 ] = {{ADDR_CMD,WR},16'h3086,16'h5F2B}; //SEQ_DATA_PORT
		init_rom[83 ] = {{ADDR_CMD,WR},16'h3086,16'h902A}; //SEQ_DATA_PORT
		init_rom[84 ] = {{ADDR_CMD,WR},16'h3086,16'hF22B}; //SEQ_DATA_PORT
		init_rom[85 ] = {{ADDR_CMD,WR},16'h3086,16'h803E}; //SEQ_DATA_PORT
		init_rom[86 ] = {{ADDR_CMD,WR},16'h3086,16'h063F}; //SEQ_DATA_PORT
		init_rom[87 ] = {{ADDR_CMD,WR},16'h3086,16'h0660}; //SEQ_DATA_PORT
		init_rom[88 ] = {{ADDR_CMD,WR},16'h3086,16'h29A2}; //SEQ_DATA_PORT
		init_rom[89 ] = {{ADDR_CMD,WR},16'h3086,16'h29A3}; //SEQ_DATA_PORT
		init_rom[90 ] = {{ADDR_CMD,WR},16'h3086,16'h5F4D}; //SEQ_DATA_PORT
		init_rom[91 ] = {{ADDR_CMD,WR},16'h3086,16'h1C2A}; //SEQ_DATA_PORT
		init_rom[92 ] = {{ADDR_CMD,WR},16'h3086,16'hFA29}; //SEQ_DATA_PORT
		init_rom[93 ] = {{ADDR_CMD,WR},16'h3086,16'h8345}; //SEQ_DATA_PORT
		init_rom[94 ] = {{ADDR_CMD,WR},16'h3086,16'hA83E}; //SEQ_DATA_PORT
		init_rom[95 ] = {{ADDR_CMD,WR},16'h3086,16'h072A}; //SEQ_DATA_PORT
		init_rom[96 ] = {{ADDR_CMD,WR},16'h3086,16'hFB3E}; //SEQ_DATA_PORT
		init_rom[97 ] = {{ADDR_CMD,WR},16'h3086,16'h2945}; //SEQ_DATA_PORT
		init_rom[98 ] = {{ADDR_CMD,WR},16'h3086,16'h8824}; //SEQ_DATA_PORT
		init_rom[99 ] = {{ADDR_CMD,WR},16'h3086,16'h3E08}; //SEQ_DATA_PORT
		init_rom[100] = {{ADDR_CMD,WR},16'h3086,16'h2AFA}; //SEQ_DATA_PORT
		init_rom[101] = {{ADDR_CMD,WR},16'h3086,16'h5D29}; //SEQ_DATA_PORT
		init_rom[102] = {{ADDR_CMD,WR},16'h3086,16'h9288}; //SEQ_DATA_PORT
		init_rom[103] = {{ADDR_CMD,WR},16'h3086,16'h102B}; //SEQ_DATA_PORT
		init_rom[104] = {{ADDR_CMD,WR},16'h3086,16'h048B}; //SEQ_DATA_PORT
		init_rom[105] = {{ADDR_CMD,WR},16'h3086,16'h1686}; //SEQ_DATA_PORT
		init_rom[106] = {{ADDR_CMD,WR},16'h3086,16'h8D48}; //SEQ_DATA_PORT
		init_rom[107] = {{ADDR_CMD,WR},16'h3086,16'h4D4E}; //SEQ_DATA_PORT
		init_rom[108] = {{ADDR_CMD,WR},16'h3086,16'h2B80}; //SEQ_DATA_PORT
		init_rom[109] = {{ADDR_CMD,WR},16'h3086,16'h4C0B}; //SEQ_DATA_PORT
		init_rom[110] = {{ADDR_CMD,WR},16'h3086,16'h603F}; //SEQ_DATA_PORT
		init_rom[111] = {{ADDR_CMD,WR},16'h3086,16'h302A}; //SEQ_DATA_PORT
		init_rom[112] = {{ADDR_CMD,WR},16'h3086,16'hF23F}; //SEQ_DATA_PORT
		init_rom[113] = {{ADDR_CMD,WR},16'h3086,16'h1029}; //SEQ_DATA_PORT
		init_rom[114] = {{ADDR_CMD,WR},16'h3086,16'h8229}; //SEQ_DATA_PORT
		init_rom[115] = {{ADDR_CMD,WR},16'h3086,16'h8329}; //SEQ_DATA_PORT
		init_rom[116] = {{ADDR_CMD,WR},16'h3086,16'h435C}; //SEQ_DATA_PORT
		init_rom[117] = {{ADDR_CMD,WR},16'h3086,16'h155F}; //SEQ_DATA_PORT
		init_rom[118] = {{ADDR_CMD,WR},16'h3086,16'h4D1C}; //SEQ_DATA_PORT
		init_rom[119] = {{ADDR_CMD,WR},16'h3086,16'h2AFA}; //SEQ_DATA_PORT
		init_rom[120] = {{ADDR_CMD,WR},16'h3086,16'h4558}; //SEQ_DATA_PORT
		init_rom[121] = {{ADDR_CMD,WR},16'h3086,16'h8E00}; //SEQ_DATA_PORT
		init_rom[122] = {{ADDR_CMD,WR},16'h3086,16'h2A98}; //SEQ_DATA_PORT
		init_rom[123] = {{ADDR_CMD,WR},16'h3086,16'h3F0A}; //SEQ_DATA_PORT
		init_rom[124] = {{ADDR_CMD,WR},16'h3086,16'h4A0A}; //SEQ_DATA_PORT
		init_rom[125] = {{ADDR_CMD,WR},16'h3086,16'h4316}; //SEQ_DATA_PORT
		init_rom[126] = {{ADDR_CMD,WR},16'h3086,16'h0B43}; //SEQ_DATA_PORT
		init_rom[127] = {{ADDR_CMD,WR},16'h3086,16'h168E}; //SEQ_DATA_PORT
		init_rom[128] = {{ADDR_CMD,WR},16'h3086,16'h032A}; //SEQ_DATA_PORT
		init_rom[129] = {{ADDR_CMD,WR},16'h3086,16'h9C45}; //SEQ_DATA_PORT
		init_rom[130] = {{ADDR_CMD,WR},16'h3086,16'h783F}; //SEQ_DATA_PORT
		init_rom[131] = {{ADDR_CMD,WR},16'h3086,16'h072A}; //SEQ_DATA_PORT
		init_rom[132] = {{ADDR_CMD,WR},16'h3086,16'h9D3E}; //SEQ_DATA_PORT
		init_rom[133] = {{ADDR_CMD,WR},16'h3086,16'h305D}; //SEQ_DATA_PORT
		init_rom[134] = {{ADDR_CMD,WR},16'h3086,16'h2944}; //SEQ_DATA_PORT
		init_rom[135] = {{ADDR_CMD,WR},16'h3086,16'h8810}; //SEQ_DATA_PORT
		init_rom[136] = {{ADDR_CMD,WR},16'h3086,16'h2B04}; //SEQ_DATA_PORT
		init_rom[137] = {{ADDR_CMD,WR},16'h3086,16'h530D}; //SEQ_DATA_PORT
		init_rom[138] = {{ADDR_CMD,WR},16'h3086,16'h4558}; //SEQ_DATA_PORT
		init_rom[139] = {{ADDR_CMD,WR},16'h3086,16'h3E08}; //SEQ_DATA_PORT
		init_rom[140] = {{ADDR_CMD,WR},16'h3086,16'h8E01}; //SEQ_DATA_PORT
		init_rom[141] = {{ADDR_CMD,WR},16'h3086,16'h2A98}; //SEQ_DATA_PORT
		init_rom[142] = {{ADDR_CMD,WR},16'h3086,16'h8E00}; //SEQ_DATA_PORT
		init_rom[143] = {{ADDR_CMD,WR},16'h3086,16'h769C}; //SEQ_DATA_PORT
		init_rom[144] = {{ADDR_CMD,WR},16'h3086,16'h779C}; //SEQ_DATA_PORT
		init_rom[145] = {{ADDR_CMD,WR},16'h3086,16'h4644}; //SEQ_DATA_PORT
		init_rom[146] = {{ADDR_CMD,WR},16'h3086,16'h1616}; //SEQ_DATA_PORT
		init_rom[147] = {{ADDR_CMD,WR},16'h3086,16'h907A}; //SEQ_DATA_PORT
		init_rom[148] = {{ADDR_CMD,WR},16'h3086,16'h1244}; //SEQ_DATA_PORT
		init_rom[149] = {{ADDR_CMD,WR},16'h3086,16'h4B18}; //SEQ_DATA_PORT
		init_rom[150] = {{ADDR_CMD,WR},16'h3086,16'h4A04}; //SEQ_DATA_PORT
		init_rom[151] = {{ADDR_CMD,WR},16'h3086,16'h4316}; //SEQ_DATA_PORT
		init_rom[152] = {{ADDR_CMD,WR},16'h3086,16'h0643}; //SEQ_DATA_PORT
		init_rom[153] = {{ADDR_CMD,WR},16'h3086,16'h1605}; //SEQ_DATA_PORT
		init_rom[154] = {{ADDR_CMD,WR},16'h3086,16'h4316}; //SEQ_DATA_PORT
		init_rom[155] = {{ADDR_CMD,WR},16'h3086,16'h0743}; //SEQ_DATA_PORT
		init_rom[156] = {{ADDR_CMD,WR},16'h3086,16'h1658}; //SEQ_DATA_PORT
		init_rom[157] = {{ADDR_CMD,WR},16'h3086,16'h4316}; //SEQ_DATA_PORT
		init_rom[158] = {{ADDR_CMD,WR},16'h3086,16'h5A43}; //SEQ_DATA_PORT
		init_rom[159] = {{ADDR_CMD,WR},16'h3086,16'h1645}; //SEQ_DATA_PORT
		init_rom[160] = {{ADDR_CMD,WR},16'h3086,16'h588E}; //SEQ_DATA_PORT
		init_rom[161] = {{ADDR_CMD,WR},16'h3086,16'h032A}; //SEQ_DATA_PORT
		init_rom[162] = {{ADDR_CMD,WR},16'h3086,16'h9C45}; //SEQ_DATA_PORT
		init_rom[163] = {{ADDR_CMD,WR},16'h3086,16'h787B}; //SEQ_DATA_PORT
		init_rom[164] = {{ADDR_CMD,WR},16'h3086,16'h3F07}; //SEQ_DATA_PORT
		init_rom[165] = {{ADDR_CMD,WR},16'h3086,16'h2A9D}; //SEQ_DATA_PORT
		init_rom[166] = {{ADDR_CMD,WR},16'h3086,16'h530D}; //SEQ_DATA_PORT
		init_rom[167] = {{ADDR_CMD,WR},16'h3086,16'h8B16}; //SEQ_DATA_PORT
		init_rom[168] = {{ADDR_CMD,WR},16'h3086,16'h863E}; //SEQ_DATA_PORT
		init_rom[169] = {{ADDR_CMD,WR},16'h3086,16'h2345}; //SEQ_DATA_PORT
		init_rom[170] = {{ADDR_CMD,WR},16'h3086,16'h5825}; //SEQ_DATA_PORT
		init_rom[171] = {{ADDR_CMD,WR},16'h3086,16'h3E10}; //SEQ_DATA_PORT
		init_rom[172] = {{ADDR_CMD,WR},16'h3086,16'h8E01}; //SEQ_DATA_PORT
		init_rom[173] = {{ADDR_CMD,WR},16'h3086,16'h2A98}; //SEQ_DATA_PORT
		init_rom[174] = {{ADDR_CMD,WR},16'h3086,16'h8E00}; //SEQ_DATA_PORT
		init_rom[175] = {{ADDR_CMD,WR},16'h3086,16'h3E10}; //SEQ_DATA_PORT
		init_rom[176] = {{ADDR_CMD,WR},16'h3086,16'h8D60}; //SEQ_DATA_PORT
		init_rom[177] = {{ADDR_CMD,WR},16'h3086,16'h1244}; //SEQ_DATA_PORT
		init_rom[178] = {{ADDR_CMD,WR},16'h3086,16'h4B2C}; //SEQ_DATA_PORT
		init_rom[179] = {{ADDR_CMD,WR},16'h3086,16'h2C2C}; //SEQ_DATA_PORT
		
		//AR0230 REV1.2 Optimized Settings
		init_rom[180] = {{ADDR_CMD,WR},16'h3ED6,16'h34B3}; // RESERVED_MFR_3ED6
		init_rom[181] = {{ADDR_CMD,WR},16'h2436,16'h000E}; // RESERVED_MFR_2436
		init_rom[182] = {{ADDR_CMD,WR},16'h320C,16'h0180}; // RESERVED_MFR_320C
		init_rom[183] = {{ADDR_CMD,WR},16'h320E,16'h0300}; // RESERVED_MFR_320E
		init_rom[184] = {{ADDR_CMD,WR},16'h3210,16'h0500}; // RESERVED_MFR_3210
		init_rom[185] = {{ADDR_CMD,WR},16'h3204,16'h0B6D}; // RESERVED_MFR_3204
		init_rom[186] = {{ADDR_CMD,WR},16'h30FE,16'h0080}; // RESERVED_MFR_30FE
		init_rom[187] = {{ADDR_CMD,WR},16'h3ED8,16'h7B99}; // RESERVED_MFR_3ED8
		init_rom[188] = {{ADDR_CMD,WR},16'h3EDC,16'h9BA8}; // RESERVED_MFR_3EDC
		init_rom[189] = {{ADDR_CMD,WR},16'h3EDA,16'h9B9B}; // RESERVED_MFR_3EDA
		init_rom[190] = {{ADDR_CMD,WR},16'h3092,16'h006F}; // RESERVED_MFR_3092
		init_rom[191] = {{ADDR_CMD,WR},16'h3EEC,16'h1C04}; // RESERVED_MFR_3EEC
		
		init_rom[192] = {{ADDR_CMD,WR},16'h3EF6,16'hA70F}; // RESERVED_MFR_3EF6
		init_rom[193] = {{ADDR_CMD,WR},16'h3044,16'h0410}; // RESERVED_MFR_3044
		init_rom[194] = {{ADDR_CMD,WR},16'h3ED0,16'hFF44}; // RESERVED_MFR_3ED0
		init_rom[195] = {{ADDR_CMD,WR},16'h3ED4,16'h031F}; // RESERVED_MFR_3ED4
		init_rom[196] = {{ADDR_CMD,WR},16'h30FE,16'h0080}; // RESERVED_MFR_30FE
		init_rom[197] = {{ADDR_CMD,WR},16'h3EE2,16'h8866}; // RESERVED_MFR_3EE2
		init_rom[198] = {{ADDR_CMD,WR},16'h3EE4,16'h6623}; // RESERVED_MFR_3EE4
		init_rom[199] = {{ADDR_CMD,WR},16'h3EE6,16'h2263}; // RESERVED_MFR_3EE6
		init_rom[200] = {{ADDR_CMD,WR},16'h30E0,16'h4283}; // RESERVED_MFR_30E0
		init_rom[201] = {{ADDR_CMD,WR},16'h30F0,16'h1283}; // RESERVED_MFR_30F0
		
		init_rom[202] = {{ADDR_CMD,WR},16'h30B0,16'h1118}; // DIGITAL_TEST
		init_rom[203] = {{ADDR_CMD,WR},16'h31AC,16'h0C0C}; // DATA_FORMAT_BITS
		
		//PLL_settings - Parallel_27Min_74.25Mout
		init_rom[204] = {{ADDR_CMD,WR},16'h302A,16'h0006};	//VT_PIX_CLK_DIV = 6
		init_rom[205] = {{ADDR_CMD,WR},16'h302C,16'h0001};	//VT_SYS_CLK_DIV = 1
		init_rom[206] = {{ADDR_CMD,WR},16'h302E,16'h0004};	//PRE_PLL_CLK_DIV = 4
		init_rom[207] = {{ADDR_CMD,WR},16'h3030,16'h0042};	//PLL_MULTIPLIER = 66
		init_rom[208] = {{ADDR_CMD,WR},16'h3036,16'h000C};	//OP_PIX_CLK_DIV = 12
		init_rom[209] = {{ADDR_CMD,WR},16'h3038,16'h0001};	//OP_SYS_CLK_DIV = 1
		
		
		//1100x1250 972x1080
		init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'd4   };	// Y_ADDR_START            d184  d2    d2    d2   
		init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'd424 };	// X_ADDR_START 330  12    d332  d330  d200  d330 
		init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'd1083};	// Y_ADDR_END              d906  d1084 d1084 d1084
		init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'd1503};	// X_ADDR_END   1290 1932  d1613 d1303 d1573 d1291
		init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'd1125};	// FRAME_LENGTH_LINES      d750  d1125 d1125 d1125
		init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'd550 };	// LINE_LENGTH_PCK         d825  d550  d1100 d550 
		init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'd800 };	// COARSE_INTEGRATION_TIME d4000 d800  d800  d800 
		init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC    1    3
		init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC
		init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		
		////1212x1274 1200x1080
		//init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'd0   };	// Y_ADDR_START              REG= 0x3002, 0x00B8 	// Y_ADDR_START           
		//init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'd0   };	// X_ADDR_START              REG= 0x3004, 0x014C 	// X_ADDR_START           
		//init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'd1079};	// Y_ADDR_END                REG= 0x3006, 0x0387 	// Y_ADDR_END             
		//init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'd1199};	// X_ADDR_END                REG= 0x3008, 0x064B 	// X_ADDR_END             
		//init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'd1125};	// FRAME_LENGTH_LINES        REG= 0x300A, 0x02EE 	// FRAME_LENGTH_LINES     
		//init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'd1100};	// LINE_LENGTH_PCK           REG= 0x300C, 0x0339 	// LINE_LENGTH_PCK        
		//init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'd700 };	// COARSE_INTEGRATION_TIME   REG= 0x3012, 0x02A3 	// COARSE_INTEGRATION_TIME
		//init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC                 REG= 0x30A2, 0x0001 	// X_ODD_INC              
		//init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC                 REG= 0x30A6, 0x0001 	// Y_ODD_INC              
		//init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		//init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		//init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		//init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		////1664x748 1280x720
		//init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'h00B6};	// Y_ADDR_START       d184   REG= 0x3002, 0x00B8 	// Y_ADDR_START           
		//init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'h014A};	// X_ADDR_START       d332   REG= 0x3004, 0x014C 	// X_ADDR_START           
		//init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'h0385};	// Y_ADDR_END         d903   REG= 0x3006, 0x0387 	// Y_ADDR_END             
		//init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'h0649};	// X_ADDR_END         d1611  REG= 0x3008, 0x064B 	// X_ADDR_END             
		//init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'h02EE};	// FRAME_LENGTH_LINES        REG= 0x300A, 0x02EE 	// FRAME_LENGTH_LINES     
		//init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'h0339};	// LINE_LENGTH_PCK           REG= 0x300C, 0x0339 	// LINE_LENGTH_PCK        
		//init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME   REG= 0x3012, 0x02A3 	// COARSE_INTEGRATION_TIME
		//init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC                 REG= 0x30A2, 0x0001 	// X_ODD_INC              
		//init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC                 REG= 0x30A6, 0x0001 	// Y_ODD_INC              
		//init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		//init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		//init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		//init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		////1688x1066 1280x1024
		//init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'h0002};	// Y_ADDR_START              REG= 0x3002, 0x00B8 	// Y_ADDR_START           
		//init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'h014A};	// X_ADDR_START              REG= 0x3004, 0x014C 	// X_ADDR_START           
		//init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'h0404};	// Y_ADDR_END                REG= 0x3006, 0x0387 	// Y_ADDR_END             
		//init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'h064A};	// X_ADDR_END                REG= 0x3008, 0x064B 	// X_ADDR_END             
		//init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'h042A};	// FRAME_LENGTH_LINES        REG= 0x300A, 0x02EE 	// FRAME_LENGTH_LINES     
		//init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'h034C};	// LINE_LENGTH_PCK           REG= 0x300C, 0x0339 	// LINE_LENGTH_PCK        
		//init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME   REG= 0x3012, 0x02A3 	// COARSE_INTEGRATION_TIME
		//init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC                 REG= 0x30A2, 0x0001 	// X_ODD_INC              
		//init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC                 REG= 0x30A6, 0x0001 	// Y_ODD_INC              
		//init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		//init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		//init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		//init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		////1100x1250 960x1080
		//init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'd2   };	// Y_ADDR_START            d184 
		//init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'd330 };	// X_ADDR_START 330  12    d332 
		//init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'd1081};	// Y_ADDR_END              d906 
		//init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'd1289};	// X_ADDR_END   1290 1932  d1613
		//init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'd1125};	// FRAME_LENGTH_LINES      d750 
		//init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'd550 };	// LINE_LENGTH_PCK         d825 
		//init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'd1000};	// COARSE_INTEGRATION_TIME d4000
		//init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC    1    3
		//init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC
		//init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		//init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		//init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		//init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		////2200x1125 1920x1080
		//init_rom[210] = {{ADDR_CMD,WR},16'h3002,16'd2   };	// Y_ADDR_START
		//init_rom[211] = {{ADDR_CMD,WR},16'h3004,16'd2   };	// X_ADDR_START
		//init_rom[212] = {{ADDR_CMD,WR},16'h3006,16'd1081};	// Y_ADDR_END
		//init_rom[213] = {{ADDR_CMD,WR},16'h3008,16'd1921};	// X_ADDR_END
		//init_rom[214] = {{ADDR_CMD,WR},16'h300A,16'd1125};	// FRAME_LENGTH_LINES
		//init_rom[215] = {{ADDR_CMD,WR},16'h300C,16'd1100};	// LINE_LENGTH_PCK
		//init_rom[216] = {{ADDR_CMD,WR},16'h3012,16'd1000};	// COARSE_INTEGRATION_TIME
		//init_rom[217] = {{ADDR_CMD,WR},16'h30A2,16'h0001};	// X_ODD_INC
		//init_rom[218] = {{ADDR_CMD,WR},16'h30A6,16'h0001};	// Y_ODD_INC
		//init_rom[219] = {{ADDR_CMD,WR},16'h30AE,16'h0001};	// X_ODD_INC_CB
		//init_rom[220] = {{ADDR_CMD,WR},16'h30A8,16'h0001};	// Y_ODD_INC_CB
		//init_rom[221] = {{ADDR_CMD,WR},16'h3040,16'h0000};	// READ_MODE
		//init_rom[222] = {{ADDR_CMD,WR},16'h31AE,16'h0301};	// SERIAL_FORMAT
		
		
		//Linear Mode Setup
		init_rom[223] = {{ADDR_CMD,WR},16'h3082,16'h0009};	// OPERATION_MODE_CTRL h0009//h0008
		init_rom[224] = {{ADDR_CMD,WR},16'h30BA,16'h760C};	// DIGITAL_CTRL        h760C//h760C
		//2D Defect Correction
		init_rom[225] = {{ADDR_CMD,WR},16'h31E0,16'h0200};	// PIX_DEF_ID          h0200//h0200
		//Motion Compensation Off
		init_rom[226] = {{ADDR_CMD,WR},16'h318C,16'h0000};	// HDR_MC_CTRL2
		//Linear Mode Low Conversion Gain
		init_rom[227] = {{ADDR_CMD,WR},16'h3176,16'h0080};	// RESERVED_MFR_3176
		init_rom[228] = {{ADDR_CMD,WR},16'h3178,16'h0080};	// RESERVED_MFR_3178
		init_rom[229] = {{ADDR_CMD,WR},16'h317A,16'h0080};	// RESERVED_MFR_317A
		init_rom[230] = {{ADDR_CMD,WR},16'h317C,16'h0080};	// RESERVED_MFR_317C
		//ALTM Bypassed
		init_rom[231] = {{ADDR_CMD,WR},16'h2400,16'h0003};	// ALTM_CONTROL        h0003//h0002
		init_rom[232] = {{ADDR_CMD,WR},16'h301E,16'h00A8};	// DATA_PEDESTAL       h00A8//h0000
		init_rom[233] = {{ADDR_CMD,WR},16'h2450,16'h0000};	// ALTM_OUT_PEDESTAL
		init_rom[234] = {{ADDR_CMD,WR},16'h320A,16'h0080};	// ADACD_PEDESTAL
		//Digital gain
		init_rom[235] = {{ADDR_CMD,WR},16'h305E,16'h0085};	// GLOBAL_GAIN
		init_rom[236] = {{ADDR_CMD,WR},16'h3056,16'h0085};	// green1_gain
		init_rom[237] = {{ADDR_CMD,WR},16'h3058,16'h00DA};	// blue_gain DA CD 
		init_rom[238] = {{ADDR_CMD,WR},16'h305A,16'h00D8};	// red_gain  D8 C5 
		init_rom[239] = {{ADDR_CMD,WR},16'h305C,16'h0085};	// green2_gain
		//ADACD_Low_Conversion_Gain
		init_rom[240] = {{ADDR_CMD,WR},16'h3100,16'h0004};	// AECTRLREG
		init_rom[241] = {{ADDR_CMD,WR},16'h3096,16'h0080};	// ROW_NOISE_ADJUST_TOP
		init_rom[242] = {{ADDR_CMD,WR},16'h3098,16'h0080};	// ROW_NOISE_ADJUST_BTM
		init_rom[243] = {{ADDR_CMD,WR},16'h3202,16'h0080};	// ADACD_NOISE_MODEL1 h00B0 h0080
		init_rom[244] = {{ADDR_CMD,WR},16'h3206,16'h0B08};	// ADACD_NOISE_FLOOR1 h1C0E h0B08
		init_rom[245] = {{ADDR_CMD,WR},16'h3208,16'h1E13};	// ADACD_NOISE_FLOOR2 h4E39 h1E13
		//1.5x analog Gain
		init_rom[246] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN
		//ADACD Disabled
		init_rom[247] = {{ADDR_CMD,WR},16'h3200,16'h0002};	// ADACD_CONTROL
		//Companding Disabled
		init_rom[248] = {{ADDR_CMD,WR},16'h31D0,16'h0000};	// COMPANDING
		
		//Enable Embedded Data and Stats
		init_rom[249] = {{ADDR_CMD,WR},16'h306E,16'h9011};	// datapath_select 
		init_rom[250] = {{ADDR_CMD,WR},16'h3064,16'h1802};	// SMIA_TEST
		init_rom[251] = {{ADDR_CMD,WR},16'h301A,16'h10DC};	// RESET_REGISTER
		
		//test pattern
		init_rom[252] = {{ADDR_CMD,WR},16'h3070,16'h0000};	// test pattern
		init_rom[253] = {{ADDR_CMD,WR},16'h3072,16'h000A};	// R
		init_rom[254] = {{ADDR_CMD,WR},16'h3074,16'h000B};	// G
		init_rom[255] = {{ADDR_CMD,WR},16'h3078,16'h000C};	// G
		init_rom[256] = {{ADDR_CMD,WR},16'h3076,16'h000D};	// B
		
		cfg_rom[0] = {{ADDR_CMD,WR},16'h3012,16'h0440};	// COARSE_INTEGRATION_TIME      | B h02E0
		cfg_rom[1] = {{ADDR_CMD,WR},16'h3060,16'h0020};	// ANALOG_GAIN                  |   h0020
		
		cfg_rom[2] = {{ADDR_CMD,WR},16'h3012,16'h0440};	// COARSE_INTEGRATION_TIME      | M h02E0
		cfg_rom[3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
		
		cfg_rom[4] = {{ADDR_CMD,WR},16'h3012,16'h0220};	// COARSE_INTEGRATION_TIME      | D h0017
		cfg_rom[5] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0001
		
		cfg_rom[6] = {{ADDR_CMD,WR},16'h3012,16'h0044};	// COARSE_INTEGRATION_TIME      | M h02E0
		cfg_rom[7] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
		
		
		/*
		init_rom[0  ] = {{ADDR_CMD,WR},16'h301A,16'h0001};             //RESET_REGISTER
		init_rom[1  ] = {{DELAY_CMD,1'b0},RESET_DELAY_CYCLES};         //DELAY=50ms
		init_rom[2  ] = {{ADDR_CMD,WR},16'h301A,16'h005C};             //RESET_REGISTER
		init_rom[3  ] = {{DELAY_CMD,1'b0},RESET_release_DELAY_CYCLES}; //DELAY=200ms
		
		init_rom[4  ] = {{ADDR_CMD,WR},16'h3088,16'h8242};// SEQ_CTRL_PORT 
		init_rom[5  ] = {{ADDR_CMD,WR},16'h3086,16'h4558};// SEQ_DATA_PORT 
		init_rom[6  ] = {{ADDR_CMD,WR},16'h3086,16'h729B};// SEQ_DATA_PORT 
		init_rom[7  ] = {{ADDR_CMD,WR},16'h3086,16'h4A31};// SEQ_DATA_PORT 
		init_rom[8  ] = {{ADDR_CMD,WR},16'h3086,16'h4342};// SEQ_DATA_PORT 
		init_rom[9  ] = {{ADDR_CMD,WR},16'h3086,16'h8E03};// SEQ_DATA_PORT 
		init_rom[10 ] = {{ADDR_CMD,WR},16'h3086,16'h2A14};// SEQ_DATA_PORT 
		init_rom[11 ] = {{ADDR_CMD,WR},16'h3086,16'h4578};// SEQ_DATA_PORT 
		init_rom[12 ] = {{ADDR_CMD,WR},16'h3086,16'h7B3D};// SEQ_DATA_PORT 
		init_rom[13 ] = {{ADDR_CMD,WR},16'h3086,16'hFF3D};// SEQ_DATA_PORT 
		init_rom[14 ] = {{ADDR_CMD,WR},16'h3086,16'hFF3D};// SEQ_DATA_PORT 
		init_rom[15 ] = {{ADDR_CMD,WR},16'h3086,16'hEA2A};// SEQ_DATA_PORT 
		init_rom[16 ] = {{ADDR_CMD,WR},16'h3086,16'h043D};// SEQ_DATA_PORT 
		init_rom[17 ] = {{ADDR_CMD,WR},16'h3086,16'h102A};// SEQ_DATA_PORT 
		init_rom[18 ] = {{ADDR_CMD,WR},16'h3086,16'h052A};// SEQ_DATA_PORT 
		init_rom[19 ] = {{ADDR_CMD,WR},16'h3086,16'h1535};// SEQ_DATA_PORT 
		init_rom[20 ] = {{ADDR_CMD,WR},16'h3086,16'h2A05};// SEQ_DATA_PORT 
		init_rom[21 ] = {{ADDR_CMD,WR},16'h3086,16'h3D10};// SEQ_DATA_PORT 
		init_rom[22 ] = {{ADDR_CMD,WR},16'h3086,16'h4558};// SEQ_DATA_PORT 
		init_rom[23 ] = {{ADDR_CMD,WR},16'h3086,16'h2A04};// SEQ_DATA_PORT 
		init_rom[24 ] = {{ADDR_CMD,WR},16'h3086,16'h2A14};// SEQ_DATA_PORT 
		init_rom[25 ] = {{ADDR_CMD,WR},16'h3086,16'h3DFF};// SEQ_DATA_PORT 
		init_rom[26 ] = {{ADDR_CMD,WR},16'h3086,16'h3DFF};// SEQ_DATA_PORT 
		init_rom[27 ] = {{ADDR_CMD,WR},16'h3086,16'h3DEA};// SEQ_DATA_PORT 
		init_rom[28 ] = {{ADDR_CMD,WR},16'h3086,16'h2A04};// SEQ_DATA_PORT 
		init_rom[29 ] = {{ADDR_CMD,WR},16'h3086,16'h622A};// SEQ_DATA_PORT 
		init_rom[30 ] = {{ADDR_CMD,WR},16'h3086,16'h288E};// SEQ_DATA_PORT 
		init_rom[31 ] = {{ADDR_CMD,WR},16'h3086,16'h0036};// SEQ_DATA_PORT 
		init_rom[32 ] = {{ADDR_CMD,WR},16'h3086,16'h2A08};// SEQ_DATA_PORT 
		init_rom[33 ] = {{ADDR_CMD,WR},16'h3086,16'h3D64};// SEQ_DATA_PORT 
		init_rom[34 ] = {{ADDR_CMD,WR},16'h3086,16'h7A3D};// SEQ_DATA_PORT 
		init_rom[35 ] = {{ADDR_CMD,WR},16'h3086,16'h0444};// SEQ_DATA_PORT 
		init_rom[36 ] = {{ADDR_CMD,WR},16'h3086,16'h2C4B};// SEQ_DATA_PORT 
		init_rom[37 ] = {{ADDR_CMD,WR},16'h3086,16'h8F03};// SEQ_DATA_PORT 
		init_rom[38 ] = {{ADDR_CMD,WR},16'h3086,16'h430D};// SEQ_DATA_PORT 
		init_rom[39 ] = {{ADDR_CMD,WR},16'h3086,16'h2D46};// SEQ_DATA_PORT 
		init_rom[40 ] = {{ADDR_CMD,WR},16'h3086,16'h4316};// SEQ_DATA_PORT 
		init_rom[41 ] = {{ADDR_CMD,WR},16'h3086,16'h5F16};// SEQ_DATA_PORT 
		init_rom[42 ] = {{ADDR_CMD,WR},16'h3086,16'h530D};// SEQ_DATA_PORT 
		init_rom[43 ] = {{ADDR_CMD,WR},16'h3086,16'h1660};// SEQ_DATA_PORT 
		init_rom[44 ] = {{ADDR_CMD,WR},16'h3086,16'h3E4C};// SEQ_DATA_PORT 
		init_rom[45 ] = {{ADDR_CMD,WR},16'h3086,16'h2904};// SEQ_DATA_PORT 
		init_rom[46 ] = {{ADDR_CMD,WR},16'h3086,16'h2984};// SEQ_DATA_PORT 
		init_rom[47 ] = {{ADDR_CMD,WR},16'h3086,16'h8E03};// SEQ_DATA_PORT 
		init_rom[48 ] = {{ADDR_CMD,WR},16'h3086,16'h2AFC};// SEQ_DATA_PORT 
		init_rom[49 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1D};// SEQ_DATA_PORT 
		init_rom[50 ] = {{ADDR_CMD,WR},16'h3086,16'h5754};// SEQ_DATA_PORT 
		init_rom[51 ] = {{ADDR_CMD,WR},16'h3086,16'h495F};// SEQ_DATA_PORT 
		init_rom[52 ] = {{ADDR_CMD,WR},16'h3086,16'h5305};// SEQ_DATA_PORT 
		init_rom[53 ] = {{ADDR_CMD,WR},16'h3086,16'h5307};// SEQ_DATA_PORT 
		init_rom[54 ] = {{ADDR_CMD,WR},16'h3086,16'h4D2B};// SEQ_DATA_PORT 
		init_rom[55 ] = {{ADDR_CMD,WR},16'h3086,16'hF810};// SEQ_DATA_PORT 
		init_rom[56 ] = {{ADDR_CMD,WR},16'h3086,16'h164C};// SEQ_DATA_PORT 
		init_rom[57 ] = {{ADDR_CMD,WR},16'h3086,16'h0955};// SEQ_DATA_PORT 
		init_rom[58 ] = {{ADDR_CMD,WR},16'h3086,16'h562B};// SEQ_DATA_PORT 
		init_rom[59 ] = {{ADDR_CMD,WR},16'h3086,16'hB82B};// SEQ_DATA_PORT 
		init_rom[60 ] = {{ADDR_CMD,WR},16'h3086,16'h984E};// SEQ_DATA_PORT 
		init_rom[61 ] = {{ADDR_CMD,WR},16'h3086,16'h1129};// SEQ_DATA_PORT 
		init_rom[62 ] = {{ADDR_CMD,WR},16'h3086,16'h9460};// SEQ_DATA_PORT 
		init_rom[63 ] = {{ADDR_CMD,WR},16'h3086,16'h5C19};// SEQ_DATA_PORT 
		init_rom[64 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1B};// SEQ_DATA_PORT 
		init_rom[65 ] = {{ADDR_CMD,WR},16'h3086,16'h4548};// SEQ_DATA_PORT 
		init_rom[66 ] = {{ADDR_CMD,WR},16'h3086,16'h4508};// SEQ_DATA_PORT 
		init_rom[67 ] = {{ADDR_CMD,WR},16'h3086,16'h4588};// SEQ_DATA_PORT 
		init_rom[68 ] = {{ADDR_CMD,WR},16'h3086,16'h29B6};// SEQ_DATA_PORT 
		init_rom[69 ] = {{ADDR_CMD,WR},16'h3086,16'h8E01};// SEQ_DATA_PORT 
		init_rom[70 ] = {{ADDR_CMD,WR},16'h3086,16'h2AF8};// SEQ_DATA_PORT 
		init_rom[71 ] = {{ADDR_CMD,WR},16'h3086,16'h3E02};// SEQ_DATA_PORT 
		init_rom[72 ] = {{ADDR_CMD,WR},16'h3086,16'h2AFA};// SEQ_DATA_PORT 
		init_rom[73 ] = {{ADDR_CMD,WR},16'h3086,16'h3F09};// SEQ_DATA_PORT 
		init_rom[74 ] = {{ADDR_CMD,WR},16'h3086,16'h5C1B};// SEQ_DATA_PORT 
		init_rom[75 ] = {{ADDR_CMD,WR},16'h3086,16'h29B2};// SEQ_DATA_PORT 
		init_rom[76 ] = {{ADDR_CMD,WR},16'h3086,16'h3F0C};// SEQ_DATA_PORT 
		init_rom[77 ] = {{ADDR_CMD,WR},16'h3086,16'h3E03};// SEQ_DATA_PORT 
		init_rom[78 ] = {{ADDR_CMD,WR},16'h3086,16'h3E15};// SEQ_DATA_PORT 
		init_rom[79 ] = {{ADDR_CMD,WR},16'h3086,16'h5C13};// SEQ_DATA_PORT 
		init_rom[80 ] = {{ADDR_CMD,WR},16'h3086,16'h3F11};// SEQ_DATA_PORT 
		init_rom[81 ] = {{ADDR_CMD,WR},16'h3086,16'h3E0F};// SEQ_DATA_PORT 
		init_rom[82 ] = {{ADDR_CMD,WR},16'h3086,16'h5F2B};// SEQ_DATA_PORT 
		init_rom[83 ] = {{ADDR_CMD,WR},16'h3086,16'h902A};// SEQ_DATA_PORT 
		init_rom[84 ] = {{ADDR_CMD,WR},16'h3086,16'hF22B};// SEQ_DATA_PORT 
		init_rom[85 ] = {{ADDR_CMD,WR},16'h3086,16'h803E};// SEQ_DATA_PORT 
		init_rom[86 ] = {{ADDR_CMD,WR},16'h3086,16'h063F};// SEQ_DATA_PORT 
		init_rom[87 ] = {{ADDR_CMD,WR},16'h3086,16'h0660};// SEQ_DATA_PORT 
		init_rom[88 ] = {{ADDR_CMD,WR},16'h3086,16'h29A2};// SEQ_DATA_PORT 
		init_rom[89 ] = {{ADDR_CMD,WR},16'h3086,16'h29A3};// SEQ_DATA_PORT 
		init_rom[90 ] = {{ADDR_CMD,WR},16'h3086,16'h5F4D};// SEQ_DATA_PORT 
		init_rom[91 ] = {{ADDR_CMD,WR},16'h3086,16'h1C2A};// SEQ_DATA_PORT 
		init_rom[92 ] = {{ADDR_CMD,WR},16'h3086,16'hFA29};// SEQ_DATA_PORT 
		init_rom[93 ] = {{ADDR_CMD,WR},16'h3086,16'h8345};// SEQ_DATA_PORT 
		init_rom[94 ] = {{ADDR_CMD,WR},16'h3086,16'hA83E};// SEQ_DATA_PORT 
		init_rom[95 ] = {{ADDR_CMD,WR},16'h3086,16'h072A};// SEQ_DATA_PORT 
		init_rom[96 ] = {{ADDR_CMD,WR},16'h3086,16'hFB3E};// SEQ_DATA_PORT 
		init_rom[97 ] = {{ADDR_CMD,WR},16'h3086,16'h2945};// SEQ_DATA_PORT 
		init_rom[98 ] = {{ADDR_CMD,WR},16'h3086,16'h8824};// SEQ_DATA_PORT 
		init_rom[99 ] = {{ADDR_CMD,WR},16'h3086,16'h3E08};// SEQ_DATA_PORT 
		init_rom[100] = {{ADDR_CMD,WR},16'h3086,16'h2AFA};// SEQ_DATA_PORT 
		init_rom[101] = {{ADDR_CMD,WR},16'h3086,16'h5D29};// SEQ_DATA_PORT 
		init_rom[102] = {{ADDR_CMD,WR},16'h3086,16'h9288};// SEQ_DATA_PORT 
		init_rom[103] = {{ADDR_CMD,WR},16'h3086,16'h102B};// SEQ_DATA_PORT 
		init_rom[104] = {{ADDR_CMD,WR},16'h3086,16'h048B};// SEQ_DATA_PORT 
		init_rom[105] = {{ADDR_CMD,WR},16'h3086,16'h1686};// SEQ_DATA_PORT 
		init_rom[106] = {{ADDR_CMD,WR},16'h3086,16'h8D48};// SEQ_DATA_PORT 
		init_rom[107] = {{ADDR_CMD,WR},16'h3086,16'h4D4E};// SEQ_DATA_PORT 
		init_rom[108] = {{ADDR_CMD,WR},16'h3086,16'h2B80};// SEQ_DATA_PORT 
		init_rom[109] = {{ADDR_CMD,WR},16'h3086,16'h4C0B};// SEQ_DATA_PORT 
		init_rom[110] = {{ADDR_CMD,WR},16'h3086,16'h603F};// SEQ_DATA_PORT 
		init_rom[111] = {{ADDR_CMD,WR},16'h3086,16'h302A};// SEQ_DATA_PORT 
		init_rom[112] = {{ADDR_CMD,WR},16'h3086,16'hF23F};// SEQ_DATA_PORT 
		init_rom[113] = {{ADDR_CMD,WR},16'h3086,16'h1029};// SEQ_DATA_PORT 
		init_rom[114] = {{ADDR_CMD,WR},16'h3086,16'h8229};// SEQ_DATA_PORT 
		init_rom[115] = {{ADDR_CMD,WR},16'h3086,16'h8329};// SEQ_DATA_PORT 
		init_rom[116] = {{ADDR_CMD,WR},16'h3086,16'h435C};// SEQ_DATA_PORT 
		init_rom[117] = {{ADDR_CMD,WR},16'h3086,16'h155F};// SEQ_DATA_PORT 
		init_rom[118] = {{ADDR_CMD,WR},16'h3086,16'h4D1C};// SEQ_DATA_PORT 
		init_rom[119] = {{ADDR_CMD,WR},16'h3086,16'h2AFA};// SEQ_DATA_PORT 
		init_rom[120] = {{ADDR_CMD,WR},16'h3086,16'h4558};// SEQ_DATA_PORT 
		init_rom[121] = {{ADDR_CMD,WR},16'h3086,16'h8E00};// SEQ_DATA_PORT 
		init_rom[122] = {{ADDR_CMD,WR},16'h3086,16'h2A98};// SEQ_DATA_PORT 
		init_rom[123] = {{ADDR_CMD,WR},16'h3086,16'h3F0A};// SEQ_DATA_PORT 
		init_rom[124] = {{ADDR_CMD,WR},16'h3086,16'h4A0A};// SEQ_DATA_PORT 
		init_rom[125] = {{ADDR_CMD,WR},16'h3086,16'h4316};// SEQ_DATA_PORT 
		init_rom[126] = {{ADDR_CMD,WR},16'h3086,16'h0B43};// SEQ_DATA_PORT 
		init_rom[127] = {{ADDR_CMD,WR},16'h3086,16'h168E};// SEQ_DATA_PORT 
		init_rom[128] = {{ADDR_CMD,WR},16'h3086,16'h032A};// SEQ_DATA_PORT 
		init_rom[129] = {{ADDR_CMD,WR},16'h3086,16'h9C45};// SEQ_DATA_PORT 
		init_rom[130] = {{ADDR_CMD,WR},16'h3086,16'h783F};// SEQ_DATA_PORT 
		init_rom[131] = {{ADDR_CMD,WR},16'h3086,16'h072A};// SEQ_DATA_PORT 
		init_rom[132] = {{ADDR_CMD,WR},16'h3086,16'h9D3E};// SEQ_DATA_PORT 
		init_rom[133] = {{ADDR_CMD,WR},16'h3086,16'h305D};// SEQ_DATA_PORT 
		init_rom[134] = {{ADDR_CMD,WR},16'h3086,16'h2944};// SEQ_DATA_PORT 
		init_rom[135] = {{ADDR_CMD,WR},16'h3086,16'h8810};// SEQ_DATA_PORT 
		init_rom[136] = {{ADDR_CMD,WR},16'h3086,16'h2B04};// SEQ_DATA_PORT 
		init_rom[137] = {{ADDR_CMD,WR},16'h3086,16'h530D};// SEQ_DATA_PORT 
		init_rom[138] = {{ADDR_CMD,WR},16'h3086,16'h4558};// SEQ_DATA_PORT 
		init_rom[139] = {{ADDR_CMD,WR},16'h3086,16'h3E08};// SEQ_DATA_PORT 
		init_rom[140] = {{ADDR_CMD,WR},16'h3086,16'h8E01};// SEQ_DATA_PORT 
		init_rom[141] = {{ADDR_CMD,WR},16'h3086,16'h2A98};// SEQ_DATA_PORT 
		init_rom[142] = {{ADDR_CMD,WR},16'h3086,16'h8E00};// SEQ_DATA_PORT 
		init_rom[143] = {{ADDR_CMD,WR},16'h3086,16'h769C};// SEQ_DATA_PORT 
		init_rom[144] = {{ADDR_CMD,WR},16'h3086,16'h779C};// SEQ_DATA_PORT 
		init_rom[145] = {{ADDR_CMD,WR},16'h3086,16'h4644};// SEQ_DATA_PORT 
		init_rom[146] = {{ADDR_CMD,WR},16'h3086,16'h1616};// SEQ_DATA_PORT 
		init_rom[147] = {{ADDR_CMD,WR},16'h3086,16'h907A};// SEQ_DATA_PORT 
		init_rom[148] = {{ADDR_CMD,WR},16'h3086,16'h1244};// SEQ_DATA_PORT 
		init_rom[149] = {{ADDR_CMD,WR},16'h3086,16'h4B18};// SEQ_DATA_PORT 
		init_rom[150] = {{ADDR_CMD,WR},16'h3086,16'h4A04};// SEQ_DATA_PORT 
		init_rom[151] = {{ADDR_CMD,WR},16'h3086,16'h4316};// SEQ_DATA_PORT 
		init_rom[152] = {{ADDR_CMD,WR},16'h3086,16'h0643};// SEQ_DATA_PORT 
		init_rom[153] = {{ADDR_CMD,WR},16'h3086,16'h1605};// SEQ_DATA_PORT 
		init_rom[154] = {{ADDR_CMD,WR},16'h3086,16'h4316};// SEQ_DATA_PORT 
		init_rom[155] = {{ADDR_CMD,WR},16'h3086,16'h0743};// SEQ_DATA_PORT 
		init_rom[156] = {{ADDR_CMD,WR},16'h3086,16'h1658};// SEQ_DATA_PORT 
		init_rom[157] = {{ADDR_CMD,WR},16'h3086,16'h4316};// SEQ_DATA_PORT 
		init_rom[158] = {{ADDR_CMD,WR},16'h3086,16'h5A43};// SEQ_DATA_PORT 
		init_rom[159] = {{ADDR_CMD,WR},16'h3086,16'h1645};// SEQ_DATA_PORT 
		init_rom[160] = {{ADDR_CMD,WR},16'h3086,16'h588E};// SEQ_DATA_PORT 
		init_rom[161] = {{ADDR_CMD,WR},16'h3086,16'h032A};// SEQ_DATA_PORT 
		init_rom[162] = {{ADDR_CMD,WR},16'h3086,16'h9C45};// SEQ_DATA_PORT 
		init_rom[163] = {{ADDR_CMD,WR},16'h3086,16'h787B};// SEQ_DATA_PORT 
		init_rom[164] = {{ADDR_CMD,WR},16'h3086,16'h3F07};// SEQ_DATA_PORT 
		init_rom[165] = {{ADDR_CMD,WR},16'h3086,16'h2A9D};// SEQ_DATA_PORT 
		init_rom[166] = {{ADDR_CMD,WR},16'h3086,16'h530D};// SEQ_DATA_PORT 
		init_rom[167] = {{ADDR_CMD,WR},16'h3086,16'h8B16};// SEQ_DATA_PORT 
		init_rom[168] = {{ADDR_CMD,WR},16'h3086,16'h863E};// SEQ_DATA_PORT 
		init_rom[169] = {{ADDR_CMD,WR},16'h3086,16'h2345};// SEQ_DATA_PORT 
		init_rom[170] = {{ADDR_CMD,WR},16'h3086,16'h5825};// SEQ_DATA_PORT 
		init_rom[171] = {{ADDR_CMD,WR},16'h3086,16'h3E10};// SEQ_DATA_PORT 
		init_rom[172] = {{ADDR_CMD,WR},16'h3086,16'h8E01};// SEQ_DATA_PORT 
		init_rom[173] = {{ADDR_CMD,WR},16'h3086,16'h2A98};// SEQ_DATA_PORT 
		init_rom[174] = {{ADDR_CMD,WR},16'h3086,16'h8E00};// SEQ_DATA_PORT 
		init_rom[175] = {{ADDR_CMD,WR},16'h3086,16'h3E10};// SEQ_DATA_PORT 
		init_rom[176] = {{ADDR_CMD,WR},16'h3086,16'h8D60};// SEQ_DATA_PORT 
		init_rom[177] = {{ADDR_CMD,WR},16'h3086,16'h1244};// SEQ_DATA_PORT 
		init_rom[178] = {{ADDR_CMD,WR},16'h3086,16'h4B2C};// SEQ_DATA_PORT 
		init_rom[179] = {{ADDR_CMD,WR},16'h3086,16'h2C2C};// SEQ_DATA_PORT 
		init_rom[180] = {{ADDR_CMD,WR},16'h3ED6,16'h34B3};// DAC_LD_10_11 
		init_rom[181] = {{ADDR_CMD,WR},16'h2436,16'h000E};// ALTM_CONTROL_AVERAGED_LUMA_NOISE_FLOOR
		init_rom[182] = {{ADDR_CMD,WR},16'h320C,16'h0180};// ADACD_GAIN_THRESHOLD_0
		init_rom[183] = {{ADDR_CMD,WR},16'h320E,16'h0300};// ADACD_GAIN_THRESHOLD_1
		init_rom[184] = {{ADDR_CMD,WR},16'h3210,16'h0500};// ADACD_GAIN_THRESHOLD_2
		init_rom[185] = {{ADDR_CMD,WR},16'h3204,16'h0B6D};// ADACD_NOISE_MODEL2
		init_rom[186] = {{ADDR_CMD,WR},16'h30FE,16'h0080};// NOISE_PEDESTAL 
		init_rom[187] = {{ADDR_CMD,WR},16'h3ED8,16'h7B99};// DAC_LD_12_13 
		init_rom[188] = {{ADDR_CMD,WR},16'h3EDC,16'h9BA8};// DAC_LD_16_17
		init_rom[189] = {{ADDR_CMD,WR},16'h3EDA,16'h9B9B};// DAC_LD_14_15
		init_rom[190] = {{ADDR_CMD,WR},16'h3092,16'h006F};// ROW_NOISE_CONTROL
		init_rom[191] = {{ADDR_CMD,WR},16'h3EEC,16'h1C04};// DAC_LD_32_33
		init_rom[192] = {{ADDR_CMD,WR},16'h30BA,16'h779C};// DIGITAL_CTRL
		init_rom[193] = {{ADDR_CMD,WR},16'h3EF6,16'hA70F};// DAC_LD_42_43
		init_rom[194] = {{ADDR_CMD,WR},16'h3044,16'h0410};// DARK_CONTROL
		init_rom[195] = {{ADDR_CMD,WR},16'h3ED0,16'hFF44};// DAC_LD_4_5
		init_rom[196] = {{ADDR_CMD,WR},16'h3ED4,16'h031F};// DAC_LD_8_9
		init_rom[197] = {{ADDR_CMD,WR},16'h30FE,16'h0080};// NOISE_PEDESTAL
		init_rom[198] = {{ADDR_CMD,WR},16'h3EE2,16'h8866};// DAC_LD_22_23
		init_rom[199] = {{ADDR_CMD,WR},16'h3EE4,16'h6623};// DAC_LD_24_25
		init_rom[200] = {{ADDR_CMD,WR},16'h3EE6,16'h2263};// DAC_LD_26_27
		init_rom[201] = {{ADDR_CMD,WR},16'h30E0,16'h4283};// ADC_COMMAND1
		init_rom[202] = {{ADDR_CMD,WR},16'h30F0,16'h1283};// ADC_COMMAND1_HS
		init_rom[203] = {{ADDR_CMD,WR},16'h301A,16'h005C};// RESET_REGISTER
		
		init_rom[204] = {{ADDR_CMD,WR},16'h30B0,16'h0118};// DIGITAL_TEST
		init_rom[205] = {{ADDR_CMD,WR},16'h31AC,16'h0C0C};// DATA_FORMAT_BITS
		
		init_rom[206] = {{ADDR_CMD,WR},16'h302A,16'h0006};// VT_PIX_CLK_DIV
		init_rom[207] = {{ADDR_CMD,WR},16'h302C,16'h0001};// VT_SYS_CLK_DIV
		init_rom[208] = {{ADDR_CMD,WR},16'h302E,16'h0004};// PRE_PLL_CLK_DIV
		init_rom[209] = {{ADDR_CMD,WR},16'h3030,16'h0042};// PLL_MULTIPLIER
		init_rom[210] = {{ADDR_CMD,WR},16'h3036,16'h000C};// OP_PIX_CLK_DIV
		init_rom[211] = {{ADDR_CMD,WR},16'h3038,16'h0001};// OP_SYS_CLK_DIV
		//init_rom[204] = {{ADDR_CMD,WR},16'h302A,16'h0006};	//VT_PIX_CLK_DIV = 6
		//init_rom[205] = {{ADDR_CMD,WR},16'h302C,16'h0001};	//VT_SYS_CLK_DIV = 1
		//init_rom[206] = {{ADDR_CMD,WR},16'h302E,16'h0004};	//PRE_PLL_CLK_DIV = 4
		//init_rom[207] = {{ADDR_CMD,WR},16'h3030,16'h0042};	//PLL_MULTIPLIER = 66
		//init_rom[208] = {{ADDR_CMD,WR},16'h3036,16'h000C};	//OP_PIX_CLK_DIV = 12
		//init_rom[209] = {{ADDR_CMD,WR},16'h3038,16'h0001};	//OP_SYS_CLK_DIV = 1
		
		init_rom[212] = {{ADDR_CMD,WR},16'h3002,16'h0000};// Y_ADDR_START
		init_rom[213] = {{ADDR_CMD,WR},16'h3004,16'h0000};// X_ADDR_START
		init_rom[214] = {{ADDR_CMD,WR},16'h3006,16'h0437};// Y_ADDR_END
		init_rom[215] = {{ADDR_CMD,WR},16'h3008,16'h077F};// X_ADDR_END
		init_rom[216] = {{ADDR_CMD,WR},16'h300A,16'h0465};// FRAME_LENGTH_LINES
		init_rom[217] = {{ADDR_CMD,WR},16'h300C,16'h044C};// LINE_LENGTH_PCK
		init_rom[218] = {{ADDR_CMD,WR},16'h3012,16'h0416};// COARSE_INTEGRATION_TIME
		init_rom[219] = {{ADDR_CMD,WR},16'h3060,16'h000B};// ANALOG_GAIN
		init_rom[220] = {{ADDR_CMD,WR},16'h30A2,16'h0001};// X_ODD_INC
		init_rom[221] = {{ADDR_CMD,WR},16'h30A6,16'h0001};// Y_ODD_INC
		init_rom[222] = {{ADDR_CMD,WR},16'h30AE,16'h0001};// X_ODD_INC_CB
		init_rom[223] = {{ADDR_CMD,WR},16'h30A8,16'h0001};// Y_ODD_INC_CB
		
		//Digital gain
		init_rom[224] = {{ADDR_CMD,WR},16'h305E,16'h0085};// GLOBAL_GAIN
		init_rom[225] = {{ADDR_CMD,WR},16'h3056,16'h0085};// green1_gain
		init_rom[226] = {{ADDR_CMD,WR},16'h3058,16'h00DA};// blue_gain DA CD 
		init_rom[227] = {{ADDR_CMD,WR},16'h305A,16'h00D8};// red_gain  D8 C5 
		init_rom[228] = {{ADDR_CMD,WR},16'h305C,16'h0085};// green2_gain
		
		init_rom[229] = {{ADDR_CMD,WR},16'h3040,16'h0000};// READ_MODE
		init_rom[230] = {{ADDR_CMD,WR},16'h31AE,16'h0304};// SERIAL_FORMAT
		init_rom[231] = {{ADDR_CMD,WR},16'h31C6,16'h0400};// HISPI_CONTROL_STATUS
		
		init_rom[232] = {{ADDR_CMD,WR},16'h3082,16'h0009};// OPERATION_MODE_CTRL
		init_rom[233] = {{ADDR_CMD,WR},16'h30BA,16'h769C};// DIGITAL_CTRL
		
		init_rom[234] = {{ADDR_CMD,WR},16'h3096,16'h0080};// ROW_NOISE_ADJUST_TOP
		init_rom[235] = {{ADDR_CMD,WR},16'h3098,16'h0080};// ROW_NOISE_ADJUST_BTM
		init_rom[236] = {{ADDR_CMD,WR},16'h31E0,16'h0200};// PIX_DEF_ID
		init_rom[237] = {{ADDR_CMD,WR},16'h318C,16'h0000};// HDR_MC_CTRL2
		init_rom[238] = {{ADDR_CMD,WR},16'h3176,16'h0080};// DELTA_DK_ADJUST_GREENR
		init_rom[239] = {{ADDR_CMD,WR},16'h3178,16'h0080};// DELTA_DK_ADJUST_RED
		init_rom[240] = {{ADDR_CMD,WR},16'h317A,16'h0080};// DELTA_DK_ADJUST_BLUE
		init_rom[241] = {{ADDR_CMD,WR},16'h317C,16'h0080};// DELTA_DK_ADJUST_GREENB
		init_rom[242] = {{ADDR_CMD,WR},16'h3206,16'h0B08};// ADACD_NOISE_FLOOR1
		init_rom[243] = {{ADDR_CMD,WR},16'h3208,16'h1E13};// ADACD_NOISE_FLOOR2
		init_rom[244] = {{ADDR_CMD,WR},16'h3202,16'h0080};// ADACD_NOISE_MODEL1
		init_rom[245] = {{ADDR_CMD,WR},16'h3200,16'h0002};// ADACD_CONTROL
		init_rom[246] = {{ADDR_CMD,WR},16'h3100,16'h0000};// AECTRLREG
		init_rom[247] = {{ADDR_CMD,WR},16'h3200,16'h0000};// ADACD_CONTROL
		init_rom[248] = {{ADDR_CMD,WR},16'h31D0,16'h0000};// COMPANDING
		init_rom[249] = {{ADDR_CMD,WR},16'h2400,16'h0003};// ALTM_CONTROL
		init_rom[250] = {{ADDR_CMD,WR},16'h301E,16'h00A8};// DATA_PEDESTAL
		init_rom[251] = {{ADDR_CMD,WR},16'h2450,16'h0000};// ALTM_OUT_PEDESTAL
		init_rom[252] = {{ADDR_CMD,WR},16'h320A,16'h0080};// ADACD_PEDESTAL
		init_rom[253] = {{ADDR_CMD,WR},16'h3064,16'h1802};// SMIA_TEST
		init_rom[254] = {{ADDR_CMD,WR},16'h306E,16'h9210};// DATAPATH_SELECT
		init_rom[255] = {{ADDR_CMD,WR},16'h31C0,{1'b1,3'd2,3'd0,3'd0,3'd0,3'd0}};
		init_rom[256] = {{ADDR_CMD,WR},16'h301A,16'h005C};// RESET_REGISTER
		
		
		//cfg_rom[0] = {{ADDR_CMD,WR},16'h31C0,{1'b1,3'd0,3'd0,3'd0,3'd0,3'd0}};
		
		cfg_rom[0] = {{ADDR_CMD,WR},16'h3012,16'h0440};	// COARSE_INTEGRATION_TIME | B h02E0
		cfg_rom[1] = {{ADDR_CMD,WR},16'h3060,16'h0020};	// ANALOG_GAIN             |   h0020
		         
		cfg_rom[2] = {{ADDR_CMD,WR},16'h3012,16'h0440};	// COARSE_INTEGRATION_TIME | M h02E0
		cfg_rom[3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN             |   h0002
		
		cfg_rom[4] = {{ADDR_CMD,WR},16'h3012,16'h0220};	// COARSE_INTEGRATION_TIME | D h0017
		cfg_rom[5] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN             |   h0001
		
		cfg_rom[6] = {{ADDR_CMD,WR},16'h3012,16'h0044};	// COARSE_INTEGRATION_TIME | M h02E0
		cfg_rom[7] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN             |   h0002
    */
  end
	// =============================================================================
	// RTL Body
	// =============================================================================
	
	always@(posedge clk)
	begin
		
		if(cfg0_data_valid)
		begin
			cfg_rom[0] = {{ADDR_CMD,WR},16'h3012,cfg0_data_IT};
			cfg_rom[1] = {{ADDR_CMD,WR},16'h3060,cfg0_data_AG};
		end
		if(cfg1_data_valid)
		begin
			cfg_rom[2] = {{ADDR_CMD,WR},16'h3012,cfg1_data_IT};
			cfg_rom[3] = {{ADDR_CMD,WR},16'h3060,cfg1_data_AG};
		end
		if(cfg2_data_valid)
		begin
			cfg_rom[4] = {{ADDR_CMD,WR},16'h3012,cfg2_data_IT};
			cfg_rom[5] = {{ADDR_CMD,WR},16'h3060,cfg2_data_AG};
		end
		if(cfg3_data_valid)
		begin
			cfg_rom[6] = {{ADDR_CMD,WR},16'h3012,cfg3_data_IT};
			cfg_rom[7] = {{ADDR_CMD,WR},16'h3060,cfg3_data_AG};
		end
		
	end
	
	reg  [15:0]  INTEGRATION_TIME_D;
	reg  [15:0]  ANALOG_GAIN_B;
	reg  [ 3:0]  BNT_valid_cnt;
	/*
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			INTEGRATION_TIME_D <= 16'h02C0;
		end
		else if(BNT_valid & INTEGRATION_TIME_D <= 16'h000B)
		begin
			INTEGRATION_TIME_D <= 16'h02C0;
		end
		else if(BNT_valid)
		begin
			INTEGRATION_TIME_D <= {1'b0,INTEGRATION_TIME_D[15:1]};//INTEGRATION_TIME + 4'd8;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			ANALOG_GAIN_B <= 16'h0001;
		end
		else if(BNT_valid & ANALOG_GAIN_B >= 16'h0040)
		begin
			ANALOG_GAIN_B <= 16'h0001;
		end
		else if(BNT_valid)
		begin
			ANALOG_GAIN_B <= {ANALOG_GAIN_B[14:0],1'b0};//INTEGRATION_TIME + 4'd8;
		end
	end
	*/
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			BNT_valid_cnt <= 0;
		end
		else if(BNT_valid & BNT_valid_cnt == 4'd10)
		begin
			BNT_valid_cnt <= 0;
		end
		else if(BNT_valid)
		begin
			BNT_valid_cnt <= BNT_valid_cnt+1'b1;
		end
	end
	/*
	always@(posedge clk or posedge reset)//
	begin
		if(reset)	
		begin
			cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
			cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
		end
		else
		begin
			case(BNT_valid_cnt)
				4'd0:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd1:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h0016};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd2:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h002C};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd3:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h0058};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd4:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h00B0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd5:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h0160};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd6:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0000};	// ANALOG_GAIN                  |   h0002
				end
				4'd7:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0010};	// ANALOG_GAIN                  |   h0002
				end
				4'd8:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0020};	// ANALOG_GAIN                  |   h0002
				end
				4'd9:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0030};	// ANALOG_GAIN                  |   h0002
				end
				4'd10:
				begin
					cfg_rom[ 2] = {{ADDR_CMD,WR},16'h3012,16'h02C0};	// COARSE_INTEGRATION_TIME      |*M h02E0
					cfg_rom[ 3] = {{ADDR_CMD,WR},16'h3060,16'h0040};	// ANALOG_GAIN                  |   h0002
				end
				default:
				begin
				end
			endcase
		end
	end
	*/
	
	
	/*
	reg  [15:0]  INTEGRATION_TIME;
	reg  [15:0]  ANALOG_GAIN;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			INTEGRATION_TIME <= 16'h000B;
			ANALOG_GAIN      <= 16'h0001;
		end
		else if(INTEGRATION_TIME >= 16'h02C0)
		begin
			if(BNT_valid & ANALOG_GAIN >= 16'h0040)
			begin
				INTEGRATION_TIME <= 16'h000B;
				ANALOG_GAIN      <= 16'h0001;
			end
			else if(BNT_valid)
			begin
				ANALOG_GAIN <= {ANALOG_GAIN[14:0],1'b0};
			end
		end
		else if(BNT_valid & INTEGRATION_TIME < 16'h02C0)
		begin
			INTEGRATION_TIME <= {INTEGRATION_TIME[14:0],1'b0};//INTEGRATION_TIME + 4'd8;
		end
	end
	
	always@(posedge clk or posedge reset)//
	begin
		//cfg_rom[ 2] <= {{ADDR_CMD,WR},16'h3012,INTEGRATION_TIME};
		if(reset)	
		begin
			cfg_rom[ 2] <= {{ADDR_CMD,WR},16'h3012,16'h02E0};
			cfg_rom[ 3] <= {{ADDR_CMD,WR},16'h3060,16'h0001};
		end
		else
		begin
			cfg_rom[ 2] <= {{ADDR_CMD,WR},16'h3012,INTEGRATION_TIME};
			cfg_rom[ 3] <= {{ADDR_CMD,WR},16'h3060,ANALOG_GAIN};
		end
	end
	*/
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			init_done <= 1'b0;
		end
		else if(init_vectors_cnt == INIT_VECTORS-1 & state == CMD_DONE)
		begin
			init_done <= 1'b1;
		end
	end
	
	assign sensor_cfg_done = init_done;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sensor_vs_d1 <= 1'b1;
			sensor_vs_d2 <= 1'b1;
			sensor_vs_d3 <= 1'b1;
			sensor_vs_d4 <= 1'b1;
		end
		else
		begin
			sensor_vs_d1 <= sensor_vs;
			sensor_vs_d2 <= sensor_vs_d1;
			sensor_vs_d3 <= sensor_vs_d2;
			sensor_vs_d4 <= sensor_vs_d3;
		end
	end
	
	assign vs_ps = sensor_vs_d3 & ~sensor_vs_d4;//1'b0;//
	
	assign init_rom_ba_da     = init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH-1:0];
	
	//assign ar0230cs_cmd_valid = (init_rom[init_vectors_cnt][2+C_BADDR_WIDTH+C_DATA_WIDTH-1] != DELAY_CMD);
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			ar0230cs_cmd_valid <= 1'b0;
		end
		else if(~init_done)
		begin
			ar0230cs_cmd_valid <= (init_rom[init_vectors_cnt][2+C_BADDR_WIDTH+C_DATA_WIDTH-1] != DELAY_CMD);
		end
		else
		begin
			ar0230cs_cmd_valid <= 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			init_rom_ba_da_t <= 0;
		end
		else
		begin
			init_rom_ba_da_t <= RESET_release_DELAY_CYCLES;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			data_addr_in_value <= 0;
		end
		else if(~init_done)
		begin
			if(state == CMD_START & ~i2c_busy & ar0230cs_cmd_valid)
			begin
				data_addr_in_value <= 1'b1;
			end
			else
			begin
				data_addr_in_value <= 0;
			end
		end
		else
		begin
			if(state == CMD_START & ~i2c_busy & cfg_valid)
			begin
				data_addr_in_value <= 1'b1;
			end
			else
			begin
				data_addr_in_value <= 0;
			end
		end
	end
	
	//assign slave_addr_in = {AR0230CS_ADDR,init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH]};
	//assign base_addr_in  = init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH-1:C_DATA_WIDTH];
	//assign data_in       = init_rom[init_vectors_cnt][C_DATA_WIDTH-1:0];
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			slave_addr_in <= {AR0230CS_ADDR,init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH]};
			base_addr_in <= init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH-1:C_DATA_WIDTH];
			data_in      <= init_rom[init_vectors_cnt][C_DATA_WIDTH-1:0];
		end
		else if(~init_done)
		begin
			slave_addr_in <= {AR0230CS_ADDR,init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH]};
			base_addr_in <= init_rom[init_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH-1:C_DATA_WIDTH];
			data_in      <= init_rom[init_vectors_cnt][C_DATA_WIDTH-1:0];
		end	
		else
		begin
			slave_addr_in <= {AR0230CS_ADDR,cfg_rom[cfg_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH]};
			base_addr_in <= cfg_rom[cfg_vectors_cnt][C_BADDR_WIDTH+C_DATA_WIDTH-1:C_DATA_WIDTH];
			data_in      <= cfg_rom[cfg_vectors_cnt][C_DATA_WIDTH-1:0];
		end	
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			init_vectors_cnt <= 'd0;
		end
		else if(state == CMD_DONE & (~init_done))
		begin
			init_vectors_cnt <= init_vectors_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			cfg_valid <= 1'b0;
		end
		else if(vs_ps)
		begin
			cfg_valid <= 1'b1;
		end
		else if(state == CMD_DONE & cfg_vectors_cnt[clog2(CFG_VECTORS)-1:0] == CFG_VECTORS-1)//
		begin
			cfg_valid <= 1'b0;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			cfg_vectors_cnt <= 'd0;
		end
		else if(state == CMD_DONE & cfg_vectors_cnt == 4*CFG_VECTORS-1)
		begin
			cfg_vectors_cnt <= 'd0;
		end
		else if(state == CMD_DONE)
		begin
			cfg_vectors_cnt <= cfg_vectors_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			bmd_flag <= 2'd0;
		end
		else if(vs_ps)
		begin
			case(cfg_vectors_cnt)
				'd0:
				begin
					bmd_flag <= 2'd0;
				end
				CFG_VECTORS:
				begin
					bmd_flag <= 2'd1;
				end
				2*CFG_VECTORS:
				begin
					bmd_flag <= 2'd2;
				end
				default:
				begin
				end
			endcase			
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			wait_cnt <= 0;
		end
		else if(state == CMD_WAIT)
		begin
			wait_cnt <= wait_cnt + 1'b1;
		end
		else
		begin
			wait_cnt <= 0;
		end
	end
	
	assign db_data_addr_in_value  = data_addr_in_value ;
	assign db_data_in             = data_in            ;
	assign db_slave_addr_in       = slave_addr_in      ;
	assign db_base_addr_in        = base_addr_in       ;

	assign db_data_addr_out_value = data_addr_out_value;
	assign db_data_out            = raed_back_ram[ 0];//data_out           ;
	assign db_slave_addr_out      = slave_addr_out     ;
	assign db_base_addr_out       = base_addr_out      ;

	assign db_i2c_busy            = i2c_busy           ;
	assign db_i2c_done            = i2c_done           ;
	assign db_error               = error              ;
	assign db_error_code          = error_code         ;

	assign db_sda_sa              = sda_sa             ;
	assign db_sda_ba              = sda_ba             ;
	assign db_sda_d               = sda_d              ;
	assign db_sda_t_acko          = sda_t_acko         ;
	assign db_sda_t_reado         = sda_t_reado        ;

	always@(posedge clk)
	begin
		if(data_addr_out_value)
		begin
			case(base_addr_out)
				//
				
				16'h302A:raed_back_ram[ 0] <= data_out;
				16'h3070:raed_back_ram[ 1] <= data_out;
				16'h3072:raed_back_ram[ 2] <= data_out;
				16'h3074:raed_back_ram[ 3] <= data_out;
				16'h3078:raed_back_ram[ 4] <= data_out;
				16'h3076:raed_back_ram[ 5] <= data_out;
				/*
				16'h3214:raed_back_ram[ 0] <= data_out;
				16'h3216:raed_back_ram[ 1] <= data_out;
				16'h321C:raed_back_ram[ 2] <= data_out;
				16'h3212:raed_back_ram[ 3] <= data_out;
				16'h3202:raed_back_ram[ 4] <= data_out;
				16'h3044:raed_back_ram[ 5] <= data_out;
				*/
				default:
				begin
					
				end
			endcase
		end
	end
	
	//------------------------------------------------------------------------------
	//CMD FSM
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			state <= CMD_IDLE;
		end
		else
		begin
			case(state)
				CMD_IDLE:
				begin
					//if(init_vectors_cnt == INIT_VECTORS)
					//begin
					//	state <= CMD_IDLE;
					//end
					//else
					//begin
						state <= CMD_START;						
					//end
				end
				
				CMD_START:
				begin
					if(~i2c_busy)
					begin
						if(~init_done)
						begin
							if(ar0230cs_cmd_valid)
							begin
								state <= CMD_WRITE;
							end
							else
							begin
								state <= CMD_WAIT;
							end
						end
						else
						begin
							if(cfg_valid)
							begin
								state <= CMD_WRITE;
							end
							else
							begin
								state <= CMD_START;
							end
						end												
					end
					else
					begin
						state <= CMD_START;
					end
				end
				
				CMD_WRITE:
				begin
					if(error)
					begin
						state <= CMD_ERROR;
					end
					else if(i2c_done)
					begin
						state <= CMD_WAIT;
					end
					else
					begin
						state <= CMD_WRITE;
					end
				end
				
				CMD_WAIT:
				begin
					if(ar0230cs_cmd_valid)
					begin
						if(wait_cnt == CMD_DELAY_CYCLES)
						begin
							state <= CMD_DONE;
						end
						else
						begin
							state <= CMD_WAIT;
						end
					end
					else
					begin
						if(wait_cnt == init_rom_ba_da)
						begin
							state <= CMD_DONE;
						end
						else
						begin
							state <= CMD_WAIT;
						end
					end					
				end
				
				CMD_DONE:
				begin
					state <= CMD_IDLE;
				end
				
				CMD_ERROR:
				begin
					state <= CMD_IDLE;
				end
				
				default:
				begin
					state <= CMD_IDLE;
				end
			endcase
		end
	end   
	
	
	i2c_master_sensor
	#
	(
		.C_CLK_FREQ          (C_CLK_FREQ         ) ,//KHz
		.C_I2C_FREQ          (C_I2C_FREQ         ) ,//KHz
		.C_DATA_WIDTH        (C_DATA_WIDTH       ) ,
		.C_SADDR_WIDTH       (C_SADDR_WIDTH      ) ,
		.C_BADDR_WIDTH       (C_BADDR_WIDTH      )
	)
	u_i2c_master_sensor
	(
		.clk                 (clk                ),//75MHz
		.reset               (reset              ),

		.data_addr_in_value  (data_addr_in_value ),
		.data_in             (data_in            ),
		.slave_addr_in       (slave_addr_in      ),
		.base_addr_in        (base_addr_in       ),

		.data_addr_out_value (data_addr_out_value),
		.data_out            (data_out           ),
		.slave_addr_out      (slave_addr_out     ),
		.base_addr_out       (base_addr_out      ),

		.i2c_busy            (i2c_busy           ),
		.i2c_done            (i2c_done           ),
		.error               (error              ),
		.error_code          (error_code         ),

		.SCL                 (SCL                ),
		//.SDA                 (SDA                ),
		.sda_i                  (sda_i),
		.sda_o                  (sda_o),
		.sda_t                  (sda_t),
		//debug signal
		.sda_sa              (sda_sa             ),
		.sda_ba              (sda_ba             ),
		.sda_d               (sda_d              ),
		.sda_t_acko          (sda_t_acko         ),
		.sda_t_reado         (sda_t_reado        ) 
		
	); 
	
	

endmodule
