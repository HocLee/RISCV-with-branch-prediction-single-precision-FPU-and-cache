module dff_1(
    input  wire        clk,
    input  wire        rstn,
    input  wire [1:0]  sel,
    input  wire [31:0] a_in,
    input  wire [31:0] b_in,
    output reg  [31:0] a_out,
    output reg  [31:0] b_out,
    output reg  [1:0]  sel_out
);

    always@ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            a_out   <= 'b0;
            b_out   <= 'b0;
            sel_out <= 'b0;
        end
        else begin
            a_out   <= a_in;
            b_out   <= b_in;
            sel_out <= sel;
        end
    end
endmodule