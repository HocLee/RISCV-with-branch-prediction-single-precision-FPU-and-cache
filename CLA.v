module CLA(
   input   wire [31:0] A_in,
   input   wire [31:0] B_in,
   input   wire        mode, // 0: add , 1: sub. 
   output       [31:0] S,
   output              zero,
   output              overflow
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [31:0] B_w;  
wire [31:0] S_w;
wire [31:0] P_w;
wire [31:0] G_w;
wire [32:1] Cin_w;
//=======================================================
//  Behavioral coding
//=======================================================
cla u_cla (.a_in (A_in[0]), .b_in (B_in[0]^mode), .cin_in (mode), .s (S_w[0]), .p (P_w[0]), .g (G_w[0]));

assign Cin_w[1] = G_w[0] | (P_w[0] & mode);


genvar m;
   generate 
      for (m=1; m<=31; m=m+1) 
         begin : block
		      assign B_w[m] = B_in[m] ^ mode;
		      assign Cin_w[m+1] = G_w[m] | (P_w[m] & Cin_w[m]);
            cla blk( 
               .a_in   (A_in[m]),
               .b_in   (B_w[m]),
				   .cin_in (Cin_w[m]),
				   .s      (S_w[m]),
				   .p      (P_w[m]),
				   .g      (G_w[m])
            );
         end
   endgenerate

   assign S = S_w;
   assign zero = ~(|S_w);
   assign overflow = (Cin_w[31] ^ Cin_w[32]);
endmodule

module cla(
   input a_in,
	input b_in,
	input cin_in,
	output s,
	output p,
	output g
);
   wire S_w, P_w, G_w;
   assign S_w = a_in ^ b_in ^ cin_in;
   assign P_w = a_in ^ b_in;
   assign G_w = a_in & b_in;
   assign s = S_w; 
   assign p = P_w; 
   assign g = G_w;
endmodule