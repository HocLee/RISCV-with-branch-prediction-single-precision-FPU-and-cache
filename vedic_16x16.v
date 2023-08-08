`timescale 1ns/1ps
`include "vedic_8x8.v"
`include "add_16_bit.v"
`include "add_24_bit.v"

module vedic_16x16(a,b,c);
input [15:0]a;
input [15:0]b;
output [31:0]c;

wire [15:0]q0;	
wire [15:0]q1;	
wire [15:0]q2;
wire [15:0]q3;	
wire [31:0]c;
wire [15:0]temp1;
wire [23:0]temp2;
wire [23:0]temp3;
wire [23:0]temp4;
wire [15:0]q4;
wire [23:0]q5;
wire [23:0]q6;
// using 4 8x8 multipliers
vedic_8x8 z1(a[7:0],b[7:0],q0[15:0]);
vedic_8x8 z2(a[15:8],b[7:0],q1[15:0]);
vedic_8x8 z3(a[7:0],b[15:8],q2[15:0]);
vedic_8x8 z4(a[15:8],b[15:8],q3[15:0]);

// stage 1 adders 
assign temp1 ={8'b0,q0[15:8]};
add_16_bit z5(q1[15:0],temp1,q4);
assign temp2 ={8'b0,q2[15:0]};
assign temp3 ={q3[15:0],8'b0};
add_24_bit z6(temp2,temp3,q5);
assign temp4={8'b0,q4[15:0]};

//stage 2 adder
add_24_bit z7(temp4,q5,q6);
// fnal output assignment 
assign c[7:0]=q0[7:0];
assign c[31:8]=q6[23:0];


endmodule