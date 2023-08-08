// R-format and I-format basic data hazard resolved by using Forwarding unit

module Forwarding_Unit (
    input  wire [4:0]  rs1_ex     , // from Reg_ID_EX
    input  wire [4:0]  rs2_ex     , // from Reg_ID_EX
    input  wire [4:0]  rd_mem     , // from Reg_EX_MEM
    input  wire [4:0]  rd_wb      , // from Reg_MEM_WB
    input              RegWr_mem  , // from Reg_EX_MEM
    input              RegWr_wb   , // from Reg_MEM_WB
	input              MemRd_wb   , // from Reg_MEM_WB
	input              MemWr_mem  , // from Reg_EX_MEM
	input              MemWr_wb   , // from Reg_MEM_WB
	input       [6:0]  opcode_ex  ,
    output reg  [1:0]  Forward_ASel,
    output reg  [1:0]  Forward_BSel 
);

//=======================================================
//  REG/WIRE declarations
//=======================================================  
    wire hazard_1a_w;
    wire hazard_2a_w;
    wire hazard_1b_w;
    wire hazard_2b_w;

    wire hazard_1aa_w;
    wire hazard_2aa_w;
    wire hazard_1bb_w;
    wire hazard_2bb_w;
//=======================================================
//  Behavioral coding
//=======================================================
    assign hazard_1a_w  = (!(opcode_ex == 7'b1010011)) && (RegWr_mem) && (rd_mem != 5'b00000)  && (rd_mem == rs1_ex);
    assign hazard_2a_w  = (!(opcode_ex == 7'b1010011)) && (RegWr_wb)  && (rd_wb  != 5'b00000)  && (rd_wb  == rs1_ex);
    assign hazard_1b_w  = (!(opcode_ex == 7'b1010011)) && (RegWr_mem) && (rd_mem != 5'b00000)  && (rd_mem == rs2_ex);
    assign hazard_2b_w  = (!(opcode_ex == 7'b1010011)) && (RegWr_wb)  && (rd_wb  != 5'b00000)  && (rd_wb  == rs2_ex);

    assign hazard_1aa_w = (!(opcode_ex == 7'b1010011)) && (MemWr_mem) && (rd_mem != 5'b00000)  && (rd_mem == rs1_ex)  && (RegWr_mem);
    assign hazard_2aa_w = (!(opcode_ex == 7'b1010011)) && (MemRd_wb)  && (rd_wb  != 5'b00000)  && (rd_wb  == rs1_ex)  && (RegWr_wb);
    assign hazard_1bb_w = (!(opcode_ex == 7'b1010011)) && (MemWr_mem) && (rd_mem != 5'b00000)  && (rd_mem == rs2_ex);
    assign hazard_2bb_w = (!(opcode_ex == 7'b1010011)) && (MemRd_wb)  && (rd_wb  != 5'b00000)  && (rd_wb  == rs2_ex);

always @(*) begin
        //The first ALU
        if (hazard_1a_w || (hazard_1aa_w)) // EX hazard
            begin
                Forward_ASel = 2'b10; //forwarded from the prior ALU result; type 1a p.296
            end
        else begin 
            if (hazard_2a_w || (hazard_2aa_w/*&& MemWr_wb*/)) // MEM hazard
            begin
                Forward_ASel = 2'b01; //forwarded from DataMem or an earlier ALU result; type 2a p.296
            end
            else begin
                Forward_ASel = 2'b00; //no data hazard occurs => The first ALU operand comes from the Register File
            end
        end

        // The second ALU
	    if (hazard_1b_w || (hazard_1bb_w)) // EX hazard
            begin
                Forward_BSel = 2'b10; //forwarded from the prior ALU result; type 1b p.296
            end
        else begin 
            if (hazard_2b_w || (hazard_2bb_w))// MEM hazard
            begin
                Forward_BSel = 2'b01; //forwarded from DataMem or an earlier ALU result; type 2b p.296
            end
            else begin
                Forward_BSel = 2'b00; //no data hazard occurs => The second ALU operand comes from the Register File
            end
        end
    end
endmodule
