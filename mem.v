module mem (
   input wire        clk,
	input wire        rstn,
	input wire        write,
	input wire        read,
	input wire [31:0] address,
	input wire [31:0] wrdata,
	output reg [31:0] rddata,
	output reg        ready
);
   integer i;

	wire [1:0] byte_offset = address[1:0];
// banks address input
	reg [31:0] bank0_addr ;
	reg [31:0] bank1_addr ;
	reg [31:0] bank2_addr ;
	reg [31:0] bank3_addr ;
// 11 bit which is 2^11 = 2048 addresses
   reg [7:0]bank_0[0:2047];
	reg [7:0]bank_1[0:2047];
	reg [7:0]bank_2[0:2047];
	reg [7:0]bank_3[0:2047];
// initial flush all banks with 0s
	reg [31:0] yo [0:2047];
	//integer i;
	always@* begin
	   for(i = 0;i<2048; i = i + 1 ) begin
          {bank_3[i],bank_2[i],bank_1[i],bank_0[i]} = yo[i];
	   end
	end	
	initial begin
		rddata = 0;
		$readmemh("DataMem.txt", yo);
/*
		rddata = 'b0;
	   for (i=0;i<2048;i=i+1) begin
          bank_3[i] = 'h0;
	      bank_2[i] = 'h0;
	      bank_1[i] = 'h0;
	      bank_0[i] = 'h0;
	   end
*/
       
	end
// address alignment mux
	always@* begin :address_alignment
	   case(byte_offset)
			'h0: begin
				bank0_addr = {address[11:2],2'h0};
				bank1_addr = {address[11:2],2'h0};
				bank2_addr = {address[11:2],2'h0};
				bank3_addr = {address[11:2],2'h0};
			end
			'h1: begin
				bank0_addr = {address[11:2],2'h0};
				bank1_addr = {address[11:2],2'h0};
				bank2_addr = {address[11:2],2'h0};
				bank3_addr = {address[11:2],2'h0} + 'h1;			
			end
			'h2: begin
				bank0_addr = {address[11:2],2'h0};
				bank1_addr = {address[11:2],2'h0};
				bank2_addr = {address[11:2],2'h0} + 'h1;
				bank3_addr = {address[11:2],2'h0} + 'h1;
			end
			'h3: begin
				bank0_addr = {address[11:2],2'h0};
				bank1_addr = {address[11:2],2'h0} + 'h1;
				bank2_addr = {address[11:2],2'h0} + 'h1;
				bank3_addr = {address[11:2],2'h0} + 'h1;			
			end
		endcase
	end
   always@(negedge clk) begin
			if(write) begin 
				case(byte_offset) 
					'h0: begin
						{
						 bank_3[bank3_addr],
						 bank_2[bank2_addr],
						 bank_1[bank1_addr],
						 bank_0[bank0_addr]
						} <= wrdata;
					end
					'h1: begin
						{
						 bank_2[bank2_addr],
						 bank_1[bank1_addr],
						 bank_0[bank0_addr],
						 bank_3[bank3_addr]
						} <= wrdata;
					end
					'h2: begin
						{
						 bank_1[bank1_addr],
						 bank_0[bank0_addr],
						 bank_3[bank3_addr],
						 bank_2[bank2_addr]
						} <= wrdata;
					end
					'h3: begin
						{
						 bank_0[bank0_addr],
						 bank_3[bank3_addr],
						 bank_2[bank2_addr],
						 bank_1[bank1_addr]				 
						} <= wrdata;
					end
				endcase
			end
			if(read) begin 
				case(byte_offset) 
					'h0: begin
						rddata <= {
						 bank_3[bank3_addr],
						 bank_2[bank2_addr],
						 bank_1[bank1_addr],
						 bank_0[bank0_addr]
						};
					end
					'h1: begin
						rddata <= {
						 bank_2[bank2_addr],
						 bank_1[bank1_addr],
						 bank_0[bank0_addr],
						 bank_3[bank3_addr]
						};
					end
					'h2: begin
						rddata <= {
						 bank_1[bank1_addr],
						 bank_0[bank0_addr],
						 bank_3[bank3_addr],
						 bank_2[bank2_addr]
						};
					end
					'h3: begin
						rddata <= {
						 bank_0[bank0_addr],
						 bank_3[bank3_addr],
						 bank_2[bank2_addr],
						 bank_1[bank1_addr]				 
						};
					end
				endcase
			end
	   end

endmodule 