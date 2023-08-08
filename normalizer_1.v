module normalizer_1(
    input  wire         result_sign,
    input  wire  [48:0] result_man,
    input  wire  [8:0]  result_exp,
    input  wire         done_cal,
    output reg          normalized_result_sign,
    output reg   [48:0] normalized_result_man,
    output reg   [8:0]  normalized_result_exp,
    output reg          overflow,
    output reg          underflow,
    output reg          done_cal_out
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    reg [31:0] extend_32b_man;
    reg [15:0] var_16;
    reg [7:0]  var_8;
    reg [3:0]  var_4;
    reg [1:0]  var_2;
    reg [4:0]  LDZ_count;
    reg [48:0] check_normalization_man;
    reg [8:0]  check_normalization_exp;
    reg [48:0] LDZ_man;
    reg [8:0]  LDZ_exp;
    reg        LDZ_check;
//=======================================================
//  Behavioral coding
//=======================================================

    always@(*) begin
        normalized_result_sign = result_sign;
        done_cal_out           = done_cal;
        if (result_man [48:47] == 2'b01) begin
            check_normalization_man = result_man;
            check_normalization_exp = result_exp;
            LDZ_check = 1'b0;
        end
        else begin
            if (result_man [48:47] == 2'b10) begin
                check_normalization_man = result_man >> 1;
                check_normalization_exp = result_exp + 1'b1;
                LDZ_check = 1'b0;
            end
            else begin 
                if (result_man [48:47] == 2'b00) begin
                    if (result_exp == 9'b0) begin
                        check_normalization_man = result_man;
                        check_normalization_exp = result_exp;
                        LDZ_check = 1'b0;
                    end
                    else begin 
                        check_normalization_man = result_man;
                        check_normalization_exp = result_exp;
                        LDZ_check = 1'b1;
                    end
                end
                else begin
                    check_normalization_man = result_man >> 1;
                    check_normalization_exp = result_exp + 'b1;
                    LDZ_check = 1'b0;
                end
            end
        end
    end

    always@(*) begin
        if (LDZ_check == 1'b0) begin
            normalized_result_man = check_normalization_man;
            normalized_result_exp = check_normalization_exp;
        end
        else begin
            normalized_result_man = LDZ_man; 
            normalized_result_exp = LDZ_exp;
        end
    end

/*==========================LEADING ZEROS COUNTING=============================*/
    always@(*) begin
        extend_32b_man = {result_man[46:24],9'b0};
        if(extend_32b_man[31:16] == 16'b0) begin
            LDZ_count[4] = 1'b1;
            var_16 = extend_32b_man[15:0];
        end
        else begin
            LDZ_count[4] = 1'b0; 
            var_16 = extend_32b_man[31:16];
        end
   
        if(var_16[15:8] == 8'b0) begin
            LDZ_count[3] = 1'b1;
            var_8 = var_16[7:0];
        end
        else begin
            LDZ_count[3] = 1'b0;
            var_8 = var_16[15:8];
        end
    
        if (var_8[7:4] == 4'b0) begin
            LDZ_count[2] = 1'b1;
            var_4 = var_8[3:0];
        end
        else begin
            LDZ_count[2] = 1'b0;
            var_4 = var_8[7:4];
        end
     
        if(var_4[3:2] == 2'b0) begin
            LDZ_count [1] = 1'b1;
            var_2 = var_4[1:0];
        end
        else begin
            LDZ_count [1] = 1'b0;
            var_2 = var_4[3:2];
        end
      

        if (var_2[1] == 1'b0 && var_2[0] == 1'b1) begin
            LDZ_count [0] = 1'b1;
        end
        else begin
            LDZ_count [0] = 1'b0;
        end           
        LDZ_man = check_normalization_man << (LDZ_count + 'b1) ;
        LDZ_exp = check_normalization_exp -  (LDZ_count + 'b1 );
    end


/*=====================CHECK IF OVERFLOW OR UNDERFLOW======================*/
    always@(*) begin 
        if(normalized_result_exp[8]) begin
            if (result_man[48:47] == 2'b10 || result_man[48:47] == 2'b11) begin
                overflow  = 1'b1;
                underflow = 1'b0;
            end
            else begin
                if (result_man[48:47] == 2'b00) begin
                    overflow  = 1'b0; 
                    underflow = 1'b1;
                end
                else begin
                    overflow  = 1'b0;
                    underflow = 1'b0;
                end
            end
        end
        else begin
            overflow  = 1'b0;
            underflow = 1'b0;
        end 
    end
endmodule