module Hazard_Detection (
  input              clk             ,
  input              rst             ,
  input              clk_2             ,
  input  wire [4:0]  rs1_id          , // From IM  
  input  wire [4:0]  rs2_id          , // From IM  
	input  wire [4:0]  rd_id           , // From IM  
  input  wire [4:0]  rd_ex           , // From Reg_ID_EX 
  input              MemRd_ex        , // From Reg_ID_EX 
	input              MemWr_id        ,
  input       [6:0]  opcode          ,
  input       [6:0]  opcode_ex       ,
  input       [1:0]  div_fp          ,    
  input       [5:0]  check_div_fp    ,
  input              stall           ,
  output reg         PC_remain       , // -> PC
	output reg         Reg_IF_ID_remain, // -> Reg_IF_ID
	output reg         zero_control      // -> Control Unit    
);
//=======================================================
// Instrucion type
//=======================================================
  parameter NoP     = 7'b0000000;
  parameter R       = 7'b0110011;
  parameter addi    = 7'b0010011;
  parameter lw      = 7'b0000011;
  parameter sw      = 7'b0100011;
  parameter SB      = 7'b1100011;
  parameter jalr    = 7'b1100111;
  parameter jal     = 7'b1101111;
  parameter auipc   = 7'b0010111;
  parameter lui     = 7'b0110111;
//=======================================================
//  REG/WIRE declarations
//=======================================================  
  wire condition, div_fp_condition;
  reg [1:0] tp;
//=======================================================
//  Behavioral coding
//=======================================================
  assign condition = (opcode == addi) || (opcode == auipc) || (opcode == jal) || (opcode == jalr) || (opcode == lui) || (opcode == lw);
  assign div_fp_condition = (opcode == 7'b1010011) && (div_fp == 2'b11) && (!tp[1]);
/*
  always@(posedge clk or posedge div_fp_condition or posedge rst) begin
    if (rst) begin
      tp <= 'd0;
    end
    else begin
        if (div_fp_condition) begin
		      if (check_div_fp < 'd48) begin
            tp <= 'd1;
			    end
          else begin
		        if (check_div_fp > 'd47) begin
              tp <= 'd2;
            end
            else begin
              tp <= tp;
            end
          end
		    end
		    else begin
		      tp <= tp;
		    end
    end
  end
*/

  always@(posedge clk or posedge div_fp_condition or posedge rst) begin
    if (rst) begin
      tp <= 'd0;
    end
    else begin
        if (div_fp_condition) begin
		      if (check_div_fp < 'd48) begin
            tp <= 'd1;
			    end
          else begin
		        if (check_div_fp > 'd47) begin
              tp <= 'd2;
            end
          end
        end
    end
  end


  always @(*) 
  //always @(negedge clk_2 or posedge rst) 
  begin
    if((MemRd_ex) && (rd_ex != 0) && (!(opcode_ex == opcode)) && ((rd_ex == rs1_id) || ((rd_ex == rs2_id) && (!condition)) /*|| (rd_ex == rd_id)*/)||((tp == 2'b01))||(stall))
	  begin
      //if(stall==1) begin
      PC_remain        <= 1'b1; 
		  Reg_IF_ID_remain <= 1'b1;
		  zero_control     <= 1'b1;   
      //end
    end
    else  begin
      //if(stall==0) begin
      PC_remain        <= 0; 
		  Reg_IF_ID_remain <= 0;
		  zero_control     <= 0;
      //end
    end
  end
endmodule
