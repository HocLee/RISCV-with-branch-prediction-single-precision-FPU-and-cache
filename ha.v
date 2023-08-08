`timescale 1ns / 1ps
module ha(a, b, sum, carry);
// a and b are inputs
    input a;
    input b;
    output sum;
    output carry;
    assign carry=a&b;
    assign sum=a^b;
endmodule
