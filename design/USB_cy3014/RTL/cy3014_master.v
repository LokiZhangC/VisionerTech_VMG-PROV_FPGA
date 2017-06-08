

module cy3014_master(sync ,reset, hdmit_clk, hdmit_vs, hdmit_hs, hdmit_de, hdmit_d, fdata, faddr, slrd, slwr, flagb, flaga, hdmit_halfclk, sloe, clk_out, slcs, pktend,fifo_full_led,Last_packet,Last_packet_size); 
   input  [15:0]   Last_packet;
   input  [15:0]   Last_packet_size;
   output          fifo_full_led;
   //port define
   input           sync;
   input 	   reset;
    
   input           hdmit_clk;     //for 16bit transfer data
   input           hdmit_vs;
   input           hdmit_hs;
   input           hdmit_de;
   input  [15:0]   hdmit_d;

   output [31:0]   fdata; 
   output [1:0]    faddr; 
   output          slrd;  
   output          slwr;  
   input           flagb; 
   input           flaga; 

   input           hdmit_halfclk; //for 32bit transfer data  
   output          clk_out;   
   output          sloe; 
   output          slcs; 
   output          pktend;  
	

   //reg define  
   reg [31:0] 	   fdata_i      ;
   reg [31:0]      fdata_head   ;
   reg [2:0] 	   cnt 	        ;	
   reg [1:0]       faddr_i      ;	
   reg             slrd_i       ;      
   reg             slcs_i       ; 
   reg             slwr_i       ;      
 
   reg [1:0]       cnt_header 	;
	
(* KEEP = "TRUE" *)   reg [3:0]       MasterState 	;
   reg [3:0]       late_count 	;
(* KEEP = "TRUE" *)   reg [15:0]      State_cnt 	;
	
   reg             sloe_i       ;
   reg             pktend_i     ;
   reg             strob 	; 
   reg [3:0]       flag_count 	;
   reg             first_frame_flag;
   reg             fifo_wr_pause;
   reg             fifo_wr_pause_1ff;
   	
   
(* KEEP = "TRUE" *)   reg [31:0]   pkt_cnt;  
   reg [31:0]   discare_pkt_cnt;  
   
   reg [31:0]   UVC_Header_Np[2:0];
   reg [31:0]   flaga_low_cnt;
   reg [31:0]   broken_State_cnt;
   reg          fifo_clr;
   reg          flaga_1ff;
   reg          reset_o;
   reg          flaga_low_assert;
   reg [31:0]   throw_data_cnt;

   reg [2:0]   frame_cnt_after_exit;
   wire         fifo_wr;
   wire         hdmit_vs_ps;
   wire         hdmit_vs_ns;
   wire         frame_after_exit_flag;
   wire         fifo_wr_1st_after_exit;

