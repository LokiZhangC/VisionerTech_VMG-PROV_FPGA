//
//-----------------------------------------------------------------------------
// Filename: 
//		RGB2YUV.v
// Description: 
//    time code	
// Author & Date:
//		Created by Zhangjilong, on 2012-09-22
//    	Updated by Zhangjilong, on 2012-09-22
//      Updated by Langzhihui,  on 2013-09-26
//-----------------------------------------------------------------------------
//

module RGB2YCbCr
	#(
	  parameter  C_DATA_WIDTH  = 10
	)
	(
		  input wire        reset      ,
		  input wire        clk        ,
		  input wire[1:0]   convert_std,//convert_std[1]='0'TV std,'1'sRGB;convert_std[0]='0'SD,'1'HD
		  input wire        VS_in      ,
		  input wire        HS_in      ,
		  input wire        DE_in      ,
		  input wire[C_DATA_WIDTH-1 : 0] R_in       ,
		  input wire[C_DATA_WIDTH-1 : 0] G_in       ,
		  input wire[C_DATA_WIDTH-1 : 0] B_in       ,
		 output reg         VS_out     ,
		 output reg         HS_out     ,
		 output reg         DE_out     ,
		 output reg [C_DATA_WIDTH-1 : 0] Y_out      ,
		 output reg [C_DATA_WIDTH-1 : 0] Cb_out     ,
		 output reg [C_DATA_WIDTH-1 : 0] Cr_out     
	);
	
	localparam signed C_comm = 16'd32768*(2**(C_DATA_WIDTH-1));//26'd16777216;//32768*512 16'd32768*(2**(C_DATA_WIDTH-1))
	//localparam signed Y_comm = 16'd32768*(2**(C_DATA_WIDTH-4));
	//HD
	localparam signed C_Y1_HD  =  18'd6966;  //32768*0.2126
	localparam signed C_Y2_HD  =  18'd23436; 
	localparam signed C_Y3_HD  =  18'd2366;  
	
	localparam signed C_Cb1_HD = -18'd3840; 
	localparam signed C_Cb2_HD = -18'd12918;
	localparam signed C_Cb3_HD =  18'd16754; 
	                                         
	localparam signed C_Cr1_HD =  18'd16758; 
	localparam signed C_Cr2_HD = -18'd15221;
	localparam signed C_Cr3_HD = -18'd1537; 
	//SD                                         
	localparam signed C_Y1_SD  =  18'd9798;  
	localparam signed C_Y2_SD  =  18'd19235; 
	localparam signed C_Y3_SD  =  18'd3736;  
	                                         
	localparam signed C_Cb1_SD = -18'd5655; 
	localparam signed C_Cb2_SD = -18'd11103;
	localparam signed C_Cb3_SD =  18'd16758; 
	                                         
	localparam signed C_Cr1_SD =  18'd16758; 
	localparam signed C_Cr2_SD = -18'd14033;
	localparam signed C_Cr3_SD = -18'd2725; 
	
	//sRGB                                         
	localparam signed Cs_Y1    =  18'd8421;  
	localparam signed Cs_Y2    =  18'd18481; 
	localparam signed Cs_Y3    =  18'd3211;  
	                                           
	localparam signed Cs_Cb1   = -18'd4850; 
	localparam signed Cs_Cb2   = -18'd9535;
	localparam signed Cs_Cb3   =  18'd14385; 
	                                           
	localparam signed Cs_Cr1   =  18'd14385; 
	localparam signed Cs_Cr2   = -18'd12059;
	localparam signed Cs_Cr3   = -18'd2327; 
	
//sRGB RGB2YCbCr
// 0.257  0.564  0.098 16
//-0.148 -0.291  0.439 128
// 0.439 -0.368 -0.071 128

//sRGB YCbCr2RGB
//(Y-16) (Cb-128) (Cr-128)
//+1.164, -0.000, +1.596 
//+1.164, -0.392, -0.813 
//+1.164, +2.017, +0.000
	
//HD RGB2YCbCr
//0.2126 0.7152 0.0722
//-0.11718790756549839016242084924223 -0.3942276175486568609791316621733 0.51130528249179824418937713902677   128
//0.51141552511415525114155251141553 -0.46452169616668000459288589810056 -0.046893828947475246548666613314962 128
//HD  YCbCr2RGB
//+1.000000000000000, -0.000000000000000, +1.539648214285714
//+0.999979805804561, -0.183179563465426, -0.457675070409875	
//+1.000200040008001, +1.814543265796016, -0.000000000000000	

//SD RGB2YCbCr
//0.299 0.587 0.114
//-0.17258830926538647865837945927002 -0.3388272158487687724831730521455 0.51141552511415525114155251141553   128
//0.51141552511415525114155251141553 -0.42824666653638963255362528416678 -0.083168858577765618587927227248744 128

