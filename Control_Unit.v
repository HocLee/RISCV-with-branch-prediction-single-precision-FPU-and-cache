module Control_Unit (
    input            zero_control,   // Freeze Control Unit to stall the program
	input            cache_done  ,
	input      [2:0] type        ,
    input      [6:0] opcode      ,  
    input      [6:0] funct7      ,
    input      [2:0] funct3      ,
	input      [1:0] div_fp      ,
    output reg       Branch      ,   // notify B-type instruction
	output reg       Jump        ,   // notify J-type instruction and Jump
	output reg       PCspecial   ,   // only 1 when jalr (nextPC depends on rs1); otherwise NextPC depends on currentPC)
    output reg [1:0] MemtoReg    ,   // connect to Mux control after DataMem
    output reg [1:0] Asel        ,   // select input of 1st operand of ALU
    output reg [1:0] Bsel        ,   // select input of 2nd operand of ALU
    output reg       MemRd       ,   // Read Enable of Data Memory, connect to DataMem  
	output reg       MemWr       ,   // Write Enable of Data Memory, connect to DataMem
    output reg       RegWr       ,   // Write Enable for Integer Register,connect to registers file  
	output reg [1:0] Br_sel      ,   // select between B instructions
	output reg [2:0] Load_sel    ,   // select between load instructions; control Mux before write_data of RegFile
	output reg [1:0] Store_sel   ,   // select between S instructions; control Mux before write_data of DataMem
    output reg [3:0] ALU_sel     ,   // Operation selection of Interger ALU, connect to ALU
	output reg [1:0] ALU_sel_fp  ,   // Operation selection of Floating-point ALU, connect to ALU
	output reg       RegWr_fp    ,   // Write Enable for Floating-point Register, connect to floating point register
	output reg       data_sel        // choose data between integer or floating point register before DataMem
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

//==================ALU operation========================
parameter ALU_add  =  4'b0000;
parameter ALU_sub  =  4'b0001;
parameter ALU_srl  =  4'b0100; // Shift Right Logical
parameter ALU_sra  =  4'b0101; // Shift Right Arithmetic
parameter ALU_sll  =  4'b0110; // Shift Left  Logical
parameter ALU_sla  =  4'b0111; // Shift Left  Arithmetic
parameter ALU_and  =  4'b1000;
parameter ALU_or   =  4'b1001;
parameter ALU_xor  =  4'b1010;
parameter ALU_not  =  4'b1011;
parameter ALU_slt  =  4'b1100; // less than
parameter ALU_sltu =  4'b1101; // less than unsigned
parameter ALU_nop  =  4'b0011;

//================Instrucion type========================
//================based on opcode========================
parameter NoP     = 7'b0000000;
parameter R       = 7'b0110011;
parameter I       = 7'b0010011;
parameter ld      = 7'b0000011;
parameter st      = 7'b0100011;
parameter B       = 7'b1100011;
parameter jalr    = 7'b1100111; //Jump to address and place return address in rd, format: jalr rd,rs1,offset
parameter jal     = 7'b1101111; //Jump to address and place return address in rd, format: jal  rd,offset
parameter auipc   = 7'b0010111; //add upper immediate to pc
parameter lui     = 7'b0110111; //load upper immediate
parameter ld_fp   = 7'b0000111;
parameter st_fp   = 7'b0100111;
parameter fp_cal  = 7'b1010011;
parameter fp_add  = 2'b00;      //Perform single-precision floating-point addition
//parameter fp_sub  = 2'b01;
//parameter fp_mul  = 2'b10;
//parameter fp_div  = 2'b11;

//=======================================================
//  Behavioral coding
//=======================================================

always @(*) begin
    if ((zero_control && ~((opcode == 7'b1010011) &&(div_fp == 2'b11)))) begin 
	    Branch      = 1'b0;      // PC = PC + 4
		Jump        = 1'b0;      // no jump
		PCspecial   = 1'b0;      // no jalr
		MemtoReg    = 2'b00;     // ALU result -> registers files
		Asel        = 2'b00;     // 1st ALU operand from rs1
		Bsel        = 2'b00;     // 2nd ALU operand from rs2
		MemRd       = 1'b0;      // don't rd or wr data memory
		MemWr       = 1'b0;      // don't rd or wr data memory
		RegWr       = 1'b0;      // No Write to rd
		ALU_sel     = ALU_nop;   // ALU nop
		ALU_sel_fp  = fp_add;
		Br_sel      = 2'b00;
		Load_sel    = 3'b100;    // normal
		Store_sel   = 2'b10;     // normal
		RegWr_fp    = 1'b0;      // No Write to floating point register
		data_sel    = 1'b0;
		$display("Halt!!!");
	end 
    else begin       
	case(opcode)      
		R: begin
	        Branch      = 1'b0;      // PC = PC + 4
		    Jump        = 1'b0;      // no jump
		    PCspecial   = 1'b0;      // no jalr
            MemtoReg    = 2'b00;     // ALU result -> registers files
		    Asel        = 2'b00;     // 1st ALU operand from rs1
            Bsel        = 2'b00;     // 2nd ALU operand from rs2
            MemRd       = 1'b0;      // don't rd or wr data memory
		    MemWr       = 1'b0;      // don't rd or wr data memory
            RegWr       = 1;         // Write to rd
		    Br_sel      = 2'b00;
		    Load_sel    = 3'b100;    // normal
		    Store_sel   = 2'b10;     // normal
			RegWr_fp    = 1'b0;      // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp  = fp_add;
		    case (funct3)
		        3'b000: begin/// add or sub 
				    case (funct7)
					    7'b0000000: ALU_sel = ALU_add; // ALU add
						7'b0100000: ALU_sel = ALU_sub; // ALU sub
		                default:    ALU_sel = ALU_add; // ALU add
		            endcase			
			    end		 
	    		3'b001:  ALU_sel = ALU_sll;    // ALU sll
                3'b010:	 ALU_sel = ALU_slt;    // ALU slt
                3'b011:	 ALU_sel = ALU_sltu;   // ALU sllu
	            3'b100:	 ALU_sel = ALU_xor;    // ALU xor			
		        3'b101: begin                  // srl or sra
		            case(funct7)
				        7'b0000000: ALU_sel = ALU_srl; // ALU srl
			            7'b0100000: ALU_sel = ALU_sra; // ALU sra	
				        default:    ALU_sel = ALU_srl; // ALU srl
			        endcase
				end
		        3'b110:  ALU_sel = ALU_or;     // ALU or
		        3'b111:	 ALU_sel = ALU_and;    // ALU and
				default: ALU_sel = ALU_add;
		    endcase
	    end
		  
        I: begin
		    Branch      = 1'b0;      // PC = PC + 4
			Jump        = 1'b0;      // no jump
			PCspecial   = 1'b0;      // no jalr
            MemtoReg    = 2'b00;     // ALU result -> registers files
			Asel        = 2'b00;     // 1st ALU operand from rs1
            Bsel        = 2'b01;     // 2nd ALU operand from imm
            MemRd       = 1'b0;      // don't rd or wr data memory
			MemWr       = 1'b0;      // don't rd or wr data memory
            RegWr       = 1;         // Write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;    // normal
			Store_sel   = 2'b10;     // normal
			RegWr_fp    = 1'b0;      // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp    = fp_add;
			case (funct3)
			    3'b000:  ALU_sel = ALU_add;    // ALU add
				3'b001:  ALU_sel = ALU_sll;    // ALU sll
      		    3'b010:  ALU_sel = ALU_slt;    // ALU slt
                3'b011:  ALU_sel = ALU_sltu;   // ALU sltu
                3'b100:  ALU_sel = ALU_xor;    // ALU xor
                3'b101: begin                  //srli or srai                    
	                case(funct7)
			            7'b0000000: ALU_sel = ALU_srl; // ALU srl 
			            7'b0100000: ALU_sel = ALU_sra; // ALU sra
			            default:    ALU_sel = ALU_sra; // ALU sra
			        endcase
			    end
		        3'b110:   ALU_sel = ALU_or;     // ALU or
		        3'b111:	  ALU_sel = ALU_and;    // ALU and
			    default:  ALU_sel = ALU_add;
            endcase	 
		end
		  
        ld: begin
            Branch      = 1'b0;      // PC = PC + 4
			Jump        = 1'b0;      // no jump
			PCspecial   = 1'b0;      // no jalr
			MemtoReg    = 2'b01;     // data from DataMem -> Int registers files
			Asel        = 2'b00;     // 1st ALU operand from rs1
			Bsel        = 2'b01;     // 2nd ALU operand from imm
			MemRd       = 1'b1;      // Read data memory
			MemWr       = 1'b0;      // don't wr to data memory
			RegWr       = 1'b1;      // Write to rd
			Br_sel      = 2'b00;
			Store_sel   = 2'b00;     // normal
			ALU_sel     = ALU_add;   // ALU add
			RegWr_fp    = 1'b0;      // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp  = fp_add;
				case (funct3)
				    3'b000:  Load_sel    = 3'b000;    // lb
				    3'b001:  Load_sel    = 3'b001;    // lh
				    3'b010:  Load_sel    = 3'b100;    // lw
				    3'b100:  Load_sel    = 3'b010;    // lbu
				    3'b101:  Load_sel    = 3'b011;    // lhu 
				    default: Load_sel    = 3'b100;    // lw
				endcase
		end

        st: begin
            Branch      = 1'b0;      // PC = PC + 4
			Jump        = 1'b0;      // no jump
			PCspecial   = 1'b0;      // no jalr
			MemtoReg    = 2'b00;     // don't need to wr to registers files
			Asel        = 2'b00;     // 1st ALU operand from rs1
			Bsel        = 2'b01;     // 2nd ALU operand from imm
			MemRd       = 1'b0;      // Don't rd data memory
			MemWr       = 1'b1;      // wr to data memory
			RegWr       = 1'b0;      // Don't write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b000;    // don't care
			ALU_sel     = ALU_add;   // ALU add
			ALU_sel_fp  = fp_add;
			RegWr_fp    = 1'b0;      // No Write to floating point register
			data_sel    = 1'b0;
			 	case(funct3)
				    3'b000:  Store_sel   = 2'b00;     // sb
				    3'b001:  Store_sel   = 2'b01;     // sh
					3'b010:  Store_sel   = 2'b10;     // sw
					default: Store_sel   = 2'b10;     // sw
                endcase
		end
        B:  begin
            Branch      = 1;          // PC may not PC + 4, depends on zero flag from ALU
			Jump        = 1'b0;       // no jump
			PCspecial   = 1'b0;       // no jalr
			MemtoReg    = 2'b00;      // don't need -> don't care
			Asel        = 2'b00;      // 1st ALU operand from rs1
			Bsel        = 2'b00;      // 2nd ALU operand from rs2
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1'b0;       // don't need to write to registers file
			ALU_sel     = ALU_slt;    // ALU compare
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp  = fp_add;
				case(funct3)
				    3'b000:  Br_sel        = 2'b00; // beq
					3'b001:  Br_sel        = 2'b01; // bne
					3'b100:  Br_sel        = 2'b10; // blt
					3'b101:  Br_sel        = 2'b11; // bge
					3'b110:  Br_sel        = 2'b10; // bltu
					3'b111:  Br_sel        = 2'b11; // bgeu
					default: Br_sel        = 2'b00; // beq
                endcase
		end
        jalr:   begin
            Branch      = 1'b0;       // PC = PC + 4
			Jump        = 1'b1;       // jump
			PCspecial   = 1'b1;       // jalr
			MemtoReg    = 2'b00;      // ALU result -> registers files
			Asel        = 2'b01;      // 1st ALU operand is PC
			Bsel        = 2'b10;      // 2nd ALU operand is 4
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1;          // Write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			ALU_sel     = ALU_add;    // ALU add
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp    = fp_add;
        end
        jal:    begin
	        Branch      = 1'b0;       // PC = PC + 4
			Jump        = 1'b1;       // jump
			PCspecial   = 1'b0;       // no jalr
			MemtoReg    = 2'b00;      // ALU result -> registers files
			Asel        = 2'b01;      // 1st ALU operand is PC
			Bsel        = 2'b10;      // 2nd ALU operand is 4
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1;          // Write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			ALU_sel     = ALU_add;    // ALU add
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp    = fp_add;
        end
        auipc:  begin
	        Branch      = 1'b0;       // PC = PC + 4
			Jump        = 1'b0;       // no jump
			PCspecial   = 1'b0;       // no jalr
			MemtoReg    = 2'b00;      // ALU result -> registers files
			Asel        = 2'b01;      // 1st ALU operand from PC
			Bsel        = 2'b01;      // 2nd ALU operand from imm
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1;          // Write to rd
			Br_sel        = 2'b00;
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			ALU_sel       = ALU_add;  // ALU add
			ALU_sel_fp    = fp_add;
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
        end

	    lui:    begin
	        Branch      = 1'b0;       // PC = PC + 4
			Jump        = 1'b0;       // no jump
			PCspecial   = 1'b0;       // no jalr
			MemtoReg    = 2'b00;      // ALU result -> registers files
			Asel        = 2'b10;      // 1st ALU operand is 0
			Bsel        = 2'b01;      // 2nd ALU operand from imm
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1;          // Write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			ALU_sel     = ALU_add;    // ALU add
			ALU_sel_fp  = fp_add;
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
        end

	    ld_fp:  begin
		    Branch      = 1'b0;      // PC = PC + 4
			Jump        = 1'b0;      // no jump
			PCspecial   = 1'b0;      // no jalr
			MemtoReg    = 2'b01;     // data from DataMem -> floating point registers files
			Asel        = 2'b00;     // 1st ALU operand from rs1
			Bsel        = 2'b01;     // 2nd ALU operand from imm
			MemRd       = 1'b1;      // Read data memory
			MemWr       = 1'b0;      // don't wr to data memory
			RegWr       = 1'b1;      // No write to integer register
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;    // normal
			Store_sel   = 2'b10;     // normal
			ALU_sel     = ALU_add;   // ALU add
			ALU_sel_fp  = fp_add;
			RegWr_fp    = 1'b1;      // Write to floating point register
			data_sel    = 1'b1;
	    end

	    st_fp:  begin
		    Branch      = 1'b0;      // PC = PC + 4
			Jump        = 1'b0;      // no jump
			PCspecial   = 1'b0;      // no jalr
			MemtoReg    = 2'b00;     // don't need to wr to registers files
			Asel        = 2'b00;     // 1st ALU operand from rs1
			Bsel        = 2'b01;     // 2nd ALU operand from imm
			MemRd       = 1'b0;      // Don't rd data memory
			MemWr       = 1'b1;      // wr to data memory
			RegWr       = 1'b0;      // Don't write to rd
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;    // normal
			Store_sel   = 2'b10;     // normal
			ALU_sel     = ALU_add;   // ALU add
			ALU_sel_fp  = fp_add;
			RegWr_fp    = 1'b0;      // No Write to floating point register
			data_sel    = 1'b1;
		  end

	    fp_cal: begin
		    Branch      = 1'b0;      // PC = PC + 4
		    Jump        = 1'b0;      // no jump
		    PCspecial   = 1'b0;      // no jalr
            MemtoReg    = 2'b10;     // ALU result -> registers files
		    Asel        = 2'b00;     // 1st ALU operand from rs1
            Bsel        = 2'b00;     // 2nd ALU operand from rs2
            MemRd       = 1'b0;      // don't rd or wr data memory
		    MemWr       = 1'b0;      // don't rd or wr data memory
            RegWr       = 1'b0;      // Write to rd
		    Br_sel      = 2'b00;
		    Load_sel    = 3'b100;    // normal
		    Store_sel   = 2'b10;     // normal
			RegWr_fp    = 1'b1;      // Write to floating point register
			data_sel    = 1'b0;
			ALU_sel_fp  = funct7[3:2]; // add, sub, mul, div FP
		end

        default:    begin
            Branch      = 1'b0;       // PC = PC + 4
			Jump        = 1'b0;       // no jump
			PCspecial   = 1'b0;       // no jalr
            MemtoReg    = 2'b00;      // ALU result -> registers files
			Asel        = 2'b00;      // 1st ALU operand from rs1
			Bsel        = 2'b00;      // 2nd ALU operand from rs2
			MemRd       = 1'b0;       // don't rd or wr data memory
			MemWr       = 1'b0;       // don't rd or wr data memory
			RegWr       = 1;          // Write to rd
			ALU_sel     = ALU_nop;    // ALU nop
			ALU_sel_fp  = fp_add;
			Br_sel      = 2'b00;
			Load_sel    = 3'b100;     // normal
			Store_sel   = 2'b10;      // normal
			RegWr_fp    = 1'b0;       // No Write to floating point register
			data_sel    = 1'b0;
		end
    endcase
  end
end
endmodule
