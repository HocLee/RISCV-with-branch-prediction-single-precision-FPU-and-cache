module cache_data_block(
   input wire        clk,
	input wire        rstn,
	input wire        update,
	input wire        fetch,
	input wire        write_cache,
	input wire        read_cache,
	input wire [5:0]  index,
	input wire [31:0] data_in,
	input wire [31:0] data_fetch,
	output reg [31:0] data_update,
	output reg [31:0] data_out
);

   reg [31:0] mem [63:0];
   integer i;
	   initial begin
		data_out <= 'h0;
		data_update <= 'h0;
	   for (i=0;i<64;i=i+1) begin
         mem[i] = 'h0;
	   end
   end
	
	
	
   always@(negedge clk) begin
/*
      if(!rstn) begin
         data_out <= 'h0;
			data_update <= 'h0;
		end
		else begin
*/			
	   if(write_cache) begin
			mem[index] <= data_in;
		end			
      else begin
		   if(fetch) begin
			   mem[index] <= data_fetch;
		   end
		end
		if(read_cache) begin
		   data_out <= mem[index];
		end			
		else begin
			if(update) begin
			   data_update <= mem[index];
			end
		end
	//end
	end

	
endmodule 