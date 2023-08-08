
module cache_controller(
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
	output reg ready,
	output reg done
);

  parameter IDLE              = 3'b000;
  parameter COMPARE_TAG       = 3'b001;
  parameter WRITE_MISS        = 3'b010;
  parameter WRITE_MISS_DIRTY  = 3'b011;
  parameter READ_MISS         = 3'b100;
  parameter READ_MISS_DIRTY   = 3'b101;
  parameter WRITE_BACK        = 3'b110;
//  parameter ALLOCATE          = 4'b0111;
  //parameter EVICTION    = 'b1000;
  
  reg [2:0] current_state;
  reg [2:0] next_state;
  
//  reg in_progress;
  reg n_write_mem;
  reg n_read_mem;
  reg n_write_cache ;
  reg n_read_cache;
  reg n_valid_control;
  reg n_valid_upd;
  reg n_dirty_control;
  reg n_dirty_upd;
  reg n_ready;
  reg n_update_tag;
  reg n_fetch_tag;
  reg n_done;
//  reg n_evict;
//  reg n_writeback;  
 
///*  
  always@(posedge clk or negedge rstn) begin
     if(!rstn) begin
	     current_state   <= IDLE;
        write_mem       <= 'b0;
        read_mem        <= 'b0;
        write_cache     <= 'b0;
        read_cache      <= 'b0;
        valid_control   <= 'b0;
        valid_upd       <= 'b0;
        dirty_control   <= 'b0;
        dirty_upd       <= 'b0;
        ready           <= 'b0;
	     update_tag      <= 'b0;
		  fetch_tag       <= 'b0;
		  done            <= 'h0;
	  end 
	  else begin
	     current_state   <= next_state;
        write_mem       <= n_write_mem;
        read_mem        <= n_read_mem;
        write_cache     <= n_write_cache;
        read_cache      <= n_read_cache;
        valid_control   <= n_valid_control;
        valid_upd       <= n_valid_upd;
        dirty_control   <= n_dirty_control;
        dirty_upd       <= n_dirty_upd;
        ready           <= n_ready;		  
	     update_tag      <= n_update_tag;
		  fetch_tag       <= n_fetch_tag;
		  done            <= n_done;
	  end
  end
//*/
/*  
  always@* begin
	  current_state   = next_state;
	  write_mem       = n_write_mem;
	  read_mem        = n_read_mem;
	  write_cache     = n_write_cache;
	  read_cache      = n_read_cache;
	  valid_control   = n_valid_control;
	  valid_upd       = n_valid_upd;
	  dirty_control   = n_dirty_control;
	  dirty_upd       = n_dirty_upd;
	  ready           = n_ready;		  
	  update_tag      = n_update_tag;
	  fetch_tag       = n_fetch_tag;
	  done            = n_done;
  end
*/
  always@* begin
     //$display("read_mem = %b",n_read_mem);
     case(current_state)
	     IDLE: begin
		     $display("cycle:",$time," IDLE");
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
           n_ready           = 'b1;
			  n_done            = 'b0;