(* KEEP = "TRUE" *)   wire         flaga_exit_from_low ;
   wire         flaga_ps;
   wire         fifo_almost_empty;
   wire         flaga_low_overtime;

   //wire define  
   reg             fifo_empty;
   reg             fifo_empty_1ff;
   reg             fifo_empty_2ff;
   wire            fifo_almost_empty_ns;
   wire            fifo_empty_ns_2cycle_pulse;

   wire [31:0]     fifo_data_read;
   wire            fifo_wr_act;
   reg             fifo_rd_en;

  //code	
	initial begin					
	UVC_Header_Np[0] = 32'h00008C0C;
	UVC_Header_Np[1] = 32'h00000000;
	UVC_Header_Np[2] = 32'h00000000;
	end
	
	
	reg[31:0] UVC_Header_Ep[2:0];
	
	initial begin					
	UVC_Header_Ep[0] = 32'h00008E0C;
	UVC_Header_Ep[1] = 32'h00000000;
	UVC_Header_Ep[2] = 32'h00000000;
	end
	
		
	
 //       parameter [15:0]  Last_packet = 254;//113;//161;//127;//113;
 //       parameter [15:0]  Last_packet_size = 5096;//9548;//1932;//10740;//9548;
     	
        parameter [3:0] A = 4'b0000; //IDLE
        parameter [3:0] B = 4'b0001; //ASSERT FLAGA TO START TRANSFER
        parameter [3:0] C = 4'b0010; //INSERT HEADER
        parameter [3:0] D = 4'b0011;
        parameter [3:0] E = 4'b0100; //TRANSFER A PACKET
        parameter [3:0] F = 4'b0101; //FINISH A PACKET
        parameter [3:0] G = 4'b0110;
        parameter [3:0] H = 4'b0111;
        
        assign slrd 	= slrd_i;
        assign slwr 	= slwr_i;   
        assign faddr 	= faddr_i;
        assign sloe 	= sloe_i;
	assign pktend  = pktend_i;	
	

	assign slcs 	= slcs_i;
	
	
	ODDR2 oddr_y
	(
		.D0(1'b1),
		.D1(1'b0),
		.C0 (~hdmit_halfclk),
		.C1(hdmit_halfclk),
		.Q(clk_out)
	);
   
//------------------------------------------------------------------------------
//Function  :HDMIT to USB 3.0 
//
//------------------------------------------------------------------------------
wire flaga_low_assert_ns;
reg  flaga_low_assert_1ff;

always @(posedge hdmit_clk or posedge reset)
begin
    if (reset == 1'b1)
    begin
        flaga_low_assert_1ff <= 1'b0;
    end
    else
    begin
        flaga_low_assert_1ff <= flaga_low_assert;
    end
end

   
   assign flaga_low_assert_ns = (~flaga_low_assert) & flaga_low_assert_1ff;

   assign flaga_exit_from_low = flaga_low_assert_ns;
   always @(posedge hdmit_halfclk or posedge reset)
   begin: test_proc 	
		if (reset == 1'b1 )
			begin
				MasterState[3:0] <= A;
				strob            <= 1'b0;
				faddr_i          <= 2'b00;				
				State_cnt        <= 1;
				sloe_i 		 <= 1'b1;                
				slrd_i 		 <= 1'b1;
				slwr_i 		 <= 1'b1;
				pktend_i 	 <= 1'b1;
				slcs_i           <= 1'b0;
				late_count       <= 0;
				cnt 		 <= 3'b000;	
                                fdata_i          <= 0;				
				fifo_rd_en       <= 0;
				first_frame_flag <= 1'b1;
				cnt_header       <= 0;
			end
		else
			begin		
				 case (MasterState[3:0])			
						A :    //IDLE
						begin
							sloe_i 		<= 1'b1;                
							slrd_i 		<= 1'b1;
							slwr_i 		<= 1'b1;
							pktend_i 	<= 1'b1;
							State_cnt       <= State_cnt;
							slcs_i          <= 1'b0;
							late_count      <= 0;
							cnt 		<= 3'b000;	
							strob 		<= strob;
                                                        fdata_i         <= 0;

							if (strob == 1'b0)
							begin						
								faddr_i 		<= 2'b00; 
							end
							else
							begin
								faddr_i 		<= 2'b01; 
							end

								
							if (first_frame_flag == 1'b1)   //before the first frame, there's no data in fifo
							begin
							    if ( fifo_empty == 1'b0)
							    begin						
							    	MasterState <= B; 
                                                                first_frame_flag <= 1'b0;
							    end
							    else 
							    begin
                                                                MasterState <= A; 
							    end
							end
							else
							begin
							        if (flag_count > 4'b1000)
								begin
								    MasterState <= B;
							        end	
								else
								begin
                                                                    MasterState <= A;
								end
							end
							
						end
						
						
						B:     //flaga :1-phy fifo ready,start  0:phy not ready,pause
						begin

                                                        sloe_i      <= sloe_i     ;    		
                                                        slrd_i 	    <= slrd_i 	  ;     
                                                        slwr_i 	    <= slwr_i 	  ;     
                                                        pktend_i    <= pktend_i   ;     
                                                        slcs_i      <= slcs_i     ;     
                                                        late_count  <= late_count ;     
                                                        cnt 	    <= cnt 	  ;     
							faddr_i     <= faddr_i    ;
							strob 	    <= strob;						
							cnt_header  <= 0;
                                                        fdata_i     <= 0;
                                             		State_cnt <= State_cnt;

							if (flaga == 1'b1)
							begin
								MasterState <= C         ; 
 
							end						
							else
							begin
								MasterState <= B          ; 
							end										
						
						end				


						C:
						begin
						    if (flaga == 1'b1)
						    begin
                                                        slwr_i 	<= 1'b0       ;
			                   	    	if (cnt_header < 2)
			                   	    	begin
                                                            MasterState <= C;
			                           	    cnt_header  <= cnt_header + 1;	
			                   	    	end
							else 
                                                        begin
							    MasterState <= E;
			                           	    cnt_header  <= cnt_header;	
                                                            fifo_rd_en  <= ~fifo_almost_empty       ;
							end
					            end
						    else 
						    begin
							slwr_i <= 1'b1;
                                                        MasterState <= C;
                                                        cnt_header  <= cnt_header;
                                                        fifo_rd_en  <= 0;
						    end
						end
						
					
						E :    //write data until almost full(last 3 data write)                                      
						begin    
                                                    if (flaga == 1'b1) 
						    begin
							sloe_i      <= 1'b1       ;
							slrd_i      <= 1'b1       ;
                                                        slcs_i      <= slcs_i     ;
							strob 	    <= strob      ;
//                                                        fdata_i     <= fifo_data_read;

							if ( State_cnt <= Last_packet-1)
						       	begin
                                                            fdata_i     <= fifo_data_read;
							    if ( pkt_cnt <= (16*1024*(Last_packet-1)+Last_packet_size)/4-1 )		
							    begin
								    faddr_i     <= faddr_i    ;
								    pktend_i    <= pktend_i   ; 
                                                                    cnt 	<= cnt 	      ;
							            State_cnt  <= State_cnt ;
								    if ((pkt_cnt == 16*1024*State_cnt/4-2) && (fifo_empty_ns_2cycle_pulse == 1'b1))           //exit from empty staus
								    begin							    
								        fifo_rd_en  <= 1'b1;
								        if ( pkt_cnt == 16*1024*State_cnt/4-2 )
								        begin
								            slwr_i      <= fifo_empty;
								            MasterState <= E;                   //write the 32K's last data (for  63 long packag)
								            late_count  <= late_count-1;	
								        end
								    end
								    else if (pkt_cnt == 16*1024*State_cnt/4-2)           //exit from empty staus
								    begin							    
									    fifo_rd_en  <= 0;
								            slwr_i      <= fifo_empty;
								            MasterState <= E;                   //write the 32K's last data (for  63 long packag)
								            late_count  <= late_count-1;	
								    end
								    else if (pkt_cnt == 16*1024*State_cnt/4-1)
								    begin
									fifo_rd_en  <= 0;
								        slwr_i      <= 1'b1;
								        MasterState <= F;                    
								        late_count  <= late_count;										
								    end
								    else
								    begin					 
									    slwr_i      <= fifo_empty;
									    fifo_rd_en  <= ~fifo_almost_empty; 
									    MasterState <= E;	                 //write until 32K-1	
									    late_count  <= late_count -1;
								    end
							    end
							end
							/*
							else if ( State_cnt == Last_packet-1)
						       	begin
                                                            fdata_i     <= fifo_data_read;
							    if ( pkt_cnt <= (16*1024*(Last_packet-1)+Last_packet_size)/4-1 )		
							    begin
								    faddr_i     <= faddr_i    ;
								    pktend_i    <= pktend_i   ; 
                                                                    cnt 	<= cnt 	      ;
							            State_cnt  <= State_cnt ;
							    
								    if ( pkt_cnt == 16*1024*State_cnt/4-1 )
								    begin
									    slwr_i      <= 1'b1;
									    fifo_rd_en  <= 1'b0;
									    MasterState <= F;                    //write the 32K's last data (for  63 long packag)
								            late_count  <= late_count;	
								    end
								    else if (pkt_cnt == 16*1024*State_cnt/4-2)
								    begin
									    slwr_i      <= fifo_empty;
									    fifo_rd_en  <= 1'b0;
									    MasterState <= E;                    
								            late_count  <= late_count -1;										
								    end
								    else
								    begin					 
									    slwr_i      <= fifo_empty;
									    fifo_rd_en  <= ~fifo_almost_empty; 
									    MasterState <= E;	                 //write until 32K-1	
									    late_count  <= late_count -1;
								    end
							    end
							end
*/
                                                        //independent with above logic (about slwr_i,late_count,MasterState),this is about pktend_i
							else if ( State_cnt == Last_packet )                                        
							begin
                                                            fdata_i     <= fifo_data_read;
                                                            late_count <= 2         ;
                                                            faddr_i    <= faddr_i   ;
							    cnt        <= cnt       ;	

                                                            if (pkt_cnt <= (16*1024*(Last_packet-1)+Last_packet_size)/4-1)
							    begin
								if (pkt_cnt == (16*1024*(Last_packet-1)+Last_packet_size)/4-2 /*((Last_packet_size/4)-1)*/ )
								begin							
						                        slwr_i          <= 1'b0      ;
								        fifo_rd_en      <= ~fifo_almost_empty;  
									pktend_i        <=  1'b0      ;		
									MasterState     <= F;                //write the last data of the last  short packag
									State_cnt 	<= 0;

								end							
								else
								begin
						                        slwr_i      <= fifo_empty      ;
								        fifo_rd_en  <= ~fifo_almost_empty; 								    
								        pktend_i    <= pktend_i      ;
								        MasterState <= E;
									State_cnt  <= State_cnt;
								end
							    end							
							    else 
							    begin
						                        slwr_i          <= 1'b1      ;
								        fifo_rd_en      <= 1'b0      ; 
									pktend_i 	<= pktend_i;		
									MasterState     <= MasterState;        
									State_cnt 	<= State_cnt;
							    end
							end
							else 
							begin
								    slwr_i 	<= 1'b1;                          
								    late_count  <= late_count;												
                                                                    faddr_i     <= faddr_i   ;
							            cnt         <= cnt       ;	

								    pktend_i 	<= pktend_i;		
								    MasterState <= MasterState;        
								    State_cnt 	<= State_cnt;

							end							
						    end	
						    else
                                                    begin
 							sloe_i      <= 1'b1       ;
							slrd_i      <= 1'b1       ;
                                                        slcs_i      <= slcs_i     ;
							strob 	    <= strob      ;
                                                        fdata_i     <= fifo_data_read;                                                   
							faddr_i     <= faddr_i    ;
							pktend_i    <= pktend_i   ; 
                                                        cnt 	    <= cnt 	      ;
							State_cnt   <= State_cnt ;
                                                        slwr_i      <= 1'b1;
                                                        fifo_rd_en  <= 1'b0;
                                                        MasterState <= E;         
                                                        late_count  <= late_count;
						    end
						end
						
						F:     //end sequence for slwr_i,pktend_i,strob
						begin 					
							
							late_count  <= late_count;												
                                                        faddr_i     <= faddr_i   ;

							sloe_i      <= 1'b1       ;
							slrd_i      <= 1'b1       ;
                                                        slcs_i      <= slcs_i     ;
                                                        fdata_i     <= fifo_data_read;

							if (cnt==3'b111)
							begin					
							        slwr_i 	        <= slwr_i;                          
							        pktend_i        <= pktend_i;		
								MasterState     <= A;		
								strob 		<= ~strob;
								State_cnt 	<= State_cnt + 1;							
								cnt             <= cnt ;
							end
						
							else
							begin
							        slwr_i 	    <= 1'b1;                          
							        pktend_i    <= 1'b1;		
							        strob 	    <= strob;
								MasterState <= F;		
                                                                State_cnt  <= State_cnt;
								cnt         <= cnt + 1'b1;
							end									
					
						end
					
						default :
						begin
						
							MasterState 	<= A;	
							
							faddr_i         <= 2'b00;
							sloe_i 		<= 1'b1;                
							slrd_i 		<= 1'b1;
							slwr_i 		<= 1'b1;
							pktend_i 	<= 1'b1;
							slcs_i          <= 1'b0;
							late_count      <= 0;
							cnt 		<= 3'b000;	
							State_cnt 	<= State_cnt;
							strob 		<= 1'b0;
						end				
					
					endcase
				end
		
		end

	
	always @(posedge hdmit_halfclk or posedge reset) 
	begin: flag_count_t		
		if (reset == 1'b1)
			begin
				flag_count <= 4'b0000;
			end
		else
			begin	
				if ( (MasterState==A) )
				begin
					flag_count <= flag_count + 1;
				end
				else
				begin
					flag_count <= 0;
				end
			end
	
	end	


//------------------------------------------------------------------------------
//Function  : data 16bit to 32 bit 
//
//------------------------------------------------------------------------------
reg [31 : 0] shift_reg;
reg          DE_1FF;	
reg          VS_1FF;	
reg div; 
	always @(posedge hdmit_clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			reset_o <= 1;
		end
		else if ( sync == 1'b1) 
		begin
                        reset_o <= 1'b0;
		end
		else if ( sync == 1'b0) 
		begin
                        reset_o <= 1'b1;
		end		
		else 
		begin
                        reset_o <= reset_o;
		end
	end
	
	wire underflow;

	cy3014_data_fifo 
	u_cy3014_data_fifo
	(
	    .rst         (reset | fifo_clr  ),
	    .wr_clk      (hdmit_clk         ),          
	    .rd_clk      (hdmit_halfclk     ),
	    .din         (shift_reg         ),
	    .wr_en       (fifo_wr_act       ),
	    .rd_en       (fifo_rd_en        ),
	    .dout        (fifo_data_read    ),
	    .full        (fifo_full         ),
	    .empty       (                  ),
	    .almost_empty(fifo_almost_empty )
	);

	always @(posedge hdmit_halfclk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
                        fdata_head <= 0;
		end
		else if ( State_cnt == Last_packet )
		begin
        		fdata_head <= UVC_Header_Ep[cnt_header];
		end
		else 
                begin
        		fdata_head <= UVC_Header_Np[cnt_header];
		end
	end


	always @(posedge hdmit_clk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                throw_data_cnt <= 0 ;
	    end
            else if ( fifo_wr_1st_after_exit == 1'b1)
            begin
                //throw_data_cnt <= (16*1024-12)*{16'h0,broken_State_cnt-1}/4 ;
                throw_data_cnt <= discare_pkt_cnt - 3*broken_State_cnt ;
            end
            else if ( (frame_after_exit_flag == 1 ) && (fifo_wr == 1'b1) && (throw_data_cnt > 0) )
            begin
                throw_data_cnt <= throw_data_cnt - 1 ;
            end
	    else
	    begin
                throw_data_cnt <= throw_data_cnt ;
	    end
	end

//	assign fifo_wr_act = (throw_data_cnt >0 && frame_after_exit_flag == 0)?0:(fifo_wr & (~(fifo_wr_pause|fifo_wr_pause_1ff)));
	assign fifo_wr_act = (throw_data_cnt >0)?0:(fifo_wr & (~(fifo_wr_pause|fifo_wr_pause_1ff)));

        reg strob_1ff;

	always @(posedge hdmit_halfclk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			strob_1ff <=0;
		end
		else
		begin
			strob_1ff <= strob;
		end
	end

assign fdata = (MasterState == C)?fdata_head:fdata_i;
//assign fdata = (MasterState == C)?fdata_head:((strob_1ff == 1'b1)?32'h00000000:32'hFFFFFFFF);

	
	always @(posedge hdmit_clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			div <= 0;
		end
		else if(hdmit_de)
		begin
			div <= ~div;	
		end
		else
		begin
			div <= 0;	
		end
	end
	
	always @(posedge hdmit_clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			shift_reg <= 0;
		end
		else if(hdmit_de)
		begin
			shift_reg <= {hdmit_d,shift_reg[31:16]};	
		end
		else
		begin
			shift_reg <= 0;
		end
	end
	
	always @(posedge hdmit_clk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			DE_1FF <= 0;
			VS_1FF <= 0;
		end
		else
		begin
			DE_1FF <= hdmit_de;
			VS_1FF <= hdmit_vs;
		end
	end

	always @(posedge hdmit_halfclk or posedge reset)
	begin
		if(reset == 1'b1)
		begin
			fifo_empty<= 0;
			fifo_empty_1ff<= 0;
			fifo_empty_2ff<= 0;
		end
		else
		begin
			fifo_empty <= fifo_almost_empty;
			fifo_empty_1ff <= fifo_empty;
			fifo_empty_2ff <= fifo_empty_1ff;
		end
	end


        assign fifo_empty_ns_2cycle_pulse =  ~fifo_empty & fifo_empty_2ff;
        assign fifo_almost_empty_ns =  ~fifo_almost_empty & fifo_empty;

	reg fifo_wr_start;

	assign hdmit_vs_ps = hdmit_vs&(~VS_1FF);
	assign hdmit_vs_ns = ~hdmit_vs & VS_1FF;
//	assign fifo_wr    = ~fifo_full & VS_1FF & DE_1FF & (~div) & fifo_wr_start ;
	assign fifo_wr    = ~fifo_full & VS_1FF & DE_1FF & (~div) ;

	always @(posedge hdmit_clk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                fifo_wr_start <= 0;
	    end
	    else if (flaga_exit_from_low == 1'b1)
	    begin
		if (hdmit_vs_ps == 1'b1)
		begin
                    fifo_wr_start <= 1'b1;
		end
		else
		begin
		    fifo_wr_start <= fifo_wr_start;
		end
	    end
	    else
	    begin
		    fifo_wr_start <= 1'b0;
	    end
	end

	always @(posedge hdmit_clk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                frame_cnt_after_exit <= 0;
	    end
	    else if (flaga_exit_from_low == 1'b1)
	    begin
		frame_cnt_after_exit <= 3'd4 ;
	    end
	    else if (frame_cnt_after_exit == 0 )
	    begin
		frame_cnt_after_exit <= frame_cnt_after_exit ;
	    end
	    else if (hdmit_vs_ns == 1'b1)
	    begin
		frame_cnt_after_exit <= frame_cnt_after_exit -1;
	    end
	    else begin
		frame_cnt_after_exit <= frame_cnt_after_exit;
	    end
	end

        assign frame_after_exit_flag = (frame_cnt_after_exit == 1)?1:0;
	assign fifo_wr_1st_after_exit = (frame_cnt_after_exit == 4)?1:0;



	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                pkt_cnt <= 0;
	    end
	    else if ((pkt_cnt == (16*1024*(Last_packet-1)+Last_packet_size)/4-1) || pktend_i == 1'b0) 
	    begin
		pkt_cnt <= 0;
	    end
	    else if (slwr_i == 1'b0) 
	    begin
		pkt_cnt <= pkt_cnt +1;
	    end	    
	    else
	    begin
		pkt_cnt <= pkt_cnt;
	    end
	end


	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                discare_pkt_cnt <= 0;
	    end
	    else if (pktend_i == 1'b0) 
	    begin
		discare_pkt_cnt <= 0;
	    end
	    else if (slwr_i == 1'b0) 
	    begin
		discare_pkt_cnt <= discare_pkt_cnt +1;
	    end	    
	    else
	    begin
		discare_pkt_cnt <= discare_pkt_cnt;
	    end
	end

	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
                flaga_low_cnt <= 0;
	    end
	    else if ((flaga_low_cnt == 32'h00000066) || (flaga == 1'b1))
	    begin
		flaga_low_cnt <= 0;
	    end
	    else if (flaga == 1'b0)
	    begin
		flaga_low_cnt <= flaga_low_cnt + 1;
	    end
	    else
	    begin
		flaga_low_cnt <= flaga_low_cnt;
	    end
	end


        assign flaga_low_overtime = ((flaga_low_cnt >= 32'h00000063) && (flaga_low_cnt <= 32'h00000067))?1:0;

	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		fifo_clr <= 1'b0;
	    end
	    else if (flaga_low_overtime == 1'b1) 
	    begin
		fifo_clr <= 1'b1;
	    end
	    else 
	    begin
		fifo_clr <= 1'b0;
	    end
	end

	always @(posedge hdmit_clk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		fifo_wr_pause <= 1'b0;
	    end
	    else if (flaga_low_overtime == 1'b1) 
	    begin
		fifo_wr_pause <= 1'b1;
	    end
	    else if (flaga_exit_from_low == 1'b1)
	    begin
		fifo_wr_pause <= 1'b0;
	    end
	    else
	    begin
		fifo_wr_pause <= fifo_wr_pause;
	    end
	end

	always @(posedge hdmit_clk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		fifo_wr_pause_1ff <= 1'b0;
	    end
	    else
	    begin
		fifo_wr_pause_1ff <= fifo_wr_pause;
	    end
	end

	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		flaga_low_assert <= 1'b0;
	    end
	    else if (fifo_clr == 1'b1)
	    begin
		flaga_low_assert <= 1'b1;
	    end
	    else if (flaga == 1'b1) 
	    begin
		flaga_low_assert <= 1'b0;
	    end
	    else begin
		flaga_low_assert <= flaga_low_assert;
	    end
	end

	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		broken_State_cnt <= 32'b0;
	    end
	    else if (flaga_low_overtime == 1'b1) 
	    begin
		broken_State_cnt <= {16'h0,State_cnt};
	    end
	    else
	    begin
		broken_State_cnt <= broken_State_cnt;
	    end
	end


	always @(posedge hdmit_halfclk or posedge reset)
	begin
	    if (reset == 1'b1)
	    begin
		flaga_1ff <= 1'b0;
	    end
	    else
	    begin
                flaga_1ff <=  flaga;
	    end
	end

	assign flaga_ps = flaga & (~flaga_1ff);


//------------------------------------------------------------------------------
//Function  :debug 
//
//------------------------------------------------------------------------------
   reg        led_light 	;
   always @(posedge hdmit_clk or posedge reset)
   begin
       if (reset == 1'b1)
       begin
           led_light <= 0;
       end
	    else if (flaga_exit_from_low == 1'b1)
	    begin
           led_light <= 1;
       end
       else begin
           led_light <= led_light;
       end

   end

assign fifo_full_led = led_light;

   reg [3:0]       MasterState_1ff 	;
   always @(posedge hdmit_halfclk or posedge reset)
   begin
       if (reset == 1'b1)
       begin
           MasterState_1ff <= 0;
       end
       else
       begin
           MasterState_1ff <= MasterState;
       end

   end
   
   assign flaga_low_begin = (MasterState == 3'h0 && MasterState_1ff ==3'h5)?1:0;

endmodule




