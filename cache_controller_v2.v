
module cache_controller_v2(
   input wire clk,
	input wire rstn,
	input wire write, // write enable from cpu
	input wire read,  // read enable from cpu
	output reg write_cache, //write enable for "write to" cache from cpu request
	output reg read_cache, //read enable for "read from" cache to cpu request
	output reg update_tag,
	output reg fetch_tag,
	input wire dirty,
	input wire req,   //request for mem access (write or read) from cpu
	input wire hit,   
	output reg write_mem,  //update to mem from cache
	output reg read_mem,   //update from mem to cache
	output reg valid_control,
	output reg valid_upd,
	output reg dirty_control,
	output reg dirty_upd,
	output reg stall,
	output reg done
);

  parameter IDLE                            = 4'h0;
  parameter COMPARE_TAG                     = 4'h1;
  parameter WRITE_HIT                       = 4'h2;
  parameter READ_HIT                        = 4'h3;
  parameter WRITE_MISS                      = 4'h4;
  parameter WRITE_MISS_DIRTY                = 4'h5;
  parameter READ_MISS                       = 4'h6;
  parameter READ_MISS_DIRTY                 = 4'h7;
  parameter WR_MISS_DIRTY_WRITE_BACK        = 4'h8;
  parameter RD_MISS_DIRTY_WRITE_BACK        = 4'h9;
  parameter WR_MISS_FETCH_FROM_MEM          = 4'hA;
  parameter RD_MISS_FETCH_FROM_MEM          = 4'hB;
//  parameter ALLOCATE          = 4'b0111;
  //parameter EVICTION    = 'b1000;
  
  reg [3:0] current_state;
  reg [3:0] next_state;
  
  reg n_write_mem ;
  reg n_read_mem;
  reg n_write_cache ;
  reg n_read_cache;
  reg n_valid_control;
  reg n_valid_upd;
  reg n_dirty_control;
  reg n_dirty_upd;
  reg n_stall;
  reg n_update_tag;
  reg n_fetch_tag;
  reg n_done;
//  reg n_evict;
//  reg n_writeback;  
 
///*  
  always@(negedge clk or negedge rstn) begin
     if(!rstn) begin
	     current_state   <= IDLE;
/*
		 write_mem       <= 'b0;
        read_mem        <= 'b0;
        write_cache     <= 'b0;
        read_cache      <= 'b0;
        valid_control   <= 'b0;
        valid_upd       <= 'b0;
        dirty_control   <= 'b0;
        dirty_upd       <= 'b0;
        stall           <= 'b0;
        update_tag      <= 'b0;
		  fetch_tag       <= 'b0;
		  done            <= 'h0;
*/		  
	  end 
	  else begin
	     current_state   <= next_state;
/*
		 write_mem       <= n_write_mem;
        read_mem        <= n_read_mem;
        write_cache     <= n_write_cache;
        read_cache      <= n_read_cache;
        valid_control   <= n_valid_control;
        valid_upd       <= n_valid_upd;
        dirty_control   <= n_dirty_control;
        dirty_upd       <= n_dirty_upd;
        stall           <= n_stall;		  
        update_tag      <= n_update_tag;
		  fetch_tag       <= n_fetch_tag;
		  done            <= n_done;
*/
	  end
  end
//*/
///*  
  always@* begin
//	  current_state   = next_state;
	  write_mem       = n_write_mem;
	  read_mem        = n_read_mem;
	  write_cache     = n_write_cache;
	  read_cache      = n_read_cache;
	  valid_control   = n_valid_control;
	  valid_upd       = n_valid_upd;
	  dirty_control   = n_dirty_control;
	  dirty_upd       = n_dirty_upd;
	  stall           = n_stall;		  
	  update_tag      = n_update_tag;
	  fetch_tag       = n_fetch_tag;
	  done            = n_done;
  end
//*/
  always@(*) begin
     //$display("read_mem = %b",n_read_mem);
     case(current_state)
	     IDLE: begin
		     $display("cycle:",$time/2," IDLE");
//         valid control signals
           n_dirty_control   = 'b0;
           n_dirty_upd       = 'b0;
//         valid control signals
           n_valid_control   = 'b0;
           n_valid_upd       = 'b0;
//         main memory control signals			  
           n_write_mem       = 'b0;
           n_read_mem        = 'b0;
//         cache data block control signals
           n_write_cache     = 'b0;
           n_read_cache      = 'b0;
//         tag block control signals			  
	       n_update_tag      = 'b0;
		   n_fetch_tag       = 'b1;
//         CPU polling signals			  
           n_stall           = 'b0;// stall 0 means cache is ready for request
		   n_done            = 'b0;
