/* all available modes include:
   2'b00:  Shift Right Logical      
   2'b01:  Shift Right Arithmetic
   2'b10:  Shift Left Logical
   2'b11:  Shift Left Arithmeticl*/
	
module shifter_1bit(
    input   wire [1:0]  mode_in_1,
    input   wire [31:0] a_in_1,
    input   wire        active_in_1,
    output       [31:0] shifted_out_1
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [31:0] shifted_reg;
//=======================================================
//  Behavioral coding
//=======================================================

always @(*)
    begin
        if (active_in_1 == 0) begin
            shifted_reg = a_in_1;
        end
        else begin
            if (mode_in_1[1] == 0) begin // shift RIGHT
	            if (mode_in_1[0] == 0) begin
                shifted_reg = {1'b0,a_in_1[31:1]};//a_in_1 >> 1;
            //        shifted_reg = a_in_1 >> 1;
                end
	            else begin                
                shifted_reg = {a_in_1[31],a_in_1[31:1]};//a_in_1 >>> 1;
            //        shifted_reg = a_in_1 >>> 1;
                end
	        end
	        else begin
		        if (mode_in_1[0] == 0) begin // shift LEFT
                   shifted_reg = {a_in_1[30:0],1'b0};//a_in_1 << 1;
                //    shifted_reg = a_in_1 << 1;
                end
		        else begin                
                    shifted_reg = {a_in_1[30:0],1'b0};//a_in_1 <<< 1;
                //    shifted_reg = a_in_1 <<< 1;
                end
	        end
        end
    end
    assign shifted_out_1 = shifted_reg;
endmodule
/*
module mux2to1 (
    input      [31:0] in_0,
    input      [31:0] in_1,
    input             mux_sel,
    output reg [31:0] out
);
    always @(*)
        begin
	        if (mux_sel == 1'b0) begin 
                out =  in_0; // mode 0: shift left
            end
	        else begin
                out =  in_1;
            end
        end
endmodule
*/