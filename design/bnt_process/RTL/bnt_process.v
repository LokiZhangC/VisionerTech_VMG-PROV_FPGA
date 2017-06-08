module bnt_process
#(
	parameter                      C_SAMPLE_TIME = 500,//ms
	parameter                      C_CLK_FREQ    = 100_000//KHz
	
)
(
  // system signal
  input  wire        clk      ,
  input  wire        reset    ,
  input  wire        bnt      ,
                              
  output wire        bnt_star ,
  output wire        bnt_end  ,
  output wire        bnt_valid
) ;
	
	reg         bnt_d1;
	reg         bnt_d2;
	reg         bnt_d3;
	
	wire        bnt_d2_ns;
	wire        bnt_ps;
	wire        bnt_ns;

	reg  [31:0] bnt_cnt;
	reg         bnt_flag;
	reg         bnt_flag_d1;
	
	assign bnt_star  = bnt_flag & ~bnt_flag_d1;
	assign bnt_end   = ~bnt_flag & bnt_flag_d1;
	assign bnt_valid = bnt_flag;

	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			bnt_d1 <= 1'b1;
			bnt_d2 <= 1'b1;
			bnt_d3 <= 1'b1;
		end
		else
		begin
			bnt_d1 <= bnt;
			bnt_d2 <= bnt_d1;
			bnt_d3 <= bnt_d2;
		end
	end
	
	assign bnt_d2_ns = ~bnt_d2 & bnt_d3;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			bnt_flag <= 1'b0;
		end
		else if(bnt_cnt == C_CLK_FREQ*C_SAMPLE_TIME)//100ms
		begin
			bnt_flag <= 1'b0;
		end
		else if(bnt_d2_ns)
		begin
			bnt_flag <= 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			bnt_flag_d1 <= 1'b0;
		end
		else
		begin
			bnt_flag_d1 <= bnt_flag;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			bnt_cnt <= 'd0;
		end
		else if(bnt_flag)
		begin
			bnt_cnt <= bnt_cnt + 1'b1;
		end
		else
		begin
			bnt_cnt <= 'd0;
		end
	end
	
endmodule