module selector (
//    input  wire        clk,
//    input  wire        rstn,
    input  wire        result_sign,
    input  wire [8:0]  result_exp,
    input  wire [48:0] result_man,
    input  wire        result_sign_1,
    input  wire [8:0]  result_exp_1,
    input  wire [48:0] result_man_1,
    input  wire        result_sign_2,
    input  wire [8:0]  result_exp_2,
    input  wire [48:0] result_man_2,
    input  wire        done_div,
    input  wire        done_add_sub,
    input  wire [1:0]  sel,
    output reg         result_sign_in,
    output reg  [8:0]  result_exp_in ,
    output reg  [48:0] result_man_in,
    output wire        done_cal 
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
//    reg [5:0] count;
    wire      done_add_sub_mul;
    wire      done_div_cal;
//=======================================================
//  Behavioral coding
//=======================================================

/*
    assign done_add_sub_mul = ((count == 'd2) && !(sel == 2'b11));
    assign done_div_cal     = (count == 'd52); 
    assign done_cal         = (done_add_sub_mul || done_div_cal );   

    always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            count <= 'd0;
        end
        else begin
            if((done_add_sub_mul) || (done_div_cal)) begin
                count <= 'd0;
            end
            else begin
                count  <= count + 'd1;
            end
        end
    end
*/

    assign done_add_sub_mul = (done_add_sub && !(sel == 2'b11));
    assign done_div_cal     = (done_div && (sel == 2'b11)); 
    assign done_cal         = (done_add_sub_mul || done_div_cal );



/*
   always@(posedge clk or negedge rstn) begin
        if (!rstn) begin */

    always@(*) begin
        if (!done_cal) begin    
        //    result_sign_in <= 'b0;
        //    result_exp_in  <= 'b0;
        //    result_man_in  <= 'b0;
            result_sign_in <= result_sign_in;
            result_exp_in  <= result_exp_in;
            result_man_in  <= result_man_in;
        end
        else begin      
            case (sel)
                2'b00,2'b01: begin     
                    result_sign_in <= result_sign;
                    result_exp_in  <= result_exp ;
                    result_man_in  <= result_man ;
                end 
                2'b10: begin
                    result_sign_in <= result_sign_1;
                    result_exp_in  <= result_exp_1 ;
                    result_man_in  <= result_man_1 ;
                end 
                default: begin
                    if (done_div) begin
                        result_sign_in <= result_sign_2;
                        result_exp_in  <= result_exp_2 ;
                        result_man_in  <= result_man_2 ;
                    end 
                else begin     
                        result_sign_in <= result_sign_in;
                        result_exp_in  <= result_exp_in;
                        result_man_in  <= result_man_in;
                    end
                end
            endcase
        end
    end
endmodule