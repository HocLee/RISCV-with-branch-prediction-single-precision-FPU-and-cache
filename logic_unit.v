module logic_unit ( 
    input  wire [31:0] A_in,
    input  wire [31:0] B_in,
    input  wire [1:0]  sel,
    output      [31:0] out
 );

    assign out = sel[1] ? (sel[0] ? ~A_in : A_in ^ B_in) : (sel[0] ? A_in | B_in : A_in & B_in);
endmodule