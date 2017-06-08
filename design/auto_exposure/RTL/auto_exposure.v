
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
module auto_exposure
#(
  parameter  C_DATA_WIDTH  = 8
)
(
  // system signal
  input   wire                    reset       ,
  input   wire                    clk         ,
  // data input
  input   wire                    pix_clk     ,
  input   wire                    vs_in       ,
  input   wire                    hs_in       ,
  input   wire                    de_in       ,
  input   wire [C_DATA_WIDTH-1:0] data_in     , 
  //
  input   wire                    ref_bri_up  ,
  input   wire                    ref_bri_down,
  // data output
  output  reg                     cfg0_data_valid,
	output  reg  [15:0]             cfg0_data_IT  ,
	output  reg  [15:0]             cfg0_data_AG  ,
	output  reg                     cfg1_data_valid,
	output  reg  [15:0]             cfg1_data_IT  ,
	output  reg  [15:0]             cfg1_data_AG  ,
	output  reg                     cfg2_data_valid,
	output  reg  [15:0]             cfg2_data_IT  ,
	output  reg  [15:0]             cfg2_data_AG  ,
	output  reg                     cfg3_data_valid,
	output  reg  [15:0]             cfg3_data_IT  ,
	output  reg  [15:0]             cfg3_data_AG  
) ;
	
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg  [3:0]              vs_d; 
  reg  [3:0]              hs_d; 
  reg  [3:0]              de_d; 
  reg  [C_DATA_WIDTH-1:0] data_d1;
  reg  [C_DATA_WIDTH-1:0] data_d2;
  reg  [C_DATA_WIDTH-1:0] data_d3;
  reg  [C_DATA_WIDTH-1:0] data_d4;
  wire                    de_ns;
  wire                    vs_ps;
  reg                     de_div;
  reg                     de_div_2;
                          
  reg  [15:0]             pix_cnt;
  reg  [15:0]             line_cnt;
                          
  wire [10:0]             weight_x;
	wire [10:0]             weight_y;
	reg  [20:0]             weight_xy;
	reg  [ 9:0]             weights;
	
	wire                    ram1_wea  ;
	wire [C_DATA_WIDTH-1:0] ram1_addra;
	wire [31:0]             ram1_dina ;
	wire [C_DATA_WIDTH-1:0] ram1_addrb;
	wire [31:0]             ram1_doutb;
	
	wire                    ram2_wea  ;
	wire [C_DATA_WIDTH-1:0] ram2_addra;
	wire [31:0]             ram2_dina ;
	wire [C_DATA_WIDTH-1:0] ram2_addrb;
	wire [31:0]             ram2_doutb;
	
	reg  [31:0]             his_dina ;
	
	reg                     read_flag;
	reg  [C_DATA_WIDTH-1:0] read_addr;
	reg                     read_flag_d1;
	reg                     read_flag_d2;
	reg                     read_flag_d3;
	reg                     read_flag_d4;
	wire                    read_flag_d2_ns;
	wire                    read_flag_d3_ns;
	reg                     read_flag_d3_ns_d;
	reg  [C_DATA_WIDTH-1:0] read_addr_d1;
	reg  [C_DATA_WIDTH-1:0] read_addr_d2;
	reg  [C_DATA_WIDTH-1:0] read_addr_d3;
	
	wire                    clear_flag;
	wire [C_DATA_WIDTH-1:0] clear_addr;
	
	reg  [31:0]             his_add;
	reg  [31:0]             his_sum;
	reg  [31:0]             his_sum_r;
	reg  [36:0]             his_addxx;
	reg  [36:0]             his_wsum;
	reg  [40:0]             his_wsum_r;
	
	wire                    div_valid_in;
	wire [31:0]             div_divisor;
	wire [47:0]             div_dividend;
	wire                    div_valid_out;
	reg                     div_valid_out_d;
	wire [47:0]             div_data_out;
	reg                     div_out_flag;
	                        
	reg  signed [12:0]      mu_target;
	                        
	reg                     ev_valid;
	reg                     ev_valid_d1;
	reg                     ev_valid_d2;
	reg                     ev_valid_d3;
	reg  signed [5:0]       ev_data;
	
	reg  [2:0]              up_d;  
	reg  [2:0]              down_d;
	
	wire                    up_ps;
	wire                    down_ps;
	
	localparam              delta_ev   =2;
	/*
	localparam signed       C_target   =110;
	localparam signed       C_target_x =C_target*delta_ev;
	*/
	
	reg  signed [31:0]      C_target  ;
	reg  signed [31:0]      C_target_x;
	
	reg                     reset_d1;
	reg                     reset_d2;
	wire                    reset_ps;
	
	reg  signed [9:0]       exposure_addr_t;
	reg  [6:0]              exposure1_addr;
	reg  [6:0]              exposure0_addr;
	reg  [6:0]              exposure2_addr;
	reg  [6:0]              exposure3_addr;
	wire [31:0]             exposure_value;
	                        
	reg                     exposure_rd_flag;
	reg  [1:0]              exposure_cnt;
	                        
	wire [6:0]              exposure_addr;
	                        
	reg                     fifo_wr;
	reg                     fifo_rd;
	wire [31:0]             fifo_dout;
	wire                    fifo_empty;
	wire                    fifo_valid;
	                        
	reg  [1:0]              fifo_valid_cnt;

	// =============================================================================
	// RTL Body
	// =============================================================================
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			up_d   <= 3'd0;
			down_d <= 3'd0;
		end
		else
		begin
			up_d   <= {up_d[1:0],ref_bri_up};
			down_d <= {down_d[1:0],ref_bri_down};
		end
	end
	
	assign up_ps   = up_d[1] & ~up_d[2];
	assign down_ps = down_d[1] & ~down_d[2];
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			C_target <= 110;
		end
		else if(up_ps & C_target <= 230)
		begin
			C_target <= C_target + 20;
		end
		else if(down_ps & C_target >= 40)
		begin
			C_target <= C_target - 20;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			C_target_x <= 220;
		end
		else
		begin
			C_target_x <= C_target * delta_ev;
		end
	end
	
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d   <= {4{1'b1}}; 
  		hs_d   <= {4{1'b1}}; 
  		de_d   <= {4{1'b0}};
  		data_d1<= 0;
  		data_d2<= 0;
  		data_d3<= 0;
  		data_d4<= 0;
		end
		else
		begin
			vs_d   <= {vs_d[2:0],vs_in}; 
  		hs_d   <= {hs_d[2:0],hs_in}; 
  		de_d   <= {de_d[2:0],de_in};
  		data_d1<= data_in;
  		data_d2<= data_d1;
  		data_d3<= data_d2;
  		data_d4<= data_d3;
		end
	end
  
  assign de_ns = ~de_in & de_d[0];
  assign vs_ps = vs_in & ~vs_d[0];
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			de_div <= 1'b0; 
		end
		else if(de_d[3])
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
			de_div_2 <= 1'b0; 
		end
		else if(de_div)
		begin
			de_div_2 <= ~de_div_2;
		end
		else if(~de_d[3])
		begin
			de_div_2 <= 1'b0; 
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			pix_cnt <= 0; 
		end
		else if(de_in)
		begin
			pix_cnt <= pix_cnt + 1'b1;
		end
		else
		begin
			pix_cnt <= 0; 
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			line_cnt <= 0; 
		end
		else if(vs_in)
		begin
			line_cnt <= 0; 
		end
		else if(de_ns)
		begin
			line_cnt <= line_cnt + 1'b1;
		end
	end
	
	ae_weight_x
	u_ae_weight_x
  (
    .clka  (pix_clk      ),//IN STD_LOGIC;
    .addra (pix_cnt[11:0]),//IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    .douta (weight_x     ) //OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
  
  
  ae_weight_y
  u_ae_weight_y
  (
    .clka  (pix_clk       ),//IN STD_LOGIC;
    .addra (line_cnt[10:0]),//IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    .douta (weight_y      ) //OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			weight_xy <= 0; 
		end
		else
		begin
			weight_xy <= weight_x * weight_y;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			weights <= 0; 
		end
		else
		begin
			weights <= weight_xy[20:12] + 9'd256;
		end
	end
	
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_dina <= 0; 
		end
		else if(de_div_2)
		begin
			his_dina <= weights + ram2_doutb;
		end
		else
		begin
			his_dina <= weights + ram1_doutb;
		end
	end
	
	assign ram1_wea   = ~de_div_2 & de_div | clear_flag;	
	assign ram1_addra = (clear_flag) ? clear_addr : data_d4;
	assign ram1_dina  = (clear_flag) ? 0 : his_dina;
	assign ram1_addrb = (read_flag) ? read_addr : data_d2;
	
	assign ram2_wea   = de_div_2 & de_div | clear_flag;	
	assign ram2_addra = (clear_flag) ? clear_addr : data_d4;
	assign ram2_dina  = (clear_flag) ? 0 : his_dina;
	assign ram2_addrb = (read_flag) ? read_addr : data_d2;
	
	his_ram_dp
	u1_his_ram_dp 
	(
	  .clka (pix_clk   ), // input clka
	  .wea  (ram1_wea  ), // input [0 : 0] wea
	  .addra(ram1_addra), // input [7 : 0] addra
	  .dina (ram1_dina ), // input [31 : 0] dina
	  .clkb (pix_clk   ), // input clkb
	  .addrb(ram1_addrb), // input [7 : 0] addrb
	  .doutb(ram1_doutb)  // output [31 : 0] doutb
	);
	
	
	his_ram_dp
	u2_his_ram_dp 
	(
	  .clka (pix_clk   ), // input clka
	  .wea  (ram2_wea  ), // input [0 : 0] wea
	  .addra(ram2_addra), // input [7 : 0] addra
	  .dina (ram2_dina ), // input [31 : 0] dina
	  .clkb (pix_clk   ), // input clkb
	  .addrb(ram2_addrb), // input [7 : 0] addrb
	  .doutb(ram2_doutb)  // output [31 : 0] doutb
	);
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			read_flag <= 1'b0; 
		end
		else if(&read_addr)
		begin
			read_flag <= 1'b0;
		end
		else if(vs_ps)
		begin
			read_flag <= 1'b1;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			read_addr <= 0; 
		end
		else if(read_flag)
		begin
			read_addr <= read_addr + 1'b1;
		end
		else
		begin
			read_addr <= 0;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			read_flag_d1 <= 1'b0;
			read_flag_d2 <= 1'b0;
			read_flag_d3 <= 1'b0;
			read_flag_d4 <= 1'b0;
			read_addr_d1 <= 0;
			read_addr_d2 <= 0;
			read_addr_d3 <= 0;
			read_flag_d3_ns_d <= 1'b0;
		end
		else
		begin
			read_flag_d1 <= read_flag;
			read_flag_d2 <= read_flag_d1;
			read_flag_d3 <= read_flag_d2;
			read_flag_d4 <= read_flag_d3;
			read_addr_d1 <= read_addr;
			read_addr_d2 <= read_addr_d1;
			read_addr_d3 <= read_addr_d2;
			read_flag_d3_ns_d <= read_flag_d3_ns;
		end
	end
	
	assign read_flag_d2_ns = ~read_flag_d2 & read_flag_d3;
	assign read_flag_d3_ns = ~read_flag_d3 & read_flag_d4;
	
	assign clear_flag = read_flag_d1;
	assign clear_addr = read_addr_d1;
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_add <= 0;
		end
		else if(read_flag_d1)
		begin
			his_add <= ram1_doutb + ram2_doutb;
		end
		else
		begin
			his_add <= 0;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_addxx <= 0;
			his_sum   <= 0;
		end
		else if(read_flag_d2)
		begin
			his_addxx <= his_add * read_addr_d2;
			his_sum   <= his_sum + his_add;
		end
		else
		begin
			his_addxx <= 0;
			his_sum   <= 0;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_wsum <= 0;
		end
		else if(read_flag_d3)
		begin
			his_wsum <= his_wsum + his_addxx;
		end
		else
		begin
			his_wsum <= 0;
		end
	end
	 
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_sum_r <= 0;
		end
		else if(read_flag_d2_ns)
		begin
			his_sum_r <= his_sum;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			his_wsum_r <= 0;
		end
		else if(read_flag_d3_ns)
		begin
			his_wsum_r <= his_wsum * delta_ev;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			div_out_flag <= 1'b0;
		end
		else if(read_flag_d3_ns_d)
		begin
			div_out_flag <= 1'b0;
		end
		else if(div_valid_out)
		begin
			div_out_flag <= ~div_out_flag;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			div_valid_out_d <= 1'b0;
		end
		else
		begin
			div_valid_out_d <= div_valid_out;
		end
	end
	
	wire [12:0] mu;
	
	assign mu = {1'b0,div_data_out[13:2]};
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			mu_target <= 0;
		end
		else
		begin
			mu_target <= C_target_x - mu;//{1'b0,div_data_out[13:2]};
		end
	end
	
	wire signed [47:0] smu_target;
	
	assign smu_target = (mu_target[12]) ? {{36{mu_target[12]}},mu_target[11:0]} : {36'd0,mu_target[11:0]};
	
	assign div_valid_in = read_flag_d3_ns_d | (div_out_flag & div_valid_out_d);
	assign div_divisor  = (read_flag_d3_ns_d) ? his_sum_r : C_target;
	assign div_dividend = (read_flag_d3_ns_d) ? {7'd0,his_wsum_r} : smu_target;
	
	div_ae
	u_div_ae
	(
	  .aclk                  (pix_clk      ), // input aclk
	  .s_axis_divisor_tvalid (div_valid_in ), // input s_axis_divisor_tvalid
	  .s_axis_divisor_tready (             ), // output s_axis_divisor_tready
	  .s_axis_divisor_tdata  (div_divisor  ), // input [31 : 0] s_axis_divisor_tdata
	  .s_axis_dividend_tvalid(div_valid_in ), // input s_axis_dividend_tvalid
	  .s_axis_dividend_tready(             ), // output s_axis_dividend_tready
	  .s_axis_dividend_tdata (div_dividend ), // input [47 : 0] s_axis_dividend_tdata
	  .m_axis_dout_tvalid    (div_valid_out), // output m_axis_dout_tvalid
	  .m_axis_dout_tdata     (div_data_out )  // output [47 : 0] m_axis_dout_tdata
	);
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			reset_d1 <= 1'b0;
			reset_d2 <= 1'b0;
		end
		else
		begin
			reset_d1 <= 1'b1;
			reset_d2 <= reset_d1;
		end
	end
	
	assign reset_ps = reset_d1 & ~reset_d2;
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			ev_valid <= 1'b0;
			ev_valid_d1 <= 1'b0;
			ev_valid_d2 <= 1'b0;
			ev_valid_d3 <= 1'b0;
		end
		else
		begin
			ev_valid <= div_out_flag & div_valid_out | reset_ps;
			ev_valid_d1 <= ev_valid;
			ev_valid_d2 <= ev_valid_d1;
			ev_valid_d3 <= ev_valid_d2;
		end
	end
	
	wire signed [5:0] ev_data1;
	wire signed [5:0] ev_data2;
	
	assign ev_data1 = {div_data_out[47],div_data_out[6:2]};
	assign ev_data2 = (div_data_out[47]) ? {6{div_data_out[0]}} : {5'd0,div_data_out[0]};
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			ev_data <= 0;
		end
		else if(reset_ps)
		begin
			ev_data <= 0;
		end
		//else if(div_data_out[47])
		//begin
		//	ev_data <= {div_data_out[47],div_data_out[6:2]} - div_data_out[1];
		//end
		else
		begin
			ev_data <= ev_data1 + ev_data2;//{div_data_out[47],div_data_out[6:2]} + {div_data_out[47],div_data_out[1]};
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure_addr_t <= 10'd61;
		end
		else if(ev_valid)
		begin
			exposure_addr_t <= exposure_addr_t + ev_data;
		end
		else if(exposure_addr_t[9])
		begin
			exposure_addr_t <= 10'd0;
		end
		else if(|exposure_addr_t[8:7] | exposure_addr_t[6:0] >= 7'd95)
		begin
			exposure_addr_t <= 10'd95;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure1_addr <= 7'd0;
		end
		else if(exposure_addr_t[9])
		begin
			exposure1_addr <= 0;
		end
		else if(|exposure_addr_t[8:7] | exposure_addr_t[6:0] >= 7'd95)
		begin
			exposure1_addr <= 7'd95;
		end
		else
		begin
			exposure1_addr <= exposure_addr_t[6:0];
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure0_addr <= 7'd0;
		end
		else if(exposure1_addr >= 7'd80)
		begin
			exposure0_addr <= 7'd95;
		end
		else
		begin
			exposure0_addr <= exposure1_addr + 7'd15;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure2_addr <= 7'd0;
		end
		else if(exposure1_addr <= 7'd10)
		begin
			exposure2_addr <= 7'd0;
		end
		else
		begin
			exposure2_addr <= exposure1_addr - 7'd10;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure3_addr <= 7'd0;
		end
		else if(exposure1_addr <= 7'd50)
		begin
			exposure3_addr <= 7'd0;
		end
		else
		begin
			exposure3_addr <= exposure1_addr - 7'd50;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure_cnt <= 2'b00;
		end
		else if(exposure_rd_flag)
		begin
			exposure_cnt <= exposure_cnt + 1'b1;
		end
		else
		begin
			exposure_cnt <= 2'b00;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			exposure_rd_flag <= 1'b0;
		end
		else if(&exposure_cnt)
		begin
			exposure_rd_flag <= 1'b0;
		end
		else if(ev_valid_d2)
		begin
			exposure_rd_flag <= 1'b1;
		end
	end
	
	assign exposure_addr = (exposure_cnt == 2'd0) ? exposure0_addr :
	                       (exposure_cnt == 2'd1) ? exposure1_addr :
	                       (exposure_cnt == 2'd2) ? exposure2_addr :
	                       exposure3_addr;
	
	ev_rom //total 96,default 61
	u_ev_rom
  (
    .clka  (pix_clk       ),
    .addra (exposure_addr ),
    .douta (exposure_value)
  );
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			fifo_wr <= 1'b0;
		end
		else
		begin
			fifo_wr <= exposure_rd_flag;
		end
	end
	
	ae_fifo
	u_ae_fifo
	(
	  .rst   (reset         ), // input rst
	  .wr_clk(pix_clk       ), // input wr_clk
	  .rd_clk(clk           ), // input rd_clk
	  .din   (exposure_value), // input [31 : 0] din
	  .wr_en (fifo_wr       ), // input wr_en
	  .rd_en (fifo_rd       ), // input rd_en
	  .dout  (fifo_dout     ), // output [31 : 0] dout
	  .full  (              ), // output full
	  .empty (fifo_empty    ), // output empty
	  .valid (fifo_valid    )  // output valid
	);
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			fifo_rd <= 1'b0;
		end
		else
		begin
			fifo_rd <= ~fifo_empty;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			fifo_valid_cnt <= 2'b00;
		end
		//else if(ev_valid_d2)
		//begin
		//	fifo_valid_cnt <= 2'b00;
		//end
		else if(fifo_valid)
		begin
			fifo_valid_cnt <= fifo_valid_cnt + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			cfg0_data_valid <= 1'b0;
			cfg0_data_IT   <= 0;
			cfg0_data_AG   <= 0;
			cfg1_data_valid <= 1'b0;
			cfg1_data_IT   <= 0;
			cfg1_data_AG   <= 0;
			cfg2_data_valid <= 1'b0;
			cfg2_data_IT   <= 0;
			cfg2_data_AG   <= 0;
			cfg3_data_valid <= 1'b0;
			cfg3_data_IT   <= 0;
			cfg3_data_AG   <= 0;
		end
		else
		begin
			cfg0_data_valid <= fifo_valid & (fifo_valid_cnt == 2'd0);
			cfg0_data_IT    <= fifo_dout[31:16];
			cfg0_data_AG    <= fifo_dout[15: 0];
			
			cfg1_data_valid <= fifo_valid & (fifo_valid_cnt == 2'd1);
			cfg1_data_IT    <= fifo_dout[31:16];
			cfg1_data_AG    <= fifo_dout[15: 0];
			
			cfg2_data_valid <= fifo_valid & (fifo_valid_cnt == 2'd2);
			cfg2_data_IT    <= fifo_dout[31:16];
			cfg2_data_AG    <= fifo_dout[15: 0];
			
			cfg3_data_valid <= fifo_valid & (fifo_valid_cnt == 2'd3);
			cfg3_data_IT    <= fifo_dout[31:16];
			cfg3_data_AG    <= fifo_dout[15: 0];
		end
	end
	
endmodule
