`timescale 1ns/1ps
//`include "half_adder.v"
//`include "full_adder.v"
module add_16_bit(input1,input2,answer);
parameter N=16;
input [N-1:0] input1,input2;
   output [N-1:0] answer;
//   wire  carry_out;
  wire [N-1:0] carry;
   genvar i;
   generate 
   for(i=0;i<N;i=i+1)
     begin: generate_N_bit_Adder
   if(i==0) 
  half_adder f(input1[0],input2[0],answer[0],carry[0]);
   else
  full_adder f(input1[i],input2[i],carry[i-1],answer[i],carry[i]);
     end
//  assign carry_out = carry[N-1];
   endgenerate
endmodule 