//           n_evict           = 'b0;//NYST
//           n_writeback       = 'b0;//NYST
			  if(write||read) begin //request from computer and assertion of write/read
			     //$display("cycle:",$time," CPU request for memory access");
			     next_state = COMPARE_TAG;
			  end
			  else begin
              //$display("cycle:",$time," Cache idling in loop...");			  
			     next_state = IDLE;
			  end
		  end
	     COMPARE_TAG: begin
		     //$display("cycle:",$time," Comparing tag and fetch/update...");
			  $display("cycle:",$time," COMPARE_TAG");
           if(hit) begin// hit cases
			     case({write,read})
				     'b10: begin
						  $display("cycle:",$time," WRITE_HIT");
			//         valid control signals
						  n_dirty_control   = 'b1;// Set valid since write new data to the cache line to 
						  n_dirty_upd       = 'b1;// indicated latest modification not write back yet to memory
			//         valid control signals
						  n_valid_control   = 'b0;
						  n_valid_upd       = 'b0;
			//         main memory control signals			  
						  n_write_mem       = 'b0;
						  n_read_mem        = 'b0;
			//         cache data block control signals
						  n_write_cache     = 'b1;// Write to cache new data 
						  n_read_cache      = 'b0;
			//         tag block control signals			  
						  n_update_tag      = 'b0;
						  n_fetch_tag       = 'b0;
			//         CPU polling signals			  
						  n_ready           = 'b0;
						  n_done            = 'b1;
			//           n_evict           = 'b0;//NYST
			//           n_writeback       = 'b0;//NYST						  
			           next_state      = IDLE;
					  end
				     'b01: begin
						  $display("cycle:",$time," READ_HIT");
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
						  n_read_cache      = 'b1;// read data from cache to cpu
			//         tag block control signals			  
						  n_update_tag      = 'b0;
						  n_fetch_tag       = 'b0;
			//         CPU polling signals			  
						  n_ready           = 'b0;
						  n_done            = 'b1;
			//           n_evict           = 'b0;//NYST
			//           n_writeback       = 'b0;//NYST							  
						  next_state      = IDLE;
					     //$display("cycle:",$time," Read hit, cache line is dirty or not -> read out data");				  
					  end
                 default: begin
						  $display("cycle:",$time," NO_WR_RD");
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
						  n_fetch_tag       = 'b0;
			//         CPU polling signals			  
						  n_ready           = 'b0;
						  n_done            = 'b0;
			//           n_evict           = 'b0;//NYST
			//           n_writeback       = 'b0;//NYST									  
						  next_state      = IDLE;
					  end
				  endcase
			  end
			  else begin //miss cases
			     case({write,read})
				     'b10: begin
					     if(dirty) begin
						     $display("cycle:",$time," WRITE_MISS and cache is DIRTY");
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
							  n_ready           = 'b0;
							  n_done            = 'b0;
				//           n_evict           = 'b0;//NYST
				//           n_writeback       = 'b0;//NYST	
						     next_state        = WRITE_MISS_DIRTY;   // first action for write miss (eviction)is writeback then fetch new data later
						  end
						  else begin
						     //$display("cycle:",$time," Write miss, Cache line is not dirty, fetch data from lower memory to cache for up-to-day data");
						     $display("cycle:",$time," WRITE_MISS and cache is CLEAN");							  
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
							  n_ready           = 'b0;
							  n_done            = 'b0;
				//           n_evict           = 'b0;//NYST
				//           n_writeback       = 'b0;//NYST							  
						     next_state        = WRITE_MISS;   // write miss is to fetch new data
						  end
					  end
				     'b01: begin
					     if(dirty) begin	
						     $display("cycle:",$time," READ_MISS and cache is DIRTY");					  
				//         valid control signals
							  n_dirty_control   = 'b0;
							  n_dirty_upd       = 'b0;
				//         valid control signals
							  n_valid_control   = 'b0;
							  n_valid_upd       = 'b0;
				//         main memory control signals			  
							  n_write_mem       = 'b1;// write back current cache line to the main memory
							  n_read_mem        = 'b0;
				//         cache data block control signals
							  n_write_cache     = 'b0;
							  n_read_cache      = 'b0;
				//         tag block control signals			  
							  n_update_tag      = 'b0;
							  n_fetch_tag       = 'b0;
				//         CPU polling signals			  
							  n_ready           = 'b0;
							  n_done            = 'b0;
				//           n_evict           = 'b0;//NYST
				//           n_writeback       = 'b0;//NYST
						     next_state = READ_MISS_DIRTY;   // first action for write miss (eviction)is writeback then fetch new data later
						  end
						  else begin
						     $display("cycle:",$time," READ_MISS and cache is CLEAN");					  
/*
    						  n_write_mem       = 'b0;
                       n_read_mem        = 'b0;  // fetch into cache line since no dirty and no valid
                       n_write_cache     = 'b0;
                       n_read_cache      = 'b0;
                       n_valid_control   = 'b0;
                       n_valid_upd       = 'b0;
                       n_dirty_control   = 'b0;
                       n_dirty_upd       = 'b0;
                       n_ready           = 'b0;
	                    n_update_tag      = 'b1;
		                 n_fetch_tag       = 'b0;  // fetch tag for comparing
			              n_done            = 'b0;		
*/							  
				//         valid control signals
							  n_dirty_control   = 'b0; 
							  n_dirty_upd       = 'b0;
				//         valid control signals
							  n_valid_control   = 'b0;
							  n_valid_upd       = 'b0;
				//         main memory control signals			  
							  n_write_mem       = 'b0;
							  n_read_mem        = 'b1;// fetch the data to the cache 
				//         cache data block control signals
							  n_write_cache     = 'b0; 
							  n_read_cache      = 'b0;
				//         tag block control signals			  
							  n_update_tag      = 'b0;// update tag after update the miss cache tag in the mem
							  n_fetch_tag       = 'b0;
				//         CPU polling signals			  
							  n_ready           = 'b0;
							  n_done            = 'b0;
				//           n_evict           = 'b0;//NYST
				//           n_writeback       = 'b0;//NYST								  
						     next_state = READ_MISS;  					  
						  end
					  end					  
		
                 default: begin
						  $display("cycle:",$time," NO_WR_RD_DIRTY");
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
						  n_fetch_tag       = 'b0;
			//         CPU polling signals			  
						  n_ready           = 'b0;
						  n_done            = 'b0;
			//           n_evict           = 'b0;//NYST
			//           n_writeback       = 'b0;//NYST									  
						  next_state      = IDLE;
					  end				     
				  endcase
			  end
		  end
