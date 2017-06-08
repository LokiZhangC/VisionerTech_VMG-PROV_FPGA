
`timescale 1ps / 1ps

module histogram
#(
  parameter  C_DATA_WIDTH     = 32,
  parameter  C_VDATA_WIDTH    = 8
)
(
    // System Signal
    input  wire                     reset    , // (i) Async. Reset (Low Active)   
    input  wire                     clk      , // (i) User Data Video Clock       
    // data in              
    input  wire                     vs_in    , // (i) Vertical Sync Pulse,active high    
    input  wire                     hs_in    , // (i) Horizontal Sync Pulse,active high
    input  wire                     de_in    , // (i) Horizontal Sync Pulse,active high
    input  wire [C_VDATA_WIDTH-1:0] data_in  , // (i) Pixel Data    
    // data out
    output reg                      data_out_valid,
  	input  wire                     data_out_ready,
  	output wire  [C_DATA_WIDTH-1:0] data_out
);    

	//function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2
	/*
	function integer clogb2;
	input integer value;
	begin 
		value = value-1;
		for (clogb2=0; value>0; clogb2=clogb2+1)
		value = value>>1;
	end 
	endfunction   
	*/
	// =============================================================================
	// Internal signal
	// =============================================================================
	//
	reg                      vs_d    ;  
  reg                      hs_d    ;
  reg  [1:0]               de_d    ;
  wire                     vs_ps   ;
	reg  [C_DATA_WIDTH-1:0]  data_max;
	                         
	reg  [1:0]               ram_sel;
	reg  [C_VDATA_WIDTH-1:0] data_in_d1;
	reg  [C_VDATA_WIDTH-1:0] data_in_d2;
	wire                     his1_wr_en;
	wire                     his2_wr_en;
	wire                     his3_wr_en;
	
	wire                     ram1_wea  ;
	wire [C_VDATA_WIDTH-1:0] ram1_addra;
	wire [C_DATA_WIDTH-1:0]  ram1_dina ;
	reg  [C_DATA_WIDTH-1:0]  his1_din  ;
	wire [C_VDATA_WIDTH-1:0] ram1_addrb;
	wire [C_DATA_WIDTH-1:0]  ram1_doutb;
	
	wire                     ram2_wea  ;
	wire [C_VDATA_WIDTH-1:0] ram2_addra;
	wire [C_DATA_WIDTH-1:0]  ram2_dina ;
	reg  [C_DATA_WIDTH-1:0]  his2_din  ;
	wire [C_VDATA_WIDTH-1:0] ram2_addrb;
	wire [C_DATA_WIDTH-1:0]  ram2_doutb;
	
	wire                     ram3_wea  ;
	wire [C_VDATA_WIDTH-1:0] ram3_addra;
	wire [C_DATA_WIDTH-1:0]  ram3_dina ;
	reg  [C_DATA_WIDTH-1:0]  his3_din  ;
	wire [C_VDATA_WIDTH-1:0] ram3_addrb;
	wire [C_DATA_WIDTH-1:0]  ram3_doutb;
	reg  [C_DATA_WIDTH-1:0]  ram3_doutb_d1;
	
	reg  [C_VDATA_WIDTH-1:0] accu_read_addr;
	reg  [C_VDATA_WIDTH-1:0] accu_write_addr;
	
	reg                      accu_read_flag;
	reg                      accu_read_flag_d1;
	reg                      accu_read_flag_d2;
	reg                      accu_write_flag;
	
	reg                      his_max_read_flag;
	reg                      his_read_flag;
	
	reg  [C_DATA_WIDTH-1:0]  his12_din  ;
	reg  [C_DATA_WIDTH-1:0]  his123_din ;
	
	reg                      clear_ram_flag;
	
	
	
	// =============================================================================
	// RTL logic
	// =============================================================================
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d <= 1'b1;
			hs_d <= 1'b1;
			de_d <= 0;
			data_in_d1 <= 0;
			data_in_d2 <= 0;
		end
		else
		begin
			vs_d <= vs_in;
			hs_d <= hs_in;
			de_d <= {de_d[0],de_in};
			data_in_d1 <= data_in;
			data_in_d2 <= data_in_d1;
		end
	end
	
	assign vs_ps = vs_in & ~vs_d;
	
	//------------------------------------------------------------------------------
	//histogram statistics
	//------------------------------------------------------------------------------
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			ram_sel <= 0;
		end
		else if(de_d[1])
		begin
			if(ram_sel == 2'b10)
			begin
				ram_sel <= 0;
			end
			else
			begin
				ram_sel <= ram_sel + 1'b1;
			end			
		end
		else
		begin
			ram_sel <= 0;
		end
	end
	
	assign his1_wr_en = (ram_sel == 0) & de_d[1];
	assign his2_wr_en = (ram_sel == 1) & de_d[1];
	assign his3_wr_en = (ram_sel == 2) & de_d[1];
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			his1_din <= 0;
			his2_din <= 0;
			his3_din <= 0;
			ram3_doutb_d1 <= 0;
			his12_din <= 0;
			his123_din <= 0;
		end
		else
		begin
			his1_din <= ram1_doutb + 1'b1;
			his2_din <= ram2_doutb + 1'b1;	
			his3_din <= ram3_doutb + 1'b1;	
			ram3_doutb_d1 <= ram3_doutb;
			his12_din <= ram1_doutb + ram2_doutb;
			his123_din <= his12_din + ram3_doutb_d1;		
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			accu_read_flag <= 1'b0;
		end
		else if(vs_ps)
		begin
			accu_read_flag <= 1'b1;		
		end
		else if(&accu_read_addr)
		begin
			accu_read_flag <= 1'b0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			accu_read_flag_d1 <= 1'b0;
			accu_read_flag_d2 <= 1'b0;
			accu_write_flag   <= 1'b0;
		end
		else
		begin
			accu_read_flag_d1 <= accu_read_flag;
			accu_read_flag_d2 <= accu_read_flag_d1;
			accu_write_flag   <= accu_read_flag_d2;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			his_max_read_flag <= 1'b0;
		end
		else if(~accu_read_flag_d2 & accu_write_flag)
		begin
			his_max_read_flag <= 1'b1;
		end
		else if(data_out_valid & data_out_ready)
		begin
			his_max_read_flag <= 1'b0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			his_read_flag <= 1'b0;
		end
		else if(data_out_valid & data_out_ready)
		begin
			if(his_max_read_flag)
			begin
				his_read_flag <= 1'b1;
			end
			else if(&accu_read_addr)
			begin
				his_read_flag <= 1'b0;
			end
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			clear_ram_flag <= 1'b0;
		end
		else if(data_out_valid & data_out_ready & (&accu_read_addr))
		begin
			clear_ram_flag <= 1'b1;
		end
		else if(&accu_write_addr)
		begin
			clear_ram_flag <= 1'b0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			accu_read_addr <= 0;
		end
		else if((|accu_read_addr) & data_out_valid & ~data_out_ready)
		begin
			accu_read_addr <= accu_read_addr - 1'b1;
		end
		else if(accu_read_flag | (his_read_flag & data_out_ready))// & data_out_valid
		begin
			accu_read_addr <= accu_read_addr + 1'b1;
		end
		else if((&accu_read_addr) & (~his_read_flag | (data_out_ready)))//data_out_valid & 
		begin
			accu_read_addr <= 0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			accu_write_addr <= 0;
		end
		else if(accu_write_flag | clear_ram_flag)
		begin
			accu_write_addr <= accu_write_addr + 1'b1;
		end
		else
		begin
			accu_write_addr <= 0;
		end
	end
	
	assign ram1_wea   = his1_wr_en | accu_write_flag | clear_ram_flag;
	assign ram1_addra = (accu_write_flag | clear_ram_flag) ? accu_write_addr : data_in_d2;
	assign ram1_dina  = (accu_write_flag) ? his123_din : 
	                    (his1_wr_en     ) ? his1_din   :
	                    0;
	assign ram1_addrb = (accu_read_flag | his_read_flag) ? accu_read_addr : data_in;
	
	his_ram_dp
	u1_his_ram_dp 
	(
	  .clka (clk       ), // input clka
	  .wea  (ram1_wea  ), // input [0 : 0] wea
	  .addra(ram1_addra), // input [7 : 0] addra
	  .dina (ram1_dina ), // input [31 : 0] dina
	  .clkb (clk       ), // input clkb
	  .addrb(ram1_addrb), // input [7 : 0] addrb
	  .doutb(ram1_doutb)  // output [31 : 0] doutb
	);
	
	assign ram2_wea   = his2_wr_en | accu_write_flag | clear_ram_flag;
	assign ram2_addra = (accu_write_flag | clear_ram_flag) ? accu_write_addr : data_in_d2;
	assign ram2_dina  = (accu_write_flag) ? his123_din : 
	                    (his2_wr_en     ) ? his2_din   :
	                    0;
	assign ram2_addrb = (accu_read_flag | his_read_flag) ? accu_read_addr : data_in;
	
	his_ram_dp
	u2_his_ram_dp 
	(
	  .clka (clk       ), // input clka
	  .wea  (ram2_wea  ), // input [0 : 0] wea
	  .addra(ram2_addra), // input [7 : 0] addra
	  .dina (ram2_dina ), // input [31 : 0] dina
	  .clkb (clk       ), // input clkb
	  .addrb(ram2_addrb), // input [7 : 0] addrb
	  .doutb(ram2_doutb)  // output [31 : 0] doutb
	);
	
	assign ram3_wea   = his3_wr_en | accu_write_flag | clear_ram_flag;
	assign ram3_addra = (accu_write_flag | clear_ram_flag) ? accu_write_addr : data_in_d2;
	assign ram3_dina  = (accu_write_flag) ? his123_din : 
	                    (his3_wr_en     ) ? his3_din   :
	                    0;
	assign ram3_addrb = (accu_read_flag | his_read_flag) ? accu_read_addr : data_in;
	
	his_ram_dp
	u3_his_ram_dp 
	(
	  .clka (clk       ), // input clka
	  .wea  (ram3_wea  ), // input [0 : 0] wea
	  .addra(ram3_addra), // input [7 : 0] addra
	  .dina (ram3_dina ), // input [31 : 0] dina
	  .clkb (clk       ), // input clkb
	  .addrb(ram3_addrb), // input [7 : 0] addrb
	  .doutb(ram3_doutb)  // output [31 : 0] doutb
	);
	
	//------------------------------------------------------------------------------
	//max/min data detect
	//------------------------------------------------------------------------------
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_max <= 0;
		end
		else if(vs_ps)
		begin
			data_max <= 0;
		end
		else if(accu_write_flag)
		begin
			if(his123_din >= data_max)
			begin
				data_max <= his123_din;
			end
		end
	end
	
	reg  data_out_ready_d1;
	wire data_out_ready_ps;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_out_ready_d1 <= 1'b0;
		end
		else if(his_max_read_flag | his_read_flag)
		begin
			data_out_ready_d1 <= data_out_ready;
		end
		else
		begin
			data_out_ready_d1 <= 1'b0;
		end
	end
	
	assign data_out_ready_ps = data_out_ready & ~data_out_ready_d1;
	
	//assign data_out_valid = (his_max_read_flag | his_read_flag) & data_out_ready;	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_out_valid <= 1'b0;
		end
		else
		begin
			data_out_valid <= (his_max_read_flag | his_read_flag) & data_out_ready;//data_out_ready_ps;
		end
	end
	
	assign data_out = (his_max_read_flag) ? data_max : ram3_doutb;
	/*
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_out <= 1'b0;
		end
		else if(his_max_read_flag)
		begin
			data_out <= data_max;
		end
		else
		begin
			data_out <= ram3_doutb;
		end
	end
	*/

endmodule