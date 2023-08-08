module Data_Mem(
    input           clk       ,
    input           rst       ,
    input  [31:0]   Address   ,
    input  [31:0]   DataWrite ,
    input           MemWr     ,
    input           MemRd     ,
    output [31:0]   ReadData           
);

    integer i;
//=======================================================
//  REG/WIRE declarations
//=======================================================
    reg  [31:0] DataMem[0:255];
    wire [7:0]  addr = Address[7:2];
    wire [31:0] Mem_fc, Mem_ec, Mem_e8, Mem_e0; 
    wire [31:0] Mem_dc, Mem_e4;
    wire [31:0] Mem_d0, Mem_d4;
    wire [31:0] Mem_d8, Mem_00;
    wire [31:0] Mem_04, Mem_08;
    wire [31:0] Mem_0c, Mem_10;
    wire [31:0] Mem_14, Mem_18;
    wire [31:0] Mem_1c, Mem_20;
    wire [31:0] Mem_24, Mem_28;
    wire [31:0] Mem_2c;
//=======================================================
//  Behavioral coding
//=======================================================
    assign Mem_e8 = DataMem[58]; 
    assign Mem_ec = DataMem[59];   
    assign Mem_fc = DataMem[63];
    assign Mem_e0 = DataMem[56]; 
    assign Mem_dc = DataMem[55];   
    assign Mem_e4 = DataMem[57];  
    assign Mem_d0 = DataMem[52];   
    assign Mem_d4 = DataMem[53];
    assign Mem_d8 = DataMem[54];
    assign Mem_00 = DataMem[0];
    assign Mem_04 = DataMem[1];
    assign Mem_08 = DataMem[2];
    assign Mem_0c = DataMem[3];
    assign Mem_10 = DataMem[4];
    assign Mem_14 = DataMem[5];
    assign Mem_18 = DataMem[6];
    assign Mem_1c = DataMem[7];
    assign Mem_20 = DataMem[8];
    assign Mem_24 = DataMem[9];
    assign Mem_28 = DataMem[10];
    assign Mem_2c = DataMem[11];

always @(posedge clk or posedge rst) 
begin
    if (rst) begin
        $readmemh("DataMem.txt", DataMem);
    end
    else begin
        if (MemWr == 1)                  
        DataMem[addr] <= DataWrite;
        //else
        //DataMem[addr] <= DataMem[addr];
    end
end
    
assign ReadData = (MemRd == 1) ? DataMem[addr] : 0; 

endmodule