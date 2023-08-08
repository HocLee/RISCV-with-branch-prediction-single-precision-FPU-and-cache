module EX_MEM (
  //================================INPUT FROM EX===========================================
  input  wire        clk              ,
  input  wire        rst              ,
  input  wire        ex_MemRd         , // Control Unit -> Reg_EX_MEM
  input  wire        ex_RegWr         , // Control Unit -> Reg_EX_MEM
  input  wire        ex_MemWr         , // Control Unit -> Reg_EX_MEM
  input  wire [1:0]  ex_MemtoReg      , // Control Unit -> Reg_EX_MEM
  input  wire        ex_zero          , // ALU -> Reg_EX_MEM
  input  wire        ex_lt            , // ALU -> Reg_EX_MEM
  input  wire [4:0]  ex_rd            , // ID block     -> Reg_EX_MEM
  input  wire [4:0]  ex_rs2           , // Reg ID_EX    -> Reg_EX_MEM
  input  wire [31:0] ex_pc            , // result of 1st CLA
  input  wire [31:0] ex_current_pc    , // current PC
  input  wire [31:0] ex_readdata2     , // Reg file     -> Reg ID_EX  -> Reg_EX_MEM
  input  wire [1:0]  ex_Br_sel        , // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
  input  wire        ex_Branch        , // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
  input  wire        ex_Jump          , // Control Unit -> Reg ID_EX  -> Reg_EX_MEM
  input  wire [2:0]  ex_Load_sel      , // Control Unit -> Reg ID_EX  -> Reg_EX_MEM -> Reg Mem/WB
  input  wire [1:0]  ex_Store_sel     , // Control Unit -> Reg ID_EX  -> Reg_EX_MEM -> DataMem
  input  wire [31:0] ex_ALU_result    ,
  input  wire        ex_predicted_bit ,
  input  wire        ex_RegWr_fp      , // Control Unit -> Reg_EX_MEM
  input  wire [31:0] ex_readdata2_fp  , // Reg file     -> Reg ID_EX  -> Reg_EX_MEM
  input  wire [31:0] ex_ALU_result_fp ,
  input              ex_data_sel      ,

  input wire         stall            ,
  
  //===============================OUTPUT TO MEM===========================================            
  output reg         mem_MemRd        ,
  output reg         mem_RegWr        ,
  output reg         mem_MemWr        ,
  output reg  [1:0]  mem_MemtoReg     ,
  output reg         mem_zero         ,
  output reg         mem_lt           ,
  output reg  [4:0]  mem_rd           ,
  output reg  [4:0]  mem_rs2          ,
  output reg  [31:0] mem_pc		      ,
  output reg  [31:0] mem_current_pc	  ,  
  output reg  [31:0] mem_readdata2    ,
  output reg  [1:0]  mem_Br_sel       ,
  output reg         mem_Branch       ,
  output reg         mem_Jump         ,
  output reg  [2:0]  mem_Load_sel     , 
  output reg  [1:0]  mem_Store_sel    , 
  output reg  [31:0] mem_ALU_result   ,
  output reg         mem_predicted_bit,
  output reg         mem_RegWr_fp     , 
  output reg  [31:0] mem_readdata2_fp ,
  output reg  [31:0] mem_ALU_result_fp,
  output reg         mem_data_sel  
);

    always @ (negedge clk) begin
        if (rst) begin
            mem_MemRd         <= 0;
            mem_RegWr         <= 0;
            mem_MemWr         <= 0;
            mem_MemtoReg      <= 0;
            mem_zero          <= 0;
            mem_lt            <= 0;
            mem_rd            <= 0;
            mem_rs2	          <= 0;
            mem_pc            <= ex_pc;
//            mem_current_pc    <= ex_current_pc;
            mem_readdata2     <= 0;
	        mem_Br_sel        <= 0;
	        mem_Branch        <= 0;
	        mem_Jump          <= 0;
	        mem_Load_sel      <= 0;
	        mem_Store_sel     <= 0;
            mem_ALU_result    <= 0;
	        mem_RegWr_fp      <= 0;
	        mem_readdata2_fp  <= 0;
	        mem_ALU_result_fp <= 0;
	        mem_data_sel      <= 0;
        end 
        else begin
            if (stall==0) begin
            mem_MemRd         <= ex_MemRd;
            mem_RegWr         <= ex_RegWr;
            mem_MemWr         <= ex_MemWr;
            mem_MemtoReg      <= ex_MemtoReg;
            mem_zero          <= ex_zero;
            mem_lt            <= ex_lt;
            mem_rd            <= ex_rd;
            mem_rs2           <= ex_rs2;
            mem_pc            <= ex_pc;
            mem_current_pc    <= ex_current_pc;
            mem_readdata2     <= ex_readdata2;
		    mem_Br_sel        <= ex_Br_sel;
		    mem_Branch        <= ex_Branch;
		    mem_Jump          <= ex_Jump;
		    mem_Load_sel      <= ex_Load_sel  ;
		    mem_Store_sel     <= ex_Store_sel ;
            mem_ALU_result    <= ex_ALU_result;
		    mem_predicted_bit <= ex_predicted_bit;
		    mem_RegWr_fp      <= ex_RegWr_fp;
		    mem_readdata2_fp  <= ex_readdata2_fp;
		    mem_ALU_result_fp <= ex_ALU_result_fp;
		    mem_data_sel      <= ex_data_sel;
            end
        end
    end
endmodule
