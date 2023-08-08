module IM (
    input [31:0] pc         ,
    output reg[31:0] instruction 
);
    reg  [31:0] IM [0:127];
    //wire [29:0] addr =  pc[31:2];


    //assign [29:0] addr =  pc[31:2]; //don't consider pc[1:0] cause pc[1:0]'s always "11"
    //assign instruction =  IM[addr];
    always@* begin
       instruction = IM[pc[31:2]];
    end
    initial begin
        instruction = 0;
        //$readmemb("IM.txt", IM);
        //$readmemh("Fibonacci9.txt", IM);
        //$readmemb("load_store.txt", IM);
        //$readmemh("bubble_sort.txt", IM);
        //$readmemh("sigmoid_main.txt", IM);
        //$readmemh("test_branch.txt", IM);
        //$readmemh("factorial12.txt", IM);
        $readmemh("store_load_normal.txt", IM);
    end
     
endmodule