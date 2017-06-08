module IMU_PACKAGE_INSERT
#(
    parameter DATA_WIDTH = 16,
    parameter IMU_PKT_SIZE = 46, 
    parameter IMU_PKT_HEADER = 16'h5AA5,
    parameter KEY_NUM = 8
)
(
    input  wire [KEY_NUM*8-1:0]  key_code       ,
    input  wire                  reset          ,
    input  wire                  sys_clk        ,
    input  wire                  pix_clk        ,
    input  wire                  sensor_hs_i    ,
    input  wire                  sensor_vs_i    ,
    input  wire                  sensor_de_i    ,
    input  wire [DATA_WIDTH-1:0] sensor_data_i  ,
    output reg                   sensor_hs_o    ,
    output reg                   sensor_vs_o    ,
    output reg                   sensor_de_o    ,
    output reg  [DATA_WIDTH-1:0] sensor_data_o  ,

    input  wire                  uart_rx        
);

wire       uart_recieve_vld;
wire [7:0] imu_data_wr;
reg        video_imu_insert_start;          //video imu should be synced to start inorder to avoid the imu_data_fifo flow. start from the 3rd frame

function integer clog2;
input integer value;
begin 
	value = value-1;
	for (clog2=0; value>0; clog2=clog2+1)
	value = value>>1;
end 
endfunction

UART_RX U_UART_RX
(
    .sys_clk      (sys_clk                ),      
    .reset        (reset                  ),
    .Rx           (uart_rx                ),
    .RxData_VLD   (uart_recieve_vld       ),
    .RxDATA       (imu_data_wr            )
);


reg [15:0] imu_package_header; //shift reg to grep the header of the imu package

