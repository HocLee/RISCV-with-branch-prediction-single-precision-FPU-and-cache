
//address[31:0] = {tag[23:0],valid[5:0]=index,byte_offset[1:0]}
module cache_tag(
	 input wire       clk,
	 input wire       rstn,
	 input wire [5:0] index,    //cache line
	 input wire [9:0] address_in,
    input wire       update_tag,
	 input wire       fetch_tag,
	 output reg [9:0] tag      //tag field
);
	 
   integer i; //used to flush and initialize tag and validity fields

   reg [9:0]  tag_field       [63:0];
	
   initial begin
	   tag = 'h0;
	   for (i=0;i<64;i=i+1) begin
		   tag_field[i]='b0;
	   end
   end

   always@(negedge clk) begin              //work well with non-blocking
	   if (fetch_tag) begin
	      tag  <= tag_field[index] ; //if cache line is valid check tag field for cache hits
	   end 
		else begin
	      if (update_tag) begin //if data block is ready updatecirresponding tag and validity bits
			   tag_field[index] <= address_in;
	      end
	   end
   end
	
	
endmodule 