`timescale 1ns/10ps
module add_sub (
   input  wire [31:0] a_in,
   input  wire [31:0] b_in, 
   input  wire [1:0]  sel,
   output reg         result_sign,
   output reg  [8:0]  result_exp,
   output reg  [48:0] result_man,

   output wire         done_add_sub
);
//=======================================================
//  REG/WIRE declarations
//=======================================================  
    reg        a_sign;
    reg        b_sign;
    reg        new_b_sign;  
    reg [8:0]  a_exp;
    reg [8:0]  b_exp;
    reg [48:0] a_man;
    reg [48:0] b_man;
    reg [8:0]  exp_diff;
    reg [7:0]  abs_exp_diff;
    reg [48:0] larger_man;
    reg [48:0] smaller_man; 
    reg [48:0] new_smaller_man;

    assign done_add_sub = !(&(sel)); // add_sub always finish calculating in 1 clk

//=======================================================
//  Behavioral coding
//=======================================================


    always@(*) begin   
        a_sign = a_in[31];
        a_exp  = {1'b0,a_in[30:23]};
        b_sign = b_in[31];
        b_exp  = {1'b0,b_in[30:23]};

//if exp of input is equal to 8'b0, add hidden bit = 0 before mantissa. If not, add 1
        a_man  = {1'b0,|a_exp,a_in[22:0],24'b0}; 
        b_man  = {1'b0,|b_exp,b_in[22:0],24'b0};
 
    
  
//compare two floating point number and match exponent
        new_b_sign = b_sign ^ |sel;
        
        if(a_exp == b_exp) begin
            if(a_man == b_man) begin
                result_sign = a_sign;
                result_exp  = a_exp;
                larger_man  = a_man;
                smaller_man = b_man;
            end
            else begin
            if (a_man > b_man) begin
                result_sign = a_sign;
                result_exp  = a_exp;
                larger_man  = a_man;
                smaller_man = b_man;
            end
            else begin
                result_sign = new_b_sign;
                result_exp  = a_exp;
                larger_man  = b_man;
                smaller_man = a_man;
                end
            end  
        end  
        else begin
            if(a_exp > b_exp) begin
                result_sign = a_sign;
                result_exp  = a_exp;
                larger_man  = a_man;
                smaller_man = b_man; 
            end
            else begin
                result_sign = new_b_sign;
                result_exp  = b_exp;
                larger_man  = b_man;
                smaller_man = a_man;
            end
        end
    end
      
//shift mantissa of smaller number after match exponent  
    always@(*) begin     
        exp_diff  = a_exp - b_exp;
        if (exp_diff[8]) begin
            abs_exp_diff = 8'b0 - exp_diff[7:0];
        end
        else begin
            abs_exp_diff = exp_diff[7:0];
        end

        new_smaller_man = smaller_man >> abs_exp_diff;
    end
    
//add or subtract two fp numbers
    always@(*) begin
        if (a_sign == new_b_sign) begin
            result_man = larger_man + new_smaller_man;
        end
        else begin
            result_man = larger_man - new_smaller_man;
        end
    end
endmodule