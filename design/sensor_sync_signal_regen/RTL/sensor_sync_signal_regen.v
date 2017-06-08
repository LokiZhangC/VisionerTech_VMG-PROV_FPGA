`timescale 1ps / 1ps
//================================================================================ 
// File Name      : sensor_sync_signal_regen.v
//--------------------------------------------------------------------------------
// Create Date    : 06/05/2015 
// Project Name   : sensor_sync_signal_regen
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
module sensor_sync_signal_regen
#(
  parameter  C_DATA_WIDTH    = 10'd12
)
(
    // System Signal
    input  wire                     reset    , // (i) Async. Reset (Low Active)   
    input  wire                     clk      , // (i) User Data Video Clock       
    // video input              
    input  wire                     vs_in    , // (i) Vertical Sync Pulse,active high    
    input  wire                     hs_in    , // (i) Horizontal Sync Pulse,active high
    //input  wire                     de_in    , // (i) Horizontal Sync Pulse,active high
    input  wire [C_DATA_WIDTH-1:0]  data_in  , // (i) Pixel Data    
    
    // data out
    output wire                     ae_vs_out, // (o) Vertical Sync Pulse
    output wire                     vs_out   , // (o) Vertical Sync Pulse       
    output wire                     hs_out   , // (o) Horizontal Sync Pulse
    output wire                     de_out   , // (o) Pixel Data Video Enable  
		output wire [C_DATA_WIDTH-1:0]  data_out     
);    

	localparam                 delay_cycles    = 4 ;
	localparam                 hs_delay_cycles = 8 ;
	
	reg                        vs_in_d  ;
	reg                        hs_in_d  ;
	reg                        de_in_d  ;
	reg  [C_DATA_WIDTH-1:0]    data_in_d;
	
	reg  [hs_delay_cycles-1:0] hs_d             ;
	reg  [delay_cycles-1:0]    de_d             ;
	
	reg  [delay_cycles-1:0]    shift_reg [C_DATA_WIDTH-1:0];
  wire [C_DATA_WIDTH-1:0]    data_shift;
  
  reg                        vs_t1  ;
	reg                        hs_t1  ;
	reg                        de_t1  ;
	reg  [C_DATA_WIDTH-1:0]    data_t1;
	
	reg                        vs_t2  ;
	reg                        hs_t2  ;
	reg                        de_t2  ;
	reg  [C_DATA_WIDTH-1:0]    data_t2;
	
	reg                        ae_vs_t3  ;
	reg                        vs_t3  ;
	reg                        hs_t3  ;
	reg                        de_t3  ;
	reg  [C_DATA_WIDTH-1:0]    data_t3;
	
	reg                        ae_vs_t4  ;
	reg                        vs_t4  ;
	reg                        hs_t4  ;
	reg                        de_t4  ;
	reg  [C_DATA_WIDTH-1:0]    data_t4;
	
	wire                       hs_t1_ps;
  reg  [15:0]                hs_cnt;
	
	assign ae_vs_out= ae_vs_t4;
	assign vs_out   = vs_t4   ;//vs_t2  ;//
	assign hs_out   = hs_t4   ;//hs_t2  ;//
	assign de_out   = de_t4   ;//de_t2  ;//
	assign data_out = data_t4 ;//data_t2;//
	
	////////////////////////////////////////////////////////////////////////////////
	
	wire  [C_DATA_WIDTH+2-1:0] input_io;
	wire  [C_DATA_WIDTH+2-1:0] input_io_t;
	
	assign input_io = {vs_in,hs_in,data_in};
	
	genvar pin_count;
  generate 
  for (pin_count = 0; pin_count < C_DATA_WIDTH+2; pin_count = pin_count + 1) 
  begin: pins
    // Pack the registers into the IOB
    wire data_in_to_device_int;
    (* IOB = "true" *)
    FDRE fdre_in_inst
      (.D              (input_io[pin_count]),
       .C              (clk                ),
       .CE             (1'b1               ),
       .R              (reset              ),
       .Q              (data_in_to_device_int)
      );
    assign input_io_t[pin_count] = data_in_to_device_int;
  end
  endgenerate
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_in_d   <= 1'b1;
			hs_in_d   <= 1'b1;
			de_in_d   <= 1'b0;
			data_in_d <= 0;
		end
		else
		begin
			vs_in_d   <=  ~input_io_t[C_DATA_WIDTH+2-1]  ;
			hs_in_d   <=  ~input_io_t[C_DATA_WIDTH+2-2]  ;
			de_in_d   <=  input_io_t[C_DATA_WIDTH+2-1] & input_io_t[C_DATA_WIDTH+2-2];
			data_in_d <=  input_io_t[C_DATA_WIDTH+2-3:0];
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			de_d <= {delay_cycles {1'b0}};
		end
		else
		begin
			de_d <= {de_d[delay_cycles-2:0],de_in_d};
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			hs_d <= {hs_delay_cycles {1'b0}};
		end
		else
		begin
			hs_d <= {hs_d[hs_delay_cycles-2:0],hs_in_d};
		end
	end
	
	genvar i;
  generate
     for (i=0; i < C_DATA_WIDTH; i=i+1) 
     begin: data_delay4
        always @(posedge clk or posedge reset)
        begin
        	if(reset)
        	begin
        		shift_reg[i] <= {delay_cycles {1'b0}};
        	end
        	else
        	begin
        		shift_reg[i] <= {shift_reg[i][delay_cycles-2:0], data_in_d[i]};
        	end              
        end
           			 
        assign data_shift[i] = shift_reg[i][delay_cycles-1];
     end
  endgenerate
  
  /*
  assign vs_t1    = vs_in_d;
	assign hs_t1    = (&hs_d) & hs_in_d;
	assign de_t1    = de_d[delay_cycles-1];
	assign data_t1  = data_shift;
  */
  
  always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t1   <= 1'b1;
			hs_t1   <= 1'b1;
			de_t1   <= 1'b0;
			data_t1 <= 0;
		end
		else
		begin
			vs_t1   <= vs_in_d;             
			hs_t1   <= (&hs_d) & hs_in_d;   
			de_t1   <= de_d[delay_cycles-1];
			data_t1 <= data_shift;          
		end
	end
  
  always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_t2   <= 1'b1;
			hs_t2   <= 1'b1;
			de_t2   <= 1'b0;
			data_t2 <= 0;
		end
		else
		begin
			vs_t2   <= vs_t1  ;//vs_in_d  ;//
			hs_t2   <= hs_t1  ;//hs_in_d  ;//
			de_t2   <= de_t1  ;//de_in_d  ;//
			data_t2 <= data_t1;//data_in_d;//
		end
	end
	
	assign hs_t1_ps = hs_t1 & ~hs_t2;
  
  always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			hs_cnt <= 0;
		end
		else if(vs_t1)
		begin
			if(hs_t1_ps)
			begin
				hs_cnt <= hs_cnt + 1'b1;
			end
		end
		else
		begin
			hs_cnt <= 0;
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			ae_vs_t3<= 1'b1;
			vs_t3   <= 1'b1;
			hs_t3   <= 1'b1;
			de_t3   <= 1'b0;
			data_t3 <= 0;
		end
		else
		begin
			if((hs_cnt > 16'd0) & (hs_cnt < 16'd7))
			begin
				ae_vs_t3   <= 1'b1  ;
			end
			else
			begin
				ae_vs_t3   <= 1'b0  ;
			end
			
			if((hs_cnt > 16'd1) & (hs_cnt < 16'd8))
			begin
				vs_t3   <= 1'b1  ;
			end
			else
			begin
				vs_t3   <= 1'b0  ;
			end
			hs_t3   <= hs_t2  ;
			de_t3   <= de_t2  ;
			data_t3 <= data_t2;
		end
	end
	
	wire vs_t3_ns;
	wire de_t3_ps;
	reg  first_pix_flag_t;
	wire first_pix_flag;
	
	assign vs_t3_ns = ~vs_t3 & vs_t4;
	assign de_t3_ps = de_t3 & ~de_t4;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			first_pix_flag_t <= 1'b0;
		end
		else if(de_t3_ps)
		begin
			first_pix_flag_t <= 1'b0;
		end
		else if(vs_t3_ns)
		begin
			first_pix_flag_t <= 1'b1;
		end
	end
	
	assign first_pix_flag = first_pix_flag_t & de_t3_ps;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			ae_vs_t4<= 1'b1;
			vs_t4   <= 1'b1;
			hs_t4   <= 1'b1;
			de_t4   <= 1'b0;
			data_t4 <= 0;
		end
		else
		begin
			ae_vs_t4<= ae_vs_t3;
			vs_t4   <= vs_t3  ;
			hs_t4   <= hs_t3  ;
			de_t4   <= de_t3  ;
			data_t4 <= data_t3;
		end
	end
    
endmodule