//           n_evict           = 'b0;//NYST
//           n_writeback       = 'b0;//NYST
			  if(req&&(write||read)&&~stall) begin //request from computer and assertion of write/read
			     //$display("cycle:",$time," CPU request for memory access");
				  $display("CPU request!!!");
			     next_state = COMPARE_TAG;
			  end
			  else begin
              //$display("cycle:",$time," Cache idling in loop...");			  
			     next_state = IDLE;
			  end
		  end
	     COMPARE_TAG: begin
		     //$display("cycle:",$time," Comparing tag and fetch/update...");
			  $display("cycle:",$time/2," COMPARE_TAG");
//         valid control signals
			  n_dirty_control   = 'b0;// Set valid since write new data to the cache line to 
			  n_dirty_upd       = 'b0;// indicated latest modification not write back yet to memory
//         valid control signals
			  n_valid_control   = 'b0;
			  n_valid_upd       = 'b0;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b0;// Write to cache new data 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b0;
			  n_fetch_tag       = 'b1;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b0;			  
           if(hit) begin// hit cases
			     if(write) begin
				     $display("cycle:",$time/2," WRITE_HIT detected");
				     next_state      = WRITE_HIT;
				  end
				  else begin
				     if(read) begin
					     $display("cycle:",$time/2," READ_HIT detected");
					     next_state      = READ_HIT;
					  end
					  else begin
					     $display("cycle:",$time/2," NO_WR_RD detected");
					     next_state      = IDLE;
					  end
				  end
			  end
			  else begin //miss cases
			     if(write) begin
				     //next_state      <= WR_MISS_DIRTY_WRITE_BACK;
					  if(dirty) begin
					     $display("cycle:",$time/2," WRITE_MISS_DIRTY detected");
						  //$display("cycle:",$time," WRITE_MISS and cache is DIRTY");
						  next_state        = WR_MISS_DIRTY_WRITE_BACK;   // first action for write miss (eviction)is writeback then fetch new data later

					  end
					  else begin
					     $display("cycle:",$time/2," WRITE_MISS_CLEAN detected");
						  //$display("cycle:",$time," Write miss, Cache line is not dirty, fetch data from lower memory to cache for up-to-day data");
						  //$display("cycle:",$time," WRITE_MISS and cache is CLEAN");							  							  
						  next_state        = WR_MISS_FETCH_FROM_MEM;   // write miss is to fetch new data	
		           end				  
				  end
				  else begin
				     if(read) begin
					     //$display("cycle:",$time," READ_HIT detected");
					     //next_state      <= READ_HIT;
					     if(dirty) begin
						     $display("cycle:",$time/2," READ_MISS_DIRTY detected");
						     next_state        = RD_MISS_DIRTY_WRITE_BACK;   // first action for write miss (eviction)is writeback then fetch new data later
						  end
						  else begin
						     //$display("cycle:",$time," Write miss, Cache line is not dirty, fetch data from lower memory to cache for up-to-day data");
						     $display("cycle:",$time/2," READ_MISS_CLEAN detected");							  							  
						     next_state        = RD_MISS_FETCH_FROM_MEM;   // write miss is to fetch new data
							  //$display("cycle:",$time," yo passed");
						  end						  
					  end
					  else begin
					     $display("cycle:",$time/2," NO_WR_RD detected");
					     next_state      = IDLE;
					  end
				  end		
			  end
		  end
        WR_MISS_DIRTY_WRITE_BACK: begin
		     $display("cycle:",$time/2," WR_MISS_DIRTY_WRITE_BACK");
	//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
	//         valid control signals
			  n_valid_control   = 'b0;
			  n_valid_upd       = 'b0;
	//         main memory control signals			  
			  n_write_mem       = 'b1;// write back the dirty data first
			  n_read_mem        = 'b0;
	//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b0;
	//         tag block control signals			  
			  n_update_tag      = 'b0;// dont update tag here since write back is in progress
			  n_fetch_tag       = 'b0;
	//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b0;
	//           n_evict           = 'b0;//NYST
	//           n_writeback       = 'b0;//NYST				  
           next_state        = WRITE_MISS_DIRTY;
			  //$display("cycle:",$time," WRITE_MISS_DIRTY_DEBUG");
			  end
        RD_MISS_DIRTY_WRITE_BACK: begin
		     $display("cycle:",$time/2," RD_MISS_DIRTY_WRITE_BACK");
	//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
	//         valid control signals
			  n_valid_control   = 'b0;
			  n_valid_upd       = 'b0;
	//         main memory control signals			  
			  n_write_mem       = 'b1;// write back the dirty data first
			  n_read_mem        = 'b0;
	//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b0;
	//         tag block control signals			  
			  n_update_tag      = 'b0;// dont update tag here since write back is in progress
			  n_fetch_tag       = 'b0;
	//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b0;
	//           n_evict           = 'b0;//NYST
	//           n_writeback       = 'b0;//NYST			 
			  next_state        = READ_MISS_DIRTY;
		  end
        WR_MISS_FETCH_FROM_MEM: begin
		     $display("cycle:",$time/2," WR_MISS_FETCH_FROM_MEM");
