`timescale 1ns/10ps
`include "vedic_32x32.v"

module mul (
    input  wire [31:0] a_in,
    input  wire [31:0] b_in,
    output reg         result_sign,
    output reg  [8:0]  result_exp,

    output      [48:0] result_man
//    output reg  [48:0] result_man
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    reg         a_sign; 
    reg         b_sign; 
    reg  [8:0]  a_exp;
    reg  [8:0]  b_exp;  
    reg  [23:0] a_man;
    reg  [23:0] b_man;
    
    wire [23:0] a_man_w;
    wire [23:0] b_man_w;
    wire [63:0] mul_result_man;
//    reg  [48:0] mul_result_man;
    
//=======================================================
//  Behavioral coding
//=======================================================

    always@(*) begin  
        a_sign = a_in[31];
        a_exp  = {1'b0,a_in[30:23]};
        b_sign = b_in[31];
        b_exp  = {1'b0,b_in[30:23]};

//if exp of input is equal to 8'b0, add hidden bit = 0 before mantissa. If not, add 1
        a_man  = {|a_exp,a_in[22:0]}; 
        b_man  = {|b_exp,b_in[22:0]};
        result_sign = a_sign ^ b_sign;

/* if there is any denormalized number in input, add the bias 126 to the sum
of two exponents. If not, add the bias 127*/

        if (a_man[23] == 1'b1 && b_man[23] == 1'b1) begin
            result_exp  = a_exp  + b_exp - 'd127;
        end
        else begin
            result_exp  = a_exp + b_exp - 'd126;
        end

    //    mul_result_man  = a_man * b_man;
    //    result_man      = mul_result_man << 1;

    end

    assign a_man_w = a_man;
    assign b_man_w = b_man;

    vedic_32x32 vedic_mul (
        .a ({8'd0,a_man_w}),
        .b ({8'd0,b_man_w}),
        .c ({mul_result_man})
    );

    assign result_man = mul_result_man[48:0] << 1;


endmodule