module CPT(
    input         clk                ,
    input         rst                ,
    input         taken              ,
    input         Gshare             ,
    input         Local              ,
    input  [9:0]  GPT_index          ,
    input  [9:0]  GPT_index_update   ,
    input         update             ,
    input  [31:0] pc_ex              ,
    output        GshareBP_or_LocalBP
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire [1:0] pred_state;
//=======================================================
//  Behavioral coding
//=======================================================

cpt u_CPT (
	.clk                (clk)                ,
	.rst                (rst)                ,
	.pc_ex              (pc_ex)              ,
	.CPT_predict_update (pred_state)         ,
	.update             (update)             ,
    .Gshare             (Gshare)             ,
    .Local              (Local)              ,
    .taken              (taken)              ,
	.GPT_index          (GPT_index)          ,
	.GPT_index_update   (GPT_index_update)   ,
	.CPT_predict        (GshareBP_or_LocalBP)
);

endmodule

module cpt
(
	input         clk                ,
	input         rst                ,
	input  [31:0] pc_ex              ,
	input  [1:0]  CPT_predict_update ,
	input         update             ,
    input         Gshare             ,
    input         Local              ,
    input         taken              ,
	input  [9:0]  GPT_index          ,
	input  [9:0]  GPT_index_update   ,
	output        CPT_predict
);

//=================== Gshare Parameter ==================
    parameter GSHARE_HISTORY_LENGTH = 10;
    parameter GSHARE_GPT_INDEX      = 10;

//=======================================================
//  REG/WIRE declarations
//=======================================================
    reg  [1:0] CPT [ 2**GSHARE_GPT_INDEX-1 : 0 ];
    wire [ GSHARE_GPT_INDEX-1 : 0 ] CPT_index;
    wire [1:0] check;
    wire [1:0] CPT_predict_tmp;
    integer i;
//=======================================================
//  Behavioral coding
//=======================================================


    assign check     = CPT[2];
    assign CPT_index = GPT_index; //use same of Gshare

 
always @ (negedge clk or posedge rst)   
    begin
        if (rst) begin
            for (i=0; i < 2**GSHARE_GPT_INDEX; i=i+1) 
            begin
                CPT[i] <= 'd0;
            end
        end
        else begin
            if((pc_ex[1:0] == 2'b00) && (update)) begin
                if (CPT[GPT_index_update] == 2'b11) begin  //Case when Strongly Gshare
                    if ((Gshare ^ taken) & (~(Local ^ taken))) begin
                        CPT[GPT_index_update] <= CPT[GPT_index_update] - 1'b1;
                    end
                    else begin
                    CPT[GPT_index_update] <= CPT[GPT_index_update];
                    end
                end
                else begin
                    if (CPT[GPT_index_update] == 2'b10) begin  //Case when Weakly Gshare
                        if ((Gshare ^ taken) & (~(Local ^ taken))) begin
                            CPT[GPT_index_update] <= CPT[GPT_index_update] - 1'b1; 
                        end
                        else begin
                            if (~(Gshare ^ taken) & (Local ^ taken)) begin
                                CPT[GPT_index_update] <= CPT[GPT_index_update] + 1'b1;
                            end
                            else begin
                                CPT[GPT_index_update] <= CPT[GPT_index_update];
                            end
                        end
                    end
                    else begin
                        if (CPT[GPT_index_update] == 2'b01) begin //Case when Weakly Local
                            if ((Gshare ^ taken) & (~(Local ^ taken))) begin
                                CPT[GPT_index_update] <= CPT[GPT_index_update] - 1'b1; 
                            end
                            else begin
                                if (~(Gshare ^ taken) & (Local ^ taken)) begin
                                    CPT[GPT_index_update] <= CPT[GPT_index_update] + 1'b1;
                                end
                                else begin
                                    CPT[GPT_index_update] <= CPT[GPT_index_update];
                                end
                            end 
                        end
                        else begin //Case when Strongly Local
                            if (~(Gshare ^ taken) & (Local ^ taken)) begin
                                CPT[GPT_index_update] <= CPT[GPT_index_update] + 1'b1;
                            end
                            else begin
                                CPT[GPT_index_update] <= CPT[GPT_index_update];
                            end
                        end 
                    end
                end
            end
            else begin
                CPT[GPT_index_update] <= CPT[GPT_index_update];
            end
        end
    end
  
    assign	CPT_predict_tmp  = CPT[CPT_index]    ;	
    assign  CPT_predict      = CPT_predict_tmp[1];  

endmodule 

