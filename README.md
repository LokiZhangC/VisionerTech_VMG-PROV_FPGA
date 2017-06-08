##Visionertech VMG-PRO FPGA project
##General Description:
This is a open-source project of VMG-PRO HMD which is mostly writed by verilog. There are two process flow contained, one is basic ISP flow, the other is HDR flow.
The top-hierarchy file is also provided in the project, what developers use to do is only new a project and add all of the RTL and ip files to start their design. By the way, all of the module included have been simulated and tested already in hardware.

##Module localtion:
design/top
The top file and UCF file.

design/clock
The system clock.

design/bnt_process
The input button process.

design/powerUp_sequence
The power up process and reset process.

design/auto_exposure
The auto exposure.

design/config_sensor
The image sensor controller.

design/sensor_sync_signal_regen
Regenerate image sensor synchronizing signal.

design/width_conv_12to10
Pixel depth compress.

design/frames_buffer DDR3
The interface of DDR3 controller.

design/Bayer2RGB
Bayer convert to RGB.

design/HDR
The HDR module.

design/output_mux
Strobe output ISP or HDR.

design/his_eq
The histogram equalization.

design/IMU_package
Packaging IMU data and button signal into video.

design/USB_cy3014
Packaging UVC data format of usb3.0.

design/YC_RGB_convertion
RGB convert to YC.

##Developer tool:
Recommended PC configuration： Intel Core i5-4460/8G RAM/at least two USB3.0/
Xilinx ISE 13.4 design suite
JATG debug tool which is compatible Xilinx, narrow edge JATG row line which is 2.0cm and 14pins.
