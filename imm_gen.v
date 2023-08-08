module imm_gen (
  input  wire [31:0] inst,
  input  wire [2:0]  type,
  output reg  [31:0] imm         
);
  always @(*) begin 
    case (type)
        //I-Type
        3'b001: imm = {{20{inst[31]}},inst[31:20]};
		    //I-Type
		    3'b110: 
		    case (inst[14:12])
		        3'b001  : imm = {{27{inst[31]}},inst[24:20]};
			      3'b101  : imm = {{27{inst[31]}},inst[24:20]};
			      default : imm = {{20{inst[31]}},inst[31:20]};
		    endcase
        //U-Type
        3'b010:  imm = {inst[31:12],12'b0};
        //B-Type
        3'b011:  imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        //S-Type
        3'b100:  imm = {{20{inst[31]}},inst[31:25], inst[11:7]};
        //J-Type
        3'b101:  imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};		
        default: imm = 32'b0;
    endcase
  end
endmodule
