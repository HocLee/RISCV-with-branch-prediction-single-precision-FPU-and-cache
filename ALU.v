//`include "CLA.v"
`include "comparator.v"
`include "logic_unit.v"
`include "mux4to1.v"
`include "shifter.v"

module ALU (
    input  wire [31:0] in1,
	input  wire [31:0] in2,
	input  wire [3:0]  sel,
	output      [31:0] ALU_result,
	output             ALU_of,
	output             ALU_zero,
	output             ALU_lt,
	output             ALU_neg
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [31:0] shifter_out, logic_out, CLA_out, alu_result, S_o;
wire lt_out;
wire OF, OF1, ZERO,zero_compare_w;

//=======================================================
//  Behavioral coding
//=======================================================
CLA u_CLA(
    .A_in     (in1),
	.B_in     (in2),
	.mode     (sel[0]),
	.S        (S_o),
	.overflow (OF),
	.zero     (ZERO)
);
assign CLA_out = (sel[2])? 1'd0 : S_o ;

shifter u_shifter(
	.A_in        (in1),
	.B_in        (in2),
	.mode        (sel[1:0]),
	.shifted_out (shifter_out)
);


logic_unit u_logic_unit(
    .A_in (in1),
	.B_in (in2),
	.sel  (sel[1:0]),
	.out  (logic_out)
);

comparator u_comparator(
    .A_in       (in1),
	.B_in       (in2),
    .mode       (sel[0]),
	.lt         (lt_out),
	.zero       (zero_compare_w),
	.of         (OF1)
);
assign ALU_lt = lt_out ;

mux4to1 u_mux_4to1(
    .a   (CLA_out),
	.b   (shifter_out),
	.c   (logic_out),
	.d   ({31'b0,lt_out}),
	.sel (sel[3:2]),
	.out (alu_result)
);

assign ALU_result = alu_result;
assign ALU_of     = OF & ~(sel[0] ^ sel[1]);
assign ALU_zero   = (ZERO & (~sel[0] & ~sel[1])) | zero_compare_w ;
assign ALU_neg    = alu_result[31] & (~sel[0] & ~sel[1]);
endmodule