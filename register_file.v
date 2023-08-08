module register_file(
	input      [4:0]  read_reg1,
  input      [4:0]  read_reg2, 
  input      [4:0]  write_reg, // Address for write data
	input      [31:0] write_data,// determine data to write into register
  input             clk,rst,
	input             write_flag,// 1: write data; 0: read data
	output     [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10,
  output     [31:0] reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20, reg21,
	output     [31:0] reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31, 
	output reg [31:0] read_data_1, read_data_2	
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
  reg [31:0] register [0:31];
  integer i;
//=======================================================
//  Behavioral coding
//=======================================================


  assign reg0  = register[0] ;
  assign reg1  = register[1] ;
  assign reg2  = register[2] ;
  assign reg3  = register[3] ;
  assign reg4  = register[4] ;
  assign reg5  = register[5] ;
  assign reg6  = register[6] ;
  assign reg7  = register[7] ;
  assign reg8  = register[8] ;
  assign reg9  = register[9] ;
  assign reg10 = register[10];
  assign reg11 = register[11];
  assign reg12 = register[12];
  assign reg13 = register[13];
  assign reg14 = register[14];
  assign reg15 = register[15];
  assign reg16 = register[16];
  assign reg17 = register[17];
  assign reg18 = register[18];
  assign reg19 = register[19];
  assign reg20 = register[20];
  assign reg21 = register[21];
  assign reg22 = register[22];
  assign reg23 = register[23];
  assign reg24 = register[24];
  assign reg25 = register[25];
  assign reg26 = register[26];
  assign reg27 = register[27];
  assign reg28 = register[28];
  assign reg29 = register[29];
  assign reg30 = register[30];
  assign reg31 = register[31];


always @ (posedge clk or posedge rst) begin
    if (rst) begin
		  for (i=0;i<32;i=i+1) begin
	      register[i] <= 32'd0;
	    end
    end
    else begin
	   if ((write_flag && write_reg) !=0) begin
			  register[write_reg]<=write_data;
	    end
    end
  end

  always @ (*) begin
	  if((rst||read_reg1)==0) begin
		  read_data_1 <=0;
	  end 
    else begin
      if (write_flag && (read_reg1 == write_reg)) begin
		    read_data_1 <= write_data;
	    end 
      else begin
		    read_data_1 <= register[read_reg1];
	    end
    end
  end
  always @ (*) begin
	  if((rst||read_reg2)==0) begin
	  	read_data_2 <=0;
	  end 
    else begin
      if (write_flag && (read_reg2 == write_reg)) begin
  		  read_data_2 <= write_data;
	    end 
     else begin
	  	  read_data_2 <= register[read_reg2];
  	  end
    end
  end
endmodule