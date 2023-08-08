`timescale 1ns/1ps
`include "vedic_16x16.v"
`include "add_32_bit.v"
`include "add_48_bit.v"

module vedic_32x32(a,b,c);
input [31:0]a;
input [31:0]b;
output [63:0]c;

wire [31:0]q0;	
wire [31:0]q1;	
wire [31:0]q2;
wire [31:0]q3;	
wire [63:0]c;
wire [31:0]temp1;
wire [47:0]temp2;
wire [47:0]temp3;
wire [47:0]temp4;
wire [31:0]q4;
wire [47:0]q5;
wire [47:0]q6;
// using 4 16x16 multipliers
vedic_16x16 z1(a[15:0],b[15:0],q0[31:0]);
vedic_16x16 z2(a[31:16],b[15:0],q1[31:0]);
vedic_16x16 z3(a[15:0],b[31:16],q2[31:0]);
vedic_16x16 z4(a[31:16],b[31:16],q3[31:0]);

// stage 1 adders 
assign temp1 ={16'b0,q0[31:16]};
add_32_bit z5(q1[31:0],temp1,q4);
assign temp2 ={16'b0,q2[31:0]};
assign temp3 ={q3[31:0],16'b0};
add_48_bit z6(temp2,temp3,q5);
assign temp4={16'b0,q4[31:0]};

//stage 2 adder
add_48_bit z7(temp4,q5,q6);
// fnal output assignment 
assign c[15:0]=q0[15:0];
assign c[63:16]=q6[47:0];

endmodule 