
`include "cache_controller_v2.v"
`include "cache_data_block.v"
`include "cache_flag.v"
`include "cache_tag.v"

module cache_unit(
   input wire          clk,
	input wire          rstn,
	input wire          req_cpu,
	input wire          write_cpu,
	input wire          read_cpu,
	input wire  [31:0]  address,
	input wire  [31:0]  wrdata_cpu,
	output wire [31:0]  rddata_cpu,
	output wire [31:0]  wrdata_mem,
	input  wire [31:0]  rddata_mem,
	output wire [9:0]   tag_out,
	output wire         write_mem,
	output wire         read_mem,
	output wire         stall,
	output wire         done
);
//   wire [31:0] wrdata_mem;
//   wire [31:0] rddata_mem;
	wire [9:0]  tag;
   assign tag_out = tag;
	reg         hit;
	wire        valid;
	wire        valid_control;
	wire        valid_upd;
	wire        dirty;
	wire        dirty_control;
	wire        dirty_upd;	
	wire        update_tag;
	wire        fetch_tag;
	wire        write_cache;
	wire        read_cache;
	
	
	
	cache_data_block u_data_block      (
	   	.clk             (clk),
	   	.rstn            (rstn),
	   	.update          (write_mem),     //write new data from cache to mem
	   	.fetch           (read_mem),      //read new data from mem to cache 
		.write_cache     (write_cache),   //write data from cpu to cache
		.read_cache      (read_cache),    //read data from cache to cpu
	   	.index           (address[7:2]),
	   	.data_in         (wrdata_cpu),
	   	.data_out        (rddata_cpu),
	   	.data_fetch      (rddata_mem),
	   	.data_update     (wrdata_mem)		
	);
	
	cache_tag       u_cache_tags      (
	   .clk             (clk),
	   .rstn            (rstn),
//		.update_tag      (update_tag),   //update cache tag meaning write new address of the block from cpu address to the tag block
//		.fetch_tag       (fetch_tag),    //fetch cache tag meaning read address of the current indexed block for comparing the tag block with the cpu request address
		.update_tag      (update_tag),   //update cache tag meaning write new address of the block from cpu address to the tag block
		.fetch_tag       (fetch_tag),    //fetch cache tag meaning read address of the current indexed block for comparing the tag block with the cpu request address
		.index           (address[7:2]),
	   .address_in      (address[17:8]),
		.tag             (tag)
	);
	
	always@* begin
	   hit = valid && (tag==address[17:8]);   
	end
	
	cache_flag      u_flag           (
	   .clk              (clk),
	   .rstn             (rstn),
		//flags interfacing to cache controller
		.index            (address[7:2]),
		.valid_upd        (valid_upd),
		.valid_control    (valid_control),
		.valid            (valid),
		.dirty_upd        (dirty_upd),
		.dirty_control    (dirty_control),
		.dirty            (dirty)
	);
	
	cache_controller_v2 u_cache_controller(
	   	.clk             (clk),
		.rstn            (rstn),
		//CPU interfacing
		.req             (req_cpu),
      	.write           (write_cpu),
		.read            (read_cpu),
		.stall           (stall),
		.done            (done),
		//DRAM interfacing
		.write_mem       (write_mem),
		.read_mem        (read_mem),
		//CACHE controlling interface	
		.write_cache     (write_cache),//update to cache data block
		.read_cache      (read_cache),//fetch from cache data block
		.update_tag      (update_tag),
		.fetch_tag       (fetch_tag),
		.dirty_control   (dirty_control),
	   	.dirty_upd       (dirty_upd),
		.valid_control   (valid_control),
		.valid_upd       (valid_upd),
		.hit             (hit),
		.dirty           (dirty)

	);

endmodule 