//SD YCbCr2RGB
//+1.000000000000000, -0.000000000000000, +1.370705357142857
//+1.000000000000000, -0.336454672669749, -0.698195744098321
//+1.000000000000000, +1.732446428571429, +0.000000000000000

//2.RGB转换为Ycbcr公式
//Y = 0.257*R+0.564*G+0.098*B+16
//Cb = -0.148*R-0.291*G+0.439*B+128
//Cr = 0.439*R-0.368*G-0.071*B+128
//
//3.Ycbcr转换为RGB公式
//R = 1.164*(Y-16)+1.596*(Cr-128)
//G = 1.164*(Y-16)-0.392*(Cb-128)-0.813*(Cr-128)
//B =1.164*(Y-16)+2.017*(Cb-128)


		
	wire signed [C_DATA_WIDTH:0] R_s;
	wire signed [C_DATA_WIDTH:0] G_s;
	wire signed [C_DATA_WIDTH:0] B_s;
	
	wire signed [17:0] C_Y1 ;
	wire signed [17:0] C_Y2 ;
	wire signed [17:0] C_Y3 ;
	                
	wire signed [17:0] C_Cb1;
	wire signed [17:0] C_Cb2;
	wire signed [17:0] C_Cb3;
                  
	wire signed [17:0] C_Cr1;
	wire signed [17:0] C_Cr2;
	wire signed [17:0] C_Cr3;
	
	reg signed [C_DATA_WIDTH+18:0] Y_reg1,Y_reg2,Y_reg3;
	reg signed [C_DATA_WIDTH+18:0] Cb_reg1,Cb_reg2,Cb_reg3;
	reg signed [C_DATA_WIDTH+18:0] Cr_reg1,Cr_reg2,Cr_reg3;
	
	reg signed [C_DATA_WIDTH+18+1:0] Y_t;
	reg signed [C_DATA_WIDTH+18+1:0] Cb_t;
	reg signed [C_DATA_WIDTH+18+1:0] Cr_t;
	
	reg signed [C_DATA_WIDTH+18+1:0] Y_t1;
	reg signed [C_DATA_WIDTH+18+1:0] Cb_t1;
	reg signed [C_DATA_WIDTH+18+1:0] Cr_t1;
	
	reg signed [C_DATA_WIDTH+18+2:0] Y_t2;
	reg signed [C_DATA_WIDTH+18+2:0] Cb_t2;
	reg signed [C_DATA_WIDTH+18+2:0] Cr_t2;
	
	reg VS_t;
	reg HS_t;
	reg DE_t;
	
	reg VS_t1;
	reg HS_t1;
	reg DE_t1;
	
	reg VS_t2;
	reg HS_t2;
	reg DE_t2;
	
	assign R_s = {1'b0,R_in};
	assign G_s = {1'b0,G_in};
	assign B_s = {1'b0,B_in};
	
	assign C_Y1  = (convert_std[1]) ? Cs_Y1  : ((convert_std[0]) ? C_Y1_HD  : C_Y1_SD );
	assign C_Y2  = (convert_std[1]) ? Cs_Y2  : ((convert_std[0]) ? C_Y2_HD  : C_Y2_SD );
	assign C_Y3  = (convert_std[1]) ? Cs_Y3  : ((convert_std[0]) ? C_Y3_HD  : C_Y3_SD );
	assign C_Cb1 = (convert_std[1]) ? Cs_Cb1 : ((convert_std[0]) ? C_Cb1_HD : C_Cb1_SD);   
	assign C_Cb2 = (convert_std[1]) ? Cs_Cb2 : ((convert_std[0]) ? C_Cb2_HD : C_Cb2_SD);
	assign C_Cb3 = (convert_std[1]) ? Cs_Cb3 : ((convert_std[0]) ? C_Cb3_HD : C_Cb3_SD);
	assign C_Cr1 = (convert_std[1]) ? Cs_Cr1 : ((convert_std[0]) ? C_Cr1_HD : C_Cr1_SD);
	assign C_Cr2 = (convert_std[1]) ? Cs_Cr2 : ((convert_std[0]) ? C_Cr2_HD : C_Cr2_SD);   
	assign C_Cr3 = (convert_std[1]) ? Cs_Cr3 : ((convert_std[0]) ? C_Cr3_HD : C_Cr3_SD);                             
	                                          
	//RGB2YCbCr                                    
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			VS_t <= 1'b1;
			HS_t <= 1'b1;
			DE_t <= 0;  
			Y_t  <= 0;
			Cb_t <= 0;
			Cr_t <= 0;   
			
			VS_t1 <= 1'b1;
			HS_t1 <= 1'b1;
			DE_t1 <= 0;
			Y_t1 <= 0;
			Cb_t1<= 0;
			Cr_t1<= 0;
			
			VS_t2 <= 1'b1;
			HS_t2 <= 1'b1;
			DE_t2 <= 0;
			Y_t2 <= 0;
			Cb_t2<= 0;
			Cr_t2<= 0;
			
			Y_reg1  <= 0;
			Y_reg2  <= 0;
			Y_reg3  <= 0;
			Cb_reg1 <= 0;
			Cb_reg2 <= 0;
			Cb_reg3 <= 0;
			Cr_reg1 <= 0;
			Cr_reg2 <= 0;
			Cr_reg3 <= 0;
		end
		else
		begin
			VS_t    <= VS_in;
			HS_t    <= HS_in;
			DE_t    <= DE_in;			
			Y_reg1  <= R_s*C_Y1;
			Y_reg2  <= G_s*C_Y2;
			Y_reg3  <= B_s*C_Y3;
			Cb_reg1 <= R_s*C_Cb1;
			Cb_reg2 <= G_s*C_Cb2;
			Cb_reg3 <= B_s*C_Cb3;
			Cr_reg1 <= R_s*C_Cr1;
			Cr_reg2 <= G_s*C_Cr2;
			Cr_reg3 <= B_s*C_Cr3;
			
			VS_t1   <= VS_t;
			HS_t1   <= HS_t;
			DE_t1   <= DE_t;			
			Y_t     <= Y_reg1 + Y_reg2;
			Cb_t    <= Cb_reg1 + Cb_reg2;
			Cr_t    <= Cr_reg1 + Cr_reg2;
			        
			Y_t1    <= Y_reg3  + {convert_std[1],{(C_DATA_WIDTH-4){1'b0}},15'd0}; 
			Cb_t1   <= Cb_reg3 + C_comm;
			Cr_t1   <= Cr_reg3 + C_comm;
      
      VS_t2   <= VS_t1;
			HS_t2   <= HS_t1;
			DE_t2   <= DE_t1;			
			Y_t2    <=  Y_t + Y_t1; 
			Cb_t2   <= Cb_t + Cb_t1;
			Cr_t2   <= Cr_t + Cr_t1;			
		end
	end
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			VS_out <= 1'b1;
			HS_out <= 1'b1;
			DE_out <= 0;
			 Y_out <= 0;
			Cb_out <= 0;
			Cr_out <= 0;
		end
		else
		begin
			VS_out <= VS_t2;
			HS_out <= HS_t2;
			DE_out <= DE_t2;			
			if(Y_t2[C_DATA_WIDTH+18+2] == 1'b1)
			begin
			  Y_out <= 10'd0;
			end
			else if(Y_t2[C_DATA_WIDTH+18+1:C_DATA_WIDTH+15] != 0)
			begin
				Y_out <= 10'd1023;
			end
			/*
			else if(Y_t2[24:15] < 10'd64)
			begin
				Y_out <= 10'd0;
			end
			else if(Y_t2[24:15] > 10'd940)
			begin
				Y_out <= 10'd1023;
			end
			*/
			else
			begin
				Y_out <= Y_t2[C_DATA_WIDTH+15-1:15];
			end
			
			if(Cb_t2[C_DATA_WIDTH+18+2] == 1'b1)
			begin
			  Cb_out <= 10'd0;
			end
			else if(Cb_t2[C_DATA_WIDTH+18+1:C_DATA_WIDTH+15] != 0)
			begin
				Cb_out <= 10'd1023;
			end
			/*
			else if(Cb_t2[24:15] < 10'd64)
			begin
				Cb_out <= 10'd0;
			end
			else if(Cb_t2[24:15] > 10'd940)
			begin
				Cb_out <= 10'd1023;
			end
			*/
			else
			begin
				Cb_out <= Cb_t2[C_DATA_WIDTH+15-1:15];
			end
			
			if(Cr_t2[C_DATA_WIDTH+18+2] == 1'b1)
			begin
			  Cr_out <= 10'd0;
			end
			else if(Cr_t2[C_DATA_WIDTH+18+1:C_DATA_WIDTH+15] != 0)
			begin
				Cr_out <= 10'd1023;
			end
			/*
			else if(Cr_t2[24:15] < 10'd64)
			begin
				Cr_out <= 10'd0;
			end
			else if(Cr_t2[24:15] > 10'd940)
			begin
				Cr_out <= 10'd1023;
			end
			*/
			else
			begin
				Cr_out <= Cr_t2[C_DATA_WIDTH+15-1:15];
			end	
		end
	end
  
    	
endmodule