//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
//         valid control signals
			  n_valid_control   = 'b0;
			  n_valid_upd       = 'b0;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b1;// fetch into cache line since no dirty and no valid
//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b0;
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b0;
//           n_evict           = 'b0;//NYST
//           n_writeback       = 'b0;//NYST			  
			  next_state        = WRITE_MISS;
		  end
        RD_MISS_FETCH_FROM_MEM: begin
		     $display("cycle:",$time/2," RD_MISS_FETCH_FROM_MEM");
//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
//         valid control signals
			  n_valid_control   = 'b0;
			  n_valid_upd       = 'b0;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b1;// fetch into cache line since no dirty and no valid
//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b0;
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b0;
//           n_evict           = 'b0;//NYST
//           n_writeback       = 'b0;//NYST			  
			  next_state        = READ_MISS;
		  end		  
	     WRITE_HIT: begin
           $display("cycle:",$time/2," WRITE_HIT");
//         valid control signals
			  n_dirty_control   = 'b1;// data is now written into the cache line and the latest will be evict later 
			  n_dirty_upd       = 'b1;
//         valid control signals
			  n_valid_control   = 'b0;// the data is now valid 
			  n_valid_upd       = 'b0;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b1;// write to modify the cache 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b0;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;		  
			  next_state      = IDLE;
		  end
	     READ_HIT: begin
           $display("cycle:",$time/2," READ_HIT");
//         valid control signals
			  n_dirty_control   = 'b0;// data is now written into the cache line and the latest will be evict later 
			  n_dirty_upd       = 'b0;
//         valid control signals
			  n_valid_control   = 'b0;// the data is now valid 
			  n_valid_upd       = 'b0;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b0;// write to modify the cache 
			  n_read_cache      = 'b1;
//         tag block control signals			  
			  n_update_tag      = 'b0;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;			  
			  next_state      = IDLE;
		  end		  
	     WRITE_MISS: begin
			  $display("cycle:",$time/2," WRITE_MISS");
//         valid control signals
			  n_dirty_control   = 'b1;// data is now written into the cache line and the latest will be evict later 
			  n_dirty_upd       = 'b1;
//         valid control signals
			  n_valid_control   = 'b1;// the data is now valid 
			  n_valid_upd       = 'b1;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b1;// write to modify the cache 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b1;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;			  
			  next_state        = IDLE;
		  end
	     WRITE_MISS_DIRTY: begin
			  $display("cycle:",$time/2," WRITE_MISS_DIRTY");
//         valid control signals
			  n_dirty_control   = 'b1;// data is now written into the cache line and the latest will be evict later 
			  n_dirty_upd       = 'b1;
//         valid control signals
			  n_valid_control   = 'b1;// the data is now valid 
			  n_valid_upd       = 'b1;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b1;// write to modify the cache 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b1;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;			  
			  next_state        = IDLE;
		  end
	     READ_MISS: begin
			  $display("cycle:",$time/2," READ_MISS");
//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
//         valid control signals
			  n_valid_control   = 'b1;// the data is now valid 
			  n_valid_upd       = 'b1;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b1;// read from cache 
//         tag block control signals			  
			  n_update_tag      = 'b1;
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;			  
			  next_state        = IDLE;
		  end		 
	     READ_MISS_DIRTY: begin
			  $display("cycle:",$time/2," READ_MISS_DIRTY");
//         valid control signals
			  n_dirty_control   = 'b0; 
			  n_dirty_upd       = 'b0;
//         valid control signals
			  n_valid_control   = 'b1;// the data is now valid 
			  n_valid_upd       = 'b1;
//         main memory control signals			  
			  n_write_mem       = 'b0;
			  n_read_mem        = 'b0;
//         cache data block control signals
			  n_write_cache     = 'b0; 
			  n_read_cache      = 'b1;// read from cache 
//         tag block control signals			  
			  n_update_tag      = 'b1;
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_stall           = 'b1;
			  n_done            = 'b1;			  
			  next_state        = IDLE;
		  end
		  		 
	  endcase
  end


endmodule 