
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : create_cumulative_sum.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : create_cumulative_sum
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : create_cumulative_sum,C(0) = M(0), C(i) = C(i-1) + M(i) for i > 0
//                  It include modify histogram and cumulative sum
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================

module create_cumulative_sum
#(
  parameter  C_DATA_WIDTH  = 32,
  parameter  C_Mu          = 5, //range=0~10,recommend 2.0 < C_Mu < 10.0
  parameter  C_VDATA_WIDTH = 8
)
(
  //system signal
  input  wire                    clk  , //
  input  wire                    reset, //
  //data input
  input  wire                    data_in_valid,
  output reg                     data_in_ready,
  input  wire [C_DATA_WIDTH-1:0] data_in,
  //ram
  output wire                    ram_wea,
  output wire [C_VDATA_WIDTH-1:0]ram_addra,
  output wire [C_DATA_WIDTH-1:0] ram_dina,
  output wire                    ram_rdb,
  output wire [C_VDATA_WIDTH-1:0]ram_addrb,
	input  wire [C_DATA_WIDTH-1:0] ram_doutb,
	//
	output wire                    cal_eq_done       ,
  //fixed2float
  output reg  [C_DATA_WIDTH-1:0] fixed2float_a     ,
	output reg                     fixed2float_valid ,          
	input  wire [C_DATA_WIDTH-1:0] fixed2float_result,
	input  wire                    fixed2float_rdy   ,
	//add
  output reg  [C_DATA_WIDTH-1:0] add_a             ,
  output reg  [C_DATA_WIDTH-1:0] add_b             ,
	output reg                     add_valid         ,
	input  wire [C_DATA_WIDTH-1:0] add_result        ,
	input  wire                    add_rdy           ,
	//sub                                            
  output reg  [C_DATA_WIDTH-1:0] sub_a             ,
  output reg  [C_DATA_WIDTH-1:0] sub_b             ,
	output reg                     sub_valid         ,
	input  wire [C_DATA_WIDTH-1:0] sub_result        ,
	input  wire                    sub_rdy           ,
	//mult                                           
  output reg  [C_DATA_WIDTH-1:0] mult_a            ,
  output reg  [C_DATA_WIDTH-1:0] mult_b            ,
	output reg                     mult_valid        ,
	input  wire [C_DATA_WIDTH-1:0] mult_result       ,
	input  wire                    mult_rdy          ,
	//div                                            
  output reg  [C_DATA_WIDTH-1:0] div_a             ,
  output reg  [C_DATA_WIDTH-1:0] div_b             ,
	output reg                     div_valid         ,
	input  wire [C_DATA_WIDTH-1:0] div_result        ,
	input  wire                    div_rdy           ,
	//float2fixed
  output wire [C_DATA_WIDTH-1:0] float2fixed_a     ,
	output wire                    float2fixed_valid ,
	input  wire [C_DATA_WIDTH-1:0] float2fixed_result,
	input  wire                    float2fixed_rdy   ,
	
	output wire [1:0]              db
);


	// =============================================================================
	// Internal signal
	// =============================================================================
	(* KEEP = "TRUE" *)reg [3:0]   state;
	localparam  IDLE           = 4'd0;
	localparam  FX2FL          = 4'd1;
	localparam  CAL_MAXU       = 4'd2;
	localparam  CAL_MAXUMAX    = 4'd3;
	localparam  CAL_MAXUMAXP1  = 4'd4;
	//localparam  CAL_MAXUH      = 4'd5;
	localparam  CAL_MAXUHP1    = 4'd5;
	localparam  FLOAT_SEP      = 4'd6;
	localparam  TSE            = 4'd7;
	localparam  LOGE_DIV       = 4'd8;
	localparam  CUMULATIVE_SUM = 4'd9;
	
	wire [C_DATA_WIDTH-1:0] Mu;
	generate
		case(C_Mu)
			0: assign Mu = 32'h3f800000;
			1: assign Mu = 32'h3dcccccd;
			2: assign Mu = 32'h3c23d70a;
			3: assign Mu = 32'h3a83126f;
			4: assign Mu = 32'h38d1b717;
			5: assign Mu = 32'h3727c5ac;
			6: assign Mu = 32'h358637bd;
			7: assign Mu = 32'h33d6bf95;
			8: assign Mu = 32'h322bcc77;
			9: assign Mu = 32'h3089705f;
			10:assign Mu = 32'h2edbe6ff;
			default:assign Mu = 32'h2edbe6ff;
		endcase
	endgenerate
	
	reg  [C_DATA_WIDTH-1:0] hmax   ;
	reg  [8:0]              data_cnt;
	wire                    data_cnt_z;
	wire                    data_cnt_1;
	reg  [C_DATA_WIDTH-1:0] maxu   ;
	reg  [C_DATA_WIDTH-1:0] logemax;
	
	reg                     add_rdy_d;
	wire                    add_rdy_ns;
	
	reg                     div_rdy_d;
	wire                    div_rdy_ns;
	reg                     logdiv_div_flag   ;
	
	//maxuhp1	
	reg                     mp_add_flag   ;
	
	reg                     mp_in_valid   ; 
  reg  [C_DATA_WIDTH-1:0] mp_in         ;
  reg  [C_DATA_WIDTH-1:0] mp_maxu_in    ;
	                                      
  wire                    mp_out_valid  ; 
  wire [C_DATA_WIDTH-1:0] mp_out        ;
  
  wire [C_DATA_WIDTH-1:0] mp_add_a      ;
  wire [C_DATA_WIDTH-1:0] mp_add_b      ;
	wire                    mp_add_valid  ;
	reg  [C_DATA_WIDTH-1:0] mp_add_result ;
	reg                     mp_add_rdy    ;
	
  wire [C_DATA_WIDTH-1:0] mp_mult_a     ;
  wire [C_DATA_WIDTH-1:0] mp_mult_b     ;
	wire                    mp_mult_valid ;
	reg  [C_DATA_WIDTH-1:0] mp_mult_result;
	reg                     mp_mult_rdy   ;
	
	//float_separate
	reg                     fs_in_valid          ; 
  reg  [C_DATA_WIDTH-1:0] fs_in                ;
  
  wire                    fs_y_valid           ; 
  wire [C_DATA_WIDTH-1:0] fs_y                 ;
  wire                    fs_nxloge2_valid     ;
  wire [C_DATA_WIDTH-1:0] fs_nxloge2           ;
  
	wire [C_DATA_WIDTH-1:0] fs_fixed2float_a     ;
	wire                    fs_fixed2float_valid ;
	reg  [C_DATA_WIDTH-1:0] fs_fixed2float_result;
	reg                     fs_fixed2float_rdy   ;
	
	wire [C_DATA_WIDTH-1:0] fs_add_a             ;       
	wire [C_DATA_WIDTH-1:0] fs_add_b             ;       
	wire                    fs_add_valid         ;       
	reg  [C_DATA_WIDTH-1:0] fs_add_result        ;       
	reg                     fs_add_rdy           ;       
	
	wire [C_DATA_WIDTH-1:0] fs_sub_a             ;       
	wire [C_DATA_WIDTH-1:0] fs_sub_b             ;       
	wire                    fs_sub_valid         ;       
	reg  [C_DATA_WIDTH-1:0] fs_sub_result        ;       
	reg                     fs_sub_rdy           ;       
	
	wire [C_DATA_WIDTH-1:0] fs_mult_a            ;       
	wire [C_DATA_WIDTH-1:0] fs_mult_b            ;       
	wire                    fs_mult_valid        ;       
	reg  [C_DATA_WIDTH-1:0] fs_mult_result       ;       
	reg                     fs_mult_rdy          ;       
	
	wire [C_DATA_WIDTH-1:0] fs_div_a             ;       
	wire [C_DATA_WIDTH-1:0] fs_div_b             ;       
	wire                    fs_div_valid         ;       
	reg  [C_DATA_WIDTH-1:0] fs_div_result        ;       
	reg                     fs_div_rdy           ;
	//taylor_series_expansion
	reg                     tse_y_valid          ;
	reg  [C_DATA_WIDTH-1:0] tse_y                ;
	reg                     tse_nxloge2_valid    ;
	reg  [C_DATA_WIDTH-1:0] tse_nxloge2          ;
	                                             
	wire                    tse_out_valid        ;
	wire [C_DATA_WIDTH-1:0] tse_out              ;
	                                             
	wire [C_DATA_WIDTH-1:0] tse_add_a            ;
	wire [C_DATA_WIDTH-1:0] tse_add_b            ;
	wire                    tse_add_valid        ;
	reg  [C_DATA_WIDTH-1:0] tse_add_result       ;
	reg                     tse_add_rdy          ;
	                                             
	wire [C_DATA_WIDTH-1:0] tse_mult_a           ;
	wire [C_DATA_WIDTH-1:0] tse_mult_b           ;
	wire                    tse_mult_valid       ;
	reg  [C_DATA_WIDTH-1:0] tse_mult_result      ;
	reg                     tse_mult_rdy         ;
	//cumulative_sum
	reg                     cs_in_valid          ; 
  reg  [C_DATA_WIDTH-1:0] cs_in                ;
                                                 
  wire                    cs_cal_eq_part_done  ;
                                               
  wire [C_DATA_WIDTH-1:0] cs_add_a             ;
	wire [C_DATA_WIDTH-1:0] cs_add_b             ;
	wire                    cs_add_valid         ;
	reg  [C_DATA_WIDTH-1:0] cs_add_result        ;
	reg                     cs_add_rdy           ;
	
	wire [C_DATA_WIDTH-1:0] cs_sub_a             ;
	wire [C_DATA_WIDTH-1:0] cs_sub_b             ;
	wire                    cs_sub_valid         ;
	reg  [C_DATA_WIDTH-1:0] cs_sub_result        ;
	reg                     cs_sub_rdy           ;
	//mult                          
  wire [C_DATA_WIDTH-1:0] cs_mult_a            ;
  wire [C_DATA_WIDTH-1:0] cs_mult_b            ;
	wire                    cs_mult_valid        ;
	reg  [C_DATA_WIDTH-1:0] cs_mult_result       ;
	reg                     cs_mult_rdy          ;
	//div                                        
  wire [C_DATA_WIDTH-1:0] cs_div_a             ;
  wire [C_DATA_WIDTH-1:0] cs_div_b             ;
	wire                    cs_div_valid         ;
	reg  [C_DATA_WIDTH-1:0] cs_div_result        ;
	reg                     cs_div_rdy           ;
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_cnt <= 0;
		end
		else if(data_in_ready & data_in_valid)//(tse_out_valid)
		begin
			if(data_cnt[8])
			begin
				data_cnt <= 0;
			end
			else
			begin
				data_cnt <= data_cnt + 1'b1;
			end
		end
	end
	
	assign data_cnt_z = ~(|data_cnt);
	assign data_cnt_1 = ~(|data_cnt[8:1]) & data_cnt[0];
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			hmax <= 0;
		end
		else if(state == FX2FL & data_cnt_1 & fixed2float_rdy)
		begin
			hmax <= fixed2float_result;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			maxu    <= 0;
			logemax <= 0;
		end
		else
		begin
			if(state == CAL_MAXU & mult_rdy)
			begin
				maxu <= mult_result;
			end
			if(data_cnt_1 & state == TSE & tse_out_valid)
			begin
				logemax <= tse_out;
			end
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_in_ready <= 1'b0;
		end
		else if(state == IDLE)
		begin
			if(data_cnt_z)
			begin
				if(data_in_ready & data_in_valid)
				begin
					data_in_ready <= 1'b0;
				end
				else
				begin
					data_in_ready <= 1'b1;
				end				
			end
			else
			begin
				if(~(|data_cnt[2:0]) & data_in_ready & data_in_valid)
				begin
					data_in_ready <= 1'b0;
				end
				else
				begin
					data_in_ready <= 1'b1;
				end
			end
		end
		else
		begin
			data_in_ready <= 1'b0;
		end
	end
	
	//------------------------------------------------------------------------------
	//FSM
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			state <= IDLE;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(~(|data_cnt[2:0]) & data_in_valid & data_in_ready)
					begin
						state <= FX2FL;
					end
					else
					begin
						state <= IDLE;
					end					
				end
				
				FX2FL://delay 
				begin
					if(fixed2float_rdy)
					begin
						if(data_cnt_1)
						begin
							state <= CAL_MAXU;
						end
						else
						begin
							state <= CAL_MAXUHP1;//CAL_MAXUH;
						end	
					end
				end
				
				CAL_MAXU://delay 
				begin
					if(mult_rdy)
					begin
						state <= CAL_MAXUMAX;
					end
					else
					begin
						state <= CAL_MAXU;
					end					
				end
				
				      
				CAL_MAXUMAX://delay 
				begin
					if(mult_rdy)
					begin
						state <= CAL_MAXUMAXP1;
					end
					else
					begin
						state <= CAL_MAXUMAX;
					end					
				end
				
				CAL_MAXUMAXP1://delay 
				begin
					if(add_rdy)
					begin
						state <= FLOAT_SEP;
					end
					else
					begin
						state <= CAL_MAXUMAXP1;
					end					
				end
				/*
				CAL_MAXUH://delay 
				begin
					if(mult_rdy)
					begin
						state <= CAL_MAXUHP1;
					end
					else
					begin
						state <= CAL_MAXUH;
					end					
				end
				*/
				CAL_MAXUHP1://delay 
				begin
					if(mp_out_valid)
					begin
						state <= FLOAT_SEP;
					end
					else
					begin
						state <= CAL_MAXUHP1;
					end					
				end
				
				FLOAT_SEP://delay 
				begin
					if(fs_y_valid)
					begin
						state <= TSE;
					end
					else
					begin
						state <= FLOAT_SEP;
					end
				end
				
				TSE://delay 
				begin
					if(tse_out_valid)
					begin
						if(data_cnt_1)
						begin
							state <= IDLE;
						end
						else
						begin
							state <= LOGE_DIV;
						end						
					end
					else
					begin
						state <= TSE;
					end					
				end
				
				LOGE_DIV:////delay 
				begin
					if(div_rdy)
					begin
						state <= CUMULATIVE_SUM;
					end
					else
					begin
						state <= LOGE_DIV;
					end					
				end
				
				CUMULATIVE_SUM://delay 
				begin
					if(cs_cal_eq_part_done)
					begin
						state <= IDLE;
					end
					else
					begin
						state <= CUMULATIVE_SUM;
					end					
				end
				
				default:
				begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			add_rdy_d <= 1'b0;
		end
		else
		begin
			add_rdy_d <= add_rdy;
		end
	end
	
	assign add_rdy_ns = ~add_rdy & add_rdy_d;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			mp_add_flag <= 1'b0;
		end
		else if(add_rdy_ns)
		begin
			mp_add_flag <= 1'b0;
		end
		else if(state == CAL_MAXUHP1 & add_rdy)
		begin
			mp_add_flag <= 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			div_rdy_d <= 1'b0;
		end
		else
		begin
			div_rdy_d <= div_rdy;
		end
	end
	
	assign div_rdy_ns = ~div_rdy & div_rdy_d;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			logdiv_div_flag <= 1'b0;
		end
		else if(div_rdy_ns)
		begin
			logdiv_div_flag <= 1'b0;
		end
		else if(state == LOGE_DIV & div_rdy)
		begin
			logdiv_div_flag <= 1'b1;
		end
	end
	
	always@(*)//(posedge clk or posedge reset)//
	begin
		/*
		if(reset)
		begin
			fixed2float_a         <= 0;
			fixed2float_valid     <= 0;       
			add_a                 <= 0;
			add_b                 <= 0;
			add_valid             <= 0;     
			sub_a                 <= 0;
			sub_b                 <= 0;
			sub_valid             <= 0;          
			mult_a                <= 0;
			mult_b                <= 0;
			mult_valid            <= 0;
			div_a                 <= 0;
			div_b                 <= 0;
			div_valid             <= 0;
			
			mp_in_valid           <= 0;
			mp_in                 <= 0;
			mp_maxu_in            <= 0;
			mp_add_result         <= 0;
			mp_add_rdy            <= 0;
			mp_mult_result        <= 0;
			mp_mult_rdy           <= 0;
			
			fs_in_valid           <= 0;
			fs_in                 <= 0;
			fs_fixed2float_result <= 0;
			fs_fixed2float_rdy    <= 0;
			fs_add_result         <= 0;
			fs_add_rdy            <= 0;  
			fs_sub_result         <= 0;
			fs_sub_rdy            <= 0;
			fs_mult_result        <= 0;
			fs_mult_rdy           <= 0;       
			fs_div_result         <= 0;
			fs_div_rdy            <= 0;
			
			tse_y_valid           <= 0;
			tse_y                 <= 0;
			tse_nxloge2_valid     <= 0;
			tse_nxloge2           <= 0;
			tse_add_result        <= 0;
			tse_add_rdy           <= 0;
			tse_mult_result       <= 0;
			tse_mult_rdy          <= 0;
			
			cs_in_valid           <= 0;
			cs_in                 <= 0;
			cs_add_result         <= 0;
			cs_add_rdy            <= 0;
			cs_sub_result         <= 0;
			cs_sub_rdy            <= 0;
			cs_mult_result        <= 0;
			cs_mult_rdy           <= 0;
			cs_div_result         <= 0;
			cs_div_rdy            <= 0;
		end
		else
		begin
		*/
			case(state)
				IDLE:
				begin
					fixed2float_a         <= data_in;                      
					fixed2float_valid     <= data_in_valid & data_in_ready;     
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					if(fixed2float_rdy & data_cnt_z)
					begin
						mult_a            <= fixed2float_result;
						mult_b            <= Mu;
						mult_valid        <= fixed2float_rdy;
						mp_in             <= 0;
						mp_maxu_in        <= 0;
						mp_in_valid       <= 0;	
					end
					else
					begin
						mp_in             <= fixed2float_result;
						mp_maxu_in        <= maxu;
						mp_in_valid       <= fixed2float_rdy;	
						mult_a            <= mp_mult_a;
						mult_b            <= mp_mult_b;
						mult_valid        <= mp_mult_valid;						
					end
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;				
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				FX2FL:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;
					if(fixed2float_rdy & data_cnt_1)
					begin
						mult_a            <= fixed2float_result;
						mult_b            <= Mu;
						mult_valid        <= fixed2float_rdy;
						mp_in             <= 0;
						mp_maxu_in        <= 0;
						mp_in_valid       <= 0;	
					end
					else
					begin
						mp_in             <= fixed2float_result;
						mp_maxu_in        <= maxu;
						mp_in_valid       <= fixed2float_rdy;	
						mult_a            <= mp_mult_a;
						mult_b            <= mp_mult_b;
						mult_valid        <= mp_mult_valid;						
					end
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				CAL_MAXU:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= mult_result;
					mult_b                <= hmax;
					mult_valid            <= mult_rdy;
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_in_valid           <= 0;
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				CAL_MAXUMAX:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= mult_result;
					add_b                 <= 32'h3F800000;
					add_valid             <= mult_rdy;
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= 0;
					mult_b                <= 0;
					mult_valid            <= 0;
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_in_valid           <= 0;
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				CAL_MAXUMAXP1:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= 0;
					mult_b                <= 0;
					mult_valid            <= 0;
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_in_valid           <= 0;
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= add_rdy;
					fs_in                 <= add_result;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				CAL_MAXUHP1:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= mp_add_a;    
					add_b                 <= mp_add_b;    
					add_valid             <= mp_add_valid;
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= mp_mult_a;
					mult_b                <= mp_mult_b;
					mult_valid            <= mp_mult_valid;	
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_in                 <= fixed2float_result;
					mp_maxu_in            <= maxu;
					mp_in_valid           <= fixed2float_rdy;	
					mp_add_result         <= add_result;
					mp_add_rdy            <= add_rdy   ;
					mp_mult_result        <= mult_result;
					mp_mult_rdy           <= mult_rdy   ;
					
					fs_in_valid           <= mp_out_valid;
					fs_in                 <= mp_out      ;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				FLOAT_SEP:
				begin
					fixed2float_a         <= fs_fixed2float_a    ;
					fixed2float_valid     <= fs_fixed2float_valid;     
					add_a                 <= fs_add_a    ;
					add_b                 <= fs_add_b    ;
					add_valid             <= fs_add_valid;
					sub_a                 <= fs_sub_a    ;
					sub_b                 <= fs_sub_b    ;
					sub_valid             <= fs_sub_valid;
					mult_a                <= fs_mult_a;
					mult_b                <= fs_mult_b;
					/*
					if(fs_mult_valid)
					begin
						mult_a              <= fs_mult_a;
						mult_b              <= fs_mult_b;
					end
					else
					begin
						mult_a              <= fs_mult_a;
						mult_b              <= fs_mult_b;
					end
					*/
					mult_valid            <= fs_mult_valid;// | tse_mult_valid
					div_a                 <= fs_div_a    ;
					div_b                 <= fs_div_b    ;
					div_valid             <= fs_div_valid;
					
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_in_valid           <= 0;	
					mp_add_result         <= add_result;
					mp_add_rdy            <= mp_add_flag & add_rdy   ;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= mp_out_valid;
					fs_in                 <= mp_out      ;
					fs_fixed2float_result <= fixed2float_result;
					fs_fixed2float_rdy    <= fixed2float_rdy   ;
					fs_add_result         <= add_result;
					fs_add_rdy            <= ~mp_add_flag & add_rdy   ;
					fs_sub_result         <= sub_result;
					fs_sub_rdy            <= sub_rdy   ;
					fs_mult_result        <= mult_result;
					fs_mult_rdy           <= mult_rdy   ; 
					fs_div_result         <= div_result;
					fs_div_rdy            <= div_rdy   ;
					
					tse_y_valid           <= fs_y_valid      ;
					tse_y                 <= fs_y            ;
					tse_nxloge2_valid     <= fs_nxloge2_valid;
					tse_nxloge2           <= fs_nxloge2      ;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				TSE:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= tse_add_a    ;
					add_b                 <= tse_add_b    ;
					add_valid             <= tse_add_valid;   
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= tse_mult_a    ;
					mult_b                <= tse_mult_b    ;
					mult_valid            <= tse_mult_valid;
					if(data_cnt_1)
					begin
						div_a              <= 0;
						div_b              <= 0;
						div_valid          <= 0;
					end
					else
					begin
						div_a              <= tse_out;
						div_b              <= logemax;
						div_valid          <= tse_out_valid;
					end
					
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_in_valid           <= 0;	
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= div_result;
					fs_div_rdy            <= div_rdy   ;
					
					tse_y_valid           <= fs_y_valid      ;
					tse_y                 <= fs_y            ;
					tse_nxloge2_valid     <= fs_nxloge2_valid;
					tse_nxloge2           <= fs_nxloge2      ;
					tse_add_result        <= add_result;
					tse_add_rdy           <= add_rdy   ;
					tse_mult_result       <= mult_result;
					tse_mult_rdy          <= mult_rdy   ;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				LOGE_DIV:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= 0;
					mult_b                <= 0;
					mult_valid            <= 0;
					div_a                 <= tse_out;
					div_b                 <= logemax;
					div_valid             <= tse_out_valid;
					
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_in_valid           <= 0;	
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= add_result;
					tse_add_rdy           <= add_rdy   ;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= div_rdy   ;
					cs_in                 <= div_result;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
				
				CUMULATIVE_SUM:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= cs_add_a    ;
					add_b                 <= cs_add_b    ;
					add_valid             <= cs_add_valid;
					sub_a                 <= cs_sub_a    ;
					sub_b                 <= cs_sub_b    ;
					sub_valid             <= cs_sub_valid;          
					mult_a                <= cs_mult_a    ;
					mult_b                <= cs_mult_b    ;
					mult_valid            <= cs_mult_valid;
					div_a                 <= cs_div_a    ;
					div_b                 <= cs_div_b    ;
					div_valid             <= cs_div_valid;
					
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_in_valid           <= 0;	
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= logdiv_div_flag & div_rdy   ;
					cs_in                 <= div_result;
					cs_add_result         <= add_result;
					cs_add_rdy            <= add_rdy   ;
					cs_sub_result         <= sub_result;
					cs_sub_rdy            <= sub_rdy   ;
					cs_mult_result        <= mult_result;
					cs_mult_rdy           <= mult_rdy   ;
					cs_div_result         <= div_result;
					cs_div_rdy            <= ~logdiv_div_flag & div_rdy   ;
				end
				
				default:
				begin
					fixed2float_a         <= 0;
					fixed2float_valid     <= 0;       
					add_a                 <= 0;
					add_b                 <= 0;
					add_valid             <= 0;     
					sub_a                 <= 0;
					sub_b                 <= 0;
					sub_valid             <= 0;          
					mult_a                <= 0;
					mult_b                <= 0;
					mult_valid            <= 0;
					div_a                 <= 0;
					div_b                 <= 0;
					div_valid             <= 0;
					
					mp_in                 <= 0;
					mp_maxu_in            <= 0;
					mp_in_valid           <= 0;	
					mp_add_result         <= 0;
					mp_add_rdy            <= 0;
					mp_mult_result        <= 0;
					mp_mult_rdy           <= 0;
					
					fs_in_valid           <= 0;
					fs_in                 <= 0;
					fs_fixed2float_result <= 0;
					fs_fixed2float_rdy    <= 0;
					fs_add_result         <= 0;
					fs_add_rdy            <= 0;  
					fs_sub_result         <= 0;
					fs_sub_rdy            <= 0;
					fs_mult_result        <= 0;
					fs_mult_rdy           <= 0;       
					fs_div_result         <= 0;
					fs_div_rdy            <= 0;
					
					tse_y_valid           <= 0;
					tse_y                 <= 0;
					tse_nxloge2_valid     <= 0;
					tse_nxloge2           <= 0;
					tse_add_result        <= 0;
					tse_add_rdy           <= 0;
					tse_mult_result       <= 0;
					tse_mult_rdy          <= 0;
					
					cs_in_valid           <= 0;
					cs_in                 <= 0;
					cs_add_result         <= 0;
					cs_add_rdy            <= 0;
					cs_sub_result         <= 0;
					cs_sub_rdy            <= 0;
					cs_mult_result        <= 0;
					cs_mult_rdy           <= 0;
					cs_div_result         <= 0;
					cs_div_rdy            <= 0;
				end
			endcase
		//end
	end
	
	maxuhp1
	#(
	  .C_DATA_WIDTH  (C_DATA_WIDTH)
	)
	u_maxuhp1
	(
	  //system signal
	  .clk             (clk         ),
	  .reset           (reset       ),
	  //data input
	  .dataf_in_valid  (mp_in_valid   ), 
	  .dataf_in        (mp_in         ),
	  .dataf_maxu_in   (mp_maxu_in    ),
	  //data output
	  .dataf_out_valid (mp_out_valid  ), 
	  .dataf_out       (mp_out        ),
	  //add
	  .add_a           (mp_add_a      ),
	  .add_b           (mp_add_b      ),
		.add_valid       (mp_add_valid  ),
		.add_result      (mp_add_result ),
		.add_rdy         (mp_add_rdy    ),
		//mult
	  .mult_a          (mp_mult_a     ),
	  .mult_b          (mp_mult_b     ),
		.mult_valid      (mp_mult_valid ),
		.mult_result     (mp_mult_result),
		.mult_rdy        (mp_mult_rdy   )
	);
	
	float_separate
	#(
	  .C_DATA_WIDTH       (C_DATA_WIDTH)
	)
	u_float_separate
	(
	  // system signal
	  .clk                (clk         ),
	  .reset              (reset       ),
	  // data input
	  .dataf_in_valid     (fs_in_valid ),
	  .dataf_in           (fs_in       ),
	  // data output                   
	  .nxloge2_valid      (fs_nxloge2_valid), 
	  .nxloge2_out        (fs_nxloge2      ),  
	  .y_valid            (fs_y_valid      ),      
	  .y_out              (fs_y            ),        
	  //fixed2float
	  .fixed2float_a      (fs_fixed2float_a     ),
		.fixed2float_valid  (fs_fixed2float_valid ),          
		.fixed2float_result (fs_fixed2float_result),
		.fixed2float_rdy    (fs_fixed2float_rdy   ),
		//add                                     
	  .add_a              (fs_add_a             ),
	  .add_b              (fs_add_b             ),
		.add_valid          (fs_add_valid         ),
		.add_result         (fs_add_result        ),
		.add_rdy            (fs_add_rdy           ),
		//sub                                     
	  .sub_a              (fs_sub_a             ),
	  .sub_b              (fs_sub_b             ),
		.sub_valid          (fs_sub_valid         ),
		.sub_result         (fs_sub_result        ),
		.sub_rdy            (fs_sub_rdy           ),
		//mult                                    
	  .mult_a             (fs_mult_a            ),
	  .mult_b             (fs_mult_b            ),
		.mult_valid         (fs_mult_valid        ),
		.mult_result        (fs_mult_result       ),
		.mult_rdy           (fs_mult_rdy          ),
		//div                                     
	  .div_a              (fs_div_a             ),
	  .div_b              (fs_div_b             ),
		.div_valid          (fs_div_valid         ),
		.div_result         (fs_div_result        ),
		.div_rdy	          (fs_div_rdy           ),
		.db                 (db[0])
	);
	
	taylor_series_expansion
	#(
	  .C_DATA_WIDTH    (C_DATA_WIDTH)
	)
	u_taylor_series_expansion
	(
	  //system signal
	  .clk             (clk            ),
	  .reset           (reset          ),
	  //data input                     
	  .nxloge2_valid   (tse_nxloge2_valid), 
	  .nxloge2_in      (tse_nxloge2      ),  
	  .y_valid         (tse_y_valid      ),      
	  .y_in            (tse_y            ),   
	  //data output                    
	  .dataf_out_valid (tse_out_valid  ), 
	  .dataf_out       (tse_out        ),
	  //add
	  .add_a           (tse_add_a      ),
	  .add_b           (tse_add_b      ),
		.add_valid       (tse_add_valid  ),
		.add_result      (tse_add_result ),
		.add_rdy         (tse_add_rdy    ),
		//mult
	  .mult_a          (tse_mult_a     ),
	  .mult_b          (tse_mult_b     ),
		.mult_valid      (tse_mult_valid ),
		.mult_result     (tse_mult_result),
		.mult_rdy        (tse_mult_rdy   ),
		.db              (db[1])
	);
	
	cumulative_sum
	#(
	  .C_DATA_WIDTH    (C_DATA_WIDTH )
	)
	u_cumulative_sum
	(
	  //system signal
	  .clk                (clk                ),
	  .reset              (reset              ),
	  //data input                            
	  .dataf_in_valid     (cs_in_valid        ),
	  .dataf_in           (cs_in              ),
  	//data output      
  	.cal_eq_done        (cal_eq_done        ),
		.cal_eq_part_done   (cs_cal_eq_part_done),
  	//ram              
  	.ram_wea            (ram_wea        ),
  	.ram_addra          (ram_addra      ),
  	.ram_dina           (ram_dina       ),
  	.ram_rdb            (ram_rdb        ),
  	.ram_addrb          (ram_addrb      ),
		.ram_doutb          (ram_doutb      ),
	  //add                             
	  .add_a              (cs_add_a       ),
	  .add_b              (cs_add_b       ),
		.add_valid          (cs_add_valid   ),
		.add_result         (cs_add_result  ),
		.add_rdy            (cs_add_rdy     ),
		//sub                               
	  .sub_a              (cs_sub_a       ),
	  .sub_b              (cs_sub_b       ),
		.sub_valid          (cs_sub_valid   ),
		.sub_result         (cs_sub_result  ),
		.sub_rdy            (cs_sub_rdy     ),
		//mult                             
	  .mult_a             (cs_mult_a      ),
	  .mult_b             (cs_mult_b      ),
		.mult_valid         (cs_mult_valid  ),
		.mult_result        (cs_mult_result ),
		.mult_rdy           (cs_mult_rdy    ),
		//div                               
	  .div_a              (cs_div_a       ),
	  .div_b              (cs_div_b       ),
		.div_valid          (cs_div_valid   ),
		.div_result         (cs_div_result  ),
		.div_rdy            (cs_div_rdy     ),
		//float2fixed       
		.float2fixed_a      (float2fixed_a     ),
		.float2fixed_valid  (float2fixed_valid ),
		.float2fixed_result (float2fixed_result),
		.float2fixed_rdy    (float2fixed_rdy   )
	);

	
endmodule