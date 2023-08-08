module normalizer_2 (
    input  wire         rounded_result_sign,
    input  wire  [8:0]  rounded_result_exp, 
    input  wire  [24:0] rounded_result_man,
    input  wire         round_flag,
    input  wire         done_cal,
    output wire  [31:0] alu_out,
    output reg          normalized_round_done,
    output reg          done_cal_out
 
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire         alu_out_sign;
    wire  [7:0]  alu_out_exp;
    wire  [22:0] alu_out_man;
    reg   [8:0]  normalized_result_exp;
    reg   [24:0] normalized_result_man;
    reg   [2:0]  check_nor_round_done;
//=======================================================
//  Behavioral coding
//=======================================================   
    assign alu_out_sign = rounded_result_sign;
    assign alu_out_exp  = normalized_result_exp[7:0];
    assign alu_out_man  = normalized_result_man[22:0];
    assign alu_out      = {alu_out_sign, alu_out_exp, alu_out_man};
   
    always@(*) begin
        done_cal_out = done_cal;

        if (rounded_result_man [24:23] == 2'b10 ||rounded_result_man [24:23] == 2'b11) begin
            normalized_result_man = rounded_result_man >> 1;
            normalized_result_exp = rounded_result_exp + 1'b1;
        end
        else begin
            normalized_result_man = rounded_result_man;
            normalized_result_exp = rounded_result_exp;
        end

        check_nor_round_done= {round_flag,normalized_result_man[24:23]};     
        if(check_nor_round_done == 3'b101|| check_nor_round_done == 3'b001) begin
            normalized_round_done = 1'b1 || normalized_result_exp[8];
        end
        else begin
            normalized_round_done = 1'b0 && normalized_result_exp[8];
        end         
    end
endmodule