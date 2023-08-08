`timescale 1ns/10ps
module div(
    input  wire [31:0] a_in,
    input  wire [31:0] b_in,

    input  wire        stall,

    input  wire        clk,
    input  wire        rstn,
    input  wire [1:0]  sel,
    output reg         result_sign_2,
    output reg  [8:0]  result_exp_2,
    output reg  [48:0] result_man_2,
    output wire [5:0]  check_div_fp,
    output wire        done_div
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire         a_sign;
    wire         b_sign;
    wire  [8:0]  a_exp;
    wire  [8:0]  b_exp;
    wire  [23:0] a_man;
    wire  [23:0] b_man;
    reg   [24:0] remain;
    reg   [48:0] quotient;
    reg   [5:0]  count;   
    wire         busy;
    wire         compare;
    wire  [24:0] next_remain;
    wire  [24:0] b_man_tmp;
//=======================================================
//  Behavioral coding
//=======================================================
    assign a_sign = a_in[31];
    assign a_exp  = {1'b0,a_in[30:23]};
    assign b_sign = b_in[31];
    assign b_exp  = {1'b0,b_in[30:23]};

//if exp of input is equal to 8'b0, add hidden bit = 0 before mantissa. If not, add 1
    assign a_man  = {|a_exp,a_in[22:0]};
    assign b_man  = {|b_exp,b_in[22:0]};


    assign done_div     =  (count == 'd50);
    assign busy         = !(count == 'd0) && (stall== 0) ;
    assign check_div_fp =  count;

    assign b_man_tmp= {1'b0,b_man}    ;
    assign compare     = remain >= b_man_tmp   ;
    assign next_remain = compare ? (remain - b_man) << 1'b1 : {remain[23:0],1'b0};

    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 6'b000000;
        end
        else begin
            if (!(sel == 2'b11) || done_div) begin
                count <= 6'b000000;
            end
            else begin
                if (!stall) begin
                    count <= count + 1'b1;
                end
            end
        end
    end  
           

    always@( posedge clk or negedge rstn) begin
        if(!rstn) begin
            quotient  <= 'd0;
            remain    <= 'd0;
        end
        else begin
            if(done_div || (count == 'd0)) begin
                quotient <= 'd0;
                remain   <= 'd0;
            end
            else begin
                if (busy) begin
                    remain     <= (count == 6'd1) ? {1'b0,a_man} : next_remain;
                    quotient   <= {quotient[47:0],compare};
                 end
                else begin

                    if (!stall) begin

                        remain    <= remain;
                        quotient  <= quotient;
                    end
                end
            end
        end
    end 
 
   always@(*) begin 
        result_man_2 = quotient;
        result_sign_2 = a_sign ^ b_sign;
    //If any input floating point input is a denormalized number then the bias is 128, otherwise it is 127.

        if (a_man[23] == 1'b1 && b_man[23] == 1'b1) begin
            result_exp_2  = a_exp - b_exp + 'd127;
         end
        else begin
            result_exp_2 = a_exp - b_exp + 'd128;
        end 
    end
endmodule