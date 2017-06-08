`timescale 1ps / 1ps
//================================================================================ 
// File Name      : Chirico_top.v
//--------------------------------------------------------------------------------
// Create Date    : 06/10/2015 
// Project Name   : Chirico_top
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
module HDR_4f //delay 40
#(
  parameter  C_DATA_WIDTH              = 24
)
(
  // system signal
  input  wire                    reset       , //
  input  wire                    clk         , //
  // data input                         
  input  wire                    data_in_VS  , 
  input  wire                    data_in_HS  , 
  input  wire                    data_in_DE  , 
  input  wire [C_DATA_WIDTH-1:0] data_in_B   ,  
  input  wire [C_DATA_WIDTH-1:0] data_in_MH  , 
  input  wire [C_DATA_WIDTH-1:0] data_in_ML  ,
  input  wire [C_DATA_WIDTH-1:0] data_in_D   ,  
  // data output
  output wire                    data_out_VS , 
  output wire                    data_out_HS , 
  output wire                    data_out_DE , 
  output wire [C_DATA_WIDTH+5:0] data_out    
) ;

	// =============================================================================
	// Internal signal
	// =============================================================================
	localparam PER_CH_DATA_W = C_DATA_WIDTH/3;
	
	localparam PERCENT30_1024  = 10'd341;//
	
	wire [PER_CH_DATA_W-1:0] dataBr;
	wire [PER_CH_DATA_W-1:0] dataBg;
	wire [PER_CH_DATA_W-1:0] dataBb;
	
	wire [PER_CH_DATA_W-1:0] dataMHr;
	wire [PER_CH_DATA_W-1:0] dataMHg;
	wire [PER_CH_DATA_W-1:0] dataMHb;
	
	wire [PER_CH_DATA_W-1:0] dataMLr;
	wire [PER_CH_DATA_W-1:0] dataMLg;
	wire [PER_CH_DATA_W-1:0] dataMLb;
	
	wire [PER_CH_DATA_W-1:0] dataDr;
	wire [PER_CH_DATA_W-1:0] dataDg;
	wire [PER_CH_DATA_W-1:0] dataDb;
	
	reg  [PER_CH_DATA_W-1:0] dataBb_d ; 
  reg  [PER_CH_DATA_W-1:0] dataMHb_d; 
  reg  [PER_CH_DATA_W-1:0] dataMLb_d; 
  reg  [PER_CH_DATA_W-1:0] dataDb_d ; 
	
	reg  [C_DATA_WIDTH-1:0] data_B_d1 ;  
  reg  [C_DATA_WIDTH-1:0] data_MH_d1; 
  reg  [C_DATA_WIDTH-1:0] data_ML_d1;
  reg  [C_DATA_WIDTH-1:0] data_D_d1 ;  
                                    
  reg  [C_DATA_WIDTH-1:0] data_B_d2 ;  
  reg  [C_DATA_WIDTH-1:0] data_MH_d2; 
  reg  [C_DATA_WIDTH-1:0] data_ML_d2;
  reg  [C_DATA_WIDTH-1:0] data_D_d2 ;  
                                    
  reg  [C_DATA_WIDTH-1:0] data_B_d3 ;  
  reg  [C_DATA_WIDTH-1:0] data_MH_d3; 
  reg  [C_DATA_WIDTH-1:0] data_ML_d3;
  reg  [C_DATA_WIDTH-1:0] data_D_d3 ;  
                                    
  reg  [C_DATA_WIDTH-1:0] data_B_d4 ;  
  reg  [C_DATA_WIDTH-1:0] data_MH_d4; 
  reg  [C_DATA_WIDTH-1:0] data_ML_d4;
  reg  [C_DATA_WIDTH-1:0] data_D_d4 ;  
                                    
  reg  [C_DATA_WIDTH-1:0] data_B_d5 ;  
  reg  [C_DATA_WIDTH-1:0] data_MH_d5; 
  reg  [C_DATA_WIDTH-1:0] data_ML_d5;
  reg  [C_DATA_WIDTH-1:0] data_D_d5 ;  
  
  wire [PER_CH_DATA_W-1:0] dataBr_d5;
	wire [PER_CH_DATA_W-1:0] dataBg_d5;
	wire [PER_CH_DATA_W-1:0] dataBb_d5;
	
	wire [PER_CH_DATA_W-1:0] dataMHr_d5;
	wire [PER_CH_DATA_W-1:0] dataMHg_d5;
	wire [PER_CH_DATA_W-1:0] dataMHb_d5;
	
	wire [PER_CH_DATA_W-1:0] dataMLr_d5;
	wire [PER_CH_DATA_W-1:0] dataMLg_d5;
	wire [PER_CH_DATA_W-1:0] dataMLb_d5;
	
	wire [PER_CH_DATA_W-1:0] dataDr_d5;
	wire [PER_CH_DATA_W-1:0] dataDg_d5;
	wire [PER_CH_DATA_W-1:0] dataDb_d5;
	
	reg  [PER_CH_DATA_W  :0] dataBMr_t1;
	reg  [PER_CH_DATA_W  :0] dataBMg_t1;
	reg  [PER_CH_DATA_W  :0] dataBMb_t1;   
	
	reg  [PER_CH_DATA_W  :0] dataMDr_t1;
	reg  [PER_CH_DATA_W  :0] dataMDg_t1;
	reg  [PER_CH_DATA_W  :0] dataMDb_t1;   
	
	reg  [PER_CH_DATA_W+1:0] dataBMDr_t2;
	reg  [PER_CH_DATA_W+1:0] dataBMDg_t2;
	reg  [PER_CH_DATA_W+1:0] dataBMDb_t2;
	
	reg  [PER_CH_DATA_W+2:0] dataBMDrg_t3;
	reg  [PER_CH_DATA_W+1:0] dataBMDb_t3;
	
	reg  [PER_CH_DATA_W+3:0] dataBMDrgb_t4;
	                                  
	reg  [PER_CH_DATA_W  :0] dataBrg ;
  reg  [PER_CH_DATA_W  :0] dataMHrg;
  reg  [PER_CH_DATA_W  :0] dataMLrg;
  reg  [PER_CH_DATA_W  :0] dataDrg ;
	
  reg  [PER_CH_DATA_W+1:0] dataBrgb ;
  reg  [PER_CH_DATA_W+1:0] dataMHrgb;
  reg  [PER_CH_DATA_W+1:0] dataMLrgb;
  reg  [PER_CH_DATA_W+1:0] dataDrgb ;
	
	reg  [PER_CH_DATA_W+13:0] L_HDR_t1;
	reg  [PER_CH_DATA_W+11:0] L_B_t1;
  reg  [PER_CH_DATA_W+11:0] L_MH_t1;
  reg  [PER_CH_DATA_W+11:0] L_ML_t1;
  reg  [PER_CH_DATA_W+11:0] L_D_t1;
  
  reg  [PER_CH_DATA_W+1:0] L_HDR_t2;
	reg  [PER_CH_DATA_W-1:0] L_B_t2;
  reg  [PER_CH_DATA_W-1:0] L_MH_t2;
  reg  [PER_CH_DATA_W-1:0] L_ML_t2;
  reg  [PER_CH_DATA_W-1:0] L_D_t2;
  
  wire [PER_CH_DATA_W-1:0] w_B_t1 ;
  wire [PER_CH_DATA_W-1:0] w_MH_t1;
  wire [PER_CH_DATA_W-1:0] w_ML_t1;
  wire [PER_CH_DATA_W-1:0] w_D_t1 ;
	
	

	// =============================================================================
	// RTL Body
	// =============================================================================
	assign dataBr  = data_in_B[C_DATA_WIDTH-1:2*PER_CH_DATA_W];
	assign dataBg  = data_in_B[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataBb  = data_in_B[PER_CH_DATA_W-1:0];

	assign dataMHr = data_in_MH[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataMHg = data_in_MH[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataMHb = data_in_MH[PER_CH_DATA_W-1:0];              

	assign dataMLr = data_in_ML[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataMLg = data_in_ML[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataMLb = data_in_ML[PER_CH_DATA_W-1:0];     
	
	assign dataDr  = data_in_D[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataDg  = data_in_D[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataDb  = data_in_D[PER_CH_DATA_W-1:0];   
	
  always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			data_B_d1   <= 0;
			data_MH_d1  <= 0;
			data_ML_d1  <= 0;
			data_D_d1   <= 0;
			
			data_B_d2   <= 0;
			data_MH_d2  <= 0;
			data_ML_d2  <= 0;
			data_D_d2   <= 0;
			
			data_B_d3   <= 0;
			data_MH_d3  <= 0;
			data_ML_d3  <= 0;
			data_D_d3   <= 0;
			
			data_B_d4   <= 0;
			data_MH_d4  <= 0;
			data_ML_d4  <= 0;
			data_D_d4   <= 0;
			
			data_B_d5   <= 0;
			data_MH_d5  <= 0;
			data_ML_d5  <= 0;
			data_D_d5   <= 0;
		end
		else
		begin
			data_B_d1   <= data_in_B ;
			data_MH_d1  <= data_in_MH;
			data_ML_d1  <= data_in_ML;
			data_D_d1   <= data_in_D ;
			
			data_B_d2   <= data_B_d1 ;
			data_MH_d2  <= data_MH_d1;
			data_ML_d2  <= data_ML_d1;
			data_D_d2   <= data_D_d1 ;
			
			data_B_d3   <= data_B_d2 ;
			data_MH_d3  <= data_MH_d2;
			data_ML_d3  <= data_ML_d2;
			data_D_d3   <= data_D_d2 ;
			
			data_B_d4   <= data_B_d3 ;
			data_MH_d4  <= data_MH_d3;
			data_ML_d4  <= data_ML_d3;
			data_D_d4   <= data_D_d3 ;
			
			data_B_d5   <= data_B_d4 ;
			data_MH_d5  <= data_MH_d4;
			data_ML_d5  <= data_ML_d4;
			data_D_d5   <= data_D_d4 ;
		end
	end
	
	assign dataBr_d5  = data_B_d5[C_DATA_WIDTH-1:2*PER_CH_DATA_W];
	assign dataBg_d5  = data_B_d5[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataBb_d5  = data_B_d5[PER_CH_DATA_W-1:0];

	assign dataMHr_d5 = data_MH_d5[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataMHg_d5 = data_MH_d5[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataMHb_d5 = data_MH_d5[PER_CH_DATA_W-1:0];              

	assign dataMLr_d5 = data_ML_d5[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataMLg_d5 = data_ML_d5[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataMLb_d5 = data_ML_d5[PER_CH_DATA_W-1:0];     
	
	assign dataDr_d5  = data_D_d5[C_DATA_WIDTH-1:2*PER_CH_DATA_W]; 
	assign dataDg_d5  = data_D_d5[2*PER_CH_DATA_W-1:PER_CH_DATA_W];
	assign dataDb_d5  = data_D_d5[PER_CH_DATA_W-1:0];
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataBMr_t1  <= 0;
			dataBMg_t1  <= 0;
			dataBMb_t1  <= 0;
			         
			dataMDr_t1  <= 0;
			dataMDg_t1  <= 0;
			dataMDb_t1  <= 0; 
		end
		else
		begin
			dataBMr_t1  <= dataBr + dataMHr;
			dataBMg_t1  <= dataBg + dataMHg;
			dataBMb_t1  <= dataBb + dataMHb;
			          
			dataMDr_t1  <= dataMLr + dataDr;
			dataMDg_t1  <= dataMLg + dataDg;
			dataMDb_t1  <= dataMLb + dataDb;  
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataBMDr_t2  <= 0;
			dataBMDg_t2  <= 0;
			dataBMDb_t2  <= 0;
		end
		else
		begin
			dataBMDr_t2  <= dataBMr_t1 + dataMDr_t1;
			dataBMDg_t2  <= dataBMg_t1 + dataMDg_t1;
			dataBMDb_t2  <= dataBMb_t1 + dataMDb_t1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataBMDrg_t3 <= 0;
			dataBMDb_t3  <= 0;
			dataBMDrgb_t4 <= 0;
			L_HDR_t1 <= 0;
			L_HDR_t2 <= 0;
		end
		else
		begin
			dataBMDrg_t3 <= dataBMDr_t2 + dataBMDg_t2;
			dataBMDb_t3  <= dataBMDb_t2;
			dataBMDrgb_t4  <= dataBMDrg_t3 + dataBMDb_t3;
			L_HDR_t1 <= dataBMDrgb_t4 * PERCENT30_1024;
			L_HDR_t2 <= L_HDR_t1[19:10] + L_HDR_t1[9];
		end
	end
	
	localparam L_HDR_delay = 17;
	
	reg  [L_HDR_delay-1:0] L_HDR_shift [PER_CH_DATA_W+1:0];
  wire [PER_CH_DATA_W+1:0] L_HDR_d15;
	
	genvar i;
  generate
     for (i=0; i<PER_CH_DATA_W+2; i=i+1) 
     begin: L_HDR_d
        always @(posedge clk or posedge reset)
        begin
        	if(reset)
        	begin
        		L_HDR_shift[i] <= {L_HDR_delay{1'b0}};
        	end
        	else
        	begin
        		L_HDR_shift[i] <= {L_HDR_shift[i][L_HDR_delay-2:0], L_HDR_t2[i]};
        	end              
        end
           			 
        assign L_HDR_d15[i] = L_HDR_shift[i][L_HDR_delay-1];
     end
  endgenerate
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataBrg  <= 0;
			dataMHrg <= 0;
			dataMLrg <= 0;
			dataDrg  <= 0;
			       
			dataBb_d  <= 0;
			dataMHb_d <= 0;
			dataMLb_d <= 0;
			dataDb_d  <= 0;
		end
		else
		begin
			dataBrg  <= dataBr  + dataBg;
			dataMHrg <= dataMHr + dataMHg;
			dataMLrg <= dataMLr + dataMLg;
			dataDrg  <= dataDr  + dataDg;
			       
			dataBb_d   <= dataBb ;
			dataMHb_d  <= dataMHb;
			dataMLb_d  <= dataMLb;
			dataDb_d   <= dataDb ;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			dataBrgb  <= 0;
			dataMHrgb <= 0;
			dataMLrgb <= 0;
			dataDrgb  <= 0;
			L_B_t1    <= 0;
  		L_MH_t1   <= 0;
  		L_ML_t1   <= 0;
  		L_D_t1    <= 0;
  		L_B_t2    <= 0;
  		L_MH_t2   <= 0;
  		L_ML_t2   <= 0;
  		L_D_t2    <= 0;
		end
		else
		begin
			dataBrgb  <= dataBrg  + dataBb_d;
			dataMHrgb <= dataMHrg + dataMHb_d;
			dataMLrgb <= dataMLrg + dataMLb_d;
			dataDrgb  <= dataDrg  + dataDb_d;
			L_B_t1    <= dataBrgb  * PERCENT30_1024;
  		L_MH_t1   <= dataMHrgb * PERCENT30_1024;
  		L_ML_t1   <= dataMLrgb * PERCENT30_1024;
  		L_D_t1    <= dataDrgb  * PERCENT30_1024;
  		L_B_t2    <= L_B_t1[17:10]  + L_B_t1[9];
  		L_MH_t2   <= L_MH_t1[17:10] + L_MH_t1[9];
  		L_ML_t2   <= L_ML_t1[17:10] + L_ML_t1[9];
  		L_D_t2    <= L_D_t1[17:10]  + L_D_t1[9];
		end
	end
	
	weight_sum_rom
	uB_weight_sum_rom
	(
  	.clka (clk   ), // input clka
  	.addra(L_B_t2), // input [7 : 0] addra
  	.douta(w_B_t1) // output [7 : 0] douta
	);
	
	weight_sum_rom
	uMH_weight_sum_rom
	(
  	.clka (clk   ), // input clka
  	.addra(L_MH_t2), // input [7 : 0] addra
  	.douta(w_MH_t1) // output [7 : 0] douta
	);
	
	weight_sum_rom
	uML_weight_sum_rom
	(
  	.clka (clk   ), // input clka
  	.addra(L_ML_t2), // input [7 : 0] addra
  	.douta(w_ML_t1) // output [7 : 0] douta
	);
	
	weight_sum_rom
	uD_weight_sum_rom
	(
  	.clka (clk   ), // input clka
  	.addra(L_D_t2), // input [7 : 0] addra
  	.douta(w_D_t1) // output [7 : 0] douta
	);
	
	reg  [PER_CH_DATA_W+8-1:0] w_B_r ;
	reg  [PER_CH_DATA_W+8-1:0] w_MH_r;
	reg  [PER_CH_DATA_W+8-1:0] w_ML_r;
	reg  [PER_CH_DATA_W+8-1:0] w_D_r ;
	
	reg  [PER_CH_DATA_W+8-1:0] w_B_g ;
	reg  [PER_CH_DATA_W+8-1:0] w_MH_g;
	reg  [PER_CH_DATA_W+8-1:0] w_ML_g;
	reg  [PER_CH_DATA_W+8-1:0] w_D_g ;
	
	reg  [PER_CH_DATA_W+8-1:0] w_B_b ;
	reg  [PER_CH_DATA_W+8-1:0] w_MH_b;
	reg  [PER_CH_DATA_W+8-1:0] w_ML_b;
	reg  [PER_CH_DATA_W+8-1:0] w_D_b ;
	
	reg  [PER_CH_DATA_W+8  :0] w_BM_r ;
	reg  [PER_CH_DATA_W+8  :0] w_MD_r ;
	reg  [PER_CH_DATA_W+8+1:0] w_BMD_r;
	reg  [PER_CH_DATA_W+8+2:0] w_BMD_rp;
	
	reg  [PER_CH_DATA_W+8  :0] w_BM_g ;
	reg  [PER_CH_DATA_W+8  :0] w_MD_g ;
	reg  [PER_CH_DATA_W+8+1:0] w_BMD_g;
	reg  [PER_CH_DATA_W+8+2:0] w_BMD_gp;
	
	reg  [PER_CH_DATA_W+8  :0] w_BM_b ;
	reg  [PER_CH_DATA_W+8  :0] w_MD_b ;
	reg  [PER_CH_DATA_W+8+1:0] w_BMD_b;
	reg  [PER_CH_DATA_W+8+2:0] w_BMD_bp;
	
	reg  [7+1:0] w_BM ;
	reg  [7+1:0] w_MD ;
	reg  [7+2:0] w_BMD;
	reg  [7+2:0] w_BMD_d1;
	reg  [7+2:0] w_BMD_d2;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			w_B_r  <= 0;
			w_MH_r <= 0;
			w_ML_r <= 0;
			w_D_r  <= 0;
			
			w_B_g  <= 0;
			w_MH_g <= 0;
			w_ML_g <= 0;
			w_D_g  <= 0;
			
			w_B_b  <= 0;
			w_MH_b <= 0;
			w_ML_b <= 0;
			w_D_b  <= 0;
			
			w_BM_r <= 0;
			w_MD_r <= 0;
			w_BMD_r<= 0;
			w_BMD_rp<= 0;
			
			w_BM_g <= 0;
			w_MD_g <= 0;
			w_BMD_g<= 0;
			w_BMD_gp<= 0;
			
			w_BM_b <= 0;
			w_MD_b <= 0;
			w_BMD_b<= 0;
			w_BMD_bp<= 0;
			
			w_BM   <= 0;
			w_MD   <= 0;
			w_BMD  <= 0;
			
			w_BMD_d1 <= 0;
			w_BMD_d2 <= 0;
		end
		else
		begin
			w_B_r  <= w_B_t1 *dataBr_d5 ;
			w_MH_r <= w_MH_t1*dataMHr_d5;
			w_ML_r <= w_ML_t1*dataMLr_d5;
			w_D_r  <= w_D_t1 *dataDr_d5 ;
			
			w_B_g  <= w_B_t1 *dataBg_d5 ;
			w_MH_g <= w_MH_t1*dataMHg_d5;
			w_ML_g <= w_ML_t1*dataMLg_d5;
			w_D_g  <= w_D_t1 *dataDg_d5 ;
			
			w_B_b  <= w_B_t1 *dataBb_d5 ;
			w_MH_b <= w_MH_t1*dataMHb_d5;
			w_ML_b <= w_ML_t1*dataMLb_d5;
			w_D_b  <= w_D_t1 *dataDb_d5 ;
			
			w_BM_r <= w_B_r +w_MH_r;
			w_MD_r <= w_ML_r+w_D_r ;
			w_BMD_r<= w_BM_r+w_MD_r;
			w_BMD_rp<= w_BMD_r;// + 40;
			
			w_BM_g <= w_B_g +w_MH_g;
			w_MD_g <= w_ML_g+w_D_g ;
			w_BMD_g<= w_BM_g+w_MD_g;
			w_BMD_gp<= w_BMD_g;// + 40;
			
			w_BM_b <= w_B_b +w_MH_b;
			w_MD_b <= w_ML_b+w_D_b ;
			w_BMD_b<= w_BM_b+w_MD_b;
			w_BMD_bp<= w_BMD_b;// + 40;
			
			w_BM   <= w_B_t1+w_MH_t1;
			w_MD   <= w_ML_t1+w_D_t1;
			w_BMD  <= w_BM+w_MD;
			
			w_BMD_d1 <= w_BMD;
			w_BMD_d2 <= w_BMD_d1;
		end
	end
	
	wire [PER_CH_DATA_W+2:0] Rc_t;
	wire [PER_CH_DATA_W+2:0] Gc_t;
	wire [PER_CH_DATA_W+2:0] Bc_t;
	
	reg  [PER_CH_DATA_W-1:0] Rc;
	reg  [PER_CH_DATA_W-1:0] Gc;
	reg  [PER_CH_DATA_W-1:0] Bc;
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_R 
	(
		.clk    (clk           ),
		.ena    (1'b1          ),
		.z      ({1'd0,w_BMD_rp}),//{2'd0,w_BMD_r}),
		.d      (w_BMD_d2      ), //w_BMD_d1      ),
		.q      (Rc_t          ),
		.s      (              ),
		.div0   (              ),
		.ovf    (              )
	);
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_G 
	(
		.clk    (clk           ),
		.ena    (1'b1          ),
		.z      ({1'd0,w_BMD_gp}),//{2'd0,w_BMD_g}),
		.d      (w_BMD_d2      ), //w_BMD_d1      ),
		.q      (Gc_t          ),
		.s      (              ),
		.div0   (              ),
		.ovf    (              )
	);
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_B 
	(
		.clk    (clk           ),
		.ena    (1'b1          ),
		.z      ({1'd0,w_BMD_bp}),//{2'd0,w_BMD_b}),
		.d      (w_BMD_d2      ), //w_BMD_d1      ),
		.q      (Bc_t          ),
		.s      (              ),
		.div0   (              ),
		.ovf    (              )
	);
	
	//assign Rc = Rc_t[PER_CH_DATA_W-1:0];
	//assign Gc = Gc_t[PER_CH_DATA_W-1:0];
	//assign Bc = Bc_t[PER_CH_DATA_W-1:0];
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			Rc <= 0;
			Gc <= 0;
			Bc <= 0;
		end
		else
		begin
			if(Rc_t[PER_CH_DATA_W])
			begin
				Rc <= {PER_CH_DATA_W{1'b1}};
			end
			else
			begin
				Rc <= Rc_t[PER_CH_DATA_W+1:0];
			end
			
			if(Gc_t[PER_CH_DATA_W])
			begin
				Gc <= {PER_CH_DATA_W{1'b1}};
			end
			else
			begin
				Gc <= Gc_t[PER_CH_DATA_W+1:0];
			end
			
			if(Bc_t[PER_CH_DATA_W])
			begin
				Bc <= {PER_CH_DATA_W{1'b1}};
			end
			else
			begin
				Bc <= Bc_t[PER_CH_DATA_W+1:0];
			end
		end
	end
	
	reg  [PER_CH_DATA_W+9:0] RcLhdr_t1;
	reg  [PER_CH_DATA_W+9:0] GcLhdr_t1;
	reg  [PER_CH_DATA_W+9:0] BcLhdr_t1;
	
	reg  [PER_CH_DATA_W+9:0] RcLhdr_t2;
	reg  [PER_CH_DATA_W+9:0] GcLhdr_t2;
	reg  [PER_CH_DATA_W+9:0] BcLhdr_t2;
	
	reg  [PER_CH_DATA_W+9:0] RcLhdr_t3;
	reg  [PER_CH_DATA_W+9:0] GcLhdr_t3;
	reg  [PER_CH_DATA_W+9:0] BcLhdr_t3;
	
	reg  [PER_CH_DATA_W+9:0] RcLhdr_t4;
	reg  [PER_CH_DATA_W+9:0] GcLhdr_t4;
	reg  [PER_CH_DATA_W+9:0] BcLhdr_t4;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			RcLhdr_t1 <= 0;
			GcLhdr_t1 <= 0;
			BcLhdr_t1 <= 0;
			
			RcLhdr_t2 <= 0;
			GcLhdr_t2 <= 0;
			BcLhdr_t2 <= 0;
			
			RcLhdr_t3 <= 0;
			GcLhdr_t3 <= 0;
			BcLhdr_t3 <= 0;
			
			RcLhdr_t4 <= 0;
			GcLhdr_t4 <= 0;
			BcLhdr_t4 <= 0;
		end
		else
		begin
			RcLhdr_t1 <= Rc*L_HDR_d15;
			GcLhdr_t1 <= Gc*L_HDR_d15;
			BcLhdr_t1 <= Bc*L_HDR_d15;
			
			RcLhdr_t2 <= RcLhdr_t1;
			GcLhdr_t2 <= GcLhdr_t1;
			BcLhdr_t2 <= BcLhdr_t1;
			
			RcLhdr_t3 <= RcLhdr_t2;
			GcLhdr_t3 <= GcLhdr_t2;
			BcLhdr_t3 <= BcLhdr_t2;
			
			RcLhdr_t4 <= RcLhdr_t3;
			GcLhdr_t4 <= GcLhdr_t3;
			BcLhdr_t4 <= BcLhdr_t3;
		end
	end
	
	reg  [PER_CH_DATA_W  :0] L_c_rg;
	reg  [PER_CH_DATA_W-1:0] L_c_b_d;
	reg  [PER_CH_DATA_W+1:0] L_c_rgb;
	
	reg  [PER_CH_DATA_W+11:0] L_c_rgb_t1;
	reg  [PER_CH_DATA_W-1:0]  L_c_rgb_t2;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)	
		begin
			L_c_rg   <= 0;
			L_c_b_d  <= 0;
			L_c_rgb_t1 <= 0;
			L_c_rgb_t2 <= 0;
		end
		else
		begin
			L_c_rg  <= Rc+Gc;
			L_c_b_d <= Bc;
			L_c_rgb <= L_c_rg+L_c_b_d;
			L_c_rgb_t1 <= L_c_rgb * PERCENT30_1024;
			L_c_rgb_t2 <= L_c_rgb_t1[17:10] + L_c_rgb_t1[9];
		end
	end
	
	wire [PER_CH_DATA_W+2:0] Rt_t;
	wire [PER_CH_DATA_W+2:0] Gt_t;
	wire [PER_CH_DATA_W+2:0] Bt_t;
	
	wire [PER_CH_DATA_W+1:0] Rt;
	wire [PER_CH_DATA_W+1:0] Gt;
	wire [PER_CH_DATA_W+1:0] Bt;
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_Rc
	(
		.clk    (clk              ),
		.ena    (1'b1             ),
		.z      ({2'd0,RcLhdr_t4} ),
		.d      ({2'd0,L_c_rgb_t2}),
		.q      (Rt_t             ),
		.s      (                 ),
		.div0   (                 ),
		.ovf    (                 )
	);
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_Gc
	(
		.clk    (clk              ),
		.ena    (1'b1             ),
		.z      ({2'd0,GcLhdr_t4} ),
		.d      ({2'd0,L_c_rgb_t2}),
		.q      (Gt_t             ),
		.s      (                 ),
		.div0   (                 ),
		.ovf    (                 )
	);
	
	div_su //delay d_width+3
	#(
		.z_width(2*(PER_CH_DATA_W+2)),
		.d_width(PER_CH_DATA_W+2)
	)
	u_div_Bc
	(
		.clk    (clk              ),
		.ena    (1'b1             ),
		.z      ({2'd0,BcLhdr_t4} ),
		.d      ({2'd0,L_c_rgb_t2}),
		.q      (Bt_t             ),
		.s      (                 ),
		.div0   (                 ),
		.ovf    (                 )
	);
	
	assign Rt = Rt_t[PER_CH_DATA_W+1:0];
	assign Gt = Gt_t[PER_CH_DATA_W+1:0];
	assign Bt = Bt_t[PER_CH_DATA_W+1:0];
	
	localparam total_delay = 40;
	reg  [total_delay-1:0] VS_d;
	reg  [total_delay-1:0] HS_d;
	reg  [total_delay-1:0] DE_d;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			VS_d <= {total_delay{1'b1}};
			HS_d <= {total_delay{1'b1}};
			DE_d <= 0;
		end
		else
		begin
			VS_d <= {VS_d[total_delay-2:0],data_in_VS};
			HS_d <= {HS_d[total_delay-2:0],data_in_HS};
			DE_d <= {DE_d[total_delay-2:0],data_in_DE};
		end
	end
	
	assign data_out_VS = VS_d[total_delay-1];                     
	assign data_out_HS = HS_d[total_delay-1];                     
	assign data_out_DE = DE_d[total_delay-1];                     
	assign data_out    = {Rt,Gt,Bt};
	

	                   
endmodule
