//
//-----------------------------------------------------------------------------
// Filename: 
//		RGB2YC.v
// Description: 
//    
// Author & Date:
//		Created by Zhangjilong, on 2012-09-22
//    	Updated by Zhangjilong, on 2012-09-22
//-----------------------------------------------------------------------------
//

module RGB2YC //delay 5
	#(
	  	parameter  C_DATA_WIDTH  = 10
	)
	(
			input wire        clk  ,
		  input wire        reset,		  
		  input wire[1:0]   convert_std,
		  input wire        VS_in ,
		  input wire        HS_in ,
		  input wire        DE_in ,
		  input wire[9 : 0]  R_in  ,
		  input wire[9 : 0]  G_in ,
		  input wire[9 : 0]  B_in ,
		 output wire        VS_out ,
		 output wire        HS_out ,
		 output wire        DE_out ,
		 output wire[9 : 0]  Y_out  ,
		 output wire[9 : 0]  C_out  
		  
	);
	
	wire         HS_r1;
	wire         VS_r1;
	wire         DE_r1;
	wire [9 : 0]  Y_r1;
	wire [9 : 0] Cb_r1;
	wire [9 : 0] Cr_r1;

    
  RGB2YCbCr
  #(
	  .C_DATA_WIDTH (C_DATA_WIDTH)
	)
  U_RGB2YCbCr
  (
   .clk               (clk),
   .reset             (reset),
   .convert_std       (convert_std),
   .VS_in             (VS_in),
   .HS_in             (HS_in),
   .DE_in             (DE_in),
   .R_in              ( R_in),
   .G_in              ( G_in),
   .B_in              ( B_in),
   .VS_out            (VS_r1),
   .HS_out            (HS_r1),
   .DE_out            (DE_r1),
   .Y_out             ( Y_r1),
   .Cb_out            (Cb_r1),
   .Cr_out            (Cr_r1)
    );
	
  YCbCr2YC
  #(
	  .C_DATA_WIDTH (C_DATA_WIDTH)
	)
  U_YCbCr2YC
  (
   .reset       (reset),
   .clk         (clk),
   .VS_in       (VS_r1),
   .HS_in       (HS_r1),
   .DE_in       (DE_r1),
   .Y_in        ( Y_r1),
   .Cb_in       (Cb_r1),
   .Cr_in       (Cr_r1),
   .VS_out      (VS_out),
   .HS_out      (HS_out),
   .DE_out      (DE_out),
   .Y_out       ( Y_out),
   .C_out       ( C_out)
  );               
                   
    	
endmodule
