module D_FF (
    input         rst_in,
    input         clk_in,
    input         PC_remain,
    input  [31:0] D_in,
	output reg [31:0] Q_out
);
initial begin
   Q_out = 0;
end
always@(posedge clk_in ,posedge rst_in ) begin
   if(rst_in) begin
      Q_out <= 0;
   end
   else begin
      if(PC_remain==0) begin
         Q_out <= D_in;
      end
   end
end
/*
    wire [31:0] Q_w;
    genvar  n;
    generate 
        for (n=0; n<=31; n=n+1) 
        begin : D_FF
            mini_D_FF blk( 
                .rst       (rst_in)   ,
                .clk       (clk_in)   ,
                .PC_remain (PC_remain),
				.D         (D_in[n])  ,
			    .Q         (Q_w[n])	  
            );
        end
    endgenerate
*/
endmodule


module mini_D_FF (
    input  rst      ,
    input  clk      ,
    input  PC_remain,
    input  D        ,
	output Q
);
reg Q_r, PC_remain_reg, old_Q;
wire PC_remain_w;

always @(posedge clk or posedge rst or posedge PC_remain) begin
    
    if (rst) begin 
        Q_r   <= 'd0;
        old_Q <= 'd0;
    end
	else begin
	    if (PC_remain) begin 
            Q_r   <= old_Q ;
            old_Q <= old_Q ;
        end
		else begin 
            Q_r   <= D  ;
            old_Q <= Q_r;
        end
    end	
end

assign Q = Q_r;
endmodule