always @ (posedge sys_clk or posedge reset) begin
    if (reset == 1'b1) begin
	imu_package_header <= 16'h0; 
    end
    else if ((uart_recieve_vld == 1'b1) && (video_imu_insert_start == 1'b1)) begin
        imu_package_header <= {imu_package_header[7:0],imu_data_wr};
    end
    else begin
        imu_package_header <= imu_package_header;
    end
end


reg [7:0] imu_package_discard_cnt;
reg       imu_package_discard_cnt_en; // use together with imu_package_aligned. effect to align with the packet header to start write into fifo
reg [1:0] imu_package_aligned;
wire      imu_data_wr_en;

always @ (posedge sys_clk or posedge reset) begin
    if (reset == 1'b1) begin
        imu_package_discard_cnt <= 8'h0; 
	imu_package_discard_cnt_en <= 1'b0; 
	imu_package_aligned <= 2'b00;
    end
    else if ((imu_package_header == IMU_PKT_HEADER) && (imu_package_aligned == 2'b00)) begin
        imu_package_discard_cnt <= imu_package_discard_cnt;
	imu_package_discard_cnt_en <= 1'b1;
	imu_package_aligned <= 2'b01;
    end
    else if (imu_package_discard_cnt == 8'd44) begin
	imu_package_discard_cnt <= 8'h0; 
        imu_package_discard_cnt_en <= 1'b0;
	imu_package_aligned <= 2'b11;
    end
    else if ((imu_package_discard_cnt_en == 1'b1) && (uart_recieve_vld == 1'b1)) begin
	imu_package_discard_cnt <= imu_package_discard_cnt + 1'b1;
	imu_package_discard_cnt_en <= imu_package_discard_cnt_en;
	imu_package_aligned <= imu_package_aligned;
    end
    else begin
	imu_package_discard_cnt <= imu_package_discard_cnt;
	imu_package_discard_cnt_en <= imu_package_discard_cnt_en;
	imu_package_aligned <= imu_package_aligned;
    end
end

assign imu_data_wr_en = (&imu_package_aligned) & uart_recieve_vld;


reg        imu_data_rd_en;
wire [7:0] imu_data_rd;
wire [9:0] rd_data_count;
wire [15:0] imu_data_encode;

wire [7:0] imu_data_pre_encode;
reg       video_1st_line_1d;
reg       video_1st_line_2d;
wire                 sensor_vs_i_ns;
wire                 sensor_hs_i_ps;
wire                 sensor_de_i_ns;
wire                 sensor_de_i_ps;



reg                  rd_strobe;
reg                  sensor_hs_i_1d;
reg                  sensor_vs_i_1d;
reg                  sensor_de_i_1d;
reg [DATA_WIDTH-1:0] sensor_data_i_1d;
reg                  sensor_hs_i_2d;
reg                  sensor_vs_i_2d;
reg                  sensor_de_i_2d;
reg [DATA_WIDTH-1:0] sensor_data_i_2d;

reg [2:0]            sensor_vs_i_ns_cnt;



wire sensor_vs_i_ns_clk_div2;
assign sensor_vs_i_ns = sensor_vs_i_1d & (~sensor_vs_i);
assign sensor_vs_i_ns_clk_div2 = sensor_vs_i_2d & (~sensor_vs_i);
assign sensor_hs_i_ps = sensor_hs_i & (~sensor_hs_i_1d);
assign sensor_de_i_ns = sensor_de_i_1d & (~sensor_de_i);
assign sensor_de_i_ps = sensor_de_i & (~sensor_de_i_1d);


always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	rd_strobe <= 1'b0;
    end
    else if (sensor_de_i_ps == 1'b1) begin
        rd_strobe <= 1'b0;
    end
    else begin
        rd_strobe <= ~rd_strobe;
    end
end

imu_data_fifo U_IMU_DATA_FIFO (
    .rst             (reset                    ),     
    .wr_clk          (sys_clk                  ),
    .rd_clk          (pix_clk                  ),
    .din             (imu_data_wr              ),
    .wr_en           (imu_data_wr_en           ), 
    .rd_en           (imu_data_rd_en & (!rd_strobe)         ),
    .dout            (imu_data_rd              ),
    .full            (                         ),
    .empty           (                         ),
    .rd_data_count   (rd_data_count            )
);

rom_imu_encode U_ROM_IMU_ENCODE
(
  .clka     (pix_clk         ),    
  .addra    (imu_data_rd     ),
  .douta    (imu_data_encode )
);


reg  [31:0] timestamp_cnt;    
wire [63:0] timestamp_cnt_encode;

//genvar i;
//generate
//for (i=0;i<4;i=i+1) begin: TIMESTAMP_ENCODE
//rom_imu_encode U_ROM_TIMESTAMP_ENCODE
//(
//  .clka     (pix_clk                        ),    
//  .addra    (timestamp_cnt[i*8:+8]          ),
//  .douta    (timestamp_cnt_encode[i*16:+16] )
//);
//end
//endgenerate



rom_imu_encode U_ROM_TIMESTAMP_ENCODE_0
(
  .clka     (pix_clk                     ),    
  .addra    (timestamp_cnt[7:0]          ),
  .douta    (timestamp_cnt_encode[15:0] )
);

rom_imu_encode U_ROM_TIMESTAMP_ENCODE_1
(
  .clka     (pix_clk                      ),    
  .addra    (timestamp_cnt[15:8]          ),
  .douta    (timestamp_cnt_encode[31:16] )
);

rom_imu_encode U_ROM_TIMESTAMP_ENCODE_2
(
  .clka     (pix_clk                       ),    
  .addra    (timestamp_cnt[23:16]          ),
  .douta    (timestamp_cnt_encode[47:32] )
);

rom_imu_encode U_ROM_TIMESTAMP_ENCODE_3
(
  .clka     (pix_clk                       ),    
  .addra    (timestamp_cnt[31:24]          ),
  .douta    (timestamp_cnt_encode[63:48] )
);



always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	sensor_vs_i_ns_cnt <= 3'b0;
    end
    else if (sensor_vs_i_ns_cnt == 3'h1) begin
        sensor_vs_i_ns_cnt <= sensor_vs_i_ns_cnt;
    end
    else if (sensor_vs_i_ns == 1'b1) begin
	sensor_vs_i_ns_cnt <= sensor_vs_i_ns_cnt + 1'b1;
    end
    else begin
	sensor_vs_i_ns_cnt <= sensor_vs_i_ns_cnt;
    end
end



always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	video_imu_insert_start <= 1'b0;
    end
    else if (sensor_vs_i_ns_cnt == 3'h1) begin
	video_imu_insert_start <= 1'b1;
    end
    else begin
	video_imu_insert_start <= video_imu_insert_start;
    end
end


reg  video_1st_line_strobe;
wire video_1st_line; 
always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	video_1st_line_strobe <= 1'b0;
    end
    else if ((sensor_vs_i_ns == 1'b1) && (video_imu_insert_start == 1'b1)) begin
	video_1st_line_strobe <= 1'b1;
    end
    else if (sensor_de_i_ns == 1'b1) begin
	video_1st_line_strobe <= 1'b0;
    end
    else begin
        video_1st_line_strobe <= video_1st_line_strobe;
    end
end

assign video_1st_line = video_1st_line_strobe & (sensor_de_i);

reg [5:0] imu_data_rd_cnt;
reg [3:0] timestamp_size_cnt; // inorder to insert timestamp. we need 4 byte to be reserved for it. 
reg imu_data_rd_next_package_en;// check at the every packet's end, to make sure wether the fifo have the next whole pocket to be read.

always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
        imu_data_rd_cnt <= 6'h0;
    end
    else if ((imu_data_rd_cnt == (IMU_PKT_SIZE-1)) && rd_strobe == 1'b1) begin
	imu_data_rd_cnt <= 6'h0;
    end
    else if (imu_data_rd_en == 1'b1 && rd_strobe == 1'b1) begin
	imu_data_rd_cnt <= imu_data_rd_cnt + 1'b1;
    end
    else begin
	imu_data_rd_cnt <= imu_data_rd_cnt;
    end
end


always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	imu_data_rd_en <= 1'b0;
        imu_data_rd_next_package_en <= 1'b1;
	timestamp_cnt <= 32'h0;
        timestamp_size_cnt <= 4'h0; 
    end
    else if ((sensor_vs_i_ns == 1'b1) && (rd_data_count >= IMU_PKT_SIZE)) begin
        imu_data_rd_en <= imu_data_rd_en;
	imu_data_rd_next_package_en <= 1'b1;
	timestamp_cnt <= timestamp_cnt;
        timestamp_size_cnt <= 4'h0; 
    end
    else if (imu_data_rd_cnt == (IMU_PKT_SIZE-1) && (rd_strobe == 1'b1)) begin
        imu_data_rd_en <= 1'b0;
	timestamp_cnt <= timestamp_cnt + 1'b1;

        if (rd_data_count >= IMU_PKT_SIZE) begin
	    imu_data_rd_next_package_en <= 1'b1;
  	    timestamp_size_cnt <= 4'h0; 
        end
	else begin
	    imu_data_rd_next_package_en <= 1'b0;
            timestamp_size_cnt <= timestamp_size_cnt; 
	end
    end
    else if ((video_1st_line_2d == 1'b1) && (imu_data_rd_next_package_en == 1'b1) && (rd_strobe == 1'b1)) begin
	if ((timestamp_size_cnt >= 4'h0) && (timestamp_size_cnt < 4'h3)) begin
	    imu_data_rd_en <= 1'b0;
	    timestamp_size_cnt <= timestamp_size_cnt + 1'b1;  
	end
	else if (timestamp_size_cnt == 4'h3) begin
	    imu_data_rd_en <= 1'b1;
	    timestamp_size_cnt <= timestamp_size_cnt + 1'b1;  
	end
	else begin
	    imu_data_rd_en <= 1'b1;
	    timestamp_size_cnt <= timestamp_size_cnt;  
	end
	    imu_data_rd_next_package_en <= imu_data_rd_next_package_en;
	    timestamp_cnt <= timestamp_cnt;
    end
    else begin
        imu_data_rd_en <= imu_data_rd_en;
	imu_data_rd_next_package_en <= imu_data_rd_next_package_en;
	timestamp_cnt <= timestamp_cnt;
	timestamp_size_cnt <= timestamp_size_cnt;  
    end
end

reg [clog2(2*KEY_NUM):0]  key_button_cycle;
reg        data_byte_strobe;
reg        imu_data_rd_en_1d;
reg        imu_data_rd_en_2d;
reg [3:0]  timestamp_size_cnt_1d;
reg        imu_data_rd_next_package_en_1d;
reg        imu_data_rd_next_package_en_2d;
reg [15:0] imu_data_encode_1d;
reg [15:0] imu_data_encode_2d;


always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
        key_button_cycle <= 0;
    end
    else if (sensor_vs_i_ns == 1'b1) begin
        key_button_cycle <= 0;
    end
    else if ((video_1st_line_1d == 1'b1) && (imu_data_rd_next_package_en == 1'b0)) begin
	if (key_button_cycle < 2*KEY_NUM+2) begin
            key_button_cycle <= key_button_cycle + 1'h1;
        end
	else begin
            key_button_cycle <= key_button_cycle;
	end
    end
end


always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	video_1st_line_1d <= 0;
	video_1st_line_2d <= 0;
    end
    else begin
	video_1st_line_1d <= video_1st_line;
	video_1st_line_2d <= video_1st_line_1d;
    end
end



always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
	imu_data_rd_en_1d <= 0;
	imu_data_rd_en_2d <= 0;
	timestamp_size_cnt_1d <= 0;
	imu_data_rd_next_package_en_1d <= 0;
	imu_data_rd_next_package_en_2d <= 0;
	imu_data_encode_1d <= 16'h0;
	imu_data_encode_2d <= 16'h0;
    end
    else begin
	imu_data_rd_en_1d <= imu_data_rd_en;
	imu_data_rd_en_2d <= imu_data_rd_en_1d;
	timestamp_size_cnt_1d <= timestamp_size_cnt;
	imu_data_rd_next_package_en_1d <= imu_data_rd_next_package_en;
	imu_data_rd_next_package_en_2d <= imu_data_rd_next_package_en_1d;
	imu_data_encode_1d <= imu_data_encode;
	imu_data_encode_2d <= imu_data_encode_1d;
    end
end

integer i;

always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
        sensor_data_o <= 0;
    end
    else if (video_1st_line_2d == 1'b1) begin
	if (imu_data_rd_en_1d == 1'b1) begin
	    if (rd_strobe == 1'b1) begin
	        sensor_data_o <= {8'h80,imu_data_encode_1d[15:8]};
	    end
	    else begin
	        sensor_data_o <= {8'h80,imu_data_encode_1d[7:0]};
	    end
	end
	else begin
	    if (timestamp_size_cnt_1d == 4'h3) begin
		if (rd_strobe == 1'b1) begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[15:8]}; 
		end
		else begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[7:0]}; 
		end
	    end
	    else if (timestamp_size_cnt_1d == 4'h2) begin
		if (rd_strobe == 1'b1) begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[31:24]}; 
		end
		else begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[23:16]}; 
		end
	    end
	    else if (timestamp_size_cnt_1d == 4'h1) begin
		if (rd_strobe == 1'b1) begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[47:40]}; 
		end
		else begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[39:32]}; 
		end
	    end
	    else if (timestamp_size_cnt_1d == 4'h0) begin
		if (rd_strobe == 1'b1) begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[63:56]}; 
		end
		else begin
	            sensor_data_o <= {8'h80,timestamp_cnt_encode[55:48]}; 
		end
	    end
	    else if (key_button_cycle >=1 && key_button_cycle <=2*KEY_NUM) begin
		if (rd_strobe == 1'b1) begin
	            sensor_data_o <= {8'h80,8'h30+key_button_cycle} ;
		end
		else begin
	            sensor_data_o <= {8'h80,key_code[(key_button_cycle-2)*4+:8]} ;
		end
	    end
	    else begin
	        sensor_data_o <= {8'h80,8'h66} ; 
	    end
	end 
    end
    else begin
        sensor_data_o <= sensor_data_i_2d; 
    end
end

//hrf always @ (posedge pix_clk or posedge reset) begin
//hrf     if (reset == 1'b1) begin
//hrf         sensor_data_o <= 0;
//hrf     end
//hrf     else if (video_1st_line_1d == 1'b1) begin
//hrf 	sensor_data_o <= {8'h80,imu_data_pre_encode};
//hrf     end
//hrf     else begin
//hrf         sensor_data_o <= sensor_data_i_2d; 
//hrf     end
//hrf end



always @ (posedge pix_clk or posedge reset) begin
    if (reset == 1'b1) begin
        sensor_hs_i_1d <= 1'h1;
        sensor_vs_i_1d <= 1'h1;
        sensor_de_i_1d <= 1'h1;
        sensor_data_i_1d <= 0;
        sensor_hs_i_2d <= 1'h1;
        sensor_vs_i_2d <= 1'h1;
        sensor_de_i_2d <= 1'h1;
        sensor_data_i_2d <= 0;
	sensor_hs_o <= 1'h1;
	sensor_vs_o <= 1'h1;
	sensor_de_o <= 1'h0;
    end
    else begin
        sensor_hs_i_1d <= sensor_hs_i;
        sensor_vs_i_1d <= sensor_vs_i;
        sensor_de_i_1d <= sensor_de_i;
        sensor_data_i_1d <= sensor_data_i;
        sensor_hs_i_2d <= sensor_hs_i_1d;
        sensor_vs_i_2d <= sensor_vs_i_1d;
        sensor_de_i_2d <= sensor_de_i_1d;
        sensor_data_i_2d <= sensor_data_i_1d;
	sensor_hs_o <= sensor_hs_i_2d;
	sensor_vs_o <= sensor_vs_i_2d;
	sensor_de_o <= sensor_de_i_2d;
    end
end

endmodule
