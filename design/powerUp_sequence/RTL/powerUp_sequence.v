
`timescale 1ps / 1ps

module powerUp_sequence
	#(
		parameter  C_CLK_FREQ    = 100_000 //KHz
	)
	(
		input  wire   clk    ,//100MHz
		input  wire   reset  ,
		
		output wire   reset_1,
		output reg    reset_2

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
	localparam PU_DELAY        = 210;//ms
	localparam PU_DELAY_CYCLES = PU_DELAY*C_CLK_FREQ;
	reg  [clog2(PU_DELAY_CYCLES):0] powerup_cnt;
	
	localparam RESET_DELAY        = 5;//ms
	localparam RESET_DELAY_CYCLES = RESET_DELAY*C_CLK_FREQ;
	
	reg         powerup_done;
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	assign reset_1 = powerup_done;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			powerup_cnt  <= 0;
		end
		else if(powerup_cnt != PU_DELAY_CYCLES)
		begin
			powerup_cnt  <= powerup_cnt + 1'b1;
		end
	end      
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			powerup_done  <= 1'b0;
		end
		else if(powerup_cnt < PU_DELAY_CYCLES)
		begin
			powerup_done  <= 1'b0;
		end
		else
		begin
			powerup_done  <= 1'b1;
		end
	end      
	
	  
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			reset_2  <= 1'b0;
		end
		else if(powerup_cnt < RESET_DELAY_CYCLES)
		begin
			reset_2  <= 1'b0;
		end
		else
		begin
			reset_2  <= 1'b1;
		end
	end  
	
	

endmodule
