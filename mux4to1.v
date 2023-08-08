module mux4to1 ( 
    input  wire [31:0]  a,
    input  wire [31:0]  b,
    input  wire [31:0]  c,
    input  wire [31:0]  d,
    input  wire [1:0]   sel,
    output      [31:0]  out
 );

    assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);
endmodule