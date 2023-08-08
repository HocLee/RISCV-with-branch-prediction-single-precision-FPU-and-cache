`include "shifter_1bit.v"

module shifter (
	input  wire [31:0]   A_in,
	input  wire [31:0]   B_in,
	input  wire [1:0]    mode,
	output      [31:0]   shifted_out
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire [31:0] shifted_1_w        ;
    wire [31:0] shifted_2_w        ;
    wire [31:0] shifted_4_w        ;
    wire [31:0] shifted_8_w        ;
    wire [31:0] shifted_16_w       ;
    wire [31:0] shifted_32_w       ;
    wire        b1_w               ;
    wire [5:0]  b_in_w;
//=======================================================
//  Behavioral coding
//=======================================================
    assign b1_w = |(B_in[31:5])      ;
    assign b_in_w = (b1_w == 1)? 6'b111111: {b1_w,B_in[4:0]}    ;
    shifter_1bit blck1 (
	    .mode_in_1      (mode),
	    .a_in_1         (A_in),
	    .active_in_1    (b_in_w[0]),
	    .shifted_out_1  (shifted_1_w)
    );

    shifter_2bit blck2 (
	    .mode_in_2      (mode),
	    .a_in_2         (shifted_1_w),
	    .active_in_2    (b_in_w[1]),
	    .shifted_out_2  (shifted_2_w)
    );

    shifter_4bit blck3 (
	    .mode_in_4      (mode),
	    .a_in_4         (shifted_2_w),
	    .active_in_4    (b_in_w[2]),
	    .shifted_out_4  (shifted_4_w)
    );

    shifter_8bit blck4 (
	    .mode_in_8      (mode),
	    .a_in_8         (shifted_4_w),
	    .active_in_8    (b_in_w[3]),
	    .shifted_out_8  (shifted_8_w)
    );

    shifter_16bit blck5 (
	    .mode_in_16      (mode),
	    .a_in_16         (shifted_8_w),
	    .active_in_16    (b_in_w[4]),
	    .shifted_out_16  (shifted_16_w)
    );
    shifter_1bit blck6 (
	    .mode_in_1      (mode),
	    .a_in_1         (shifted_16_w),
	    .active_in_1    (b_in_w[5]),
	    .shifted_out_1  (shifted_32_w)
    );
    assign shifted_out = shifted_32_w;
endmodule

module shifter_16bit(
	input  wire [1:0]  mode_in_16,
	input  wire [31:0] a_in_16,
	input  wire        active_in_16,
	output      [31:0] shifted_out_16
);
    wire [31:0] shifted16_w;
    wire [31:0] shifted_out_16_w;
    shifter_8bit u_block1(
	    .mode_in_8     (mode_in_16),
	    .a_in_8        (a_in_16),
	    .active_in_8   (active_in_16),
	    .shifted_out_8 (shifted16_w)
    );
    shifter_8bit u_block2  (
	    .mode_in_8     (mode_in_16),
	    .a_in_8        (shifted16_w),
	    .active_in_8   (active_in_16),
	    .shifted_out_8 (shifted_out_16_w)
    );
    assign shifted_out_16 = shifted_out_16_w;
endmodule

module shifter_8bit(
	input  wire [1:0]  mode_in_8,
	input  wire [31:0] a_in_8,
	input  wire        active_in_8,
	output      [31:0] shifted_out_8
);
    wire [31:0] shifted8_w;
    wire [31:0] shifted_out_8_w;
    shifter_4bit u_block1(
	    .mode_in_4     (mode_in_8),
	    .a_in_4        (a_in_8),
	    .active_in_4   (active_in_8),
	    .shifted_out_4 (shifted8_w)
    );
    shifter_4bit u_block2  (
    	.mode_in_4     (mode_in_8),
	    .a_in_4        (shifted8_w),
	    .active_in_4   (active_in_8),
	    .shifted_out_4 (shifted_out_8_w)
    );
    assign shifted_out_8 = shifted_out_8_w;
endmodule

module shifter_4bit(
	input  wire [1:0]  mode_in_4,
	input  wire [31:0] a_in_4,
	input  wire        active_in_4,
	output      [31:0] shifted_out_4
);
    wire [31:0] shifted4_w;
    wire [31:0] shifted_out_4_w;
    shifter_2bit u_block1(
	    .mode_in_2     (mode_in_4),
	    .a_in_2        (a_in_4),
	    .active_in_2   (active_in_4),
	    .shifted_out_2 (shifted4_w)
    );
    shifter_2bit u_block2  (
	    .mode_in_2     (mode_in_4),
	    .a_in_2        (shifted4_w),
	    .active_in_2   (active_in_4),
	    .shifted_out_2 (shifted_out_4_w)
    );
    assign shifted_out_4 = shifted_out_4_w;
endmodule

module shifter_2bit(
	input  wire [1:0]  mode_in_2,
	input  wire [31:0] a_in_2,
	input  wire        active_in_2,
	output      [31:0] shifted_out_2
);
    wire [31:0] shifted2_w;
    wire [31:0] shifted_out_2_w;
    shifter_1bit u_block1(
	    .mode_in_1     (mode_in_2),
	    .a_in_1        (a_in_2),
	    .active_in_1   (active_in_2),
	    .shifted_out_1 (shifted2_w)
    );
    shifter_1bit u_block2  (
	    .mode_in_1     (mode_in_2),
	    .a_in_1        (shifted2_w),
	    .active_in_1   (active_in_2),
	    .shifted_out_1 (shifted_out_2_w)
    );
    assign shifted_out_2 = shifted_out_2_w;
endmodule