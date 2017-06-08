`timescale 1ps / 1ps

module i2c_master_sensor
	#
	(
		parameter                     C_CLK_FREQ    = 100_000,//KHz
		parameter                     C_I2C_FREQ    = 100    ,//KHz
		parameter                     C_DATA_WIDTH  = 10'd16 ,
		parameter                     C_SADDR_WIDTH = 10'd8  ,
		parameter                     C_BADDR_WIDTH = 10'd16
	)
	(
		input  wire                    clk                ,
		input  wire                    reset              ,
		
		input  wire                    data_addr_in_value ,
		input  wire[C_DATA_WIDTH-1:0]  data_in            ,
		input  wire[C_SADDR_WIDTH-1:0] slave_addr_in      ,
		input  wire[C_BADDR_WIDTH-1:0] base_addr_in       ,
		
		output reg                     data_addr_out_value,
		output reg [C_DATA_WIDTH-1:0]  data_out           ,
		output reg [C_SADDR_WIDTH-1:0] slave_addr_out     ,
		output reg [C_BADDR_WIDTH-1:0] base_addr_out      ,
		
		output wire                    i2c_busy           ,
		output wire                    i2c_done           ,
		output reg                     error              ,
		output reg [2:0]               error_code         ,
		
		output wire                    SCL                ,
		//inout  wire                    SDA                ,
		input  wire                               sda_i   ,
		output reg                                sda_o   ,
		output wire                               sda_t   ,
		//debug signal
		output wire                    sda_sa             ,
		output wire                    sda_ba             ,
		output wire                    sda_d              ,
		output wire                    sda_t_acko         ,
		output wire                    sda_t_reado         
		
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
	reg [3:0] state;
	reg [3:0] state_d;
	localparam I2C_IDLE                    = 4'd0;
	localparam I2C_START                   = 4'd1;
	localparam I2C_SLAVE_ADDR              = 4'd2;
	localparam I2C_ACK_SA                  = 4'd3;
	localparam I2C_BASE_ADDR_H             = 4'd4;
	localparam I2C_ACK_BAH                 = 4'd5;
	localparam I2C_BASE_ADDR_L             = 4'd6;
	localparam I2C_ACK_BAL                 = 4'd7;
	localparam I2C_RESTART                 = 4'd8;
	localparam I2C_DATA1                   = 4'd9;
	localparam I2C_ACK_D1                  = 4'd10;
	localparam I2C_DATA2                   = 4'd11;
	localparam I2C_ACK_D2                  = 4'd12;
	localparam I2C_STOP                    = 4'd13;
	
	localparam I2C_SCL_DUTY_CYCLE   = (C_CLK_FREQ/C_I2C_FREQ)/2-1;
	localparam I2C_SCL_DUTY_CYCLE_2 = I2C_SCL_DUTY_CYCLE/2;
	
	reg  [clog2(I2C_SCL_DUTY_CYCLE):0] scl_duty_cycle;
	reg  [clog2(C_DATA_WIDTH)-1:0]     scl_duty_cycle_num;
	reg                                scl_duty_cycle_flag_div;
	reg                                scl_r;
	reg                                scl_r_d;
	wire                               scl_ns;
	reg                                sda_capture;
	reg                                scl_duty_cycle_end;
	
	reg  [1:0]                         r_w_fsm;
	
	wire [C_DATA_WIDTH/2-1:0]          datah_is           ;
	wire [C_DATA_WIDTH/2-1:0]          datal_is           ;
	wire [C_SADDR_WIDTH-1:0]           slave_addr_is      ;
	wire [C_BADDR_WIDTH/2-1:0]         base_addrh_is      ;
	wire [C_BADDR_WIDTH/2-1:0]         base_addrl_is      ;
	
	reg  [C_DATA_WIDTH/2-1:0]          datah_w            ;
	reg  [C_DATA_WIDTH/2-1:0]          datal_w            ;
	reg  [C_SADDR_WIDTH-1:0]           slave_addr_w       ;
	reg  [C_BADDR_WIDTH/2-1:0]         base_addrh_w       ;
	reg  [C_BADDR_WIDTH/2-1:0]         base_addrl_w       ;
	                                   
	reg  [C_DATA_WIDTH/2-1:0]          sda_data;
	
	wire                               sa_error;
	wire                               ba_error;
	wire                               da_error;
	
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	assign SCL   = scl_r;
	//assign SDA   = (sda_t) ? 1'bz : sda_o;
	//assign sda_i = SDA;
	assign sda_t = (state == I2C_ACK_SA) | (state == I2C_ACK_BAH | state == I2C_ACK_BAL) | ((state == I2C_ACK_D1 | state == I2C_ACK_D2) & ~r_w_fsm[1]) | ((state == I2C_DATA1 | state == I2C_DATA2) & r_w_fsm[1]);
	
	//debug
	assign sda_t_acko  = (state == I2C_ACK_SA) | (state == I2C_ACK_BAH | state == I2C_ACK_BAL) | ((state == I2C_ACK_D1 | state == I2C_ACK_D2) & ~r_w_fsm[1]);
	assign sda_t_reado = ((state == I2C_DATA1 | state == I2C_DATA2) & r_w_fsm[1]);
	assign sda_sa      = state == I2C_SLAVE_ADDR;
	assign sda_ba      = state == I2C_BASE_ADDR_H | state == I2C_BASE_ADDR_L;
	assign sda_d       = state == I2C_DATA1 | state == I2C_DATA2;
	
	assign i2c_busy = (state != I2C_IDLE) | reset;
	
	genvar i;
  generate
     for (i=0; i < C_DATA_WIDTH/2; i=i+1) 
     begin: data_index_swap
        assign datah_is[i] = data_in[C_DATA_WIDTH-1-i];
        assign datal_is[i] = data_in[C_DATA_WIDTH/2-1-i];
     end
  endgenerate
  
  genvar j;
  generate
     for (j=0; j < C_SADDR_WIDTH; j=j+1) 
     begin: sa_index_swap
        assign slave_addr_is[j] = slave_addr_in[C_SADDR_WIDTH-1-j];
     end
  endgenerate
  
  genvar k;
  generate
     for (k=0; k < C_BADDR_WIDTH/2; k=k+1) 
     begin: ba_index_swap
        assign base_addrh_is[k] = base_addr_in[C_BADDR_WIDTH-1-k];
        assign base_addrl_is[k] = base_addr_in[C_BADDR_WIDTH/2-1-k];
     end
  endgenerate
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			datah_w      <= 0;
			datal_w      <= 0;
			slave_addr_w <= 0;
			base_addrh_w <= 0;
			base_addrl_w <= 0;
		end
		else if(data_addr_in_value)
		begin
			datah_w      <= datah_is;
			datal_w      <= datal_is;
			slave_addr_w <= slave_addr_is;
			base_addrh_w  <= base_addrh_is;
			base_addrl_w  <= base_addrl_is;
		end
	end
	
	
	
	//------------------------------------------------------------------------------
	//I2C scl
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			scl_duty_cycle <= 0;
		end
		else if((state == I2C_IDLE) | (scl_duty_cycle == I2C_SCL_DUTY_CYCLE))
		begin
			scl_duty_cycle <= 0;
		end
		else
		begin
			scl_duty_cycle <= scl_duty_cycle + 1'b1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			scl_duty_cycle_end <= 1'b0;
		end
		else if(scl_duty_cycle == I2C_SCL_DUTY_CYCLE-1)
		begin
			scl_duty_cycle_end <= 1'b1;
		end
		else
		begin
			scl_duty_cycle_end <= 1'b0;
		end
	end 
	
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			state_d <= 0;
		end
		else
		begin
			state_d <= state;
		end
	end
	
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			scl_duty_cycle_flag_div <= 0;
		end
		else if((state != state_d) | (state == I2C_IDLE))
		begin
			scl_duty_cycle_flag_div <= 0;
		end
		else if(scl_duty_cycle_end)
		begin
			scl_duty_cycle_flag_div <= ~scl_duty_cycle_flag_div;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sda_capture <= 1'b0;
		end
		else if(scl_duty_cycle_flag_div & scl_duty_cycle == I2C_SCL_DUTY_CYCLE_2)
		begin
			sda_capture <= 1'b1;
		end
		else
		begin
			sda_capture <= 1'b0;
		end
	end 
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sda_data <= 0;
		end
		else if(sda_capture)
		begin
			sda_data <= {sda_data[(C_DATA_WIDTH/2)-2:0],sda_i};
		end
	end 
	
	//------------------------------------------------------------------------------
	//I2C read or write
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			r_w_fsm <= 2'b00;
		end
		else if(state == I2C_STOP)
		begin
			r_w_fsm <= 2'b00;
		end
		else if(data_addr_in_value)
		begin
			r_w_fsm[0] <= slave_addr_in[0];
		end
		else if(state == I2C_ACK_BAL & scl_duty_cycle_flag_div & scl_duty_cycle_end)
		begin
			r_w_fsm <= {r_w_fsm[0],1'b0};
		end
	end    
	
	
	
	//------------------------------------------------------------------------------
	//I2C FSM
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			state <= I2C_IDLE;
		end
		else
		begin
			case(state)
				I2C_IDLE:
				begin
					if(data_addr_in_value)
					begin
						state <= I2C_START;
					end
					else
					begin
						state <= I2C_IDLE;
					end
				end
				
				I2C_START:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						state <= I2C_SLAVE_ADDR;
					end
					else
					begin
						state <= I2C_START;
					end
				end
				
				I2C_SLAVE_ADDR:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						state <= I2C_ACK_SA;
					end
					else
					begin
						state <= I2C_SLAVE_ADDR;
					end
				end
				
				I2C_ACK_SA:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						if(~sda_data[0])
						begin
							if(r_w_fsm[1])
							begin
								state <= I2C_DATA1;
							end
							else
							begin
								state <= I2C_BASE_ADDR_H;
							end							
						end
						else//slave no ack error
						begin
							state <= I2C_STOP;
						end
					end
					else
					begin
						state <= I2C_ACK_SA;
					end
				end
				
				I2C_BASE_ADDR_H:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						state <= I2C_ACK_BAH;
					end
					else
					begin
						state <= I2C_BASE_ADDR_H;
					end
				end
				
				I2C_ACK_BAH:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						if(~sda_data[0])
						begin
							state <= I2C_BASE_ADDR_L;
						end
						else//slave no ack error
						begin
							state <= I2C_STOP;
						end							
					end
					else
					begin
						state <= I2C_ACK_BAH;
					end
				end
				
				I2C_BASE_ADDR_L:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						state <= I2C_ACK_BAL;
					end
					else
					begin
						state <= I2C_BASE_ADDR_L;
					end
				end
				
				I2C_ACK_BAL:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						if(~sda_data[0])
						begin
							if(r_w_fsm[0])//read data
							begin
								state <= I2C_RESTART;
							end
							else//write data
							begin
								state <= I2C_DATA1;
							end
						end
						else//slave no ack error
						begin
							state <= I2C_STOP;
						end							
					end
					else
					begin
						state <= I2C_ACK_BAL;
					end
				end
				
				I2C_RESTART:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						state <= I2C_SLAVE_ADDR;
					end
					else
					begin
						state <= I2C_RESTART;
					end
				end
				
				I2C_DATA1:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						state <= I2C_ACK_D1;
					end
					else
					begin
						state <= I2C_DATA1;
					end
				end
				
				I2C_ACK_D1:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						if(r_w_fsm[1])//read data
						begin
							state <= I2C_DATA2;
						end
						else//write data
						begin
							if(~sda_data[0])
							begin
								state <= I2C_DATA2;
							end
							else//slave no ack error
							begin
								state <= I2C_STOP;
							end	
						end
					end
					else
					begin
						state <= I2C_ACK_D1;
					end
				end
				
				I2C_DATA2:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						state <= I2C_ACK_D2;
					end
					else
					begin
						state <= I2C_DATA2;
					end
				end
				
				I2C_ACK_D2:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						state <= I2C_STOP;
					end
					else
					begin
						state <= I2C_ACK_D2;
					end
				end
				
				I2C_STOP:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						state <= I2C_IDLE;
					end
					else
					begin
						state <= I2C_STOP;
					end
				end
				
				default:
				begin
					state <= I2C_IDLE;
				end
			endcase
		end
	end 
	
	//------------------------------------------------------------------------------
	//I2C scl
	//------------------------------------------------------------------------------
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			scl_duty_cycle_num <= 0;
			scl_r <= 1'b1;
		end
		else
		begin
			case(state)
				I2C_IDLE:
				begin
					scl_duty_cycle_num <= 0;
					scl_r <= 1'b1;
				end
				
				I2C_START:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
					end
					
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_r <= 1'b0;
					end
					else
					begin
						scl_r <= 1'b1;
					end
				end
				
				I2C_SLAVE_ADDR:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_ACK_SA:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
						//if(~sda_data[0])
						//begin
							scl_r <= 1'b0;
						//end
						//else
						//begin
						//	scl_r <= 1'b1;
						//end		
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_BASE_ADDR_H:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_ACK_BAH:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
						//if(~sda_data[0])
						//begin
							scl_r <= 1'b0;
						//end
						//else
						//begin
						//	scl_r <= 1'b1;
						//end		
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_BASE_ADDR_L:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_ACK_BAL:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
						//if(~sda_data[0])
						//begin
							scl_r <= 1'b0;
						//end
						//else
						//begin
						//	scl_r <= 1'b1;
						//end		
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_RESTART:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						scl_duty_cycle_num <= 0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
					end
					
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end & scl_duty_cycle_num == 'd0)
					begin
						scl_r <= 1'b1;
					end
				end
				
				I2C_DATA1:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_ACK_D1:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
						//if(~sda_data[0])
						//begin
							scl_r <= 1'b0;
						//end
						//else
						//begin
						//	scl_r <= 1'b1;
						//end						
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_DATA2:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == (C_DATA_WIDTH-1))
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_ACK_D2:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						scl_duty_cycle_num <= 0;
						scl_r <= 1'b0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
						scl_r <= ~scl_r;
					end
				end
				
				I2C_STOP:
				begin
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						scl_duty_cycle_num <= 0;
					end
					else if(scl_duty_cycle_end)
					begin
						scl_duty_cycle_num <= scl_duty_cycle_num + 1'b1;
					end
					
					if(scl_duty_cycle_end & scl_duty_cycle_num == 'd2)
					begin
						scl_r <= 1'b1;
					end
					else if(scl_duty_cycle_end & scl_duty_cycle_num == 'd0)
					begin
						scl_r <= 1'b1;
					end
					
					//scl_r <= 1'b1;
				end
				
				default:
				begin
					
				end
				
			endcase
		end
	end  
	
	//------------------------------------------------------------------------------
	//I2C sda
	//------------------------------------------------------------------------------
	//I2C scl flag
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			scl_r_d <= 1'b1;
		end
		else
		begin
			scl_r_d <= scl_r;
		end
	end   
	
	assign scl_ns = ~scl_r & scl_r_d;
	
	//I2C sda
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			sda_o <= 1'b1;
		end
		else
		begin
			case(state)
				I2C_IDLE:
				begin
					sda_o <= 1'b1;
				end
				
				I2C_START:
				begin
					if(scl_duty_cycle_end)
					begin
						sda_o <= 1'b0;
					end
				end
				
				I2C_SLAVE_ADDR:
				begin
					if(scl_ns & scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1] == ((C_DATA_WIDTH/2)-1))
					begin
						sda_o <= r_w_fsm[1];
					end
					else if(scl_ns)
					begin
						sda_o <= slave_addr_w[scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1]];
					end
				end
				
				I2C_ACK_SA:
				begin
					if(scl_ns)
					begin
						sda_o <= 1'b0;
					end
				end
				
				I2C_BASE_ADDR_H:
				begin
					if(scl_ns)
					begin
						sda_o <= base_addrh_w[scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1]];
					end
				end
				
				I2C_ACK_BAH:
				begin
					sda_o <= 1'b0;
				end
				
				I2C_BASE_ADDR_L:
				begin
					if(scl_ns)
					begin
						sda_o <= base_addrl_w[scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1]];
					end
				end
				
				I2C_ACK_BAL:
				begin
					//if(r_w_fsm[0])
					//begin
						sda_o <= 1'b0;
					//end
					//else
					//begin
					//	sda_o <= 1'b0;
					//end					
				end
				
				I2C_RESTART:
				begin
					if(scl_ns)
					begin
						sda_o <= 1'b1;
					end
					else if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						sda_o <= 1'b0;
					end
				end
				
				I2C_DATA1:
				begin
					if(r_w_fsm[1])
					begin
						sda_o <= 1'b0;
					end
					else if(scl_ns)
					begin
						sda_o <= datah_w[scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1]];
					end
				end
				
				I2C_ACK_D1:
				begin
					sda_o <= 1'b0;
				end
				
				I2C_DATA2:
				begin
					if(r_w_fsm[1])
					begin
						sda_o <= 1'b0;
					end
					else if(scl_ns)
					begin
						sda_o <= datal_w[scl_duty_cycle_num[clog2(C_DATA_WIDTH)-1:1]];
					end
				end
				
				I2C_ACK_D2:
				begin
					sda_o <= 1'b0;
				end
				
				I2C_STOP:
				begin
					if(scl_ns)
					begin
						sda_o <= 1'b0;
					end
					else if(scl_duty_cycle_end & scl_duty_cycle_num == 'd1)
					begin
						sda_o <= 1'b1;
					end
				end
				
				default:
				begin
					sda_o <= 1'b1;
				end
			endcase
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			data_out <= 0;
		end
		else if(r_w_fsm[1] & scl_duty_cycle_num == (C_DATA_WIDTH-1) & scl_duty_cycle_end)
		begin
			if(state == I2C_DATA1)
			begin
				data_out[C_DATA_WIDTH-1:C_DATA_WIDTH-8] <= sda_data;
			end
			else if(state == I2C_DATA2)
			begin
				data_out[C_DATA_WIDTH-9:0] <= sda_data;
			end
		end
	end 
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			data_addr_out_value <= 0;
		end
		else if(state == I2C_DATA2 & r_w_fsm[1] & scl_duty_cycle_num == (C_DATA_WIDTH-1) & scl_duty_cycle_end)
		begin
			data_addr_out_value <= 1'b1;
		end
		else
		begin
			data_addr_out_value <= 0;
		end
	end 
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			slave_addr_out <= 0;     
			base_addr_out  <= 0; 
		end
		else if(data_addr_in_value)
		begin
			slave_addr_out <= {slave_addr_in[C_SADDR_WIDTH-1:1],1'b0};     
			base_addr_out  <= base_addr_in ;
		end
	end 
	
	assign sa_error = (state == I2C_ACK_SA & scl_duty_cycle_end & scl_duty_cycle_num == 'd1 & sda_data[0] != 1'b0);
	assign ba_error = ((state == I2C_ACK_BAH | state == I2C_ACK_BAL) & scl_duty_cycle_end & scl_duty_cycle_num == 'd1 & r_w_fsm[0] & sda_data[0] != 1'b0);
	assign da_error = ((state == I2C_ACK_D1 | state == I2C_ACK_D2) & scl_duty_cycle_end & scl_duty_cycle_num == 'd1 & r_w_fsm[0] & sda_data[0] != 1'b0);
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			error <= 0;
		end
		else
		begin
			error <= sa_error | ba_error | da_error;
		end
	end 
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			error_code <= 0;
		end
		else
		begin
			error_code <= {sa_error,ba_error,da_error};
		end
	end 

	assign i2c_done = (state == I2C_STOP) & scl_duty_cycle_end & scl_duty_cycle_flag_div;
	
	

endmodule
