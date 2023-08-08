module Local_BP(
    input         clk               ,
    input         rst               ,
    input         taken             ,
    input  [31:0] pc_in             ,
    input         update            , // inform B,J type
    input  [31:0] pc_ex             ,
    input         BTB_hit           ,
    output [1:0]  tmp              ,
    output [1:0]  LBP_predict_tmp_o ,
    output        LBP_predict_o
);
//=======================================================
//  REG/WIRE declarations
//=======================================================
    wire [1:0] pred_state;
//=======================================================
//  Behavioral coding
//=======================================================
    assign  tmp = pred_state;
Local u_Local
(
    .pc_in              (pc_in)             ,
	.clk                (clk)               ,
    .reset              (rst)               ,
	.pc_ex              (pc_ex)             ,
	.LBP_predict_update (pred_state)        ,
	.update             (update)            ,
    .actual             (taken)             ,
	.BTB_hit            (BTB_hit)           ,
	.LBP_predict_temp   (LBP_predict_tmp_o) ,
	.LBP_predict        (LBP_predict_o)
);


endmodule

//======================Local============================
module Local (
    input         clk                ,
    input         reset              ,
    input  [31:0] pc_in              ,
	input  [31:0] pc_ex              ,
	input         update             ,
    input         actual             ,
	input         BTB_hit            ,
	output [1:0]  LBP_predict_temp   ,
    output [1:0]  LBP_predict_update ,
	output        LBP_predict
);

//===============Local BP Parameter======================
    parameter LOCAL_LHT_INDEX      = 12;
    parameter LOCAL_HISTORY_LENGTH = 10;
    parameter LOCAL_LPT_INDEX      = 10;

//=======================================================
//  REG/WIRE declarations
//=======================================================
    reg  [LOCAL_HISTORY_LENGTH-1:0]	LHT [2**LOCAL_LHT_INDEX-1:0]; // 2D array
    reg  [1:0]	LPT	[2**LOCAL_LPT_INDEX-1:0];
    wire [LOCAL_LHT_INDEX-1:0] LHT_index, LHT_index_update, LPT_index, LPT_index_update;
    wire [LOCAL_HISTORY_LENGTH-1:0]	LBHR, LBHR_old;
    reg  [LOCAL_HISTORY_LENGTH-1:0]	LBHR_reg1,  LBHR_reg2, LBHR_reg3;
    wire [1:0] byte_index_mem;
//=======================================================
//  Behavioral coding
//=======================================================
    integer i;
    integer n;

    assign LBP_predict_update = LPT[1016];
    assign LBHR               = LHT[pc_in[LOCAL_LHT_INDEX+1:2]]; // br_check_fetch.LBHR

    always @(posedge clk) begin
	   LBHR_reg1 <= LBHR; 
    end

    always @(negedge clk) begin
	   LBHR_reg2 <= LBHR_reg1; 
    end
 

    assign LBHR_old = LBHR_reg2; // br_update_ex.LBHR_old
    assign LHT_index_update = pc_ex[LOCAL_LHT_INDEX+1:2];
    assign LPT_index = pc_in[LOCAL_LPT_INDEX+1:2] ^ LBHR; //ignore 2 LSB bit (Byte index)
    assign LPT_index_update = pc_ex[LOCAL_LPT_INDEX+1:2] ^ LBHR_old; 


    always @ (negedge clk or posedge reset) begin
        if (reset) begin
		    for (i=0;i<2**LOCAL_LHT_INDEX;i=i+1) begin
	    	    LHT[i] <= 32'd0;
	        end
        end
        else begin
            if((pc_ex[1:0] == 2'b00)&&(update)) begin
		        LHT[LHT_index_update] <= {LBHR_old[LOCAL_HISTORY_LENGTH-2:0],actual};
            end
        end 
    end
 
    always @(negedge clk or posedge reset) begin
        if (reset) begin
		    for (n=0 ; n<2**LOCAL_LPT_INDEX ; n=n+1) begin
	    	    LPT[n] <= 32'd0;
	        end
        end
        else begin
            if( (pc_ex[1:0] == 2'b00) && (update) && actual ) begin
                if (LPT[LPT_index_update] == 2'b11) begin
                    LPT[LPT_index_update] <= LPT[LPT_index_update];
                end
                else begin
	                LPT[LPT_index_update] <= LPT[LPT_index_update] + 'd1;
                end
            end
            else begin 
                if( (pc_ex[1:0] == 2'b00) && (update) && !actual ) begin
                    if (LPT[LPT_index_update] == 2'b00) begin
                        LPT[LPT_index_update] <= LPT[LPT_index_update];
                    end
                    else begin
                        LPT[LPT_index_update] <= LPT[LPT_index_update] - 'd1;
                    end
                end
                else begin
                    LPT[LPT_index_update] <= LPT[LPT_index_update];
                end
            end
        end
    end
  
    assign	LBP_predict_temp = LPT[LPT_index];	
    assign  LBP_predict      = (BTB_hit) ? LBP_predict_temp[1] : 0; 

endmodule 
//--------------------------------------------------------------------------------------------------------

