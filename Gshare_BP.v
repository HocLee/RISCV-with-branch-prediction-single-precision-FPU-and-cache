module Gshare_BP(
    input         clk                ,
    input         rst                ,
    input         taken              , // taken or not bit
    input  [31:0] pc_in              ,
    input         update             , // inform B,J type
    input  [31:0] pc_ex              ,
    output [9:0]  GPT_index_o        ,
    output [9:0]  GPT_index_update_o ,
    output        Gshare_predict
);
wire [1:0] pred_state;

Gshare u_Gshare
(
    .pc_in              (pc_in)              ,
	.clk                (clk)                ,
	.rst                (rst)                ,
	.pc_ex              (pc_ex)              ,
	.update             (update)             ,
    .actual             (taken)              ,
    .GPT_index_o        (GPT_index_o)        ,
    .GPT_index_update_o (GPT_index_update_o) ,
	.Gshare_predict     (Gshare_predict)
);


endmodule

//=========================== Gshare======================================
module Gshare
(
    input  [31:0] pc_in              ,
	input         clk                ,
	input         rst                ,
	input  [31:0] pc_ex              ,
	input         update             ,
    input         actual             ,
    output [9:0]  GPT_index_o        ,
    output [1:0]  GBP_predict_update ,
    output [9:0]  GPT_index_update_o ,
	output        Gshare_predict
);

//=============== Gshare Parameter=======================
    parameter GSHARE_HISTORY_LENGTH = 10;
    parameter GSHARE_GPT_INDEX = 10;

//=======================================================
//  REG/WIRE declarations
//======================================================= 
    reg  [GSHARE_HISTORY_LENGTH-1:0] GBHR, GBHR_reg1, GBHR_reg2; // 1D array
    reg  [1:0] GPT [2**GSHARE_GPT_INDEX-1:0];
    wire [GSHARE_GPT_INDEX-1:0] GPT_index, GPT_index_update;
    wire [GSHARE_HISTORY_LENGTH-1:0] GBHR_old;
    wire [1:0] GPT_predict_temp;

//=======================================================
//  Behavioral coding
//=======================================================
    integer i;

    assign GBP_predict_update = GPT[25]; 
    assign GPT_index_o        = GPT_index;
    assign GPT_index_update_o = GPT_index_update; 
    assign GPT_index          = pc_in [GSHARE_GPT_INDEX+1:2] ^ GBHR;	  // ignore 2 LSB bit (Byte index)
    assign GPT_index_update   = pc_ex [GSHARE_GPT_INDEX+1:2] ^ GBHR_old; 


    always @(posedge clk or posedge rst)begin
		if(rst)
			GBHR <= 1'b0;	
		else if((pc_ex[1:0] == 2'b00) && (update))
			GBHR <= {GBHR_old[GSHARE_HISTORY_LENGTH-2:0], actual};
		else 
			GBHR <= GBHR;
    end
 
    always @ (negedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<2**GSHARE_GPT_INDEX;i=i+1) begin
	    	    GPT[i] <= 32'd0;
	        end
        end
        else begin
            if((pc_ex[1:0] == 2'b00) && (update) && actual) begin
                if (GPT[GPT_index_update] == 2'b11) begin
                    GPT[GPT_index_update] <= GPT[GPT_index_update];
                end
                else begin
		            GPT[GPT_index_update] <= GPT[GPT_index_update] + 'd1;
                end
            end
            else begin
                if((pc_ex[1:0] == 2'b00) && (update) && !actual) begin
                    if (GPT[GPT_index_update] == 2'b00) begin
                        GPT[GPT_index_update] <= GPT[GPT_index_update];
                    end
                    else begin
		                GPT[GPT_index_update] <= GPT[GPT_index_update] - 'd1;
                    end
                end
                else begin
                    GPT[GPT_index_update] <= GPT[GPT_index_update];
                end
            end
        end
    end

    always @(negedge clk) begin
	   GBHR_reg1 <= GBHR; 
    end

    always @(negedge clk) begin
	   GBHR_reg2 <= GBHR_reg1; 
    end
  
    assign	GPT_predict_temp = GPT[GPT_index];	
    assign  Gshare_predict = GPT_predict_temp[1];  
    assign  GBHR_old = GBHR_reg2;

endmodule 

