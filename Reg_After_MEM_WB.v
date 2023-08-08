module Reg_After_MEM_WB (
  input  wire        clk        ,
  input  wire        rst        ,
  input  wire        wb_MemRd   ,
  input  wire        wb_RegWr   ,
  input  wire  [4:0] wb_rd      ,
  output reg         extra_MemRd, // resolve Data hazard caused by load after 2 instruction
  output reg         extra_RegWr,
  output reg   [4:0] extra_rd
);
    always @ (posedge clk) begin
        if (rst) begin
        extra_MemRd  <= 0;
		    extra_RegWr  <= 0;
		    extra_rd     <= 0;
        end 
	    else begin
	      extra_MemRd   <= wb_MemRd; 
		    extra_RegWr   <= wb_RegWr;
		    extra_rd      <= wb_rd   ;
		end 
    end
endmodule 