`include "Control_Unit.v"
`include "Hazard_Detection.v"
`include "IM.v"
`include "ID.v"
`include "register_file.v"
`include "Branch_Predictor_Unit.v"
`include "Data_Mem.v"
`include "imm_gen.v"
`include "Forwarding_Unit.v"
`include "Forwarding_Unit_FP.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "ALU.v"
`include "FPU.v"
`include "D_FF.v"
`include "top_wrapper.v"
//`include "CLA.v"

`define cache
module RISCV(

	//////////// CLOCK /////////////////////
	input 		          		  CLOCK_50,
	input                         reset,
    input              [31:0]     addr_in,
	//////////// INPUT ////////////////////
	input 		       [9:0]	  SW,

	//////////// OUTPUT ///////////////////
	output		       [9:0]	  LEDR,
	output                        a,
	output             [1:0]      b,
	output 		       [31:0]     r,r1,pc_out,r2
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [6:0]  w_opcode, w_opcode_reg;  						   // out ID
wire [4:0]  w_rd, w_rd_reg, w_rd_reg1, w_rd_reg2;              // out ID
wire [4:0]  w_rs1;   								           // out ID
wire [4:0]  w_rs2;   										   // out ID
wire [4:0]  w_rs1_reg, w_rs2_reg, w_rs2_reg1;				   // out Reg_ID_EX
wire [2:0]  w_funct3;   									   // out ID
wire [6:0]  w_funct7;   									   // out ID
wire [2:0]  w_type;   										   // out ID, in ImmGen
wire [31:0] w_imm, w_imm_reg;   							   // out ImmGen
wire [31:0] w_addr_ins, w_addr_ins_temp  ;   				   // out PC, in Reg_IF_ID
wire [31:0] w_addr_ins_reg, w_addr_ins_reg1,w_addr_ins_reg2;   // out Reg_IF_ID -> Reg_ID_EX -> CLA1
wire [31:0] w_addr_ins1 ;   								   // input of A of adder 1 to calculate nextPC (currentPC or rs1)
wire [31:0] w_ins       ;   								   // out IM, in ID, in Reg_IF_ID
wire [31:0] w_ins_reg   ;   								   // out Reg_IF_ID -> in ID
wire [31:0] w_readdata1, w_readdata2, w_readdata1_fp, w_readdata2_fp, w_readdata1_fp_reg, w_readdata2_fp_reg; 	// w_readdata1: out RegFile -> Reg_ID_EX -> in ALU
wire [31:0] w_readdata1_reg, w_readdata2_reg, w_readdata2_reg1, w_readdata2_fp_reg1; // w_readdata2: out RegFile -> Reg_ID_EX -> in ALU -> Reg_EX_MEM
wire [31:0] w_readdata1_forward, w_readdata2_forward;
wire [31:0] w_inALU2;   									   // in ALU2
wire [31:0] w_inALU1;   									   // in ALU1
wire        w_Branch, w_MemRd, w_MemWr; 					   // out Control unit -> Reg_ID_EX -> Reg_EX_MEM
wire        w_Branch_reg, w_MemRd_reg, w_MemWr_reg;			   // out Reg_ID_EX
wire        w_Branch_reg1, w_MemRd_reg1, w_MemWr_reg1; 		   // out Reg_EX_MEM
wire        w_MemRd_reg2;
wire        w_MemRd_reg3, w_RegWr_reg3;						   // out Reg_AfterMEM_WB
wire [4:0]  w_rd_reg3;             							   // out Reg_AfterMEM_WB
wire [1:0]  w_MemtoReg, w_MemtoReg_reg, w_MemtoReg_reg1,w_MemtoReg_reg1_release, w_MemtoReg_reg2; // out Control unit -> Reg_ID_EX -> Reg_EX_MEM -> Reg_MEM_WB
wire        w_RegWr, w_RegWr_reg, w_RegWr_reg1, w_RegWr_reg2; 	// out Control unit -> Reg_ID_EX -> Reg_EX_MEM -> Reg_MEM_WB
wire [3:0]  w_ALU_sel,w_ALU_sel_reg;  								// out Control unit
wire [1:0]  w_ALU_sel_fp, w_ALU_sel_fp_reg;
wire [31:0] w_ALUresult, w_ALUresult_fp, w_ALUresult_reg, w_ALUresult_fp_reg, w_ALUresult_fp_reg1, w_ALUresult_reg1;    // out ALU -> Reg_EX_MEM -> in DataMem or Reg_MEM_WB
wire [31:0] w_ReadData, w_ReadData_reg  ;   					// out DataMem -> Reg_MEM_WB -> RegFile
wire [31:0] w_WriteData ;  										// in RegFile,
wire [31:0] w_WriteData1;   									// out Mux after DataMem,
wire [31:0] w_MemDataWr, w_MemDataWr1;							// in DataMem
wire        w_zero, w_zero_reg;   								// out ALU,
wire        w_lt, w_lt_reg;  									// out ALU,
wire [1:0]  w_Br_sel,w_Br_sel_reg, w_Br_sel_reg1;   					// out Control unit
wire [31:0] w_Normal_ins, w_Normal_ins_reg, w_Normal_ins_reg1;  // out Adder1, PC + 4
wire [31:0] w_Branch_ins, w_Branch_ins_reg;   					// out Adder2,
wire [31:0] w_Next_ins  ;   									// out mux top, in PC
wire        w_Next_ins_temp, w_Next_ins_temp1;
wire        w_ALUOF, w_ALUneg, w_adder1OF, w_adder1zero, w_adder2OF, w_adder2zero; // non-connect
wire        w_Jump, w_PCspecial,w_Jump_reg, w_PCspecial_reg, w_Jump_reg1, w_PCspecial_reg1;
wire [1:0]  w_Asel, w_Bsel; 									// select inputs of 1st and 2nd ALU operand
wire [1:0]  w_Asel_reg, w_Bsel_reg; 							// out Reg_ID_EX
wire [2:0]  w_Load_sel, w_Load_sel_reg, w_Load_sel_reg1, w_Load_sel_reg2; // out Control Unit -> Reg_ID_EX -> Reg_EX_MEM -> Reg_MEM_WB
wire [1:0]  w_Store_sel, w_Store_sel_reg, w_Store_sel_reg1; 	// out Control Unit -> Reg_ID_EX -> Reg_EX_MEM
wire [1:0]  w_ForwardASel, w_ForwardBSel, w_ForwardASel_fp, w_ForwardBSel_fp;                      // output of Forwarding unit
wire        w_ForwardStoSel;                                    // output of Forwarding unit_MEM
wire [31:0] w_WriteData_hazard;
wire        w_PC_remain, w_Reg_IF_ID_remain, w_zero_control;    // output of Hazard_Detection_Unit
wire [31:0] w_target_predict;
wire [31:0] actual_pc_temp, actual_pc;
wire        w_pc_sel,w_predict_bit_BP,w_predict_bit_BP_reg,w_predict_bit_BP_reg1;
wire        w_wrong_predict;
wire        w_RegWr_fp, w_RegWr_fp_reg, w_RegWr_fp_reg1, w_RegWr_fp_reg2, w_data_sel, w_data_sel_reg, w_data_sel_reg1;
wire        w_overflow_fp, w_underflow_fp, w_div_done,w_normalized_round_done,w_done_cal;
wire [31:0] w_readdata1_fp_forward, w_readdata2_fp_forward;
reg  [1:0]  count;
wire [31:0] w_next_addr;
wire [5:0]  w_check;
reg  [10:0] count_ins, count_br, count_wrong, count_jmp, count_stall;
wire        w_stall, cache_done ,d1_w_stall;

wire         w_MemRd_reg1_release        ;
wire         w_RegWr_reg1_release        ;
wire         w_MemWr_reg1_release        ;
//wire  [1:0]  w_MemtoReg_reg1_release     ;
wire         w_zero_reg_release         ;
wire         w_lt_reg_release           ;
wire  [4:0]  w_rd_reg1_release           ;
wire  [4:0]  w_rs2_reg1_release          ;
wire  [31:0] w_Branch_ins_reg_release		      ;
wire  [31:0] w_addr_ins_reg2_release	  ;  
wire  [31:0] w_readdata2_reg1_release    ;
wire  [1:0]  w_Br_sel_reg1_release       ;
wire         w_Branch_reg1_release       ;
wire         w_Jump_reg1_release         ;
wire  [2:0]  w_Load_sel_reg1_release     ; 
wire  [1:0]  w_Store_sel_reg1_release    ; 
wire  [31:0] w_ALUresult_reg_release   ;

wire         w_RegWr_fp_reg1_release     ; 
wire  [31:0] w_readdata2_fp_reg1_release ;
wire  [31:0] w_ALUresult_fp_reg_release;
wire         w_data_sel_reg1_release ;


//=======================================================
//  Behavioral coding
//=======================================================

//assign pc_out = w_Next_ins;


    assign w_next_addr = (count == 2'b01) ?  addr_in : w_Next_ins;
`ifdef cache
    always@(posedge CLOCK_50&&~w_stall or posedge reset) 
