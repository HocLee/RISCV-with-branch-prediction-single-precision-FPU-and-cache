`timescale 1ns/10ps
`include "RISCV.v"
module RISCV_tb;   
                                                                  
    reg    [9:0]    SW;
    reg             reset, w_RegWr_reg2;
    reg             clk;
    wire   [31:0]   pc,instruction_im,pc_up, w_readdata1, w_readdata2;
    wire   [9:0]    LEDR;
    wire            a;
    wire   [1:0]    b;
    wire   [31:0]   r,r1,r2;
	reg    [31:0]   instruction,pc_im,pc_next,addr_in, w_WriteData;
    reg    [4:0]    w_rs1, w_rs2, w_rd_reg2;
   
    RISCV u_RISCV (
                        .addr_in(addr_in),
	                    .SW(SW),               
    		            .reset(reset),
                        .CLOCK_50(clk),
                        .LEDR(LEDR),      
                        .a(a),
                        .b(b),
                        .r(r),
                        .r1(r1),
						.r2(r2)
						);
   /*RegisterFile RegFile_Int (
	.readreg1    (w_rs1)       ,
	.readreg2    (w_rs2)       ,
	.writereg    (w_rd_reg2)   ,
	.writedata   (w_WriteData) ,
	.write       (w_RegWr_reg2),
	.clk         (clk)    ,
	.rst         (reset)       ,
	.readdata1   (w_readdata1) ,
	.readdata2	 (w_readdata2)
);*/
								
								
	/*IM u_IM (
    .pc          (pc_im),
	 //.IM          (IM),
    //.clk         (clk)  ,
    .instruction (instruction_im)     
);

   D_FF PC (
    .i_clr      (reset)          ,
    .PC_remain  (1'b0), 
    .i_D        (pc_next) ,
	 .i_clk      (clk)   ,
	 .o_Q        (pc)
);

   always@(*)begin
      instruction = instruction_im;
      pc_im = pc;
   end*/
	
	initial begin
      clk = 1'b0;
      forever #5 clk = ~clk;
   end
	
	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0,RISCV_tb);
   end
	
	initial begin
      reset = 1'b1;
      #4;
	   reset = 1'b0;
      /*w_rs1 = 'd1;
      w_rs2 = 'd2;
      w_rd_reg2 = 'd3;
      w_WriteData = 'd4;
      w_RegWr_reg2 = 1'b0;*/
      addr_in = 32'd0;
		//instruction = 32'b00000000000100001000000010010011;
		//#5;
	   //reset = 1'b0;
		//pc_next = 32'd4;
		//#10;
		//pc_im = 32'd1;
		#13000;
		$finish;
	end
	
endmodule