/*
	     WRITE_HIT: begin
           $display("cycle:",$time," WRITE_HIT");
			  n_dirty_control = 'b1;
	        n_dirty_upd     = 'b1;
			  n_valid_control = 'b0;
	        n_valid_upd     = 'b0;
			  n_read_cache    = 'b0;
           n_write_cache   = 'b1;
			  n_read_mem      = 'b0;
           n_write_mem     = 'b0;
			  n_update_tag    = 'b0;
			  n_fetch_tag     = 'b0;
	        n_ready         = 'b0;
			  n_done          = 'b1;			  
			  next_state      = IDLE;
		  end
	     READ_HIT: begin
           $display("cycle:",$time," READ_HIT");
			  n_dirty_control = 'b0;
	        n_dirty_upd     = 'b0;
			  n_valid_control = 'b0;
	        n_valid_upd     = 'b0;
			  n_read_cache    = 'b1;
           n_write_cache   = 'b0;
			  n_read_mem      = 'b0;
           n_write_mem     = 'b0;
			  n_update_tag    = 'b0;
			  n_fetch_tag     = 'b0;
	        n_ready         = 'b0;
			  n_done          = 'b1;			  
			  next_state      = IDLE;
		  end		  
*/
	     WRITE_MISS: begin
		  	  //$display("cycle:",$time," fetched the new data to cache, valid is set, now write the data from cpu and set dirty bit");
			  $display("cycle:",$time," WRITE_MISS");
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
			  n_write_cache     = 'b0;// write to modify the cache 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b1;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_ready           = 'b0;
			  n_done            = 'b1;			  
			  next_state      = IDLE;
		  end
	     WRITE_MISS_DIRTY: begin
		  	  //$display("cycle:",$time," fetched the new data to cache, valid is set, now write the data from cpu and set dirty bit");
			  $display("cycle:",$time," WRITE_MISS_DIRTY");
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
			  n_write_cache     = 'b0;// write to modify the cache 
			  n_read_cache      = 'b0;
//         tag block control signals			  
			  n_update_tag      = 'b1;// update tag block since miss 
			  n_fetch_tag       = 'b0;
//         CPU polling signals			  
			  n_ready           = 'b0;
			  n_done            = 'b1;			  
			  next_state      = IDLE;
		  end
	     READ_MISS: begin
			  $display("cycle:",$time," READ_MISS");
/*
			  n_dirty_control = 'b0;
	        n_dirty_upd     = 'b0;
			  n_valid_control = 'b1;
	        n_valid_upd     = 'b1;			  
			  n_read_cache    = 'b1;
           n_write_cache   = 'b0;
			  n_read_mem      = 'b0;
           n_write_mem     = 'b0;			  
			  n_update_tag    = 'b1;
			  n_fetch_tag     = 'b0;
			  n_ready         = 'b0;
			  n_done          = 'b1;
*/

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
			  n_ready           = 'b0;
			  n_done            = 'b1;			  
			  next_state      = IDLE;
		  end		 
	     READ_MISS_DIRTY: begin
			  $display("cycle:",$time," READ_MISS_DIRTY");
/*
			  n_dirty_control = 'b0;
	        n_dirty_upd     = 'b0;
			  n_valid_control = 'b1;
	        n_valid_upd     = 'b1;			  
			  n_read_cache    = 'b1;
           n_write_cache   = 'b0;
			  n_read_mem      = 'b0;
           n_write_mem     = 'b0;			  
			  n_update_tag    = 'b1;
			  n_fetch_tag     = 'b0;
			  n_ready         = 'b0;
			  n_done          = 'b1;
*/

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
			  n_ready           = 'b0;
			  n_done            = 'b1;			  
			  next_state      = IDLE;
		  end		 
	  endcase
  end


endmodule 