`else
    always@(posedge CLOCK_50 or posedge reset) 
`endif
    begin
       if (reset) begin
            count <= 'd0;
        end
        else begin
            if (count == 2'b11) begin
                count <= count;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

`ifdef cache
    always@(posedge CLOCK_50&&~w_stall or posedge reset) 
`else
    always@(posedge CLOCK_50 or posedge reset) 
`endif
    begin
        if (reset) begin
            count_ins <= 'd0;
        end
        else begin
            count_ins <= count_ins + 1'b1;
        end
    end

`ifdef cache
    always@(posedge CLOCK_50&&~w_stall or posedge reset) 
`else
    always@(posedge CLOCK_50 or posedge reset) 
`endif
    begin
        if (reset) begin
            count_br <= 'd0;
        end
        else begin
            if (w_opcode == 7'b1100011) begin
                count_br <= count_br + 1'b1;
            end
            else begin
                count_br <= count_br;
            end
        end
    end

`ifdef cache
    always@(posedge CLOCK_50&&~w_stall or posedge reset) 
`else
    always@(posedge CLOCK_50 or posedge reset) 
`endif
    begin
        if (reset) begin
            count_jmp <= 'd0;
        end
        else begin
            if (w_opcode == 7'b1101111) begin
                count_jmp <= count_jmp + 1'b1;
            end
            else begin
                count_jmp <= count_jmp;
            end
        end
    end

`ifdef cache
    always@(posedge CLOCK_50&&~w_stall or posedge reset) 
`else
    always@(posedge CLOCK_50 or posedge reset) 
`endif
    begin
        if (reset) begin
            count_wrong <= 'd0;
        end
        else begin
            if (w_wrong_predict) begin
                count_wrong <= count_wrong + 1'b1;
            end
            else begin
                count_wrong <= count_wrong;
            end
        end
    end

    always@(posedge w_PC_remain or posedge reset) begin
        if (reset) begin
            count_stall <= 'd0;
        end
        else begin
            if (w_PC_remain) begin
                count_stall <= count_stall + 1'b1;
            end
            else begin
                count_stall <= count_stall;
            end
        end
    end


//=======================================================
//  Structural coding
//=======================================================


//********************************************************
//                      FETCH STAGE
//********************************************************
    IM u_IM (
        .pc          (w_addr_ins),
        .instruction (w_ins)     
    );

    D_FF PC (
        .rst_in     (1'b0)        ,
`ifdef cache
        .clk_in             (CLOCK_50&&~w_stall&&~d1_w_stall),
`else
        .clk_in             (CLOCK_50),
`endif        
        .PC_remain  (w_PC_remain) , 
        .D_in       (w_next_addr) ,
	    .Q_out      (w_addr_ins)
    );
    CLA Adder1 (                       // Branch Instruction
        .A_in        (w_addr_ins1) ,
	    .B_in        (w_imm_reg)   ,
	    .mode        (1'b0)        ,   //0: add; 1: sub
	    .S           (w_Branch_ins),
	    .overflow    (w_adder1OF)  ,
	    .zero        (w_adder1zero)
    );
    CLA Adder2 (                       //PC + 4 ; Normal Instruction                    
        .A_in        (w_addr_ins)  ,
	    .B_in        (32'd4)       ,
	    .mode        (1'b0)        ,   //0: add; 1: sub
	    .S           (w_Normal_ins) ,
	    .overflow    (w_adder2OF)   ,
	    .zero        (w_adder2zero)
    );
    assign w_Next_ins_temp  = (w_Br_sel_reg[1]) ? (w_Br_sel_reg[0] ? (~w_lt) & w_Branch_reg : w_lt & w_Branch_reg) : (w_Br_sel_reg[0] ? ~(w_zero) & w_Branch_reg : w_zero & w_Branch_reg);// mux PC selection
    assign w_Next_ins_temp1 = w_Next_ins_temp | w_Jump_reg;
    assign w_Next_ins       = (w_wrong_predict) ? actual_pc : (w_pc_sel) /*1'b0*/ ? w_target_predict : w_Normal_ins;
    assign actual_pc        = (w_Next_ins_temp | w_Jump_reg) ? w_Branch_ins: w_Normal_ins_reg1;
    
    Branch_Predictor_Unit u_Branch_Predictor_Unit
    (    
`ifdef cache
        .clk                (CLOCK_50&&~w_stall&&~d1_w_stall),
`else
        .clk                (CLOCK_50),
`endif        
	    .rst              (reset)                     ,
	    .update_i         (w_Branch_reg | w_Jump_reg) , // inform B,J type
	    .taken_i          (w_Next_ins_temp1)          ,
	    .pc_ex_i          (w_addr_ins_reg1)           , // after Reg ID_EX
	    .pc_in_i          (w_addr_ins)                ,
	    .target_pc_i      (w_Branch_ins)              ,	 
	    .pc_sel_o         (w_pc_sel)                  , // PC + 4 or BJ
	    .target_predict_o (w_target_predict),
	    .predict_bit_BP_o (w_predict_bit_BP)
    );

    assign w_wrong_predict = ((w_Next_ins_temp1 ^ w_predict_bit_BP_reg1) & (w_Branch_reg | w_Jump_reg));  
    assign w_addr_ins1     = (w_PCspecial_reg) ? w_readdata1_reg : w_addr_ins_reg1;
//**************************************************************
//                    REGISTER IF/ID
//**************************************************************

    IF_ID u_Reg_IF_ID(
`ifdef cache
        .clk                (CLOCK_50&&~w_stall&&~d1_w_stall),
`else
        .clk                (CLOCK_50),
`endif        
	    .rst                (reset | w_wrong_predict) ,
	    .Reg_IF_ID_remain   (w_Reg_IF_ID_remain),
	    .if_predicted_bit   (w_predict_bit_BP),
        .if_pc              (w_addr_ins)    ,
        .if_next_pc         (w_Normal_ins),
        .if_inst            (w_ins)       ,
	    .id_pc              (w_addr_ins_reg),
        .id_next_pc         (w_Normal_ins_reg),
	    .id_predicted_bit   (w_predict_bit_BP_reg),
        .id_inst            (w_ins_reg)
    );

//**************************************************************
//                    DECODE STAGE
//**************************************************************

    ID u_ID (
        .instruction    (w_ins_reg),
        .rd             (w_rd)     ,
        .rs1            (w_rs1)    ,
        .rs2            (w_rs2)    , 
        .opcode         (w_opcode) ,
        .funct3         (w_funct3) ,
        .funct7         (w_funct7) ,
        .type		    (w_type)
    );

   imm_gen Imm_Gen (
        .inst 		  (w_ins_reg), 
        .type     	  (w_type)   ,	
        .imm          (w_imm)  
    );

    register_file u_RegFile_Int (
	    .read_reg1     (w_rs1)       ,
	    .read_reg2     (w_rs2)       ,
	    .write_reg     (w_rd_reg2)   ,
	    .write_data    (w_WriteData) ,
	    .write_flag    (w_RegWr_reg2),
	    .clk           (CLOCK_50)    ,
	    .rst           (reset)       ,
	    .read_data_1   (w_readdata1) ,
	    .read_data_2   (w_readdata2)
    );

    register_file u_RegFile_FPU (
	    .read_reg1    (w_rs1)          ,
	    .read_reg2    (w_rs2)          ,
	    .write_reg     (w_rd_reg2)      ,
	    .write_data    (w_WriteData)    ,
	    .write_flag    (w_RegWr_fp_reg2),
	    .clk           (CLOCK_50)       ,
	    .rst           (reset)          ,
	    .read_data_1   (w_readdata1_fp) ,
	    .read_data_2   (w_readdata2_fp)
    );


    Control_Unit u_Control_Unit(
	    .zero_control (w_zero_control | w_wrong_predict),
        .cache_done   (1),
	    .type         (w_type)           ,
        .opcode       (w_opcode)         ,  
        .div_fp       (w_ins_reg[28:27]) ,
        .funct7       (w_funct7)         ,
        .funct3       (w_funct3)         ,
        .Branch       (w_Branch)         , // notify B-type instruction
	    .Jump         (w_Jump)           , // notify J-type instruction and Jump
	    .PCspecial    (w_PCspecial)      , // only 1 when jalr (nextPC depends on rs1); otherwise NextPC depends on currentPC)
        .MemtoReg     (w_MemtoReg)       , // connect to mux after DataMem
	    .Asel         (w_Asel)           , // connect to mux select input of 1st operand of ALU
        .Bsel         (w_Bsel)           , // connect to mux select input ALU2
        .MemRd        (w_MemRd)          , // connect to DataMem  
	    .MemWr        (w_MemWr)          , // connect to DataMem
        .RegWr        (w_RegWr)          , // connect to registers file
	    .Br_sel       (w_Br_sel)         ,
	    .Load_sel     (w_Load_sel)       ,
	    .Store_sel    (w_Store_sel)      ,
        .ALU_sel      (w_ALU_sel)        , // connect to Int ALU
	    .ALU_sel_fp   (w_ALU_sel_fp)     , // connect to FPU ALU
	    .RegWr_fp     (w_RegWr_fp)       , // connect to floating point register
	    .data_sel     (w_data_sel)         // choose data between integer or floating point register before DataMem
);



    Hazard_Detection u_Hazard_Detection_Unit(
`ifdef cache
        .clk                (CLOCK_50&&~w_stall&&~d1_w_stall),
        .clk_2              (CLOCK_50),
`else
        .clk                (CLOCK_50),
        .clk_2              (CLOCK_50),
`endif        
        .rst                (reset),
        .stall              (cache_done),
        .rs1_id             (w_ins_reg[19:15])      , // From IM  
        .rs2_id             (w_ins_reg[24:20])      , // From IM
	    .rd_id              (w_ins_reg[11:7])       , // From IM 
        .opcode             (w_opcode),
        .opcode_ex          (w_opcode_reg),
        .div_fp             (w_ins_reg[28:27]),
        .check_div_fp       (w_check),
        .rd_ex              (w_rd_reg)          , // From Reg_ID_EX 
        .MemRd_ex           (w_MemRd_reg)       , // From Reg_ID_EX 
	    .MemWr_id           (w_MemWr)           ,
        .PC_remain          (w_PC_remain)       , // -> PC
	    .Reg_IF_ID_remain   (w_Reg_IF_ID_remain), // -> Reg_IF_ID
	    .zero_control       (w_zero_control)      // -> Control Unit    
    );
//**************************************************************
//                    REGISTER ID/EX
//**************************************************************

    ID_EX u_Reg_ID_EX(
    //INPUT
`ifdef cache
        .clk                (CLOCK_50&&~w_stall),
`else
        .clk                (CLOCK_50),
`endif        
	    .rst              (reset | w_wrong_predict),
        .id_pc            (w_addr_ins_reg)  ,// output of reg IF/ID
        .id_next_pc       (w_Normal_ins_reg),// output of reg IF/ID
        .id_DataA         (w_readdata1),     // output of Register File: readdata1
        .id_DataB         (w_readdata2),     // output of Register File: readdata2
        .id_rd            (w_rd)       ,     // output of Instruction Decode
        .id_rs1           (w_rs1)      ,     // output of Instruction Decode
        .id_rs2           (w_rs2)      ,     // output of Instruction Decode
	    .id_opcode        (w_opcode)   ,     // output of Instruction Decode
        .id_Branch        (w_Branch)   ,     // output of Control Unit to notify B-type instruction
        .id_Jump          (w_Jump)     ,     // output of Control Unit to notify J-type instruction
        .id_PCspecial     (w_PCspecial),     // output of Control Unit to notify jalr instruction
        .id_Asel          (w_Asel)     ,     // output of Control Unit to select 1st operand of ALU
        .id_Bsel          (w_Bsel)     ,     // output of Control Unit to select 2nd operand of ALU
        .id_MemRd         (w_MemRd)    ,     // output of Control Unit to read from DataMem
        .id_MemWr         (w_MemWr)    ,  	 // output of Control Unit to write to DataMem
        .id_RegWr         (w_RegWr)    ,     // output of Control Unit to write to Integer Register File
        .id_MemtoReg      (w_MemtoReg) ,     // output of Control Unit to control Mux after DataMem
        .id_ALU_sel       (w_ALU_sel)  ,     // output of Control Unit to select ALU
        .id_Br_sel        (w_Br_sel)   ,     // output of Control Unit to select type of Branch
        .id_Load_sel      (w_Load_sel) ,     // output of Control Unit to select type of Load
        .id_Store_sel     (w_Store_sel),     // output of Control Unit to select type of Store
        .id_imm           (w_imm)      ,     // output of ImmGen
	    .id_predicted_bit (w_predict_bit_BP_reg),
	    .id_RegWr_fp      (w_RegWr_fp) ,     // output of Control Unit to write to FPU Register File
	    .id_DataA_fp      (w_readdata1_fp),  // output of Register File: readdata1
        .id_DataB_fp      (w_readdata2_fp),  // output of Register File: readdata2
	    .id_data_sel      (w_data_sel) ,
        .id_ALU_sel_fp    (w_ALU_sel_fp),
    // OUPUT
        .ex_pc 		      (w_addr_ins_reg1),
        .ex_next_pc       (w_Normal_ins_reg1),
        .ex_DataA         (w_readdata1_reg),
        .ex_DataB         (w_readdata2_reg),
        .ex_rd            (w_rd_reg)       ,
	    .ex_rs1           (w_rs1_reg)      ,    // -> Forwarding unit
        .ex_rs2           (w_rs2_reg)      ,    // -> Forwarding unit
	    .ex_opcode        (w_opcode_reg)   ,    // -> Forwarding unit
        .ex_Branch        (w_Branch_reg)   ,    // -> Reg EX_MEM
        .ex_Jump          (w_Jump_reg)     ,    // -> Reg EX_MEM
        .ex_PCspecial     (w_PCspecial_reg),    // -> Reg EX_MEM    
        .ex_Asel          (w_Asel_reg)     ,
        .ex_Bsel          (w_Bsel_reg)     ,
        .ex_MemRd         (w_MemRd_reg)    ,
        .ex_MemWr         (w_MemWr_reg)    ,
        .ex_RegWr         (w_RegWr_reg)    ,    // -> Reg EX_MEM -> RegMEM_WB -> RegFile
        .ex_MemtoReg      (w_MemtoReg_reg) ,    // -> Reg EX_MEM -> RegMEM_WB -> mux after DataMem
        .ex_ALU_sel       (w_ALU_sel_reg)  ,    // -> ALU
        .ex_Br_sel        (w_Br_sel_reg)   ,    // -> Reg EX_MEM
        .ex_Load_sel      (w_Load_sel_reg) ,    // Reg EX_MEM -> RegMEM_WB -> mux after  mux of DataMem
        .ex_Store_sel     (w_Store_sel_reg),    // -> Reg EX_MEM -> mux -> WriteData of DataMem
        .ex_imm           (w_imm_reg),	        // CLA1
	    .ex_predicted_bit (w_predict_bit_BP_reg1),
	    .ex_RegWr_fp      (w_RegWr_fp_reg)    , // -> Reg EX_MEM -> RegMEM_WB -> RegFile
	    .ex_DataA_fp      (w_readdata1_fp_reg), // output of Register File: readdata1
        .ex_DataB_fp      (w_readdata2_fp_reg), // output of Register File: readdata2
	    .ex_data_sel      (w_data_sel_reg)    , 
        .ex_ALU_sel_fp    (w_ALU_sel_fp_reg)
    );

//**************************************************************
//                    EXECUTE STAGE
//**************************************************************

//mux before ALU

assign w_inALU1 = (w_Asel_reg[1])? 3'b000 : (w_Asel_reg[0])  ? w_addr_ins_reg1 : w_readdata1_forward ;   //  00:rs1, 01:PC, 10: 0
assign w_inALU2 = (w_Bsel_reg[1])? 3'b100 : (w_Bsel_reg[0])  ? w_imm_reg       : w_readdata2_forward ;   //  00:rs2, 01:imm, 10: 4
assign w_readdata1_forward = (w_ForwardASel[1])? w_ALUresult_reg : (w_ForwardASel[0])? w_WriteData : w_readdata1_reg;
assign w_readdata2_forward = (w_ForwardBSel[1])? w_ALUresult_reg : (w_ForwardBSel[0])? w_WriteData : w_readdata2_reg;

    ALU Int_ALU (
	    .in1        (w_inALU1),
	    .in2        (w_inALU2)   ,
	    .sel        (w_ALU_sel_reg),
	    .ALU_result (w_ALUresult),
	    .ALU_of     (w_ALUOF)    ,
	    .ALU_zero   (w_zero)     ,
	    .ALU_lt     (w_lt),
	    .ALU_neg    (w_ALUneg)
    );



    assign w_readdata1_fp_forward = (w_ForwardASel_fp[1])? w_ALUresult_fp_reg : (w_ForwardASel_fp[0])? w_WriteData : w_readdata1_fp_reg;
    assign w_readdata2_fp_forward = (w_ForwardBSel_fp[1])? w_ALUresult_fp_reg : (w_ForwardBSel_fp[0])? w_WriteData : w_readdata2_fp_reg;

    FPU FPU_ALU(
`ifdef cache
        .clk                (CLOCK_50&&~w_stall),
`else
        .clk                (CLOCK_50),
`endif        
        .rstn                 (!reset),
        .stall                (1'b0),
        .a_in                 (w_readdata1_fp_forward),
        .b_in                 (w_readdata2_fp_forward),
        .sel                  (w_ALU_sel_fp_reg),
        .check_div_fp         (w_check),
        .normalized_round_done(w_normalized_round_done),
        .overflow             (w_overflow_fp),
        .underflow            (w_underflow_fp),
        .done_cal             (w_done_cal),
        .alu_out              (w_ALUresult_fp)
    );    

    Forwarding_Unit u_Forwarding_Unit(
        .rs1_ex      (w_rs1_reg)    ,  // from Reg_ID_EX
        .rs2_ex      (w_rs2_reg)    ,  // from Reg_ID_EX
        .rd_mem      (w_rd_reg1_release)    ,  // from Reg_EX_MEM
        .rd_wb       (w_rd_reg2)    ,  // from Reg_MEM_WB
        .RegWr_mem   (w_RegWr_reg1_release) ,  // from Reg_EX_MEM
        .RegWr_wb    (w_RegWr_reg2) ,  // from Reg_MEM_WB
	    .MemRd_wb    (w_MemRd_reg)  ,
	    .MemWr_mem   (w_MemWr_reg1_release) ,  // from Reg_EX_MEM
	    .MemWr_wb    (w_MemWr_reg2) ,
	    .opcode_ex   (w_opcode_reg) ,
        .Forward_ASel(w_ForwardASel),
        .Forward_BSel(w_ForwardBSel) 
  );
  
    Forwarding_Unit_FP u_Forwarding_Unit_FP(
        .rs1_ex      (w_rs1_reg),        // from Reg_ID_EX
        .rs2_ex      (w_rs2_reg),        // from Reg_ID_EX
        .rd_mem      (w_rd_reg1_release),        // from Reg_EX_MEM
        .rd_wb       (w_rd_reg2),        // from Reg_MEM_WB
        .RegWr_mem   (w_RegWr_fp_reg1_release),  // from Reg_EX_MEM
        .RegWr_wb    (w_RegWr_fp_reg2),  // from Reg_MEM_WB
	    .MemRd_wb    (w_MemRd_reg),
	    .MemWr_mem   (w_MemWr_reg1_release),     // from Reg_EX_MEM
	    .MemWr_wb    (w_MemWr_reg2),
	    .opcode_ex   (w_opcode_reg),
        .Forward_ASel(w_ForwardASel_fp),
        .Forward_BSel(w_ForwardBSel_fp) 
    );






//**************************************************************
//                    REGISTER EX/MEM
//**************************************************************

    EX_MEM u_Reg_EX_MEM(
    //INPUT

`ifdef cache
        .clk                (CLOCK_50&&~w_stall),
`else
        .clk                (CLOCK_50),
`endif        
        .rst                (reset | w_wrong_predict),
        .ex_MemRd           (w_MemRd_reg), 	 // Control Unit -> Reg_EX_MEM
        .ex_RegWr           (w_RegWr_reg), 	 // Control Unit -> Reg_EX_MEM
	    .ex_MemWr           (w_MemWr_reg),
        .ex_MemtoReg        (w_MemtoReg_reg), // Control Unit -> Reg_EX_MEM
        .ex_zero            (w_zero),         // ALU -> Reg_EX_MEM
        .ex_lt              (w_lt),			    // ALU -> Reg_EX_MEM
        .ex_rd              (w_rd_reg), 		 // ID block     -> Reg_EX_MEM
	    .ex_rs2             (w_rs2_reg),      // Reg ID_EX    -> Reg_EX_MEM
        .ex_pc              (w_Branch_ins),   // result of 1st CLA
	    .ex_current_pc      (w_addr_ins_reg1), // current PC
        .ex_readdata2       (w_readdata2_forward/*w_readdata2_reg*/),// Reg file -> Reg ID_EX  -> Reg_EX_MEM
        .ex_Br_sel          (w_Br_sel_reg),     // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
        .ex_Branch          (w_Branch_reg),   // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
        .ex_Jump            (w_Jump_reg),     // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
        .ex_Load_sel        (w_Load_sel_reg), // Control Unit -> Reg ID_EX  -> Reg_EX_MEM -> Reg Mem/WB
        .ex_Store_sel       (w_Store_sel_reg), // Control Unit -> Reg ID_EX  -> Reg_EX_MEM -> DataMem
        .ex_ALU_result      (w_ALUresult),
	    .ex_predicted_bit   ( ),
	    .ex_RegWr_fp        (w_RegWr_fp_reg), // Control Unit -> Reg_EX_MEM
	    .ex_readdata2_fp    (w_readdata2_fp_forward),
	    .ex_ALU_result_fp   (w_ALUresult_fp),
	    .ex_data_sel        (w_data_sel_reg) ,

        .stall              (0),

    //OUTPUT                
        .mem_MemRd          (w_MemRd_reg1), 	 // -> DataMem
        .mem_RegWr          (w_RegWr_reg1),   	 // -> Reg MEM_WB
        .mem_MemWr          (w_MemWr_reg1),  	 // -> DataMem
        .mem_MemtoReg       (w_MemtoReg_reg1),	 // -> Reg MEM_WB
        .mem_zero           (w_zero_reg),     	 // B-type sel
        .mem_lt             (w_lt_reg),       	 // B-type sel      
        .mem_rd             (w_rd_reg1),      	 // -> Reg MEM_WB
	    .mem_rs2            (w_rs2_reg1),
        .mem_pc		        (w_Branch_ins_reg),  // -> Mux before PC 
	    .mem_current_pc     (w_addr_ins_reg2),
        .mem_readdata2      (w_readdata2_reg1),  // -> input of Load Mux
        .mem_Br_sel         (w_Br_sel_reg1),     // B-type sel
        .mem_Branch         (w_Branch_reg1),     // B-type sel
        .mem_Jump           (w_Jump_reg1),       // B-type sel
        .mem_Load_sel       (w_Load_sel_reg1),   // -> Load Mux
        .mem_Store_sel      (w_Store_sel_reg1),  // -> Store Mux
        .mem_ALU_result     (w_ALUresult_reg),   // -> addr of DataMem or Reg MEM_WB  
        .mem_predicted_bit  (),
        .mem_RegWr_fp       (w_RegWr_fp_reg1),   // -> Reg MEM_WB	 
	    .mem_readdata2_fp   (w_readdata2_fp_reg1),
	    .mem_ALU_result_fp  (w_ALUresult_fp_reg),
	    .mem_data_sel       (w_data_sel_reg1) 
    );


//**************************************************************
//                    MEMORY STAGE
//**************************************************************


`ifndef cache
    Data_Mem u_Data_Mem (
    .clk        (CLOCK_50)                                             ,
    .rst        (reset)                                                ,
    .Address    (w_ALUresult_reg)                                      ,
    .DataWrite  ((w_data_sel_reg1) ? w_readdata2_fp_reg1 : w_MemDataWr),
    .MemWr      (w_MemWr_reg1)                                         ,
    .MemRd      (w_MemRd_reg1)                                         ,
    .ReadData   (w_ReadData)        
);
`else
///*
    top_wrapper D_mem (
    .clk        (CLOCK_50),
    .rstn       (~reset),
	.req_cpu    (w_MemWr_reg1 | w_MemRd_reg1),
	.write      (w_MemWr_reg1),
	.read       (w_MemRd_reg1),
    //.read_cmd_capture (w_MemtoReg_reg1),
    //.read_cmd_release (w_MemtoReg_reg1_release),
	.address    (w_ALUresult_reg),
	.wrdata     ((w_data_sel_reg1) ? w_readdata2_fp_reg1 : w_MemDataWr),
	.rddata     (w_ReadData),
	.stall      (w_stall),
    .d1_stall   (d1_w_stall),
	.done       (cache_done),

    .mem_MemRd          (w_MemRd_reg1), 	 // -> DataMem
    .mem_RegWr          (w_RegWr_reg1),   	 // -> Reg MEM_WB
    .mem_MemWr          (w_MemWr_reg1),  	 // -> DataMem
    .mem_MemtoReg       (w_MemtoReg_reg1),	 // -> Reg MEM_WB
    .mem_zero           (w_zero_reg),     	 // B-type sel
    .mem_lt             (w_lt_reg),       	 // B-type sel      
    .mem_rd             (w_rd_reg1),      	 // -> Reg MEM_WB
    .mem_rs2            (w_rs2_reg1),
    .mem_pc		        (w_Branch_ins_reg),  // -> Mux before PC 
    .mem_current_pc     (w_addr_ins_reg2),
    .mem_readdata2      (w_readdata2_reg1),  // -> input of Load Mux
    .mem_Br_sel         (w_Br_sel_reg1),     // B-type sel
    .mem_Branch         (w_Branch_reg1),     // B-type sel
    .mem_Jump           (w_Jump_reg1),       // B-type sel
    .mem_Load_sel       (w_Load_sel_reg1),   // -> Load Mux
    .mem_Store_sel      (w_Store_sel_reg1),  // -> Store Mux
    .mem_ALU_result     (w_ALUresult_reg),   // -> addr of DataMem or Reg MEM_WB  
    .mem_predicted_bit  (),
    .mem_RegWr_fp       (w_RegWr_fp_reg1),   // -> Reg MEM_WB	 
    .mem_readdata2_fp   (w_readdata2_fp_reg1),
    .mem_ALU_result_fp  (w_ALUresult_fp_reg),
    .mem_data_sel       (w_data_sel_reg1), 

    .mem_MemRd_release          (w_MemRd_reg1_release), 	 // -> DataMem
    .mem_RegWr_release          (w_RegWr_reg1_release),   	 // -> Reg MEM_WB
    .mem_MemWr_release          (w_MemWr_reg1_release),  	 // -> DataMem
    .mem_MemtoReg_release       (w_MemtoReg_reg1_release),	 // -> Reg MEM_WB
    .mem_zero_release           (w_zero_reg_release),     	 // B-type sel
    .mem_lt_release             (w_lt_reg_release),       	 // B-type sel      
    .mem_rd_release             (w_rd_reg1_release),      	 // -> Reg MEM_WB
    .mem_rs2_release            (w_rs2_reg1_release),
    .mem_pc_release		        (w_Branch_ins_reg_release),  // -> Mux before PC 
    .mem_current_pc_release     (w_addr_ins_reg2_release),
    .mem_readdata2_release      (w_readdata2_reg1_release),  // -> input of Load Mux
    .mem_Br_sel_release         (w_Br_sel_reg1_release),     // B-type sel
    .mem_Branch_release         (w_Branch_reg1_release),     // B-type sel
    .mem_Jump_release           (w_Jump_reg1_release),       // B-type sel
    .mem_Load_sel_release       (w_Load_sel_reg1_release),   // -> Load Mux
    .mem_Store_sel_release      (w_Store_sel_reg1_release),  // -> Store Mux
    .mem_ALU_result_release     (w_ALUresult_reg_release),   // -> addr of DataMem or Reg MEM_WB  
    .mem_predicted_bit_release  (),
    .mem_RegWr_fp_release       (w_RegWr_fp_reg1_release),   // -> Reg MEM_WB	 
    //.mem_readdata2_fp_release   (w_readdata2_fp_reg1_release),
    .mem_ALU_result_fp_release  (w_ALUresult_fp_reg_release),
    .mem_data_sel_release       (w_data_sel_reg1_release) 
    );
//*/
`endif

//mux before Data Memory
assign w_MemDataWr1 = (w_Store_sel_reg1[1]) ? w_readdata2_reg1 : (w_Store_sel_reg1[0]) ? {{16{w_readdata2_reg1[15]}},w_readdata2_reg1[15:0]} : {{24{w_readdata2_reg1[7]}},w_readdata2_reg1[7:0]};
assign w_MemDataWr  = w_MemDataWr1;


//**************************************************************
//                    REGISTER MEM/WB
//**************************************************************

    Reg_MEM_WB u_Reg_MEM_WB(
`ifdef cache
    .clk                (CLOCK_50&&~w_stall),
    .clk_2              (CLOCK_50),
`else
    .clk                (CLOCK_50),
    .clk_2              (CLOCK_50),
`endif        
	    .rst			(reset),
        .stall          (0),
	    .mem_MemtoReg   (w_MemtoReg_reg1_release),  // from the output of Reg EX/MEM to control Mux after DataMem
	    .mem_RegWr      (w_RegWr_reg1_release), 	// from the output of Reg EX/MEM to write to Int_Reg File
	    .mem_rd         (w_rd_reg1_release),  		// ID -> IF/ID reg -> ID/EX reg -> EX/MEM Reg -> MEM/WB Reg 
	    .mem_MemRd      (w_MemRd_reg1_release),
	    .mem_datamem    (w_ReadData),  		// from the output of readdata of DataMem 
	    .mem_dataALU	(w_ALUresult_reg_release),  // ALU result -> EX/MEM Reg -> MEM/WB Reg
	    .mem_Load_sel   (w_Load_sel_reg1_release),  // ALU result -> EX/MEM Reg -> MEM/WB Reg

	    .mem_RegWr_fp   (w_RegWr_fp_reg1_release), 	// from the output of Reg EX/MEM to write to FP_Reg File
	    
        .mem_dataALU_fp (w_ALUresult_fp_reg_release),
	    .wb_dataALU	    (w_ALUresult_reg1),
	    .wb_datamem	    (w_ReadData_reg),
	    .wb_memtoreg	(w_MemtoReg_reg2),
	    .wb_RegWr  	    (w_RegWr_reg2),
	    
        .wb_MemRd       (w_MemRd_reg2),
	    
        .wb_Load_sel	(w_Load_sel_reg2),
	    .wb_rd			(w_rd_reg2),
	    .wb_RegWr_fp 	(w_RegWr_fp_reg2),
	    .wb_dataALU_fp  (w_ALUresult_fp_reg1)
    );


//**************************************************************
//                    WRITE BACK STAGE
//**************************************************************



// mux after DataMem
assign w_WriteData1 = (w_MemtoReg_reg2[1]) ? w_ALUresult_fp_reg1 : ((w_MemtoReg_reg2[0]) ? w_ReadData_reg : w_ALUresult_reg1); 
assign w_WriteData  = (w_Load_sel_reg2[2]) ? w_WriteData1 : (w_Load_sel_reg2[1]) ? ( (w_Load_sel_reg2[0]) ? {16'b0,w_WriteData1[15:0]} : {24'b0,w_WriteData1[7:0]} ) : ( (w_Load_sel_reg2[0]) ? {{16{w_WriteData1[15]}},w_WriteData1[15:0]}: {{24{w_WriteData1[7]}},w_WriteData1[7:0]} );

assign w_WriteData_hazard = (w_Store_sel_reg1[1]) ? w_WriteData1 : (w_Store_sel_reg1[0]) ? {{16{w_WriteData1[15]}},w_WriteData1[15:0]} : {{24{w_WriteData1[7]}},w_WriteData1[7:0]};





/*assign LEDR[9] = w_wrong_predict;
assign LEDR[8] = w_Branch_reg;*/
assign LEDR[7] = w_Next_ins_temp1;
assign LEDR[6] = w_predict_bit_BP_reg1;


assign r = w_WriteData;
//assign r1 = w_MemDataWr;
//assign r2  = w_ALUresult_reg;

endmodule