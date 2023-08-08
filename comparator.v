`include "CLA.v"

module comparator (
    input  wire [31:0] A_in,
	input  wire [31:0] B_in,
    input  wire        mode,  // 1: unsigned;         0: signed
	output             lt,    // 1: A is less than B; 0: B is less than A 
    output             zero,  // 1: A is equal to B;  0: not equal
	output             of     //overflow
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire [31:0] S_w;
    wire        of_w,zero_w;
    wire        wire1,wire2;
//=======================================================
//  Behavioral coding
//=======================================================
    CLA blk (
		.A_in     (A_in),
	    .B_in     (B_in),
	    .mode     (1'b1),
	    .S        (S_w),
	    .overflow (of_w),
	    .zero     (zero_w)
		);

    assign wire1 = (A_in[31] ^ B_in[31]) & mode ;
    assign wire2 = wire1 ^ A_in[31];
    assign lt = (mode == 1 && wire1 == 1) ? wire2 : S_w[31] ;
    assign of = (mode == 1 && wire1 == 1) ? 0 : of_w;
    assign zero = zero_w;

endmodule
