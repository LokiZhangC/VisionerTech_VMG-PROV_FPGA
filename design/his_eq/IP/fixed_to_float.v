////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: O.87xd
//  \   \         Application: netgen
//  /   /         Filename: fixed_to_float.v
// /___/   /\     Timestamp: Mon Dec 26 17:35:14 2016
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/Xilinx/Project_VMG-PROV_v2/Project_ise13_4/ipcore_dir/tmp/_cg/fixed_to_float.ngc E:/Xilinx/Project_VMG-PROV_v2/Project_ise13_4/ipcore_dir/tmp/_cg/fixed_to_float.v 
// Device	: 6slx45csg324-2
// Input file	: E:/Xilinx/Project_VMG-PROV_v2/Project_ise13_4/ipcore_dir/tmp/_cg/fixed_to_float.ngc
// Output file	: E:/Xilinx/Project_VMG-PROV_v2/Project_ise13_4/ipcore_dir/tmp/_cg/fixed_to_float.v
// # of Modules	: 1
// Design Name	: fixed_to_float
// Xilinx        : D:\Xilinx\13.4\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module fixed_to_float (
  operation_nd, clk, operation_rfd, rdy, a, result
)/* synthesis syn_black_box syn_noprune=1 */;
  input operation_nd;
  input clk;
  output operation_rfd;
  output rdy;
  input [31 : 0] a;
  output [31 : 0] result;
  
  // synthesis translate_off
  
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/sign_op ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[7] ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[4] ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[3] ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[2] ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[1] ;
  wire \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[0] ;
  wire \U0/op_inst/FLT_PT_OP/HND_SHK/RDY ;
  wire NlwRenamedSig_OI_operation_rfd;
  wire sig00000001;
  wire sig00000002;
  wire sig00000003;
  wire sig00000004;
  wire sig00000005;
  wire sig00000006;
  wire sig00000007;
  wire sig00000008;
  wire sig00000009;
  wire sig0000000a;
  wire sig0000000b;
  wire sig0000000c;
  wire sig0000000d;
  wire sig0000000e;
  wire sig0000000f;
  wire sig00000010;
  wire sig00000011;
  wire sig00000012;
  wire sig00000013;
  wire sig00000014;
  wire sig00000015;
  wire sig00000016;
  wire sig00000017;
  wire sig00000018;
  wire sig00000019;
  wire sig0000001a;
  wire sig0000001b;
  wire sig0000001c;
  wire sig0000001d;
  wire sig0000001e;
  wire sig0000001f;
  wire sig00000020;
  wire sig00000021;
  wire sig00000022;
  wire sig00000023;
  wire sig00000024;
  wire sig00000025;
  wire sig00000026;
  wire sig00000027;
  wire sig00000028;
  wire sig00000029;
  wire sig0000002a;
  wire sig0000002b;
  wire sig0000002c;
  wire sig0000002d;
  wire sig0000002e;
  wire sig0000002f;
  wire sig00000030;
  wire sig00000031;
  wire sig00000032;
  wire sig00000033;
  wire sig00000034;
  wire sig00000035;
  wire sig00000036;
  wire sig00000037;
  wire sig00000038;
  wire sig00000039;
  wire sig0000003a;
  wire sig0000003b;
  wire sig0000003c;
  wire sig0000003d;
  wire sig0000003e;
  wire sig0000003f;
  wire sig00000040;
  wire sig00000041;
  wire sig00000042;
  wire sig00000043;
  wire sig00000044;
  wire sig00000045;
  wire sig00000046;
  wire sig00000047;
  wire sig00000048;
  wire sig00000049;
  wire sig0000004a;
  wire sig0000004b;
  wire sig0000004c;
  wire sig0000004d;
  wire sig0000004e;
  wire sig0000004f;
  wire sig00000050;
  wire sig00000051;
  wire sig00000052;
  wire sig00000053;
  wire sig00000054;
  wire sig00000055;
  wire sig00000056;
  wire sig00000057;
  wire sig00000058;
  wire sig00000059;
  wire sig0000005a;
  wire sig0000005b;
  wire sig0000005c;
  wire sig0000005d;
  wire sig0000005e;
  wire sig0000005f;
  wire sig00000060;
  wire sig00000061;
  wire sig00000062;
  wire sig00000063;
  wire sig00000064;
  wire sig00000065;
  wire sig00000066;
  wire sig00000067;
  wire sig00000068;
  wire sig00000069;
  wire sig0000006a;
  wire sig0000006b;
  wire sig0000006c;
  wire sig0000006d;
  wire sig0000006e;
  wire sig0000006f;
  wire sig00000070;
  wire sig00000071;
  wire sig00000072;
  wire sig00000073;
  wire sig00000074;
  wire sig00000075;
  wire sig00000076;
  wire sig00000077;
  wire sig00000078;
  wire sig00000079;
  wire sig0000007a;
  wire sig0000007b;
  wire sig0000007c;
  wire sig0000007d;
  wire sig0000007e;
  wire sig0000007f;
  wire sig00000080;
  wire sig00000081;
  wire sig00000082;
  wire sig00000083;
  wire sig00000084;
  wire sig00000085;
  wire sig00000086;
  wire sig00000087;
  wire sig00000088;
  wire sig00000089;
  wire sig0000008a;
  wire sig0000008b;
  wire sig0000008c;
  wire sig0000008d;
  wire sig0000008e;
  wire sig0000008f;
  wire sig00000090;
  wire sig00000091;
  wire sig00000092;
  wire sig00000093;
  wire sig00000094;
  wire sig00000095;
  wire sig00000096;
  wire sig00000097;
  wire sig00000098;
  wire sig00000099;
  wire sig0000009a;
  wire sig0000009b;
  wire sig0000009c;
  wire sig0000009d;
  wire sig0000009e;
  wire sig0000009f;
  wire sig000000a0;
  wire sig000000a1;
  wire sig000000a2;
  wire sig000000a3;
  wire sig000000a4;
  wire sig000000a5;
  wire sig000000a6;
  wire sig000000a7;
  wire sig000000a8;
  wire sig000000a9;
  wire sig000000aa;
  wire sig000000ab;
  wire sig000000ac;
  wire sig000000ad;
  wire sig000000ae;
  wire sig000000af;
  wire sig000000b0;
  wire sig000000b1;
  wire sig000000b2;
  wire sig000000b3;
  wire sig000000b4;
  wire sig000000b5;
  wire sig000000b6;
  wire sig000000b7;
  wire sig000000b8;
  wire sig000000b9;
  wire sig000000ba;
  wire sig000000bb;
  wire sig000000bc;
  wire sig000000bd;
  wire sig000000be;
  wire sig000000bf;
  wire sig000000c0;
  wire sig000000c1;
  wire sig000000c2;
  wire sig000000c3;
  wire sig000000c4;
  wire sig000000c5;
  wire sig000000c6;
  wire sig000000c7;
  wire sig000000c8;
  wire sig000000c9;
  wire sig000000ca;
  wire sig000000cb;
  wire sig000000cc;
  wire sig000000cd;
  wire sig000000ce;
  wire sig000000cf;
  wire sig000000d0;
  wire sig000000d1;
  wire sig000000d2;
  wire sig000000d3;
  wire sig000000d4;
  wire sig000000d5;
  wire sig000000d6;
  wire sig000000d7;
  wire sig000000d8;
  wire sig000000d9;
  wire sig000000da;
  wire sig000000db;
  wire sig000000dc;
  wire sig000000dd;
  wire sig000000de;
  wire sig000000df;
  wire sig000000e0;
  wire sig000000e1;
  wire sig000000e2;
  wire sig000000e3;
  wire sig000000e4;
  wire sig000000e5;
  wire sig000000e6;
  wire sig000000e7;
  wire sig000000e8;
  wire sig000000e9;
  wire sig000000ea;
  wire sig000000eb;
  wire sig000000ec;
  wire sig000000ed;
  wire sig000000ee;
  wire sig000000ef;
  wire sig000000f0;
  wire sig000000f1;
  wire sig000000f2;
  wire sig000000f3;
  wire sig000000f4;
  wire sig000000f5;
  wire sig000000f6;
  wire sig000000f7;
  wire sig000000f8;
  wire sig000000f9;
  wire sig000000fa;
  wire sig000000fb;
  wire sig000000fc;
  wire sig000000fd;
  wire sig000000fe;
  wire sig000000ff;
  wire sig00000100;
  wire sig00000101;
  wire sig00000102;
  wire sig00000103;
  wire sig00000104;
  wire sig00000105;
  wire sig00000106;
  wire sig00000107;
  wire sig00000108;
  wire sig00000109;
  wire sig0000010a;
  wire sig0000010b;
  wire sig0000010c;
  wire sig0000010d;
  wire sig0000010e;
  wire sig0000010f;
  wire sig00000110;
  wire sig00000111;
  wire sig00000112;
  wire sig00000113;
  wire sig00000114;
  wire sig00000115;
  wire sig00000116;
  wire sig00000117;
  wire sig00000118;
  wire sig00000119;
  wire sig0000011a;
  wire sig0000011b;
  wire sig0000011c;
  wire sig0000011d;
  wire sig0000011e;
  wire sig0000011f;
  wire sig00000120;
  wire sig00000121;
  wire sig00000122;
  wire sig00000123;
  wire sig00000124;
  wire sig00000125;
  wire sig00000126;
  wire sig00000127;
  wire sig00000128;
  wire sig00000129;
  wire sig0000012a;
  wire sig0000012b;
  wire sig0000012c;
  wire sig0000012d;
  wire sig0000012e;
  wire sig0000012f;
  wire sig00000130;
  wire sig00000131;
  wire sig00000132;
  wire sig00000133;
  wire sig00000134;
  wire sig00000135;
  wire sig00000136;
  wire sig00000137;
  wire sig00000138;
  wire sig00000139;
  wire sig0000013a;
  wire sig0000013b;
  wire sig0000013c;
  wire sig0000013d;
  wire sig0000013e;
  wire sig0000013f;
  wire sig00000140;
  wire sig00000141;
  wire sig00000142;
  wire sig00000143;
  wire sig00000144;
  wire sig00000145;
  wire sig00000146;
  wire sig00000147;
  wire sig00000148;
  wire sig00000149;
  wire sig0000014a;
  wire sig0000014b;
  wire sig0000014c;
  wire sig0000014d;
  wire sig0000014e;
  wire sig0000014f;
  wire sig00000150;
  wire sig00000151;
  wire sig00000152;
  wire sig00000153;
  wire sig00000154;
  wire sig00000155;
  wire sig00000156;
  wire sig00000157;
  wire sig00000158;
  wire sig00000159;
  wire sig0000015a;
  wire sig0000015b;
  wire sig0000015c;
  wire sig0000015d;
  wire sig0000015e;
  wire sig0000015f;
  wire sig00000160;
  wire sig00000161;
  wire sig00000162;
  wire sig00000163;
  wire sig00000164;
  wire sig00000165;
  wire sig00000166;
  wire sig00000167;
  wire sig00000168;
  wire sig00000169;
  wire sig0000016a;
  wire sig0000016b;
  wire sig0000016c;
  wire sig0000016d;
  wire sig0000016e;
  wire sig0000016f;
  wire sig00000170;
  wire sig00000171;
  wire sig00000172;
  wire sig00000173;
  wire sig00000174;
  wire sig00000175;
  wire sig00000176;
  wire sig00000177;
  wire sig00000178;
  wire sig00000179;
  wire sig0000017a;
  wire sig0000017b;
  wire sig0000017c;
  wire sig0000017d;
  wire sig0000017e;
  wire sig0000017f;
  wire sig00000180;
  wire sig00000181;
  wire sig00000182;
  wire sig00000183;
  wire sig00000184;
  wire sig00000185;
  wire sig00000186;
  wire sig00000187;
  wire sig00000188;
  wire sig00000189;
  wire sig0000018a;
  wire sig0000018b;
  wire sig0000018c;
  wire sig0000018d;
  wire sig0000018e;
  wire sig0000018f;
  wire sig00000190;
  wire sig00000191;
  wire sig00000192;
  wire sig00000193;
  wire sig00000194;
  wire sig00000195;
  wire sig00000196;
  wire sig00000197;
  wire sig00000198;
  wire sig00000199;
  wire sig0000019a;
  wire sig0000019b;
  wire sig0000019c;
  wire sig0000019d;
  wire sig0000019e;
  wire sig0000019f;
  wire sig000001a0;
  wire sig000001a1;
  wire sig000001a2;
  wire sig000001a3;
  wire sig000001a4;
  wire sig000001a5;
  wire sig000001a6;
  wire sig000001a7;
  wire sig000001a8;
  wire sig000001a9;
  wire sig000001aa;
  wire sig000001ab;
  wire sig000001ac;
  wire sig000001ad;
  wire sig000001ae;
  wire sig000001af;
  wire sig000001b0;
  wire sig000001b1;
  wire sig000001b2;
  wire sig000001b3;
  wire sig000001b4;
  wire sig000001b5;
  wire sig000001b6;
  wire sig000001b7;
  wire sig000001b8;
  wire sig000001b9;
  wire sig000001ba;
  wire sig000001bb;
  wire sig000001bc;
  wire sig000001bd;
  wire sig000001be;
  wire sig000001bf;
  wire sig000001c0;
  wire sig000001c1;
  wire sig000001c2;
  wire sig000001c3;
  wire sig000001c4;
  wire sig000001c5;
  wire sig000001c6;
  wire sig000001c7;
  wire sig000001c8;
  wire sig000001c9;
  wire sig000001ca;
  wire sig000001cb;
  wire sig000001cc;
  wire sig000001cd;
  wire sig000001ce;
  wire sig000001cf;
  wire sig000001d0;
  wire sig000001d1;
  wire sig000001d2;
  wire sig000001d3;
  wire sig000001d4;
  wire sig000001d5;
  wire sig000001d6;
  wire sig000001d7;
  wire sig000001d8;
  wire sig000001d9;
  wire sig000001da;
  wire sig000001db;
  wire sig000001dc;
  wire sig000001dd;
  wire sig000001de;
  wire sig000001df;
  wire sig000001e0;
  wire sig000001e1;
  wire sig000001e2;
  wire sig000001e3;
  wire sig000001e4;
  wire sig000001e5;
  wire sig000001e6;
  wire sig000001e7;
  wire sig000001e8;
  wire sig000001e9;
  wire sig000001ea;
  wire sig000001eb;
  wire sig000001ec;
  wire sig000001ed;
  wire sig000001ee;
  wire sig000001ef;
  wire sig000001f0;
  wire sig000001f1;
  wire sig000001f2;
  wire sig000001f3;
  wire sig000001f4;
  wire sig000001f5;
  wire sig000001f6;
  wire sig000001f7;
  wire sig000001f8;
  wire sig000001f9;
  wire sig000001fa;
  wire sig000001fb;
  wire sig000001fc;
  wire sig000001fd;
  wire sig000001fe;
  wire sig000001ff;
  wire sig00000200;
  wire sig00000201;
  wire sig00000202;
  wire sig00000203;
  wire sig00000204;
  wire sig00000205;
  wire sig00000206;
  wire sig00000207;
  wire sig00000208;
  wire sig00000209;
  wire sig0000020a;
  wire sig0000020b;
  wire sig0000020c;
  wire sig0000020d;
  wire sig0000020e;
  wire sig0000020f;
  wire sig00000210;
  wire sig00000211;
  wire sig00000212;
  wire NLW_blk000000c2_O_UNCONNECTED;
  wire NLW_blk000000c4_O_UNCONNECTED;
  wire NLW_blk000000c5_O_UNCONNECTED;
  wire NLW_blk000000c6_O_UNCONNECTED;
  wire NLW_blk0000022e_Q15_UNCONNECTED;
  wire NLW_blk00000230_Q15_UNCONNECTED;
  wire NLW_blk00000232_Q15_UNCONNECTED;
  wire NLW_blk00000234_Q15_UNCONNECTED;
  wire NLW_blk00000236_Q15_UNCONNECTED;
  wire [6 : 6] \NlwRenamedSignal_U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op ;
  wire [22 : 0] \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op ;
  assign
    result[31] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/sign_op ,
    result[30] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[7] ,
    result[29] = \NlwRenamedSignal_U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op [6],
    result[28] = \NlwRenamedSignal_U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op [6],
    result[27] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[4] ,
    result[26] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[3] ,
    result[25] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[2] ,
    result[24] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[1] ,
    result[23] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[0] ,
    result[22] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [22],
    result[21] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [21],
    result[20] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [20],
    result[19] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [19],
    result[18] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [18],
    result[17] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [17],
    result[16] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [16],
    result[15] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [15],
    result[14] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [14],
    result[13] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [13],
    result[12] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [12],
    result[11] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [11],
    result[10] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [10],
    result[9] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [9],
    result[8] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [8],
    result[7] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [7],
    result[6] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [6],
    result[5] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [5],
    result[4] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [4],
    result[3] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [3],
    result[2] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [2],
    result[1] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [1],
    result[0] = \U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [0],
    operation_rfd = NlwRenamedSig_OI_operation_rfd,
    rdy = \U0/op_inst/FLT_PT_OP/HND_SHK/RDY ;
  VCC   blk00000001 (
    .P(NlwRenamedSig_OI_operation_rfd)
  );
  GND   blk00000002 (
    .G(sig00000001)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000003 (
    .C(clk),
    .D(sig00000003),
    .Q(sig00000063)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000004 (
    .C(clk),
    .D(sig0000005d),
    .Q(sig00000064)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000005 (
    .C(clk),
    .D(sig0000005e),
    .Q(sig00000065)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000006 (
    .C(clk),
    .D(sig0000005f),
    .Q(sig00000066)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000007 (
    .C(clk),
    .D(sig00000060),
    .Q(sig00000067)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000008 (
    .C(clk),
    .D(sig00000061),
    .Q(sig00000068)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000009 (
    .C(clk),
    .D(sig00000062),
    .Q(sig00000069)
  );
  XORCY   blk0000000a (
    .CI(sig00000107),
    .LI(sig00000001),
    .O(sig00000105)
  );
  XORCY   blk0000000b (
    .CI(sig00000109),
    .LI(sig000000fd),
    .O(sig00000106)
  );
  MUXCY   blk0000000c (
    .CI(sig00000109),
    .DI(sig00000001),
    .S(sig000000fd),
    .O(sig00000107)
  );
  XORCY   blk0000000d (
    .CI(sig0000010b),
    .LI(sig000000fc),
    .O(sig00000108)
  );
  MUXCY   blk0000000e (
    .CI(sig0000010b),
    .DI(sig00000001),
    .S(sig000000fc),
    .O(sig00000109)
  );
  XORCY   blk0000000f (
    .CI(sig0000010d),
    .LI(sig000000fb),
    .O(sig0000010a)
  );
  MUXCY   blk00000010 (
    .CI(sig0000010d),
    .DI(sig00000001),
    .S(sig000000fb),
    .O(sig0000010b)
  );
  XORCY   blk00000011 (
    .CI(sig0000010f),
    .LI(sig000000fa),
    .O(sig0000010c)
  );
  MUXCY   blk00000012 (
    .CI(sig0000010f),
    .DI(sig00000001),
    .S(sig000000fa),
    .O(sig0000010d)
  );
  XORCY   blk00000013 (
    .CI(sig00000111),
    .LI(sig000000f9),
    .O(sig0000010e)
  );
  MUXCY   blk00000014 (
    .CI(sig00000111),
    .DI(sig00000001),
    .S(sig000000f9),
    .O(sig0000010f)
  );
  XORCY   blk00000015 (
    .CI(sig00000113),
    .LI(sig000000f8),
    .O(sig00000110)
  );
  MUXCY   blk00000016 (
    .CI(sig00000113),
    .DI(sig00000001),
    .S(sig000000f8),
    .O(sig00000111)
  );
  XORCY   blk00000017 (
    .CI(sig00000115),
    .LI(sig000000f7),
    .O(sig00000112)
  );
  MUXCY   blk00000018 (
    .CI(sig00000115),
    .DI(sig00000001),
    .S(sig000000f7),
    .O(sig00000113)
  );
  XORCY   blk00000019 (
    .CI(sig00000117),
    .LI(sig000000f6),
    .O(sig00000114)
  );
  MUXCY   blk0000001a (
    .CI(sig00000117),
    .DI(sig00000001),
    .S(sig000000f6),
    .O(sig00000115)
  );
  XORCY   blk0000001b (
    .CI(sig00000119),
    .LI(sig000000f5),
    .O(sig00000116)
  );
  MUXCY   blk0000001c (
    .CI(sig00000119),
    .DI(sig00000001),
    .S(sig000000f5),
    .O(sig00000117)
  );
  XORCY   blk0000001d (
    .CI(sig0000011b),
    .LI(sig000000f4),
    .O(sig00000118)
  );
  MUXCY   blk0000001e (
    .CI(sig0000011b),
    .DI(sig00000001),
    .S(sig000000f4),
    .O(sig00000119)
  );
  XORCY   blk0000001f (
    .CI(sig0000011d),
    .LI(sig000000f3),
    .O(sig0000011a)
  );
  MUXCY   blk00000020 (
    .CI(sig0000011d),
    .DI(sig00000001),
    .S(sig000000f3),
    .O(sig0000011b)
  );
  XORCY   blk00000021 (
    .CI(sig0000011f),
    .LI(sig000000f2),
    .O(sig0000011c)
  );
  MUXCY   blk00000022 (
    .CI(sig0000011f),
    .DI(sig00000001),
    .S(sig000000f2),
    .O(sig0000011d)
  );
  XORCY   blk00000023 (
    .CI(sig00000121),
    .LI(sig000000f1),
    .O(sig0000011e)
  );
  MUXCY   blk00000024 (
    .CI(sig00000121),
    .DI(sig00000001),
    .S(sig000000f1),
    .O(sig0000011f)
  );
  XORCY   blk00000025 (
    .CI(sig00000123),
    .LI(sig000000f0),
    .O(sig00000120)
  );
  MUXCY   blk00000026 (
    .CI(sig00000123),
    .DI(sig00000001),
    .S(sig000000f0),
    .O(sig00000121)
  );
  XORCY   blk00000027 (
    .CI(sig00000125),
    .LI(sig000000ef),
    .O(sig00000122)
  );
  MUXCY   blk00000028 (
    .CI(sig00000125),
    .DI(sig00000001),
    .S(sig000000ef),
    .O(sig00000123)
  );
  XORCY   blk00000029 (
    .CI(sig00000127),
    .LI(sig000000ee),
    .O(sig00000124)
  );
  MUXCY   blk0000002a (
    .CI(sig00000127),
    .DI(sig00000001),
    .S(sig000000ee),
    .O(sig00000125)
  );
  XORCY   blk0000002b (
    .CI(sig00000129),
    .LI(sig000000ed),
    .O(sig00000126)
  );
  MUXCY   blk0000002c (
    .CI(sig00000129),
    .DI(sig00000001),
    .S(sig000000ed),
    .O(sig00000127)
  );
  XORCY   blk0000002d (
    .CI(sig0000012b),
    .LI(sig000000ec),
    .O(sig00000128)
  );
  MUXCY   blk0000002e (
    .CI(sig0000012b),
    .DI(sig00000001),
    .S(sig000000ec),
    .O(sig00000129)
  );
  XORCY   blk0000002f (
    .CI(sig0000012d),
    .LI(sig000000eb),
    .O(sig0000012a)
  );
  MUXCY   blk00000030 (
    .CI(sig0000012d),
    .DI(sig00000001),
    .S(sig000000eb),
    .O(sig0000012b)
  );
  XORCY   blk00000031 (
    .CI(sig0000012f),
    .LI(sig000000ea),
    .O(sig0000012c)
  );
  MUXCY   blk00000032 (
    .CI(sig0000012f),
    .DI(sig00000001),
    .S(sig000000ea),
    .O(sig0000012d)
  );
  XORCY   blk00000033 (
    .CI(sig00000131),
    .LI(sig000000e9),
    .O(sig0000012e)
  );
  MUXCY   blk00000034 (
    .CI(sig00000131),
    .DI(sig00000001),
    .S(sig000000e9),
    .O(sig0000012f)
  );
  XORCY   blk00000035 (
    .CI(sig00000133),
    .LI(sig000000e8),
    .O(sig00000130)
  );
  MUXCY   blk00000036 (
    .CI(sig00000133),
    .DI(sig00000001),
    .S(sig000000e8),
    .O(sig00000131)
  );
  XORCY   blk00000037 (
    .CI(sig00000135),
    .LI(sig000000e7),
    .O(sig00000132)
  );
  MUXCY   blk00000038 (
    .CI(sig00000135),
    .DI(sig00000001),
    .S(sig000000e7),
    .O(sig00000133)
  );
  XORCY   blk00000039 (
    .CI(sig00000137),
    .LI(sig000000e6),
    .O(sig00000134)
  );
  MUXCY   blk0000003a (
    .CI(sig00000137),
    .DI(sig00000001),
    .S(sig000000e6),
    .O(sig00000135)
  );
  XORCY   blk0000003b (
    .CI(sig00000139),
    .LI(sig000000e5),
    .O(sig00000136)
  );
  MUXCY   blk0000003c (
    .CI(sig00000139),
    .DI(sig00000001),
    .S(sig000000e5),
    .O(sig00000137)
  );
  XORCY   blk0000003d (
    .CI(sig0000013b),
    .LI(sig000000e4),
    .O(sig00000138)
  );
  MUXCY   blk0000003e (
    .CI(sig0000013b),
    .DI(sig00000001),
    .S(sig000000e4),
    .O(sig00000139)
  );
  XORCY   blk0000003f (
    .CI(sig0000013d),
    .LI(sig000000e3),
    .O(sig0000013a)
  );
  MUXCY   blk00000040 (
    .CI(sig0000013d),
    .DI(sig00000001),
    .S(sig000000e3),
    .O(sig0000013b)
  );
  XORCY   blk00000041 (
    .CI(sig0000013f),
    .LI(sig000000e2),
    .O(sig0000013c)
  );
  MUXCY   blk00000042 (
    .CI(sig0000013f),
    .DI(sig00000001),
    .S(sig000000e2),
    .O(sig0000013d)
  );
  XORCY   blk00000043 (
    .CI(sig00000141),
    .LI(sig000000e1),
    .O(sig0000013e)
  );
  MUXCY   blk00000044 (
    .CI(sig00000141),
    .DI(sig00000001),
    .S(sig000000e1),
    .O(sig0000013f)
  );
  XORCY   blk00000045 (
    .CI(sig00000143),
    .LI(sig000000e0),
    .O(sig00000140)
  );
  MUXCY   blk00000046 (
    .CI(sig00000143),
    .DI(sig00000001),
    .S(sig000000e0),
    .O(sig00000141)
  );
  XORCY   blk00000047 (
    .CI(a[31]),
    .LI(sig000000df),
    .O(sig00000142)
  );
  MUXCY   blk00000048 (
    .CI(a[31]),
    .DI(sig00000001),
    .S(sig000000df),
    .O(sig00000143)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000049 (
    .C(clk),
    .D(sig00000105),
    .Q(sig000000de)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004a (
    .C(clk),
    .D(sig00000106),
    .Q(sig000000dd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004b (
    .C(clk),
    .D(sig00000108),
    .Q(sig000000dc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004c (
    .C(clk),
    .D(sig0000010a),
    .Q(sig000000db)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004d (
    .C(clk),
    .D(sig0000010c),
    .Q(sig000000da)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004e (
    .C(clk),
    .D(sig0000010e),
    .Q(sig000000d9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000004f (
    .C(clk),
    .D(sig00000110),
    .Q(sig000000d8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000050 (
    .C(clk),
    .D(sig00000112),
    .Q(sig000000d7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000051 (
    .C(clk),
    .D(sig00000114),
    .Q(sig000000d6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000052 (
    .C(clk),
    .D(sig00000116),
    .Q(sig000000d5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000053 (
    .C(clk),
    .D(sig00000118),
    .Q(sig000000d4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000054 (
    .C(clk),
    .D(sig0000011a),
    .Q(sig000000d3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000055 (
    .C(clk),
    .D(sig0000011c),
    .Q(sig000000d2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000056 (
    .C(clk),
    .D(sig0000011e),
    .Q(sig000000d1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000057 (
    .C(clk),
    .D(sig00000120),
    .Q(sig000000d0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000058 (
    .C(clk),
    .D(sig00000122),
    .Q(sig000000cf)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000059 (
    .C(clk),
    .D(sig00000124),
    .Q(sig000000ce)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005a (
    .C(clk),
    .D(sig00000126),
    .Q(sig000000cd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005b (
    .C(clk),
    .D(sig00000128),
    .Q(sig000000cc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005c (
    .C(clk),
    .D(sig0000012a),
    .Q(sig000000cb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005d (
    .C(clk),
    .D(sig0000012c),
    .Q(sig000000ca)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005e (
    .C(clk),
    .D(sig0000012e),
    .Q(sig000000c9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000005f (
    .C(clk),
    .D(sig00000130),
    .Q(sig000000c8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000060 (
    .C(clk),
    .D(sig00000132),
    .Q(sig000000c7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000061 (
    .C(clk),
    .D(sig00000134),
    .Q(sig000000c6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000062 (
    .C(clk),
    .D(sig00000136),
    .Q(sig000000c5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000063 (
    .C(clk),
    .D(sig00000138),
    .Q(sig000000c4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000064 (
    .C(clk),
    .D(sig0000013a),
    .Q(sig000000c3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000065 (
    .C(clk),
    .D(sig0000013c),
    .Q(sig000000c2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000066 (
    .C(clk),
    .D(sig0000013e),
    .Q(sig000000c1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000067 (
    .C(clk),
    .D(sig00000140),
    .Q(sig000000c0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000068 (
    .C(clk),
    .D(sig00000142),
    .Q(sig000000bf)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000069 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000025),
    .Q(sig00000009)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006a (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000026),
    .Q(sig0000000a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006b (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000027),
    .Q(sig0000000b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000028),
    .Q(sig0000000c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006d (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000029),
    .Q(sig0000000d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006e (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002a),
    .Q(sig0000000e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000006f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002b),
    .Q(sig0000000f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000070 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002c),
    .Q(sig00000010)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000071 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002d),
    .Q(sig00000011)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000072 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002e),
    .Q(sig00000012)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000073 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000002f),
    .Q(sig00000013)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000074 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000030),
    .Q(sig00000014)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000075 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000031),
    .Q(sig00000015)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000076 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000032),
    .Q(sig00000016)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000077 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000033),
    .Q(sig00000017)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000078 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000034),
    .Q(sig00000018)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000079 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000035),
    .Q(sig00000019)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007a (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000036),
    .Q(sig0000001a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007b (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000037),
    .Q(sig0000001b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000038),
    .Q(sig0000001c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007d (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000039),
    .Q(sig0000001d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007e (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003a),
    .Q(sig0000001e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000007f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003b),
    .Q(sig0000001f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000080 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003c),
    .Q(sig00000020)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000081 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003d),
    .Q(sig00000021)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000082 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003e),
    .Q(sig00000172)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000083 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000003f),
    .Q(sig00000022)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000084 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000040),
    .Q(sig00000173)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000085 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000041),
    .Q(sig00000023)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000086 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000042),
    .Q(sig00000174)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000087 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000043),
    .Q(sig00000024)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000088 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000044),
    .Q(sig00000081)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000089 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000045),
    .Q(sig00000082)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008a (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000046),
    .Q(sig00000083)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008b (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000047),
    .Q(sig00000084)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000048),
    .Q(sig00000085)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008d (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000049),
    .Q(sig00000086)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008e (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004a),
    .Q(sig00000087)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000008f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004b),
    .Q(sig00000088)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000090 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004c),
    .Q(sig00000089)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000091 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004d),
    .Q(sig0000008a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000092 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004e),
    .Q(sig0000008b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000093 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000004f),
    .Q(sig0000008c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000094 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000050),
    .Q(sig0000008d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000095 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000051),
    .Q(sig0000008e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000096 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000052),
    .Q(sig0000008f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000097 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000053),
    .Q(sig00000090)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000098 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000054),
    .Q(sig00000091)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000099 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000055),
    .Q(sig00000092)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009a (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000056),
    .Q(sig00000093)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009b (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000057),
    .Q(sig00000094)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000058),
    .Q(sig00000095)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009d (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000059),
    .Q(sig00000096)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009e (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000005a),
    .Q(sig00000097)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000009f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000005b),
    .Q(sig00000098)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000005c),
    .Q(sig00000099)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a1 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000de),
    .Q(sig000000be)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a2 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000dd),
    .Q(sig000000bd)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a3 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000dc),
    .Q(sig000000bc)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a4 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000db),
    .Q(sig000000bb)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a5 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000da),
    .Q(sig000000ba)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a6 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d9),
    .Q(sig000000b9)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a7 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d8),
    .Q(sig000000b8)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a8 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d7),
    .Q(sig000000b7)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a9 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d6),
    .Q(sig000000b6)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000aa (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d5),
    .Q(sig000000b5)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ab (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d4),
    .Q(sig000000b4)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ac (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d3),
    .Q(sig000000b3)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ad (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d2),
    .Q(sig000000b2)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ae (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d1),
    .Q(sig000000b1)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000af (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000d0),
    .Q(sig000000b0)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000cf),
    .Q(sig000000af)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b1 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000ce),
    .Q(sig000000ae)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b2 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000cd),
    .Q(sig000000ad)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b3 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000cc),
    .Q(sig000000ac)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b4 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000cb),
    .Q(sig000000ab)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b5 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000ca),
    .Q(sig000000aa)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b6 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c9),
    .Q(sig000000a9)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b7 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c8),
    .Q(sig000000a8)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b8 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c7),
    .Q(sig000000a7)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000b9 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c6),
    .Q(sig000000a6)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ba (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c5),
    .Q(sig000000a5)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000bb (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c4),
    .Q(sig000000a4)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000bc (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c3),
    .Q(sig000000a3)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000bd (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c2),
    .Q(sig000000a2)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000be (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c1),
    .Q(sig000000a1)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000bf (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000c0),
    .Q(sig000000a0)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000c0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000000bf),
    .Q(sig0000009f)
  );
  MUXF7   blk000000c1 (
    .I0(sig00000144),
    .I1(sig00000145),
    .S(sig0000009c),
    .O(sig00000146)
  );
  MUXF7   blk000000c2 (
    .I0(sig00000147),
    .I1(sig00000148),
    .S(sig0000009c),
    .O(NLW_blk000000c2_O_UNCONNECTED)
  );
  MUXF7   blk000000c3 (
    .I0(sig00000149),
    .I1(sig0000014d),
    .S(sig0000009e),
    .O(sig00000151)
  );
  MUXF7   blk000000c4 (
    .I0(sig0000014a),
    .I1(sig0000014e),
    .S(sig0000009e),
    .O(NLW_blk000000c4_O_UNCONNECTED)
  );
  MUXF7   blk000000c5 (
    .I0(sig0000014b),
    .I1(sig0000014f),
    .S(sig0000009e),
    .O(NLW_blk000000c5_O_UNCONNECTED)
  );
  MUXF7   blk000000c6 (
    .I0(sig0000014c),
    .I1(sig00000150),
    .S(sig0000009e),
    .O(NLW_blk000000c6_O_UNCONNECTED)
  );
  MUXF7   blk000000c7 (
    .I0(sig00000152),
    .I1(sig00000156),
    .S(sig0000009e),
    .O(sig0000015a)
  );
  MUXF7   blk000000c8 (
    .I0(sig00000153),
    .I1(sig00000157),
    .S(sig0000009e),
    .O(sig0000015b)
  );
  MUXF7   blk000000c9 (
    .I0(sig00000154),
    .I1(sig00000158),
    .S(sig0000009e),
    .O(sig0000015c)
  );
  MUXF7   blk000000ca (
    .I0(sig00000155),
    .I1(sig00000159),
    .S(sig0000009e),
    .O(sig0000015d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cb (
    .C(clk),
    .D(sig0000009c),
    .Q(sig00000007)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000cc (
    .C(clk),
    .D(sig0000009b),
    .Q(sig00000008)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000cd (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000146),
    .Q(sig0000016e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ce (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015a),
    .Q(sig00000171)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000cf (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015b),
    .Q(sig0000009c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000d0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015c),
    .Q(sig00000170)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000d1 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015d),
    .Q(sig0000016f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000d2 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000151),
    .Q(sig00000175)
  );
  MUXCY   blk000000d3 (
    .CI(sig00000186),
    .DI(sig00000001),
    .S(sig0000016d),
    .O(sig00000185)
  );
  MUXCY   blk000000d4 (
    .CI(sig00000187),
    .DI(sig00000001),
    .S(sig0000016c),
    .O(sig00000186)
  );
  MUXCY   blk000000d5 (
    .CI(sig00000188),
    .DI(sig00000001),
    .S(sig0000016b),
    .O(sig00000187)
  );
  MUXCY   blk000000d6 (
    .CI(sig00000189),
    .DI(sig00000001),
    .S(sig0000016a),
    .O(sig00000188)
  );
  MUXCY   blk000000d7 (
    .CI(sig0000018a),
    .DI(sig00000001),
    .S(sig00000169),
    .O(sig00000189)
  );
  MUXCY   blk000000d8 (
    .CI(sig0000018b),
    .DI(sig00000001),
    .S(sig00000168),
    .O(sig0000018a)
  );
  MUXCY   blk000000d9 (
    .CI(sig0000018c),
    .DI(sig00000001),
    .S(sig00000167),
    .O(sig0000018b)
  );
  MUXCY   blk000000da (
    .CI(NlwRenamedSig_OI_operation_rfd),
    .DI(sig00000001),
    .S(sig00000166),
    .O(sig0000018c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000db (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000185),
    .Q(sig0000017c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000dc (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000186),
    .Q(sig00000178)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000dd (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000187),
    .Q(sig00000177)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000de (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000188),
    .Q(sig00000176)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000df (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000189),
    .Q(sig0000017d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000e0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018a),
    .Q(sig0000017b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000e1 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018b),
    .Q(sig0000017a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000e2 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018c),
    .Q(sig00000179)
  );
  MUXCY   blk000000e3 (
    .CI(sig0000018e),
    .DI(sig00000001),
    .S(sig00000165),
    .O(sig0000018d)
  );
  MUXCY   blk000000e4 (
    .CI(sig0000018f),
    .DI(sig00000001),
    .S(sig00000164),
    .O(sig0000018e)
  );
  MUXCY   blk000000e5 (
    .CI(sig00000190),
    .DI(sig00000001),
    .S(sig00000163),
    .O(sig0000018f)
  );
  MUXCY   blk000000e6 (
    .CI(sig00000191),
    .DI(sig00000001),
    .S(sig00000162),
    .O(sig00000190)
  );
  MUXCY   blk000000e7 (
    .CI(sig00000192),
    .DI(sig00000001),
    .S(sig00000161),
    .O(sig00000191)
  );
  MUXCY   blk000000e8 (
    .CI(sig00000193),
    .DI(sig00000001),
    .S(sig00000160),
    .O(sig00000192)
  );
  MUXCY   blk000000e9 (
    .CI(sig00000194),
    .DI(sig00000001),
    .S(sig0000015f),
    .O(sig00000193)
  );
  MUXCY   blk000000ea (
    .CI(NlwRenamedSig_OI_operation_rfd),
    .DI(sig00000001),
    .S(sig0000015e),
    .O(sig00000194)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000eb (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018d),
    .Q(sig0000009e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ec (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018e),
    .Q(sig00000180)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ed (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000018f),
    .Q(sig0000017f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ee (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000190),
    .Q(sig0000017e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ef (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000191),
    .Q(sig00000184)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000f0 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000192),
    .Q(sig00000183)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000f1 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000193),
    .Q(sig00000182)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000f2 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000194),
    .Q(sig00000181)
  );
  MUXCY   blk000000f3 (
    .CI(NlwRenamedSig_OI_operation_rfd),
    .DI(sig00000001),
    .S(NlwRenamedSig_OI_operation_rfd),
    .O(sig00000195)
  );
  MUXCY   blk000000f4 (
    .CI(sig00000198),
    .DI(sig00000001),
    .S(sig0000019b),
    .O(sig00000197)
  );
  MUXCY   blk000000f5 (
    .CI(sig00000199),
    .DI(sig00000001),
    .S(sig0000019c),
    .O(sig00000198)
  );
  MUXCY   blk000000f6 (
    .CI(sig00000195),
    .DI(sig00000001),
    .S(sig0000019d),
    .O(sig00000199)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f7 (
    .C(clk),
    .D(sig0000019a),
    .Q(sig0000009a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f8 (
    .C(clk),
    .D(sig000001a3),
    .Q(sig0000019e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000f9 (
    .C(clk),
    .D(sig000001a4),
    .Q(sig0000019f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fa (
    .C(clk),
    .D(sig000001a5),
    .Q(sig000001a0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk000000fb (
    .C(clk),
    .D(sig000001a6),
    .Q(sig000001a1)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000fc (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000195),
    .Q(sig000001a3)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000fd (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000199),
    .Q(sig000001a4)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000fe (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000198),
    .Q(sig000001a5)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ff (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000197),
    .Q(sig000001a6)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000100 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000196),
    .Q(sig000001a2)
  );
  MUXCY   blk00000101 (
    .CI(NlwRenamedSig_OI_operation_rfd),
    .DI(sig00000001),
    .S(sig000001c4),
    .O(sig000001c1)
  );
  MUXCY   blk00000102 (
    .CI(sig000001c1),
    .DI(sig00000001),
    .S(sig00000001),
    .O(sig000001c2)
  );
  MUXCY   blk00000103 (
    .CI(sig000001c2),
    .DI(NlwRenamedSig_OI_operation_rfd),
    .S(sig000001c3),
    .O(sig000001c0)
  );
  XORCY   blk00000104 (
    .CI(sig000001c7),
    .LI(sig000001bd),
    .O(sig000001c5)
  );
  MUXCY   blk00000105 (
    .CI(sig000001c7),
    .DI(sig00000001),
    .S(sig000001bd),
    .O(sig000001bf)
  );
  XORCY   blk00000106 (
    .CI(sig000001c9),
    .LI(sig000001bc),
    .O(sig000001c6)
  );
  MUXCY   blk00000107 (
    .CI(sig000001c9),
    .DI(sig00000001),
    .S(sig000001bc),
    .O(sig000001c7)
  );
  XORCY   blk00000108 (
    .CI(sig000001cb),
    .LI(sig000001bb),
    .O(sig000001c8)
  );
  MUXCY   blk00000109 (
    .CI(sig000001cb),
    .DI(sig00000001),
    .S(sig000001bb),
    .O(sig000001c9)
  );
  XORCY   blk0000010a (
    .CI(sig000001cd),
    .LI(sig000001ba),
    .O(sig000001ca)
  );
  MUXCY   blk0000010b (
    .CI(sig000001cd),
    .DI(sig00000001),
    .S(sig000001ba),
    .O(sig000001cb)
  );
  XORCY   blk0000010c (
    .CI(sig000001cf),
    .LI(sig000001b9),
    .O(sig000001cc)
  );
  MUXCY   blk0000010d (
    .CI(sig000001cf),
    .DI(sig00000001),
    .S(sig000001b9),
    .O(sig000001cd)
  );
  XORCY   blk0000010e (
    .CI(sig000001d1),
    .LI(sig000001b8),
    .O(sig000001ce)
  );
  MUXCY   blk0000010f (
    .CI(sig000001d1),
    .DI(sig00000001),
    .S(sig000001b8),
    .O(sig000001cf)
  );
  XORCY   blk00000110 (
    .CI(sig000001d3),
    .LI(sig000001b7),
    .O(sig000001d0)
  );
  MUXCY   blk00000111 (
    .CI(sig000001d3),
    .DI(sig00000001),
    .S(sig000001b7),
    .O(sig000001d1)
  );
  XORCY   blk00000112 (
    .CI(sig000001d5),
    .LI(sig000001b6),
    .O(sig000001d2)
  );
  MUXCY   blk00000113 (
    .CI(sig000001d5),
    .DI(sig00000001),
    .S(sig000001b6),
    .O(sig000001d3)
  );
  XORCY   blk00000114 (
    .CI(sig000001d7),
    .LI(sig000001b5),
    .O(sig000001d4)
  );
  MUXCY   blk00000115 (
    .CI(sig000001d7),
    .DI(sig00000001),
    .S(sig000001b5),
    .O(sig000001d5)
  );
  XORCY   blk00000116 (
    .CI(sig000001d9),
    .LI(sig000001b4),
    .O(sig000001d6)
  );
  MUXCY   blk00000117 (
    .CI(sig000001d9),
    .DI(sig00000001),
    .S(sig000001b4),
    .O(sig000001d7)
  );
  XORCY   blk00000118 (
    .CI(sig000001db),
    .LI(sig000001b3),
    .O(sig000001d8)
  );
  MUXCY   blk00000119 (
    .CI(sig000001db),
    .DI(sig00000001),
    .S(sig000001b3),
    .O(sig000001d9)
  );
  XORCY   blk0000011a (
    .CI(sig000001c0),
    .LI(sig000001b2),
    .O(sig000001da)
  );
  MUXCY   blk0000011b (
    .CI(sig000001c0),
    .DI(sig00000001),
    .S(sig000001b2),
    .O(sig000001db)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000011c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001da),
    .Q(sig0000006a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000011d (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001d8),
    .Q(sig0000006b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000011e (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001d6),
    .Q(sig0000006c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000011f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001d4),
    .Q(sig0000006d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000120 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001d2),
    .Q(sig0000006e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000121 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001d0),
    .Q(sig0000006f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000122 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001ce),
    .Q(sig00000070)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000123 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001cc),
    .Q(sig00000071)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000124 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001ca),
    .Q(sig00000072)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000125 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001c8),
    .Q(sig00000073)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000126 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001c6),
    .Q(sig00000074)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000127 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001c5),
    .Q(sig00000075)
  );
  XORCY   blk00000128 (
    .CI(sig000001de),
    .LI(NlwRenamedSig_OI_operation_rfd),
    .O(sig000001dc)
  );
  XORCY   blk00000129 (
    .CI(sig000001e0),
    .LI(sig000001b1),
    .O(sig000001dd)
  );
  MUXCY   blk0000012a (
    .CI(sig000001e0),
    .DI(sig00000001),
    .S(sig000001b1),
    .O(sig000001de)
  );
  XORCY   blk0000012b (
    .CI(sig000001e2),
    .LI(sig000001b0),
    .O(sig000001df)
  );
  MUXCY   blk0000012c (
    .CI(sig000001e2),
    .DI(sig00000001),
    .S(sig000001b0),
    .O(sig000001e0)
  );
  XORCY   blk0000012d (
    .CI(sig000001e4),
    .LI(sig000001af),
    .O(sig000001e1)
  );
  MUXCY   blk0000012e (
    .CI(sig000001e4),
    .DI(sig00000001),
    .S(sig000001af),
    .O(sig000001e2)
  );
  XORCY   blk0000012f (
    .CI(sig000001e6),
    .LI(sig000001ae),
    .O(sig000001e3)
  );
  MUXCY   blk00000130 (
    .CI(sig000001e6),
    .DI(sig00000001),
    .S(sig000001ae),
    .O(sig000001e4)
  );
  XORCY   blk00000131 (
    .CI(sig000001e8),
    .LI(sig000001ad),
    .O(sig000001e5)
  );
  MUXCY   blk00000132 (
    .CI(sig000001e8),
    .DI(sig00000001),
    .S(sig000001ad),
    .O(sig000001e6)
  );
  XORCY   blk00000133 (
    .CI(sig000001ea),
    .LI(sig000001ac),
    .O(sig000001e7)
  );
  MUXCY   blk00000134 (
    .CI(sig000001ea),
    .DI(sig00000001),
    .S(sig000001ac),
    .O(sig000001e8)
  );
  XORCY   blk00000135 (
    .CI(sig000001ec),
    .LI(sig000001ab),
    .O(sig000001e9)
  );
  MUXCY   blk00000136 (
    .CI(sig000001ec),
    .DI(sig00000001),
    .S(sig000001ab),
    .O(sig000001ea)
  );
  XORCY   blk00000137 (
    .CI(sig000001ee),
    .LI(sig000001aa),
    .O(sig000001eb)
  );
  MUXCY   blk00000138 (
    .CI(sig000001ee),
    .DI(sig00000001),
    .S(sig000001aa),
    .O(sig000001ec)
  );
  XORCY   blk00000139 (
    .CI(sig000001f0),
    .LI(sig000001a9),
    .O(sig000001ed)
  );
  MUXCY   blk0000013a (
    .CI(sig000001f0),
    .DI(sig00000001),
    .S(sig000001a9),
    .O(sig000001ee)
  );
  XORCY   blk0000013b (
    .CI(sig000001f2),
    .LI(sig000001a8),
    .O(sig000001ef)
  );
  MUXCY   blk0000013c (
    .CI(sig000001f2),
    .DI(sig00000001),
    .S(sig000001a8),
    .O(sig000001f0)
  );
  XORCY   blk0000013d (
    .CI(sig000001bf),
    .LI(sig000001a7),
    .O(sig000001f1)
  );
  MUXCY   blk0000013e (
    .CI(sig000001bf),
    .DI(sig00000001),
    .S(sig000001a7),
    .O(sig000001f2)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000013f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001f1),
    .Q(sig00000076)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000140 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001ef),
    .Q(sig00000077)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000141 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001ed),
    .Q(sig00000078)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000142 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001eb),
    .Q(sig00000079)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000143 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001e9),
    .Q(sig0000007a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000144 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001e7),
    .Q(sig0000007b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000145 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001e5),
    .Q(sig0000007c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000146 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001e3),
    .Q(sig0000007d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000147 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001e1),
    .Q(sig0000007e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000148 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001df),
    .Q(sig0000007f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000149 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001dd),
    .Q(sig00000080)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000014a (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig000001dc),
    .Q(sig000001be)
  );
  FD   blk0000014b (
    .C(clk),
    .D(sig00000209),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [22])
  );
  FD   blk0000014c (
    .C(clk),
    .D(sig00000208),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [21])
  );
  FD   blk0000014d (
    .C(clk),
    .D(sig00000207),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [20])
  );
  FD   blk0000014e (
    .C(clk),
    .D(sig00000206),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [19])
  );
  FD   blk0000014f (
    .C(clk),
    .D(sig00000205),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [18])
  );
  FD   blk00000150 (
    .C(clk),
    .D(sig00000204),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [17])
  );
  FD   blk00000151 (
    .C(clk),
    .D(sig00000203),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [16])
  );
  FD   blk00000152 (
    .C(clk),
    .D(sig00000202),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [15])
  );
  FD   blk00000153 (
    .C(clk),
    .D(sig00000201),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [14])
  );
  FD   blk00000154 (
    .C(clk),
    .D(sig00000200),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [13])
  );
  FD   blk00000155 (
    .C(clk),
    .D(sig000001ff),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [12])
  );
  FD   blk00000156 (
    .C(clk),
    .D(sig000001fe),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [11])
  );
  FD   blk00000157 (
    .C(clk),
    .D(sig000001fd),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [10])
  );
  FD   blk00000158 (
    .C(clk),
    .D(sig000001fc),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [9])
  );
  FD   blk00000159 (
    .C(clk),
    .D(sig000001fb),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [8])
  );
  FD   blk0000015a (
    .C(clk),
    .D(sig000001fa),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [7])
  );
  FD   blk0000015b (
    .C(clk),
    .D(sig000001f9),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [6])
  );
  FD   blk0000015c (
    .C(clk),
    .D(sig000001f8),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [5])
  );
  FD   blk0000015d (
    .C(clk),
    .D(sig000001f7),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [4])
  );
  FD   blk0000015e (
    .C(clk),
    .D(sig000001f6),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [3])
  );
  FD   blk0000015f (
    .C(clk),
    .D(sig000001f5),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [2])
  );
  FD   blk00000160 (
    .C(clk),
    .D(sig000001f4),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [1])
  );
  FD   blk00000161 (
    .C(clk),
    .D(sig000001f3),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/mant_op [0])
  );
  LUT4 #(
    .INIT ( 16'h6555 ))
  blk00000162 (
    .I0(sig00000006),
    .I1(sig0000016e),
    .I2(sig00000007),
    .I3(sig00000008),
    .O(sig0000005f)
  );
  LUT5 #(
    .INIT ( 32'hBFFFFFFF ))
  blk00000163 (
    .I0(sig0000016e),
    .I1(sig00000005),
    .I2(sig00000008),
    .I3(sig00000007),
    .I4(sig00000006),
    .O(sig00000003)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000164 (
    .I0(sig00000019),
    .I1(sig00000015),
    .I2(sig00000013),
    .I3(sig00000017),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004e)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000165 (
    .I0(sig00000017),
    .I1(sig00000013),
    .I2(sig00000011),
    .I3(sig00000015),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004c)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000166 (
    .I0(sig0000001a),
    .I1(sig00000016),
    .I2(sig00000014),
    .I3(sig00000018),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004f)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000167 (
    .I0(sig00000018),
    .I1(sig00000014),
    .I2(sig00000012),
    .I3(sig00000016),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004d)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000168 (
    .I0(sig0000001b),
    .I1(sig00000017),
    .I2(sig00000015),
    .I3(sig00000019),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000050)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000169 (
    .I0(sig0000001d),
    .I1(sig00000019),
    .I2(sig00000017),
    .I3(sig0000001b),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000052)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016a (
    .I0(sig0000001c),
    .I1(sig00000018),
    .I2(sig00000016),
    .I3(sig0000001a),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000051)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016b (
    .I0(sig0000001e),
    .I1(sig0000001a),
    .I2(sig00000018),
    .I3(sig0000001c),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000053)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016c (
    .I0(sig0000001f),
    .I1(sig0000001b),
    .I2(sig00000019),
    .I3(sig0000001d),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000054)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016d (
    .I0(sig00000021),
    .I1(sig0000001d),
    .I2(sig0000001b),
    .I3(sig0000001f),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000056)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016e (
    .I0(sig00000172),
    .I1(sig0000001e),
    .I2(sig0000001c),
    .I3(sig00000020),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000057)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000016f (
    .I0(sig00000020),
    .I1(sig0000001c),
    .I2(sig0000001a),
    .I3(sig0000001e),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000055)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000170 (
    .I0(sig00000022),
    .I1(sig0000001f),
    .I2(sig0000001d),
    .I3(sig00000021),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000058)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000171 (
    .I0(sig00000173),
    .I1(sig00000020),
    .I2(sig0000001e),
    .I3(sig00000172),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000059)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000172 (
    .I0(sig00000023),
    .I1(sig00000022),
    .I2(sig00000021),
    .I3(sig0000001f),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000005a)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000173 (
    .I0(sig00000174),
    .I1(sig00000173),
    .I2(sig00000172),
    .I3(sig00000020),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000005b)
  );
  LUT6 #(
    .INIT ( 64'hAAAAF0F0CCCCFF00 ))
  blk00000174 (
    .I0(sig00000009),
    .I1(sig0000000b),
    .I2(sig0000000d),
    .I3(sig0000000f),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000044)
  );
  LUT6 #(
    .INIT ( 64'hAAAAF0F0CCCCFF00 ))
  blk00000175 (
    .I0(sig0000000a),
    .I1(sig0000000c),
    .I2(sig0000000e),
    .I3(sig00000010),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000045)
  );
  LUT6 #(
    .INIT ( 64'hAAAAFF00CCCCF0F0 ))
  blk00000176 (
    .I0(sig0000000b),
    .I1(sig0000000d),
    .I2(sig00000011),
    .I3(sig0000000f),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000046)
  );
  LUT6 #(
    .INIT ( 64'hAAAAFF00CCCCF0F0 ))
  blk00000177 (
    .I0(sig0000000c),
    .I1(sig0000000e),
    .I2(sig00000012),
    .I3(sig00000010),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000047)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000178 (
    .I0(sig00000024),
    .I1(sig00000023),
    .I2(sig00000022),
    .I3(sig00000021),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000005c)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk00000179 (
    .I0(sig00000015),
    .I1(sig00000011),
    .I2(sig0000000f),
    .I3(sig00000013),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004a)
  );
  LUT6 #(
    .INIT ( 64'hAAAAFF00F0F0CCCC ))
  blk0000017a (
    .I0(sig0000000d),
    .I1(sig00000013),
    .I2(sig0000000f),
    .I3(sig00000011),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000048)
  );
  LUT6 #(
    .INIT ( 64'hF0F0FF00CCCCAAAA ))
  blk0000017b (
    .I0(sig00000016),
    .I1(sig00000012),
    .I2(sig00000010),
    .I3(sig00000014),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig0000004b)
  );
  LUT6 #(
    .INIT ( 64'hAAAAFF00F0F0CCCC ))
  blk0000017c (
    .I0(sig0000000e),
    .I1(sig00000014),
    .I2(sig00000010),
    .I3(sig00000012),
    .I4(sig0000009c),
    .I5(sig0000009b),
    .O(sig00000049)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk0000017d (
    .I0(sig000000b7),
    .I1(sig000000af),
    .I2(sig000000a7),
    .I3(sig0000009f),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig0000003d)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk0000017e (
    .I0(sig000000b8),
    .I1(sig000000b0),
    .I2(sig000000a8),
    .I3(sig000000a0),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig0000003e)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk0000017f (
    .I0(sig000000b9),
    .I1(sig000000b1),
    .I2(sig000000a9),
    .I3(sig000000a1),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig0000003f)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000180 (
    .I0(sig000000ba),
    .I1(sig000000b2),
    .I2(sig000000aa),
    .I3(sig000000a2),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig00000040)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000181 (
    .I0(sig000000bb),
    .I1(sig000000b3),
    .I2(sig000000ab),
    .I3(sig000000a3),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig00000041)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000182 (
    .I0(sig000000bc),
    .I1(sig000000b4),
    .I2(sig000000ac),
    .I3(sig000000a4),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig00000042)
  );
  LUT6 #(
    .INIT ( 64'hFF00CCCCF0F0AAAA ))
  blk00000183 (
    .I0(sig000000bd),
    .I1(sig000000b5),
    .I2(sig000000ad),
    .I3(sig000000a5),
    .I4(sig0000009e),
    .I5(sig0000009d),
    .O(sig00000043)
  );
  LUT3 #(
    .INIT ( 8'h65 ))
  blk00000184 (
    .I0(sig00000007),
    .I1(sig0000016e),
    .I2(sig00000008),
    .O(sig00000060)
  );
  LUT5 #(
    .INIT ( 32'h44441444 ))
  blk00000185 (
    .I0(sig00000104),
    .I1(sig00000065),
    .I2(sig00000066),
    .I3(sig00000067),
    .I4(sig00000002),
    .O(sig00000101)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000186 (
    .I0(sig00000008),
    .I1(sig0000016e),
    .O(sig00000061)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000187 (
    .I0(a[0]),
    .I1(a[31]),
    .O(sig000000df)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000188 (
    .I0(a[10]),
    .I1(a[31]),
    .O(sig000000e9)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000189 (
    .I0(a[11]),
    .I1(a[31]),
    .O(sig000000ea)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018a (
    .I0(a[12]),
    .I1(a[31]),
    .O(sig000000eb)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018b (
    .I0(a[13]),
    .I1(a[31]),
    .O(sig000000ec)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018c (
    .I0(a[14]),
    .I1(a[31]),
    .O(sig000000ed)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018d (
    .I0(a[15]),
    .I1(a[31]),
    .O(sig000000ee)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018e (
    .I0(a[16]),
    .I1(a[31]),
    .O(sig000000ef)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000018f (
    .I0(a[17]),
    .I1(a[31]),
    .O(sig000000f0)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000190 (
    .I0(a[18]),
    .I1(a[31]),
    .O(sig000000f1)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000191 (
    .I0(a[19]),
    .I1(a[31]),
    .O(sig000000f2)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000192 (
    .I0(a[1]),
    .I1(a[31]),
    .O(sig000000e0)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000193 (
    .I0(a[20]),
    .I1(a[31]),
    .O(sig000000f3)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000194 (
    .I0(a[21]),
    .I1(a[31]),
    .O(sig000000f4)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000195 (
    .I0(a[22]),
    .I1(a[31]),
    .O(sig000000f5)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000196 (
    .I0(a[23]),
    .I1(a[31]),
    .O(sig000000f6)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000197 (
    .I0(a[24]),
    .I1(a[31]),
    .O(sig000000f7)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000198 (
    .I0(a[25]),
    .I1(a[31]),
    .O(sig000000f8)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000199 (
    .I0(a[26]),
    .I1(a[31]),
    .O(sig000000f9)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019a (
    .I0(a[27]),
    .I1(a[31]),
    .O(sig000000fa)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019b (
    .I0(a[28]),
    .I1(a[31]),
    .O(sig000000fb)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019c (
    .I0(a[29]),
    .I1(a[31]),
    .O(sig000000fc)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019d (
    .I0(a[2]),
    .I1(a[31]),
    .O(sig000000e1)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019e (
    .I0(a[30]),
    .I1(a[31]),
    .O(sig000000fd)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000019f (
    .I0(a[3]),
    .I1(a[31]),
    .O(sig000000e2)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a0 (
    .I0(a[4]),
    .I1(a[31]),
    .O(sig000000e3)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a1 (
    .I0(a[5]),
    .I1(a[31]),
    .O(sig000000e4)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a2 (
    .I0(a[6]),
    .I1(a[31]),
    .O(sig000000e5)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a3 (
    .I0(a[7]),
    .I1(a[31]),
    .O(sig000000e6)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a4 (
    .I0(a[8]),
    .I1(a[31]),
    .O(sig000000e7)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000001a5 (
    .I0(a[9]),
    .I1(a[31]),
    .O(sig000000e8)
  );
  LUT3 #(
    .INIT ( 8'h41 ))
  blk000001a6 (
    .I0(sig00000104),
    .I1(sig00000069),
    .I2(sig000001be),
    .O(sig00000004)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001a7 (
    .I0(sig00000184),
    .I1(sig000000be),
    .I2(sig000000b6),
    .O(sig00000149)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001a8 (
    .I0(sig00000184),
    .I1(sig000000bc),
    .I2(sig000000b4),
    .O(sig0000014a)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001a9 (
    .I0(sig00000184),
    .I1(sig000000ba),
    .I2(sig000000b2),
    .O(sig0000014b)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001aa (
    .I0(sig00000184),
    .I1(sig000000b8),
    .I2(sig000000b0),
    .O(sig0000014c)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001ab (
    .I0(sig0000017d),
    .I1(sig000000ae),
    .I2(sig000000a6),
    .O(sig0000014d)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001ac (
    .I0(sig0000017d),
    .I1(sig000000ac),
    .I2(sig000000a4),
    .O(sig0000014e)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001ad (
    .I0(sig0000017d),
    .I1(sig000000aa),
    .I2(sig000000a2),
    .O(sig0000014f)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001ae (
    .I0(sig0000017d),
    .I1(sig000000a8),
    .I2(sig000000a0),
    .O(sig00000150)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001af (
    .I0(sig00000184),
    .I1(sig00000181),
    .I2(sig0000017e),
    .O(sig00000152)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b0 (
    .I0(sig00000184),
    .I1(sig00000182),
    .I2(sig0000017f),
    .O(sig00000153)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b1 (
    .I0(sig00000184),
    .I1(sig00000183),
    .I2(sig00000180),
    .O(sig00000154)
  );
  LUT2 #(
    .INIT ( 4'h8 ))
  blk000001b2 (
    .I0(sig00000184),
    .I1(sig0000009e),
    .O(sig00000155)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b3 (
    .I0(sig0000017d),
    .I1(sig00000179),
    .I2(sig00000176),
    .O(sig00000156)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b4 (
    .I0(sig0000017d),
    .I1(sig0000017a),
    .I2(sig00000177),
    .O(sig00000157)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b5 (
    .I0(sig0000017d),
    .I1(sig0000017b),
    .I2(sig00000178),
    .O(sig00000158)
  );
  LUT2 #(
    .INIT ( 4'h8 ))
  blk000001b6 (
    .I0(sig0000017d),
    .I1(sig0000017c),
    .O(sig00000159)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001b7 (
    .I0(sig0000017d),
    .I1(sig00000184),
    .I2(sig0000009e),
    .O(sig0000009d)
  );
  LUT3 #(
    .INIT ( 8'hD8 ))
  blk000001b8 (
    .I0(sig0000020c),
    .I1(sig00000170),
    .I2(sig00000171),
    .O(sig0000009b)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001b9 (
    .I0(sig00000171),
    .I1(sig00000175),
    .I2(sig00000174),
    .O(sig00000144)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001ba (
    .I0(sig00000170),
    .I1(sig00000173),
    .I2(sig00000172),
    .O(sig00000145)
  );
  LUT2 #(
    .INIT ( 4'h8 ))
  blk000001bb (
    .I0(sig0000009c),
    .I1(sig00000171),
    .O(sig00000147)
  );
  LUT2 #(
    .INIT ( 4'h8 ))
  blk000001bc (
    .I0(sig0000016f),
    .I1(sig00000170),
    .O(sig00000148)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001bd (
    .I0(sig000000de),
    .I1(sig000000dd),
    .O(sig0000015e)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001be (
    .I0(sig000000dc),
    .I1(sig000000db),
    .O(sig0000015f)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001bf (
    .I0(sig000000da),
    .I1(sig000000d9),
    .O(sig00000160)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c0 (
    .I0(sig000000d8),
    .I1(sig000000d7),
    .O(sig00000161)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c1 (
    .I0(sig000000d6),
    .I1(sig000000d5),
    .O(sig00000162)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c2 (
    .I0(sig000000d4),
    .I1(sig000000d3),
    .O(sig00000163)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c3 (
    .I0(sig000000d2),
    .I1(sig000000d1),
    .O(sig00000164)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c4 (
    .I0(sig000000d0),
    .I1(sig000000cf),
    .O(sig00000165)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c5 (
    .I0(sig000000ce),
    .I1(sig000000cd),
    .O(sig00000166)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c6 (
    .I0(sig000000cc),
    .I1(sig000000cb),
    .O(sig00000167)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c7 (
    .I0(sig000000ca),
    .I1(sig000000c9),
    .O(sig00000168)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c8 (
    .I0(sig000000c8),
    .I1(sig000000c7),
    .O(sig00000169)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001c9 (
    .I0(sig000000c6),
    .I1(sig000000c5),
    .O(sig0000016a)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001ca (
    .I0(sig000000c4),
    .I1(sig000000c3),
    .O(sig0000016b)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001cb (
    .I0(sig000000c2),
    .I1(sig000000c1),
    .O(sig0000016c)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001cc (
    .I0(sig000000c0),
    .I1(sig000000bf),
    .O(sig0000016d)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001cd (
    .I0(sig000000c3),
    .I1(sig000000c4),
    .O(sig0000019b)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001ce (
    .I0(sig000000c1),
    .I1(sig000000c2),
    .O(sig0000019c)
  );
  LUT2 #(
    .INIT ( 4'h1 ))
  blk000001cf (
    .I0(sig000000bf),
    .I1(sig000000c0),
    .O(sig0000019d)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d0 (
    .I0(sig0000008f),
    .I1(sig0000008e),
    .I2(sig0000016e),
    .O(sig000001a7)
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  blk000001d1 (
    .I0(sig0000016e),
    .I1(sig00000098),
    .I2(sig00000099),
    .O(sig000001b1)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d2 (
    .I0(sig00000090),
    .I1(sig0000008f),
    .I2(sig0000016e),
    .O(sig000001a8)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d3 (
    .I0(sig00000091),
    .I1(sig00000090),
    .I2(sig0000016e),
    .O(sig000001a9)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d4 (
    .I0(sig00000092),
    .I1(sig00000091),
    .I2(sig0000016e),
    .O(sig000001aa)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d5 (
    .I0(sig00000093),
    .I1(sig00000092),
    .I2(sig0000016e),
    .O(sig000001ab)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d6 (
    .I0(sig00000094),
    .I1(sig00000093),
    .I2(sig0000016e),
    .O(sig000001ac)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d7 (
    .I0(sig00000095),
    .I1(sig00000094),
    .I2(sig0000016e),
    .O(sig000001ad)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d8 (
    .I0(sig00000096),
    .I1(sig00000095),
    .I2(sig0000016e),
    .O(sig000001ae)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001d9 (
    .I0(sig00000097),
    .I1(sig00000096),
    .I2(sig0000016e),
    .O(sig000001af)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001da (
    .I0(sig00000098),
    .I1(sig00000097),
    .I2(sig0000016e),
    .O(sig000001b0)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001db (
    .I0(sig00000083),
    .I1(sig00000082),
    .I2(sig0000016e),
    .O(sig000001b2)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001dc (
    .I0(sig0000008d),
    .I1(sig0000008c),
    .I2(sig0000016e),
    .O(sig000001bc)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001dd (
    .I0(sig0000008e),
    .I1(sig0000008d),
    .I2(sig0000016e),
    .O(sig000001bd)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001de (
    .I0(sig00000084),
    .I1(sig00000083),
    .I2(sig0000016e),
    .O(sig000001b3)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001df (
    .I0(sig00000085),
    .I1(sig00000084),
    .I2(sig0000016e),
    .O(sig000001b4)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e0 (
    .I0(sig00000086),
    .I1(sig00000085),
    .I2(sig0000016e),
    .O(sig000001b5)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e1 (
    .I0(sig00000087),
    .I1(sig00000086),
    .I2(sig0000016e),
    .O(sig000001b6)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e2 (
    .I0(sig00000088),
    .I1(sig00000087),
    .I2(sig0000016e),
    .O(sig000001b7)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e3 (
    .I0(sig00000089),
    .I1(sig00000088),
    .I2(sig0000016e),
    .O(sig000001b8)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e4 (
    .I0(sig0000008a),
    .I1(sig00000089),
    .I2(sig0000016e),
    .O(sig000001b9)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e5 (
    .I0(sig0000008b),
    .I1(sig0000008a),
    .I2(sig0000016e),
    .O(sig000001ba)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk000001e6 (
    .I0(sig0000008c),
    .I1(sig0000008b),
    .I2(sig0000016e),
    .O(sig000001bb)
  );
  LUT5 #(
    .INIT ( 32'h0F2F3B3B ))
  blk000001e7 (
    .I0(sig0000009a),
    .I1(sig00000081),
    .I2(sig00000082),
    .I3(sig00000083),
    .I4(sig0000016e),
    .O(sig000001c3)
  );
  LUT3 #(
    .INIT ( 8'hFB ))
  blk000001e8 (
    .I0(sig00000082),
    .I1(sig0000009a),
    .I2(sig00000081),
    .O(sig000001c4)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001e9 (
    .I0(sig00000104),
    .I1(sig0000006a),
    .O(sig000001f3)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ea (
    .I0(sig00000104),
    .I1(sig0000006b),
    .O(sig000001f4)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001eb (
    .I0(sig00000104),
    .I1(sig0000006d),
    .O(sig000001f6)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ec (
    .I0(sig00000104),
    .I1(sig0000006e),
    .O(sig000001f7)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ed (
    .I0(sig00000104),
    .I1(sig0000006c),
    .O(sig000001f5)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ee (
    .I0(sig00000104),
    .I1(sig00000070),
    .O(sig000001f9)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ef (
    .I0(sig00000104),
    .I1(sig00000071),
    .O(sig000001fa)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f0 (
    .I0(sig00000104),
    .I1(sig0000006f),
    .O(sig000001f8)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f1 (
    .I0(sig00000104),
    .I1(sig00000073),
    .O(sig000001fc)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f2 (
    .I0(sig00000104),
    .I1(sig00000074),
    .O(sig000001fd)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f3 (
    .I0(sig00000104),
    .I1(sig00000072),
    .O(sig000001fb)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f4 (
    .I0(sig00000104),
    .I1(sig00000076),
    .O(sig000001ff)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f5 (
    .I0(sig00000104),
    .I1(sig00000077),
    .O(sig00000200)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f6 (
    .I0(sig00000104),
    .I1(sig00000075),
    .O(sig000001fe)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f7 (
    .I0(sig00000104),
    .I1(sig00000079),
    .O(sig00000202)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f8 (
    .I0(sig00000104),
    .I1(sig0000007a),
    .O(sig00000203)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001f9 (
    .I0(sig00000104),
    .I1(sig00000078),
    .O(sig00000201)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001fa (
    .I0(sig00000104),
    .I1(sig0000007c),
    .O(sig00000205)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001fb (
    .I0(sig00000104),
    .I1(sig0000007d),
    .O(sig00000206)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001fc (
    .I0(sig00000104),
    .I1(sig0000007b),
    .O(sig00000204)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001fd (
    .I0(sig00000104),
    .I1(sig0000007f),
    .O(sig00000208)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001fe (
    .I0(sig00000104),
    .I1(sig0000007e),
    .O(sig00000207)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  blk000001ff (
    .I0(sig00000104),
    .I1(sig00000080),
    .O(sig00000209)
  );
  LUT3 #(
    .INIT ( 8'hAC ))
  blk00000200 (
    .I0(sig0000019e),
    .I1(sig000001a0),
    .I2(sig0000020d),
    .O(sig0000020a)
  );
  LUT6 #(
    .INIT ( 64'hFFFFAAAAFAEEFAEE ))
  blk00000201 (
    .I0(sig000001a2),
    .I1(sig000001a1),
    .I2(sig0000019f),
    .I3(sig0000009c),
    .I4(sig0000020a),
    .I5(sig0000009b),
    .O(sig0000019a)
  );
  FD   blk00000202 (
    .C(clk),
    .D(sig00000103),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[7] )
  );
  FD   blk00000203 (
    .C(clk),
    .D(sig00000102),
    .Q(\NlwRenamedSignal_U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op [6])
  );
  FD   blk00000204 (
    .C(clk),
    .D(sig00000101),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[4] )
  );
  FD   blk00000205 (
    .C(clk),
    .D(sig00000100),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[3] )
  );
  FD   blk00000206 (
    .C(clk),
    .D(sig000000ff),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[2] )
  );
  FD   blk00000207 (
    .C(clk),
    .D(sig000000fe),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[1] )
  );
  FD   blk00000208 (
    .C(clk),
    .D(sig00000004),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/exp_op[0] )
  );
  LUT6 #(
    .INIT ( 64'h2222222202222222 ))
  blk00000209 (
    .I0(sig00000064),
    .I1(sig00000104),
    .I2(sig00000066),
    .I3(sig00000067),
    .I4(sig00000065),
    .I5(sig00000002),
    .O(sig00000102)
  );
  LUT4 #(
    .INIT ( 16'hFFDF ))
  blk0000020a (
    .I0(sig00000069),
    .I1(sig000001be),
    .I2(sig00000068),
    .I3(sig00000104),
    .O(sig00000002)
  );
  LUT4 #(
    .INIT ( 16'h7FFF ))
  blk0000020b (
    .I0(sig00000066),
    .I1(sig00000067),
    .I2(sig00000068),
    .I3(sig00000069),
    .O(sig0000020b)
  );
  LUT6 #(
    .INIT ( 64'h4444441444444444 ))
  blk0000020c (
    .I0(sig00000104),
    .I1(sig00000063),
    .I2(sig00000064),
    .I3(sig000001be),
    .I4(sig0000020b),
    .I5(sig00000065),
    .O(sig00000103)
  );
  LUT5 #(
    .INIT ( 32'h55559555 ))
  blk0000020d (
    .I0(sig00000005),
    .I1(sig00000006),
    .I2(sig00000008),
    .I3(sig00000007),
    .I4(sig0000016e),
    .O(sig0000005e)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk0000020e (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a6),
    .I3(sig000000ae),
    .O(sig00000034)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk0000020f (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a2),
    .I3(sig000000aa),
    .O(sig00000030)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000210 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a4),
    .I3(sig000000ac),
    .O(sig00000032)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000211 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a1),
    .I3(sig000000a9),
    .O(sig0000002f)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000212 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a0),
    .I3(sig000000a8),
    .O(sig0000002e)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000213 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a5),
    .I3(sig000000ad),
    .O(sig00000033)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000214 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig0000009f),
    .I3(sig000000a7),
    .O(sig0000002d)
  );
  LUT4 #(
    .INIT ( 16'h5140 ))
  blk00000215 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a3),
    .I3(sig000000ab),
    .O(sig00000031)
  );
  LUT4 #(
    .INIT ( 16'h4144 ))
  blk00000216 (
    .I0(sig00000104),
    .I1(sig00000068),
    .I2(sig000001be),
    .I3(sig00000069),
    .O(sig000000fe)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk00000217 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a6),
    .O(sig0000002c)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk00000218 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a5),
    .O(sig0000002b)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk00000219 (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a3),
    .O(sig00000029)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk0000021a (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a2),
    .O(sig00000028)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk0000021b (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a4),
    .O(sig0000002a)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk0000021c (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a0),
    .O(sig00000026)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk0000021d (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig000000a1),
    .O(sig00000027)
  );
  LUT3 #(
    .INIT ( 8'h10 ))
  blk0000021e (
    .I0(sig0000009e),
    .I1(sig00000184),
    .I2(sig0000009f),
    .O(sig00000025)
  );
  LUT2 #(
    .INIT ( 4'hE ))
  blk0000021f (
    .I0(sig0000009e),
    .I1(sig00000184),
    .O(sig00000196)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000220 (
    .I0(sig000000af),
    .I1(sig000000a7),
    .I2(sig0000009f),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig00000035)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000221 (
    .I0(sig000000b0),
    .I1(sig000000a8),
    .I2(sig000000a0),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig00000036)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000222 (
    .I0(sig000000b1),
    .I1(sig000000a9),
    .I2(sig000000a1),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig00000037)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000223 (
    .I0(sig000000b2),
    .I1(sig000000aa),
    .I2(sig000000a2),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig00000038)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000224 (
    .I0(sig000000b3),
    .I1(sig000000ab),
    .I2(sig000000a3),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig00000039)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000225 (
    .I0(sig000000b4),
    .I1(sig000000ac),
    .I2(sig000000a4),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig0000003a)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000226 (
    .I0(sig000000b5),
    .I1(sig000000ad),
    .I2(sig000000a5),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig0000003b)
  );
  LUT6 #(
    .INIT ( 64'h00F000F0CCCCAAAA ))
  blk00000227 (
    .I0(sig000000b6),
    .I1(sig000000ae),
    .I2(sig000000a6),
    .I3(sig0000017d),
    .I4(sig00000184),
    .I5(sig0000009e),
    .O(sig0000003c)
  );
  LUT5 #(
    .INIT ( 32'h44441444 ))
  blk00000228 (
    .I0(sig00000104),
    .I1(sig00000067),
    .I2(sig00000069),
    .I3(sig00000068),
    .I4(sig000001be),
    .O(sig000000ff)
  );
  LUT6 #(
    .INIT ( 64'h4444444414444444 ))
  blk00000229 (
    .I0(sig00000104),
    .I1(sig00000066),
    .I2(sig00000069),
    .I3(sig00000068),
    .I4(sig00000067),
    .I5(sig000001be),
    .O(sig00000100)
  );
  LUT5 #(
    .INIT ( 32'h40000000 ))
  blk0000022a (
    .I0(sig0000016e),
    .I1(sig00000005),
    .I2(sig00000008),
    .I3(sig00000007),
    .I4(sig00000006),
    .O(sig0000005d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000022b (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015b),
    .Q(sig0000020c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000022c (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000015b),
    .Q(sig0000020d)
  );
  INV   blk0000022d (
    .I(sig0000016e),
    .O(sig00000062)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk0000022e (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(sig00000001),
    .A3(sig00000001),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .CLK(clk),
    .D(sig0000009d),
    .Q(sig0000020e),
    .Q15(NLW_blk0000022e_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk0000022f (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000020e),
    .Q(sig00000006)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000230 (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(sig00000001),
    .A3(sig00000001),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .CLK(clk),
    .D(sig0000016f),
    .Q(sig0000020f),
    .Q15(NLW_blk00000230_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000231 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig0000020f),
    .Q(sig00000104)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000232 (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(sig00000001),
    .A3(sig00000001),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .CLK(clk),
    .D(sig0000009e),
    .Q(sig00000210),
    .Q15(NLW_blk00000232_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000233 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000210),
    .Q(sig00000005)
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000234 (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(NlwRenamedSig_OI_operation_rfd),
    .A3(sig00000001),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .CLK(clk),
    .D(a[31]),
    .Q(sig00000211),
    .Q15(NLW_blk00000234_Q15_UNCONNECTED)
  );
  FDE   blk00000235 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000211),
    .Q(\U0/op_inst/FLT_PT_OP/FIX_TO_FLT_OP.SPD.OP/OP/sign_op )
  );
  SRLC16E #(
    .INIT ( 16'h0000 ))
  blk00000236 (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(NlwRenamedSig_OI_operation_rfd),
    .A3(sig00000001),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .CLK(clk),
    .D(operation_nd),
    .Q(sig00000212),
    .Q15(NLW_blk00000236_Q15_UNCONNECTED)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk00000237 (
    .C(clk),
    .CE(NlwRenamedSig_OI_operation_rfd),
    .D(sig00000212),
    .Q(\U0/op_inst/FLT_PT_OP/HND_SHK/RDY )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
