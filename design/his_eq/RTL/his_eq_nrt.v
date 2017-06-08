
`timescale 1ps / 1ps
//================================================================================ 
// File Name      : his_eq.v
//--------------------------------------------------------------------------------
// Create Date    : 31/10/2016 
// Project Name   : his_eq
// Target Devices : XC7A200T-1FFG676
// Tool versions  : ISE 14.7 (64-bit)
//--------------------------------------------------------------------------------
// Description    : his_eq
//                 
//--------------------------------------------------------------------------------
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//================================================================================ 

// =============================================================================
// RTL Header
// =============================================================================

module his_eq_nrt//delay 2
#(
  parameter  C_Mu          = 5 , //range=0~10,recommend 2.0 < C_Mu < 10.0
  parameter  C_VDATA_WIDTH = 8
)
(
  // system signal
  input   wire                      clk  , //
  input   wire                      reset, //
  // data input                     
  input   wire                      vs_in  ,
  input   wire                      hs_in  ,
  input   wire                      de_in  ,
  input   wire [3*C_VDATA_WIDTH-1:0]data_in,
  // data output
  output  reg                       vs_out  , 
  output  reg                       hs_out  ,
  output  reg                       de_out  , 
  output  reg  [3*C_VDATA_WIDTH-1:0]data_out,
  
  output  wire [6:0]                db
) ;


	// =============================================================================
	// Internal signal
	// =============================================================================
	localparam  C_DATA_WIDTH  = 32;
	
	reg                     vs_d;
	reg                     hs_d;
	
	reg  [1:0]              his_cnt;
	
	reg                     hisG_vs;
	reg                     hisB_vs;
	
	wire                    his_valid ;
  wire                    his_ready ;
  wire [C_DATA_WIDTH-1:0] his_data  ;
	wire                    hisR_valid ;
  wire                    hisR_ready ;
  wire [C_DATA_WIDTH-1:0] hisR_data  ;
  wire                    hisG_valid ;
  wire                    hisG_ready ;
  wire [C_DATA_WIDTH-1:0] hisG_data  ;
  wire                    hisB_valid ;
  wire                    hisB_ready ;
  wire [C_DATA_WIDTH-1:0] hisB_data  ;
	
	wire                    video_in_valid;
  wire [C_VDATA_WIDTH-1:0]videoR_in     ;
  wire [C_VDATA_WIDTH-1:0]videoG_in     ;
  wire [C_VDATA_WIDTH-1:0]videoB_in     ;
	
	wire                    eq_valid;
	wire [C_DATA_WIDTH-1:0] eqR_data;
	wire [C_DATA_WIDTH-1:0] eqG_data;
	wire [C_DATA_WIDTH-1:0] eqB_data;
	
	wire [C_DATA_WIDTH-1:0] fixed2float_a     ;
	wire                    fixed2float_valid ;
	wire                    fixed2float_rfd   ;
	wire [C_DATA_WIDTH-1:0] fixed2float_result;
	wire                    fixed2float_rdy   ;
	
  wire [C_DATA_WIDTH-1:0] add_a             ;
  wire [C_DATA_WIDTH-1:0] add_b             ;
	wire                    add_valid         ;
	wire                    add_rfd           ;
	wire [C_DATA_WIDTH-1:0] add_result        ;
	wire                    add_rdy           ;
	
  wire [C_DATA_WIDTH-1:0] sub_a             ;
  wire [C_DATA_WIDTH-1:0] sub_b             ;
	wire                    sub_valid         ;
	wire                    sub_rfd           ;
	wire [C_DATA_WIDTH-1:0] sub_result        ;
	wire                    sub_rdy           ;
	
  wire [C_DATA_WIDTH-1:0] mult_a            ;
  wire [C_DATA_WIDTH-1:0] mult_b            ;
	wire                    mult_valid        ;
	wire                    mult_rfd          ;
	wire [C_DATA_WIDTH-1:0] mult_result       ;
	wire                    mult_rdy          ;
	
  wire [C_DATA_WIDTH-1:0] div_a             ;
  wire [C_DATA_WIDTH-1:0] div_b             ;
	wire                    div_valid         ;
	wire                    div_rfd           ;
	wire [C_DATA_WIDTH-1:0] div_result        ;
	wire                    div_rdy           ;
	
	wire [C_DATA_WIDTH-1:0] float2fixed_a     ;
	wire                    float2fixed_valid ;
	wire                    float2fixed_rfd   ;
	wire [C_DATA_WIDTH-1:0] float2fixed_result;
	wire                    float2fixed_rdy   ;
	
	wire                    cal_eq_done       ;
	
	wire                    ram_wea  ;
  wire [C_VDATA_WIDTH-1:0]ram_addra;
  wire [C_DATA_WIDTH-1:0] ram_dina ;
  wire                    ram_rdb  ;
  wire [C_VDATA_WIDTH-1:0]ram_addrb;
	wire [C_DATA_WIDTH-1:0] ram_doutb;
	
	wire                    ramR_wea  ;
  wire [C_VDATA_WIDTH-1:0]ramR_addra;
  wire [C_DATA_WIDTH-1:0] ramR_dina ;
  wire                    ramR_rdb  ;
  wire [C_VDATA_WIDTH-1:0]ramR_addrb;
	wire [C_DATA_WIDTH-1:0] ramR_doutb;
	
	wire                    ramG_wea  ;
  wire [C_VDATA_WIDTH-1:0]ramG_addra;
  wire [C_DATA_WIDTH-1:0] ramG_dina ;
  wire                    ramG_rdb  ;
  wire [C_VDATA_WIDTH-1:0]ramG_addrb;
	wire [C_DATA_WIDTH-1:0] ramG_doutb;
	
	wire                    ramB_wea  ;
  wire [C_VDATA_WIDTH-1:0]ramB_addra;
  wire [C_DATA_WIDTH-1:0] ramB_dina ;
  wire                    ramB_rdb  ;
  wire [C_VDATA_WIDTH-1:0]ramB_addrb;
	wire [C_DATA_WIDTH-1:0] ramB_doutb;
	
	reg  [C_VDATA_WIDTH-1:0]data_cnt;
	
	/*
	test value
	     0.123456789f,Hf(3dfcd6ea),y(bea7d583),nxlog2(c0317218),log(Hf(c005e11a))
	     0.693147180f,Hf(3f317218),y(),nxlog2(),log(Hf(bebba795))
	    10.123456789f,Hf(4121f9ae),y(),nxlog2(),log(Hf(40142696))
	    22.123456789f,Hf(41b0fcd7),y(),nxlog2(),log(Hf(40462f53))
	 20736.123456789f,Hf(46a2003f),y(),nxlog2(),log(Hf(411f08bc))
	207360.123456789f,Hf(484a8008),y(be66d389),nxlog2(413c893a),log(Hf(4143e01a))
	*/
	/*
	          1=Bf(3f800000),         0.1=Bf(3dcccccd),      0.01=Bf(3c23d70a),
	      0.001=Bf(3a83126f),      0.0001=Bf(38d1b717),   0.00001=Bf(3727c5ac),
	   0.000001=Bf(358637bd),   0.0000001=Bf(33d6bf95),0.00000001=Bf(322bcc77),
	0.000000001=Bf(3089705f),0.0000000001=Bf(2edbe6ff)
	*/
	
	// =============================================================================
	// RTL Body
	// =============================================================================
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			vs_d <= 1'b1;
			hs_d <= 1'b1;
		end
		else
		begin
			vs_d <= vs_in;
			hs_d <= hs_in;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			data_cnt <= 0;
		end
		else if(float2fixed_rdy)
		begin
			if(&data_cnt)
			begin
				data_cnt <= 0;
			end
			else
			begin
				data_cnt <= data_cnt + 1'b1;
			end			
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			his_cnt <= 0;
		end
		else if(&data_cnt & float2fixed_rdy)//(cal_eq_done)
		begin
			if(his_cnt == 2'd2)
			begin
				his_cnt <= 0;
			end
			else
			begin
				his_cnt <= his_cnt + 1'b1;
			end			
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			hisG_vs <= 1'b0;
		end
		else if(his_cnt == 2'd1)
		begin
			hisG_vs <= 1'b1;
		end
		else
		begin
			hisG_vs <= 1'b0;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			hisB_vs <= 1'b0;
		end
		else if(his_cnt == 2'd2)
		begin
			hisB_vs <= 1'b1;
		end
		else
		begin
			hisB_vs <= 1'b0;
		end
	end
	
	assign db[0] = vs_in;
	assign db[1] = de_in;
	assign db[2] = hisG_vs;
	assign db[3] = hisB_vs;
	assign db[4] = cal_eq_done;
	
	histogram
	#(
	  .C_DATA_WIDTH     (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH    (C_VDATA_WIDTH)
	)
	uR_histogram
	(
	    // System Signal
	    .reset          (reset    ),
	    .clk            (clk      ),
	    // data in                
	    .vs_in          (vs_in    ),
	    .hs_in          (hs_in    ),
	    .de_in          (de_in    ),
	    .data_in        (data_in[3*C_VDATA_WIDTH-1:2*C_VDATA_WIDTH]  ),
	    // data out
	    .data_out_valid (hisR_valid),
	  	.data_out_ready (hisR_ready),
	  	.data_out       (hisR_data )
	);
	
	histogram
	#(
	  .C_DATA_WIDTH     (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH    (C_VDATA_WIDTH)
	)
	uG_histogram
	(
	    // System Signal
	    .reset          (reset    ),
	    .clk            (clk      ),
	    // data in                
	    .vs_in          (hisG_vs    ),
	    .hs_in          (hs_in    ),
	    .de_in          (de_in    ),
	    .data_in        (data_in[2*C_VDATA_WIDTH-1:C_VDATA_WIDTH]  ),
	    // data out
	    .data_out_valid (hisG_valid),
	  	.data_out_ready (hisG_ready),
	  	.data_out       (hisG_data )
	);
	
	histogram
	#(
	  .C_DATA_WIDTH     (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH    (C_VDATA_WIDTH)
	)
	uB_histogram
	(
	    // System Signal
	    .reset          (reset    ),
	    .clk            (clk      ),
	    // data in                
	    .vs_in          (hisB_vs    ),
	    .hs_in          (hs_in    ),
	    .de_in          (de_in    ),
	    .data_in        (data_in[C_VDATA_WIDTH-1:0]  ),
	    // data out
	    .data_out_valid (hisB_valid),
	  	.data_out_ready (hisB_ready),
	  	.data_out       (hisB_data )
	);
	
	assign his_valid = (hisG_vs) ? hisG_valid : 
	                   (hisB_vs) ? hisB_valid :
	                   hisR_valid;
	assign his_data = (hisG_vs) ? hisG_data : 
	                  (hisB_vs) ? hisB_data :
	                  hisR_data;
	assign hisR_ready = his_ready;
	assign hisG_ready = his_ready;
	assign hisB_ready = his_ready;
	
	create_cumulative_sum
	#(
		.C_DATA_WIDTH      (C_DATA_WIDTH ),
		.C_Mu              (C_Mu         ),
		.C_VDATA_WIDTH     (C_VDATA_WIDTH)
	) 
	u_create_cumulative_sum
	(
		.clk               (clk  ), 
		.reset             (reset), 
		.data_in_valid     (his_valid), 
		.data_in_ready     (his_ready), 
		.data_in           (his_data ), 
		.ram_wea           (ram_wea  ),
  	.ram_addra         (ram_addra),
  	.ram_dina          (ram_dina ),
  	.ram_rdb           (ram_rdb  ),
  	.ram_addrb         (ram_addrb),
		.ram_doutb         (ram_doutb),
		.cal_eq_done       (cal_eq_done),
		.fixed2float_a     (fixed2float_a), 
		.fixed2float_valid (fixed2float_valid), 
		.fixed2float_result(fixed2float_result), 
		.fixed2float_rdy   (fixed2float_rdy), 
		.add_a             (add_a), 
		.add_b             (add_b), 
		.add_valid         (add_valid), 
		.add_result        (add_result), 
		.add_rdy           (add_rdy), 
		.sub_a             (sub_a), 
		.sub_b             (sub_b), 
		.sub_valid         (sub_valid), 
		.sub_result        (sub_result), 
		.sub_rdy           (sub_rdy), 
		.mult_a            (mult_a), 
		.mult_b            (mult_b), 
		.mult_valid        (mult_valid), 
		.mult_result       (mult_result), 
		.mult_rdy          (mult_rdy), 
		.div_a             (div_a), 
		.div_b             (div_b), 
		.div_valid         (div_valid), 
		.div_result        (div_result), 
		.div_rdy           (div_rdy),
		.float2fixed_a     (float2fixed_a     ),
		.float2fixed_valid (float2fixed_valid ),
		.float2fixed_result(float2fixed_result),
		.float2fixed_rdy   (float2fixed_rdy   ),
		.db                (db[6:5])
	);
	
	assign ramR_wea   = (~(hisG_vs | hisB_vs)) ? ram_wea   : 1'b0;  
	assign ramR_addra = (~(hisG_vs | hisB_vs)) ? ram_addra : 8'd0;
	assign ramR_dina  = (~(hisG_vs | hisB_vs)) ? ram_dina  : 0;
	assign ramR_rdb   = (~(hisG_vs | hisB_vs)) ? ram_rdb   : 1'b0;
	assign ramR_addrb = (~(hisG_vs | hisB_vs)) ? ram_addrb : 8'd0;
	
	assign ramG_wea   = (hisG_vs) ? ram_wea   : 1'b0;  
	assign ramG_addra = (hisG_vs) ? ram_addra : 8'd0;
	assign ramG_dina  = (hisG_vs) ? ram_dina  : 0;   
	assign ramG_rdb   = (hisG_vs) ? ram_rdb   : 1'b0;
	assign ramG_addrb = (hisG_vs) ? ram_addrb : 8'd0;
	
	assign ramB_wea   = (hisB_vs) ? ram_wea   : 1'b0;  
	assign ramB_addra = (hisB_vs) ? ram_addra : 8'd0;
	assign ramB_dina  = (hisB_vs) ? ram_dina  : 0;   
	assign ramB_rdb   = (hisB_vs) ? ram_rdb   : 1'b0;
	assign ramB_addrb = (hisB_vs) ? ram_addrb : 8'd0;
	
	assign ram_doutb  = (hisG_vs) ? ramG_doutb :
	                    (hisB_vs) ? ramB_doutb :
	                    ramR_doutb;
	
	assign video_in_valid = de_in;
	assign videoR_in      = data_in[3*C_VDATA_WIDTH-1:2*C_VDATA_WIDTH];
	assign videoG_in      = data_in[2*C_VDATA_WIDTH-1:C_VDATA_WIDTH];
	assign videoB_in      = data_in[C_VDATA_WIDTH-1:0];
	
	equalize //delay 1
	#(
	  .C_DATA_WIDTH  (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH (C_VDATA_WIDTH)
	)
	uR_equalize
	(
	  //system signal
	  .clk             (clk           ),
	  .reset           (reset         ),
	  //ram                           
	  .ram_wea         (ramR_wea      ),
	  .ram_addra       (ramR_addra    ),
	  .ram_dina        (ramR_dina     ),
	  .ram_rdb         (ramR_rdb      ),
	  .ram_addrb       (ramR_addrb    ),
		.ram_doutb       (ramR_doutb    ),
		//data input
	  .video_in_valid  (video_in_valid),
	  .video_in        (videoR_in     ),
	  //data output
	  .video_out_valid (eq_valid      ), 
	  .video_out       (eqR_data      )
	);
	
	equalize //delay 1
	#(
	  .C_DATA_WIDTH  (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH (C_VDATA_WIDTH)
	)
	uG_equalize
	(
	  //system signal
	  .clk             (clk           ),
	  .reset           (reset         ),
	  //ram                           
	  .ram_wea         (ramG_wea      ),
	  .ram_addra       (ramG_addra    ),
	  .ram_dina        (ramG_dina     ),
	  .ram_rdb         (ramG_rdb      ),
	  .ram_addrb       (ramG_addrb    ),
		.ram_doutb       (ramG_doutb    ),
		//data input
	  .video_in_valid  (video_in_valid),
	  .video_in        (videoG_in     ),
	  //data output
	  .video_out_valid (), 
	  .video_out       (eqG_data      )
	);
	
	equalize //delay 1
	#(
	  .C_DATA_WIDTH  (C_DATA_WIDTH ),
	  .C_VDATA_WIDTH (C_VDATA_WIDTH)
	)
	uB_equalize
	(
	  //system signal
	  .clk             (clk           ),
	  .reset           (reset         ),
	  //ram                           
	  .ram_wea         (ramB_wea      ),
	  .ram_addra       (ramB_addra    ),
	  .ram_dina        (ramB_dina     ),
	  .ram_rdb         (ramB_rdb      ),
	  .ram_addrb       (ramB_addrb    ),
		.ram_doutb       (ramB_doutb    ),
		//data input
	  .video_in_valid  (video_in_valid),
	  .video_in        (videoB_in     ),
	  //data output
	  .video_out_valid (), 
	  .video_out       (eqB_data      )
	);
	
	always@(posedge clk or posedge reset)
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
			vs_out   <= vs_d;                                       
			hs_out   <= hs_d;                                       
			de_out   <= eq_valid;
			data_out <= {eqR_data[7:0],eqG_data[7:0],eqB_data[7:0]};
			/*
			if(eqR_data[C_DATA_WIDTH-1:8])
			begin
				data_out[23:16] <= 8'd255;
			end
			//else if(|eqR_data[C_DATA_WIDTH-2:8])
			//begin
			//	data_out[23:16] <= 8'd255;
			//end
			else
			begin
				data_out[23:16] <= eqR_data[7:0];
			end
			
			if(eqG_data[C_DATA_WIDTH-1:8])
			begin
				data_out[15:8] <= 8'd255;
			end
			//else if(|eqG_data[C_DATA_WIDTH-2:8])
			//begin
			//	data_out[15:8] <= 8'd255;
			//end
			else
			begin
				data_out[15:8] <= eqG_data[7:0];
			end
			
			if(eqB_data[C_DATA_WIDTH-1:8])
			begin
				data_out[7:0] <= 8'd255;
			end
			//else if(|eqB_data[C_DATA_WIDTH-2:8])
			//begin
			//	data_out[7:0] <= 8'd255;
			//end
			else
			begin
				data_out[7:0] <= eqB_data[7:0];
			end
			*/
		end
	end
	/*
	assign vs_out   = vs_d;
	assign hs_out   = hs_d;
	assign de_out   = eq_valid;
	assign data_out = {eqR_data[7:0],eqG_data[7:0],eqB_data[7:0]};
	*/
	arithmetic_unit
	#(
	  .C_DATA_WIDTH       (C_DATA_WIDTH)
	)
	u_arithmetic_unit
	(
	  // system signal
	  .clk                (clk  ),
	  .reset              (1'b0 ),
	  //fixed2float
	  .fixed2float_a      (fixed2float_a     ),
		.fixed2float_valid  (fixed2float_valid ),  
		.fixed2float_rfd    (fixed2float_rfd   ),        
		.fixed2float_result (fixed2float_result),
		.fixed2float_rdy    (fixed2float_rdy   ),
		//add
	  .add_a              (add_a             ),
	  .add_b              (add_b             ),
		.add_valid          (add_valid         ),
		.add_rfd            (add_rfd           ),
		.add_result         (add_result        ),
		.add_rdy            (add_rdy           ),
		//sub
	  .sub_a              (sub_a             ),
	  .sub_b              (sub_b             ),
		.sub_valid          (sub_valid         ),
		.sub_rfd            (sub_rfd           ),
		.sub_result         (sub_result        ),
		.sub_rdy            (sub_rdy           ),
		//mult
	  .mult_a             (mult_a            ),
	  .mult_b             (mult_b            ),
		.mult_valid         (mult_valid        ),
		.mult_rfd           (mult_rfd          ),
		.mult_result        (mult_result       ),
		.mult_rdy           (mult_rdy          ),
		//div
	  .div_a              (div_a             ),
	  .div_b              (div_b             ),
		.div_valid          (div_valid         ),
		.div_rfd            (div_rfd           ),
		.div_result         (div_result        ),
		.div_rdy            (div_rdy           ),
		//
	  .float2fixed_a      (float2fixed_a     ),
		.float2fixed_valid  (float2fixed_valid ),
		.float2fixed_rfd    (float2fixed_rfd   ),
		.float2fixed_result (float2fixed_result),
		.float2fixed_rdy    (float2fixed_rdy   )
	);

	
endmodule