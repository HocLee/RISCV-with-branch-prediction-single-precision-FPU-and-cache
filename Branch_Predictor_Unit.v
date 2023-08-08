`include "Gshare_BP.v"
`include "Local_BP.v"
`include "BTB.v"
`include "CPT.v"

module	Branch_Predictor_Unit
(
    input 	        clk,
	input           rst,
	input           update_i,     // inform B,J type
	input           taken_i,
	input 	[31:0]	pc_ex_i,
	input 	[31:0]  pc_in_i,
	input 	[31:0]  target_pc_i,	 
	output 	        pc_sel_o,       // PC + 4 or BJ
	output  [1:0]   tmp,
	output	[31:0]	target_predict_o,
    output  [1:0]   LBP_predict_tmp_o,
	output          predict_bit_BP_o
);
parameter PC_LENGTH        = 32;
parameter GSHARE_GPT_INDEX = 10;

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [GSHARE_GPT_INDEX-1:0] GPT_index_w, GPT_index_update_w;
wire LBP_predict_w;
wire Gshare_predict_w;
wire BTB_hit_w; 
wire GshareBP_or_LocalBP_w;
wire taken_w;
reg  Gshare_predict_id_reg;
reg  Gshare_predict_ex_reg;
wire Gshare_predict_id_w;
wire Gshare_predict_ex_w;
reg  LBP_predict_id_reg;
reg  LBP_predict_ex_reg;
wire LBP_predict_id_w;
wire LBP_predict_ex_w;
//=======================================================
//  Behavioral coding
//=======================================================

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            Gshare_predict_id_reg <= 'd0;
            LBP_predict_id_reg    <= 'd0;
        end
        else begin
            Gshare_predict_id_reg <= Gshare_predict_w;
            LBP_predict_id_reg    <= LBP_predict_w;
        end
    end

    assign Gshare_predict_id_w = Gshare_predict_id_reg;
    assign LBP_predict_id_w    = LBP_predict_id_reg;

    always@(negedge clk or posedge rst) begin
        if (rst) begin
            Gshare_predict_ex_reg <= 'd0;
            LBP_predict_ex_reg    <= 'd0;
        end
        else begin
            Gshare_predict_ex_reg <= Gshare_predict_id_w;
            LBP_predict_ex_reg    <= LBP_predict_id_w;
        end
    end

    assign Gshare_predict_ex_w = Gshare_predict_ex_reg;
    assign LBP_predict_ex_w    = LBP_predict_ex_reg;

BTB u_BTB(
	.clk            (clk)             ,
	.rst            (rst)             ,          
	.br_update      (update_i)        ,  //signal for informing updating in BTB
	.target_pc      (target_pc_i)     ,  //target address after execute state 
	.pc_in          (pc_in_i)         ,  //input address to BTB
	.pc_ex          (pc_ex_i)         ,  //address of the branch instruction 
	.target_predict (target_predict_o),  //predict address from BTB when having input address
	.hit            (BTB_hit_w)          //signal for identifying stored address in BTB
);

Gshare_BP u_Gshare_BP(
    .clk                (clk)               ,
    .rst                (rst)               ,
    .taken              (taken_i)           , // taken or not taken
    .pc_in              (pc_in_i)           ,
    .update             (update_i)          , // inform B,J type
    .pc_ex              (pc_ex_i)           ,
    .GPT_index_o        (GPT_index_w)       ,
    .GPT_index_update_o (GPT_index_update_w),
    .Gshare_predict     (Gshare_predict_w)
);

Local_BP u_Local_BP(
    .clk               (clk),
    .rst               (rst),
    .taken             (taken_i),
    .pc_in             (pc_in_i),
    .update            (update_i),
    .pc_ex             (pc_ex_i),
    .BTB_hit           (BTB_hit_w),
    .tmp               (tmp),
	.LBP_predict_tmp_o (LBP_predict_tmp_o),
    .LBP_predict_o     (LBP_predict_w)
);

CPT u_CPT(

    .clk                 (clk),
    .rst                 (rst),
    .taken               (taken_i),
    .Gshare              (Gshare_predict_ex_w),
    .Local               (LBP_predict_ex_w),
    .GPT_index           (GPT_index_w),
    .GPT_index_update    (GPT_index_update_w),
    .update              (update_i),
    .pc_ex               (pc_ex_i),
    .GshareBP_or_LocalBP (GshareBP_or_LocalBP_w)
);

    assign taken_w          = (GshareBP_or_LocalBP_w /*1'b1*//*1'b0*/)? Gshare_predict_w : LBP_predict_w /*1'b0 : 1'b0*/;
    assign predict_bit_BP_o = /*LBP_predict_w*/ taken_w;
    assign pc_sel_o         = BTB_hit_w && taken_w ;

endmodule
