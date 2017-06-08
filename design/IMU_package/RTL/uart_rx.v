module UART_RX (  
    input             sys_clk,
    input             reset,
    input             Rx,
    output reg        RxData_VLD,
    output reg  [7:0] RxDATA
);  
                  
      
    parameter FRE_SYS_CLK = 100000000; // sys_clk frequency 
    parameter UART_RATE = 115200;     // 115200bps  
    parameter RXCLK_DIV_CNT = FRE_SYS_CLK / UART_RATE - 1;
      
    localparam RX_IDLE         = 4'd0;
    localparam RX_START_BIT    = 4'd1;
    localparam RX_RECIEVE_BIT0 = 4'd2;
    localparam RX_RECIEVE_BIT1 = 4'd3;
    localparam RX_RECIEVE_BIT2 = 4'd4;
    localparam RX_RECIEVE_BIT3 = 4'd5;
    localparam RX_RECIEVE_BIT4 = 4'd6;
    localparam RX_RECIEVE_BIT5 = 4'd7;
    localparam RX_RECIEVE_BIT6 = 4'd8;
    localparam RX_RECIEVE_BIT7 = 4'd9;
    localparam RX_PARITY_BIT   = 4'd10;
    localparam RX_END_BIT      = 4'd11;
      

    reg     [clogb2(RXCLK_DIV_CNT):0] clk_cnt;  
    reg     RXCLK_EN;
(* KEEP = "TRUE" *)    wire    RX_CLK;


    function integer clogb2;
    input integer value;
    begin 
    	value = value-1;
    	for (clogb2=0; value>0; clogb2=clogb2+1)
    	value = value>>1;
    end 
    endfunction                                             

    always @ (posedge sys_clk or posedge reset)  
        if(reset == 1'b1)  
            clk_cnt <= 12'd0;      
	else if(RXCLK_EN == 1'b0) begin
            clk_cnt <= 12'd0;   
	end   
	else if(clk_cnt == RXCLK_DIV_CNT) begin 
            clk_cnt <= 12'd0;  
	end
	else begin  
            clk_cnt <= clk_cnt + 1'b1;  
	end
              
    assign RX_CLK = (clk_cnt == RXCLK_DIV_CNT/2); 
      
      
    reg     Rx_1d;  
    reg     Rx_2d;  
    wire    RxStart;  

    always @ (posedge sys_clk or posedge reset) begin 
        if(reset == 1'b1) begin  
            Rx_1d <= 1'b1;  
            Rx_2d <= 1'b1;  
            end  
        else begin  
            Rx_2d <= Rx_1d;  
            Rx_1d <= Rx;  
        end  
    end
      
    assign RxStart = Rx_2d & (~Rx_1d);
      
      
(* KEEP = "TRUE" *)    reg [10 : 0] RxTemp;  
(* KEEP = "TRUE" *)    reg [4 : 0]  RxState;  

    always @ (posedge sys_clk or posedge reset)  
        if(reset == 1'b1) begin  
            RxDATA <= 8'd0;  
            RxTemp <= 11'd0;  
            RxState <= RX_IDLE;  
            RXCLK_EN <= 1'b0;
            RxData_VLD <= 1'b0;
        end  
        else if((RxState == RX_IDLE) && (RxStart == 1'b1))begin
                RXCLK_EN <= 1'd1;
                RxState  <= RX_START_BIT; 
        end  
        else if(RX_CLK) begin
                case (RxState) //synthesis full_case  
                    RX_START_BIT    :   begin  
                                RxTemp[0] <= Rx; //start bit 
                                RxState <= RX_RECIEVE_BIT0;  
                                end  
                    RX_RECIEVE_BIT0    :   begin  
                                RxTemp[1] <= Rx;//bit0  
                                RxState <= RX_RECIEVE_BIT1;  
                                end  
                    RX_RECIEVE_BIT1    :   begin  
                                RxTemp[2] <= Rx;//bit1  
                                RxState <= RX_RECIEVE_BIT2;  
                                end  
                    RX_RECIEVE_BIT2    :   begin  
                                RxTemp[3] <= Rx;//bit2  
                                RxState <= RX_RECIEVE_BIT3;  
                                end  
                    RX_RECIEVE_BIT3    :   begin  
                                RxTemp[4] <= Rx;//bit3  
                                RxState <= RX_RECIEVE_BIT4;  
                                end  
                    RX_RECIEVE_BIT4    :   begin  
                                RxTemp[5] <= Rx;//bit4  
                                RxState <= RX_RECIEVE_BIT5;  
                                end  
                    RX_RECIEVE_BIT5    :   begin  
                                RxTemp[6] <= Rx;//bit5  
                                RxState <= RX_RECIEVE_BIT6;  
                                end  
                    RX_RECIEVE_BIT6    :   begin  
                                RxTemp[7] <= Rx;//bit6  
                                RxState <= RX_RECIEVE_BIT7;  
                                end  
                    RX_RECIEVE_BIT7    :   begin  
                                RxTemp[8] <= Rx;//bit7  
                                RxState <= RX_END_BIT;  
                                end  
//                    RX_PARITY_BIT   :   begin  
//                                RxTemp[9] <= Rx;//parity bit  
//                                RxState <= RX_END_BIT;  
//                                end  
                    RX_END_BIT    :   begin  
                                RxTemp[10] <= Rx;
                                RXCLK_EN <= 1'b0;
                                RxState <= RX_IDLE;
				    if((RxTemp[0] == 1'b0) && (RxTemp[10] == 1'b1)) begin//check start bit & stop bit 
					RxDATA <= RxTemp[8:1];  
					RxData_VLD <= 1'b1; 
				    end  
				    else begin
					RxDATA <= RxDATA;  
					RxData_VLD <= RxData_VLD; 
				    end
                                end  
		   default    :   begin
                                RxDATA <= 8'd0;  
                                RxTemp <= 11'd0;  
                                RxState <= RX_IDLE;  
                                RXCLK_EN <= 1'b0;
                                RxData_VLD <= 1'b0;
		   end
                endcase  
        end //end else if  
	else begin 
            RxData_VLD <= 1'b0;
            RxDATA <= RxDATA;  
            RxTemp <= RxTemp;  
            RxState <= RxState;  
            RXCLK_EN <= RXCLK_EN;
	end
          
endmodule  
