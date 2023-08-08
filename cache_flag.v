module cache_flag (
   input wire        clk,
	input wire        rstn,
	input wire [5:0]  index,
	input wire        valid_control,
	input wire        valid_upd,
	input wire        dirty_control,
	input wire        dirty_upd,
	output wire       dirty,
	output wire       valid
);

    reg [63:0] valid_reg;
	reg [63:0] dirty_reg;
	
	assign valid = valid_reg[index];
	assign dirty = dirty_reg[index];
    initial begin
	   valid_reg = 'h0;
	   dirty_reg = 'h0;
	end
	
   always@(negedge clk) begin
/*
	if(!rstn) begin
		   valid_reg <= 'h0;
			dirty_reg <= 'h0;
		end
*/
		//else begin 
		   if(valid_upd) begin
			   valid_reg[index] <= valid_control;
			end
		   if(dirty_upd) begin
			   dirty_reg[index] <= dirty_control;
			end
		//end
	end
endmodule 