module rounding (
    input  wire        normalized_result_sign,
    input  wire [8:0]  normalized_result_exp,
    input  wire [48:0] normalized_result_man,
    input  wire        done_cal,
    output reg         rounded_result_sign,
    output reg  [8:0]  rounded_result_exp,
    output reg  [24:0] rounded_result_man,
    output reg         round_flag,
    output reg         done_cal_out
);
//=======================================================
//  REG/WIRE declarations
//=======================================================  
    reg       S_bit;
    reg       R_bit;
    reg       last_bit;
    reg [2:0] check_round;
//=======================================================
//  Behavioral coding
//=======================================================
  
    always@(*) begin
   
        rounded_result_sign = normalized_result_sign;
        rounded_result_exp  = normalized_result_exp;
        done_cal_out        = done_cal;
    
        S_bit               = |normalized_result_man[22:0];
        R_bit               = normalized_result_man [23];
        last_bit            = normalized_result_man [24];
        check_round         = {R_bit,S_bit,last_bit};
     

        if (check_round == 3'b110 || check_round == 3'b111|| check_round == 3'b101) begin
            rounded_result_man = normalized_result_man[48:24] +'b1;
        end
        else begin
            rounded_result_man = normalized_result_man[48:24]; 
        end
         
        if (normalized_result_man [23:0] == 24'b0) begin  
            round_flag = 1'b0; //no need rounding
        end
        else begin
            round_flag = 1'b1; //have to round
        end     
    end
endmodule