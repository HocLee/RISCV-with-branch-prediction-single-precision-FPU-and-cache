module dff_2 (   
    input wire [31:0] alu_in,
    input wire        clk,
    input wire        rstn,
    input wire        overflow_in,
    input wire        underflow_in,
    input wire        normalized_round_done_in,
    input wire        done_cal_in,
    output reg [31:0] alu_out,
    output reg        overflow,
    output reg        underflow,
    output reg        done_cal,
    output reg        normalized_round_done
); 

    always @ (posedge clk or negedge rstn) begin 
        if (!rstn) begin  
            alu_out                      <= 'b0; 
            normalized_round_done        <= 1'b0;
            underflow                    <= 1'b0;
            overflow                     <= 1'b0;
            done_cal                     <= 1'b0;
        end 

        else begin
            if (underflow_in) begin
                alu_out                  <= 'h00000000;
                normalized_round_done    <= normalized_round_done_in;
                underflow                <= underflow_in;
                overflow                 <= overflow_in;
                done_cal                 <= done_cal_in;
            end
            else begin
                if (overflow_in) begin
                alu_out                  <= 'h7f7fffff;
                normalized_round_done    <= normalized_round_done_in;
                underflow                <= underflow_in;
                overflow                 <= overflow_in;
                done_cal                 <= done_cal_in;
                end
                else begin
                    alu_out                  <= alu_in;
                    normalized_round_done    <= normalized_round_done_in;
                    underflow                <= underflow_in;
                    overflow                 <= overflow_in;
                    done_cal                 <= done_cal_in;
                end
            end
        end 
    end 
endmodule