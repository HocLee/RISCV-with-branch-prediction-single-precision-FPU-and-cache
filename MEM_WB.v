module Reg_MEM_WB(
//=========================INPUT FROM MEM====================================
	input				clk            ,
	input               clk_2          ,
	input				rst            ,
	input               stall          ,
	input	   [1:0]    mem_MemtoReg   ,  // from the output of Reg EX/MEM to control Mux after DataMem
	input				mem_RegWr      ,  // from the output of Reg EX/MEM to write to Int_Reg File
	input	   [4:0]	mem_rd         ,  // ID -> IF/ID reg -> ID/EX reg -> EX/MEM Reg -> MEM/WB Reg 
	input               mem_MemRd      ,
	input	   [31:0]	mem_datamem    ,  // from the output of readdata of DataMem 
	input      [31:0]   mem_dataALU	   ,  // ALU result -> EX/MEM Reg -> MEM/WB Reg
	input      [2:0]    mem_Load_sel   ,  // ALU result -> EX/MEM Reg -> MEM/WB Reg
	input				mem_RegWr_fp   ,  // from the output of Reg EX/MEM to write to FPU_Reg File
	input      [31:0]   mem_dataALU_fp ,  // FPU ALU result -> EX/MEM Reg -> MEM/WB Reg
//=========================OUTPUT TO WB======================================================
	output reg [31:0]	wb_dataALU	   ,
	output reg [31:0]	wb_datamem	   ,
	output reg [1:0]	wb_memtoreg	   ,
	output reg			wb_RegWr  	   ,
	output reg      	wb_MemRd  	   ,
	output reg [2:0]	wb_Load_sel	   ,
	output reg [4:0]	wb_rd          ,
	output reg			wb_RegWr_fp    ,
	output reg [31:0]   wb_dataALU_fp    // FP_ALU result -> EX/MEM Reg -> MEM/WB Reg
);
    reg d1_mem_MemtoReg;

/*
always @ (negedge clk ) begin
	if (rst) begin
	   d1_stall <= 0;
	end
	else begin
	   d1_stall <= stall;
	end
end
*/
/*
always@(posedge clk_2) begin
	if (rst) begin
		wb_memtoreg   <= 0;
	end
	else begin
	if(stall==0) begin
		wb_memtoreg   <= mem_MemtoReg;
	 end   
	end
end
//*/
//always @ (negedge clk /*posedge clk*/ ) begin
always @ (negedge clk /*posedge clk*/ ) begin	
	if (rst) begin
		wb_dataALU    <= 0;
		wb_datamem    <= 0;
		wb_memtoreg   <= 0;
		wb_RegWr	  <= 0;
		wb_rd		  <= 0;
		wb_MemRd      <= 0;
		wb_Load_sel   <= 0;
		wb_RegWr_fp   <= 0;
		wb_dataALU_fp <= 0;
	end
	else begin
		
		if(stall==0) begin
/*		
		if(wb_memtoreg=='b01) begin
		   wb_memtoreg   <= mem_MemtoReg;
		end
		else begin
		   wb_memtoreg   <= d1_mem_MemtoReg;
		end
*/
		//d1_mem_MemtoReg  <= mem_MemtoReg;
		wb_memtoreg   <= mem_MemtoReg;
		wb_datamem    <= mem_datamem;
		wb_dataALU	  <= mem_dataALU;
		

		wb_RegWr	  <= mem_RegWr;
		wb_rd		  <= mem_rd;
		wb_MemRd      <= mem_MemRd;
		wb_Load_sel   <= mem_Load_sel;
		wb_RegWr_fp   <= mem_RegWr_fp;
		wb_dataALU_fp <= mem_dataALU_fp;
	    end
	end	
end
endmodule
