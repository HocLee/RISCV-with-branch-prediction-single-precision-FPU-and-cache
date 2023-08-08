module ID (
    input  wire [31:0]           instruction     ,// Instruction from Instruction Memory
    output      [4:0]            rd              ,//Register Destination
    output      [4:0]            rs1             ,//Register Source 1
    output      [4:0]            rs2             ,//Register Source 2
    output      [6:0]            opcode          ,//opcode to Control Unit
    output      [2:0]            funct3          ,
    output      [6:0]            funct7          ,
    output      [2:0]            type
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire [6:0] opcode_w;
    reg  [2:0] type_r;
//=======================================================
//  Behavioral coding
//=======================================================
    assign opcode_w = instruction[6:0]  ; 
    assign rd       = instruction[11:7] ; 
    assign rs1      = instruction[19:15]; 
    assign rs2      = instruction[24:20]; 
    assign funct3   = instruction[14:12];
    assign funct7   = instruction[31:25];
    assign opcode   = opcode_w;
    assign type     = type_r;

always @(*)	
begin
    case (opcode_w)
        7'b0110011: type_r = 3'b000; // R_type
	    7'b0010011: type_r = 3'b110; // I_type, ALU
	    7'b0000011: type_r = 3'b001; // I_type, Load
	    7'b1100111: type_r = 3'b001; // I_type, jalr
	    7'b0110111: type_r = 3'b010; // U_type
	    7'b0010111: type_r = 3'b010; // U_type
	    7'b1100011: type_r = 3'b011; // B_type 
	    7'b0100011: type_r = 3'b100; // S_type 
	    7'b1101111: type_r = 3'b101; // J_type
	    7'b0000111: type_r = 3'b001; // flw as I_type
	    7'b0100111: type_r = 3'b100; // fsw as S_type
	    default     type_r = 3'b111;
	endcase
end

endmodule
