`timescale 1ns/1ns
`include "mem.v"
`include "cache_unit.v"

module top_wrapper(
   input wire          clk,
	input wire          rstn,
	input wire          req_cpu,
	input wire          write,
	input wire          read,
//	input wire  [1:0]   read_cmd_capture,
//	output reg  [1:0]   read_cmd_release,
	input wire  [31:0]  address,
	input wire  [31:0]  wrdata,
	output wire [31:0]  rddata,
	output wire          stall,
	output reg          d1_stall,
	output reg          done,

	input wire         mem_MemRd        ,
	input wire         mem_RegWr        ,
	input wire         mem_MemWr        ,
	input wire  [1:0]  mem_MemtoReg     ,
	input wire         mem_zero         ,
	input wire         mem_lt           ,
	input wire  [4:0]  mem_rd           ,
	input wire  [4:0]  mem_rs2          ,
	input wire  [31:0] mem_pc		      ,
	input wire  [31:0] mem_current_pc	  ,  
	input wire  [31:0] mem_readdata2    ,
	input wire  [1:0]  mem_Br_sel       ,
	input wire         mem_Branch       ,
	input wire         mem_Jump         ,
	input wire  [2:0]  mem_Load_sel     , 
	input wire  [1:0]  mem_Store_sel    , 
	input wire  [31:0] mem_ALU_result   ,
	input wire         mem_predicted_bit,
	input wire         mem_RegWr_fp     , 
	input wire  [31:0] mem_readdata2_fp ,
	input wire  [31:0] mem_ALU_result_fp,
	input wire         mem_data_sel,
	
	output reg         mem_MemRd_release        ,
	output reg         mem_RegWr_release        ,
	output reg         mem_MemWr_release        ,
	output reg  [1:0]  mem_MemtoReg_release     ,
	output reg         mem_zero_release         ,
	output reg         mem_lt_release           ,
	output reg  [4:0]  mem_rd_release           ,
	output reg  [4:0]  mem_rs2_release          ,
	output reg  [31:0] mem_pc_release		      ,
	output reg  [31:0] mem_current_pc_release	  ,  
	output reg  [31:0] mem_readdata2_release    ,
	output reg  [1:0]  mem_Br_sel_release       ,
	output reg         mem_Branch_release       ,
	output reg         mem_Jump_release         ,
	output reg  [2:0]  mem_Load_sel_release     , 
	output reg  [1:0]  mem_Store_sel_release    , 
	output reg  [31:0] mem_ALU_result_release   ,
	output reg         mem_predicted_bit_release,
	output reg         mem_RegWr_fp_release     , 
	output reg  [31:0] mem_readdata2_fp_release ,
	output reg  [31:0] mem_ALU_result_fp_release,
	output reg         mem_data_sel_release  
); 
	//wire        write_cache;
	//wire        read_cache;
	wire        hit;
	//wire        ready;
    wire [31:0] wrdata_mem;
	wire [31:0] rddata_mem;
	wire        write_mem;
    wire        read_mem;
	wire [9:0]  tag_out;
	
	reg         d1_write_mem;
	reg         d1_read_mem;
	reg         d1_write;
	reg         d1_read;	
	reg         d1_req_cpu;
	reg  [31:0] d1_wrdata;
	wire  [31:0] d1_rddata;
	wire         d1_done;
	reg         d2_stall;
	reg  [31:0] d1_address;
	reg  [1:0]  read_cmd_store;

	reg         mem_MemRd_store        ;
	reg         mem_RegWr_store        ;
	reg         mem_MemWr_store        ;
	reg  [1:0]  mem_MemtoReg_store     ;
	reg         mem_zero_store         ;
	reg         mem_lt_store           ;
	reg  [4:0]  mem_rd_store           ;
	reg  [4:0]  mem_rs2_store          ;
	reg  [31:0] mem_pc_store		      ;
	reg  [31:0] mem_current_pc_store	  ;  
	reg  [31:0] mem_readdata2_store    ;
	reg  [1:0]  mem_Br_sel_store       ;
	reg         mem_Branch_store       ;
	reg         mem_Jump_store         ;
	reg  [2:0]  mem_Load_sel_store     ; 
	reg  [1:0]  mem_Store_sel_store    ; 
	reg  [31:0] mem_ALU_result_store   ;
	reg         mem_predicted_bit_store;
	reg         mem_RegWr_fp_store     ; 
	reg  [31:0] mem_readdata2_fp_store ;
	reg  [31:0] mem_ALU_result_fp_store;
	reg         mem_data_sel_store;

	always@(posedge clk or negedge rstn) begin
	   if(!rstn) begin
		   d1_write_mem <= 'b0;
			d1_read_mem  <= 'b0;
			d1_req_cpu   <= 'b0;
		end
		else begin
		   d1_write_mem <= write_mem;
			d1_read_mem  <= read_mem;	
           //d1_req_cpu   <= req_cpu&&~d1_stall;			
	   end
	end
	always@(posedge clk or negedge rstn) begin
	   if(!rstn) begin
		   d1_write <= 'b0;
			d1_read  <= 'b0;
			d1_wrdata    <= 'b0;
			d1_address <= 'b0;

			mem_MemRd_store         <= 'h0;
			mem_RegWr_store         <= 'h0;
			mem_MemWr_store         <= 'h0;
			mem_MemtoReg_store      <= 'h0;
			mem_zero_store          <= 'h0;
			mem_lt_store            <= 'h0;
			mem_rd_store            <= 'h0;
			mem_rs2_store           <= 'h0;
			mem_pc_store		    <= 'h0  ;
			mem_current_pc_store	   <= 'h0;  
			mem_readdata2_store     <= 'h0;
			mem_Br_sel_store        <= 'h0;
			mem_Branch_store        <= 'h0;
			mem_Jump_store          <= 'h0;
			mem_Load_sel_store      <= 'h0; 
			mem_Store_sel_store     <= 'h0; 
			mem_ALU_result_store    <= 'h0;
			mem_predicted_bit_store <= 'h0;
			mem_RegWr_fp_store      <= 'h0; 
			mem_readdata2_fp_store  <= 'h0;
			mem_ALU_result_fp_store <= 'h0;
			mem_data_sel_store <= 'h0;		
			
			mem_MemRd_release         <= 'h0;
			mem_RegWr_release         <= 'h0;
			mem_MemWr_release         <= 'h0;
			mem_MemtoReg_release      <= 'h0;
			mem_zero_release          <= 'h0;
			mem_lt_release            <= 'h0;
			mem_rd_release            <= 'h0;
			mem_rs2_release           <= 'h0;
			mem_pc_release		       <= 'h0;
			mem_current_pc_release	   <= 'h0;  
			mem_readdata2_release     <= 'h0;
			mem_Br_sel_release        <= 'h0;
			mem_Branch_release        <= 'h0;
			mem_Jump_release          <= 'h0;
			mem_Load_sel_release      <= 'h0; 
			mem_Store_sel_release     <= 'h0; 
			mem_ALU_result_release    <= 'h0;
			mem_predicted_bit_release <= 'h0;
			mem_RegWr_fp_release      <= 'h0; 
			mem_readdata2_fp_release  <= 'h0;
			mem_ALU_result_fp_release <= 'h0;
			mem_data_sel_release <= 'h0;
			//read_cmd_release <= 0;
			//read_cmd_store <= 0;
			//rddata    <= 'b0;	
		end
		else begin
		   if(req_cpu&&~stall) begin
		      d1_write <= write;
			   d1_read  <= read;
			   d1_wrdata <= wrdata;
			   d1_address <= address;

			   mem_MemRd_store         <= mem_MemRd;
			   mem_RegWr_store         <= mem_RegWr;
			   mem_MemWr_store         <= mem_MemWr;
			   mem_MemtoReg_store      <= mem_MemtoReg;
			   mem_zero_store          <= mem_zero;
			   mem_lt_store            <= mem_lt;
			   mem_rd_store            <= mem_rd;
			   mem_rs2_store           <= mem_rs2;
			   mem_pc_store		    <= mem_pc  ;
			   mem_current_pc_store	   <= mem_current_pc;  
			   mem_readdata2_store     <= mem_readdata2;
			   mem_Br_sel_store        <= mem_Br_sel;
			   mem_Branch_store        <= mem_Branch;
			   mem_Jump_store          <= mem_Jump;
			   mem_Load_sel_store      <= mem_Load_sel; 
			   mem_Store_sel_store     <= mem_Store_sel; 
			   mem_ALU_result_store    <= mem_ALU_result;
			   mem_predicted_bit_store <= mem_predicted_bit;
			   mem_RegWr_fp_store      <= mem_RegWr_fp; 
			   mem_readdata2_fp_store  <= mem_readdata2_fp;
			   mem_ALU_result_fp_store <= mem_ALU_result_fp;
			   mem_data_sel_store <= mem_data_sel;		
			   
			   mem_MemRd_release         <= mem_MemRd_store;
			   mem_RegWr_release         <= mem_RegWr_store;
			   mem_MemWr_release         <= mem_MemWr_store;
			   mem_MemtoReg_release     <= mem_MemtoReg_store;
			   mem_zero_release          <= mem_zero_store;
			   mem_lt_release            <= mem_lt_store;
			   mem_rd_release            <= mem_rd_store;
			   mem_rs2_release           <= mem_rs2_store;
			   mem_pc_release		    <= mem_pc_store  ;
			   mem_current_pc_release	   <= mem_current_pc_store;  
			   mem_readdata2_release     <= mem_readdata2_store;
			   mem_Br_sel_release        <= mem_Br_sel_store;
			   mem_Branch_release        <= mem_Branch_store;
			   mem_Jump_release          <= mem_Jump_store;
			   mem_Load_sel_release      <= mem_Load_sel_store; 
			   mem_Store_sel_release     <= mem_Store_sel_store; 
			   mem_ALU_result_release    <= mem_ALU_result_store;
			   mem_predicted_bit_release <= mem_predicted_bit_store;
			   mem_RegWr_fp_release      <= mem_RegWr_fp_store; 
			   mem_readdata2_fp_release  <= mem_readdata2_fp_store;
			   mem_ALU_result_fp_release <= mem_ALU_result_fp_store;
			   mem_data_sel_release <= mem_data_sel_store;	
			   //read_cmd_store <= read_cmd_capture;
			   //rddata    <= d1_rddata;				
			end
			else begin
			   if(done) begin
				  d1_read  <= 0;
				  d1_write <= 0;
				  //read_cmd_release <= read_cmd_store;
				  
				  mem_MemRd_release         <= mem_MemRd_store;
				  mem_RegWr_release         <= mem_RegWr_store;
				  mem_MemWr_release         <= mem_MemWr_store;
				  mem_MemtoReg_release     <= mem_MemtoReg_store;
				  mem_zero_release          <= mem_zero_store;
				  mem_lt_release            <= mem_lt_store;
				  mem_rd_release            <= mem_rd_store;
				  mem_rs2_release           <= mem_rs2_store;
				  mem_pc_release		    <= mem_pc_store  ;
				  mem_current_pc_release	   <= mem_current_pc_store;  
				  mem_readdata2_release     <= mem_readdata2_store;
				  mem_Br_sel_release        <= mem_Br_sel_store;
				  mem_Branch_release        <= mem_Branch_store;
				  mem_Jump_release          <= mem_Jump_store;
				  mem_Load_sel_release      <= mem_Load_sel_store; 
				  mem_Store_sel_release     <= mem_Store_sel_store; 
				  mem_ALU_result_release    <= mem_ALU_result_store;
				  mem_predicted_bit_release <= mem_predicted_bit_store;
				  mem_RegWr_fp_release      <= mem_RegWr_fp_store; 
				  mem_readdata2_fp_release  <= mem_readdata2_fp_store;
				  mem_ALU_result_fp_release <= mem_ALU_result_fp_store;
				  mem_data_sel_release <= mem_data_sel_store;	
			   end
			   else begin

					mem_MemRd_release         <= mem_MemRd;
					mem_RegWr_release         <= mem_RegWr;
					mem_MemWr_release         <= mem_MemWr;
					mem_MemtoReg_release     <= mem_MemtoReg;
					mem_zero_release          <= mem_zero;
					mem_lt_release            <= mem_lt;
					mem_rd_release            <= mem_rd;
					mem_rs2_release           <= mem_rs2;
					mem_pc_release		    <= mem_pc ;
					mem_current_pc_release	   <= mem_current_pc;  
					mem_readdata2_release     <= mem_readdata2;
					mem_Br_sel_release        <= mem_Br_sel;
					mem_Branch_release        <= mem_Branch;
					mem_Jump_release          <= mem_Jump;
					mem_Load_sel_release      <= mem_Load_sel; 
					mem_Store_sel_release     <= mem_Store_sel; 
					mem_ALU_result_release    <= mem_ALU_result;
					mem_predicted_bit_release <= mem_predicted_bit;
					mem_RegWr_fp_release      <= mem_RegWr_fp; 
					mem_readdata2_fp_release  <= mem_readdata2_fp;
					mem_ALU_result_fp_release <= mem_ALU_result_fp;
					mem_data_sel_release <= mem_data_sel;
			   end
			end
	   end
	end
///*        delay a cycle for done signal	
	always@(negedge clk or negedge rstn) begin
	   if(!rstn) begin
		  done  <= 0;
		  d1_stall <= 0;
		  d2_stall <= 0;
		end
		else begin
          done <= d1_done;
		  d2_stall <= stall;
		  d1_stall <= d2_stall;
	   end
	end
//*/
	mem u_mem(
	   .clk        (clk),         //clock
		.rstn       (rstn),        //negative reset
		.write      (d1_write_mem),   //d1_write enable port delayed 1 cycle since cache controller output sooner than the data 1 cycle
		.read       (d1_read_mem),  //d1_read enable port delayed 1 cycle since cache controller output sooner than the data 1 cycle
		.address    ({14'b0,tag_out,address[7:0]}),     //address cache want to interact with mem
//		.address    (address),     //address cache want to interact with mem
		.wrdata     (wrdata_mem),//data that get write into the 4 banks with 32-bit word per address with alignment
		.rddata     (rddata_mem),//data that get read out from the 4 banks with 32-bit word per address with alignment
		.ready      ()
	);

   cache_unit u_cache (
	    .clk          (clk),
		.rstn         (rstn),
		.req_cpu      (req_cpu),
		.write_cpu    (d1_write),
		.read_cpu     (d1_read),
		.stall        (stall),
		.done         (d1_done),
		.wrdata_cpu   (d1_wrdata),
		.rddata_cpu   (rddata),
		.address      (d1_address),
		.write_mem    (write_mem),
		.read_mem     (read_mem),
		.tag_out      (tag_out),
		.wrdata_mem   (wrdata_mem),
		.rddata_mem   (rddata_mem)
		
	);
endmodule
/*
rst: Reset;
 clk: Clock input;
 wr, rd: Cache operation request signals;
 data_rd: Data returned from cache (Cache to host);
 data_wr: Data written to cache (Host to cache);
 addr_req: Cache request address (Host to cache);
 addr_resp: The data address of cache response (Cache to host, cache controller keeps the address of cache request in a buffer when cache miss happens);
 rdy: Cache ready;
 busy: Cache busy;
 wr_mem, rd_mem: Memory operation request signals;
 busy_mem: Memory busy;
 data_rd_mem: Data returned from memory (Memory to cache);
 data_wr_mem: Data written to memory (Cache to memory);
 addr_mem: Memory access address (Cache to memory);
 cache_miss_count: Cache miss statistics;
 cache_hit_count: Cache hit statistics;

*/
