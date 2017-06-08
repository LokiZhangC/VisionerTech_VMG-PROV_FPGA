//
//-----------------------------------------------------------------------------
// Filename: 
//		YCbCr422YC.v
// Description: 
//    time code	
// Author & Date:
//		Created by Zhangjilong, on 2012-09-22
//    	Updated by Zhangjilong, on 2012-09-22
//-----------------------------------------------------------------------------
//

module YCbCr2YC
	#(
	  parameter  C_DATA_WIDTH  = 10
	)
	(
		  input wire        reset,
		  input wire        clk  ,
		  input wire        VS_in ,
		  input wire        HS_in ,
		  input wire        DE_in ,
		  input wire[C_DATA_WIDTH-1 : 0]  Y_in  ,
		  input wire[C_DATA_WIDTH-1 : 0] Cb_in  ,
		  input wire[C_DATA_WIDTH-1 : 0] Cr_in  ,
		 output reg         VS_out ,
		 output reg         HS_out ,
		 output reg         DE_out ,
		 output reg [C_DATA_WIDTH-1 : 0] Y_out  ,
		 output reg [C_DATA_WIDTH-1 : 0] C_out 
	);

	reg div;
	
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			div <= 0;
		end
		else if(DE_in)
		begin
			div <= ~div;	
		end
		else
		begin
			div <= 0;	
		end
	end	
                               
	always @(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			VS_out  <= 1'b1;
			HS_out  <= 1'b1;
	    DE_out  <= 0;
	     Y_out  <= 0;
	     C_out  <= 0;
		end
		else
		begin
			VS_out  <= VS_in;
			HS_out  <= HS_in;
	    DE_out <= DE_in;
	    Y_out  <= Y_in;
	    if(div)
	    begin
	    	C_out  <= Cr_in;
	    end
	    else
	    begin
	    	C_out  <= Cb_in;
	    end
		end
	end
    	
endmodule
