
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : hdr_ae_signal.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : hdr_ae_signal
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
module hdr_ae_signal
#(
  parameter  C_DATA_WIDTH   = 8
)
(
  // system signal
  input   wire                    reset   ,
  input   wire                    pix_clk ,
  // data input
  input   wire                    vs_in   ,
  input   wire                    hs_in   ,
  input   wire                    de_in   ,
  input   wire [C_DATA_WIDTH-1:0] data_in , 
  // data output
  output  reg                     vs_out  ,
  output  reg                     hs_out  ,
  output  reg                     de_out  ,
  output  reg  [C_DATA_WIDTH-1:0] data_out
);
	
	
	// =============================================================================
	// Internal signal
	// =============================================================================
	reg  [1:0]              vs_d; 
  reg  [1:0]              hs_d; 
  reg  [1:0]              de_d; 
  reg  [C_DATA_WIDTH-1:0] data_d1;
  wire                    data_sum_valid;
  reg  [18:0]             data_sum;
  reg  [18:0]             data_sum0;
  reg  [18:0]             data_sum1;
  reg  [18:0]             data_sum2;
  reg  [1:0]              frames_num;
  reg                     frames_num_valid;
  reg  [1:0]              frames_num_r;
  reg  [2:0]              compare_r;
  
  wire                    vs_ps;
  reg  [1:0]              vs_cnt;
  wire                    de_ns;
  reg                     line_div;
  reg                     output_valid_flag;
  

	// =============================================================================
	// RTL Body
	// =============================================================================
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d   <= {2{1'b1}}; 
  		hs_d   <= {2{1'b1}}; 
  		de_d   <= {2{1'b0}};
  		data_d1<= 0;
		end
		else
		begin
			vs_d   <= {vs_d[0],vs_in}; 
  		hs_d   <= {hs_d[0],hs_in}; 
  		de_d   <= {de_d[0],de_in};
  		data_d1<= data_in;
		end
	end
  
  assign de_ns = ~de_in & de_d[0];
  assign vs_ps = vs_in & ~vs_d[0];
  
  always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_cnt <= 2'b00; 
		end
		else if(vs_ps)
		begin
			vs_cnt <= vs_cnt + 1'b1;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			output_valid_flag <= 1'b0;
		end
		else if(&vs_cnt & vs_ps)
		begin
			output_valid_flag <= 1'b1;
		end
	end
	
	assign data_sum_valid = ~line_div & de_ns;
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			line_div <= 1'b0; 
		end
		else if(data_sum_valid)
		begin
			line_div <= ~line_div;
		end
		else if(vs_in)
		begin
			line_div <= 1'b0; 
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			data_sum <= 0; 
		end
		else if(~line_div & de_in)
		begin
			data_sum <= data_sum + data_in;
		end
		else
		begin
			data_sum <= 0;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			data_sum0 <= 0;
			data_sum1 <= 0;
			data_sum2 <= 0;
			
			frames_num<= 0;
			compare_r <= 0;
		end
		else
		begin
			case(vs_cnt)
				2'b00:
				begin
					if(data_sum_valid)
					begin
						data_sum0 <= data_sum;
						frames_num<= 2'd0;
						compare_r <= 3'd0;
					end
				end				
				2'b01:
				begin
					if(data_sum_valid)
					begin
						data_sum1 <= data_sum;
						if(data_sum >= data_sum0)
						begin
							frames_num<= 2'd1;
							compare_r[0] <= 1'b1;
						end
						else
						begin
							compare_r[0] <= 1'b0;
						end
					end
				end
				2'b10:
				begin
					if(data_sum_valid)
					begin
						data_sum2 <= data_sum;
						if(~compare_r[0])
						begin
							if(data_sum <= data_sum0 & data_sum >= data_sum1)
							begin
								frames_num<= 2'd2;
								compare_r[2:1] <= 2'b01;
							end
							else if(data_sum >= data_sum0)
							begin
								compare_r[2:1] <= 2'b10;
							end
							else
							begin
								compare_r[2:1] <= 2'b00;
								frames_num<= 2'd1;
							end
						end
						else if(compare_r[0])
						begin
							if(data_sum >= data_sum0 & data_sum <= data_sum1)
							begin
								frames_num<= 2'd2;
								compare_r[2:1] <= 2'b01;
							end
							else if(data_sum >= data_sum1)
							begin
								compare_r[2:1] <= 2'b10;
							end
							else
							begin
								compare_r[2:1] <= 2'b00;
								frames_num<= 2'd0;
							end
						end						
					end
				end
				2'b11:
				begin
					if(data_sum_valid)
					begin
						case(compare_r)
							3'b000:
							begin
								if(data_sum >= data_sum1 & data_sum <= data_sum0)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum0)
								begin
									frames_num<= 2'd0;
								end
							end
							
							3'b010:
							begin
								if(data_sum >= data_sum2 & data_sum <= data_sum0)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum0)
								begin
									frames_num<= 2'd0;
								end
							end
							
							3'b100:
							begin
								if(data_sum >= data_sum0 & data_sum <= data_sum2)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum2)
								begin
									frames_num<= 2'd2;
								end
							end
							
							3'b001:
							begin
								if(data_sum >= data_sum0 & data_sum <= data_sum1)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum1)
								begin
									frames_num<= 2'd1;
								end
							end
							
							3'b011:
							begin
								if(data_sum >= data_sum2 & data_sum <= data_sum1)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum1)
								begin
									frames_num<= 2'd1;
								end
							end
							
							3'b101:
							begin
								if(data_sum >= data_sum1 & data_sum <= data_sum2)
								begin
									frames_num<= 2'd3;
								end
								else if(data_sum >= data_sum2)
								begin
									frames_num<= 2'd2;
								end
							end
							
							default:
							begin
								
							end
						endcase
					end
				end
			endcase
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			frames_num_valid <= 1'b0;
		end
		else if(&vs_cnt & vs_ps)
		begin
			frames_num_valid <= 1'b1;
		end
		else
		begin
			frames_num_valid <= 1'b0;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			frames_num_r <= 2'b00;
		end
		else if(frames_num_valid)
		begin
			frames_num_r <= frames_num;
		end
	end
	
	always@(posedge pix_clk or posedge reset)
	begin
		if(reset)
		begin
			vs_out   <= 1'b1;
			hs_out   <= 1'b1;
			de_out   <= 1'b0;
			data_out <= 0;
		end
		else
		begin
			if(output_valid_flag)
			begin
				if(~(|vs_cnt))
				begin
					vs_out   <= vs_d[0];
				end
				else
				begin
					vs_out   <= 1'b0;
				end
			end
			else
			begin
				vs_out   <= 1'b1;
			end
			
			if(output_valid_flag)
			begin
				if(vs_cnt == frames_num_r)
				begin
					de_out   <= de_d[0];
				end
				else
				begin
					de_out   <= 1'b0;
				end
			end
			else
			begin
				de_out   <= 1'b0;
			end
			
			hs_out   <= hs_d[0];
			data_out <= data_d1;		
		end
	end
	
endmodule
