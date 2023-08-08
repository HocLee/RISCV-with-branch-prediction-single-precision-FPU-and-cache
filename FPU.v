`include "add_sub.v"
`include "mul.v"
`include "div.v"
`include "selector.v"
`include "normalizer_1.v"
`include "rounding.v"
`include "normalizer_2.v"
//`include "dff_1.v"
//`include "dff_2.v"
module FPU(
   input  wire        clk,
   input  wire        rstn,
   input  wire [31:0] a_in,
   input  wire [31:0] b_in,
   input  wire [1:0]  sel,
   input  wire        stall,
   output wire [5:0]  check_div_fp,
   output             normalized_round_done,
   output             overflow,
   output             underflow,
   output             done_cal,  
   output      [31:0] alu_out
);
//=======================================================
//  REG/WIRE declarations
//======================================================= 
    wire [31:0] a_o          ;
    wire [31:0] b_o          ;
    wire [1:0]  sel_o        ;
  
    wire        result_sign  ;
    wire [8:0]  result_exp   ;
    wire [48:0] result_man   ;
  
    wire        result_sign_1  ;
    wire [8:0]  result_exp_1   ;
    wire [48:0] result_man_1   ;
  
    wire        result_sign_2  ;
    wire [8:0]  result_exp_2   ;
    wire [48:0] result_man_2   ;   
    wire        done_div       ;
   
    wire        result_sign_in  ;
    wire [8:0]  result_exp_in   ;
    wire [48:0] result_man_in   ;

    wire        normalized_result_sign;
    wire [8:0]  normalized_result_exp ;
    wire [48:0] normalized_result_man ;
    wire        rounded_result_sign   ;
    wire [8:0]  rounded_result_exp    ;
    wire [24:0] rounded_result_man    ;
    wire        round_flag            ;
    wire [31:0] alu_o                 ;
    wire        overflow_o            ;
    wire        underflow_o           ;
    wire        normalized_round_done_out;

    wire        done_cal_1;
    wire        done_cal_2;
    wire        done_cal_3;
    wire        done_cal_4;

    wire        done_add_sub_w;


//=======================================================
//  Structural coding
//=======================================================


   /*
   dff_1 u_dff1 (
      .clk     (clk) , 
      .rstn    (rstn), 
      .a_in    (a_in), 
      .b_in    (b_in), 
      .sel     (sel) , 
      .a_out   (a_o) , 
      .b_out   (b_o) , 
      .sel_out (sel_o) 
   );
   */
/*========================ADD--SUB--MUL--DIV=============================*/  
   /*
   add_sub u_add_sub (
      .a_in       (a_o)        , 
      .b_in       (b_o)        , 
      .sel        (sel_o)      , 
      .result_sign(result_sign),
      .result_exp (result_exp) ,
      .result_man (result_man)
   );
   
   mul u_mul (
      .a_in          (a_o)          ,
      .b_in          (b_o)          ,
      .result_sign   (result_sign_1),
      .result_exp    (result_exp_1) ,
      .result_man    (result_man_1) 
   );
  
   div u_div (
      .a_in          (a_o)          ,
      .b_in          (b_o)          ,
      .clk           (clk)          ,
      .sel           (sel_o)        ,
      .rstn          (rstn)         ,
      .result_sign_2 (result_sign_2),
      .result_exp_2  (result_exp_2) ,
      .result_man_2  (result_man_2) ,
      .check_div_fp  (check_div_fp) ,
      .done_div      (done_div)     
   );   
   */



   add_sub u_add_sub (
      .a_in        (a_in)        , 
      .b_in        (b_in)        , 
      .sel         (sel)         , 
      .result_sign (result_sign) ,
      .result_exp  (result_exp)  ,
      .result_man  (result_man)  ,
      .done_add_sub(done_add_sub_w)
   );
   
   mul u_mul (
      .a_in          (a_in)          ,
      .b_in          (b_in)          ,
      .result_sign   (result_sign_1) ,
      .result_exp    (result_exp_1)  ,
      .result_man    (result_man_1) 
   );
  
   div u_div (
      .a_in          (a_in)         ,
      .b_in          (b_in)         ,
      .stall         (stall)        ,
      .clk           (clk)          ,
      .sel           (sel)          ,
      .rstn          (rstn)         ,
      .result_sign_2 (result_sign_2),
      .result_exp_2  (result_exp_2) ,
      .result_man_2  (result_man_2) ,
      .check_div_fp  (check_div_fp) ,
      .done_div      (done_div)     
   );

/*==============================SELECT MODE======================================*/
   selector u_selector(
   //   .clk           (clk)          ,
   //   .rstn          (rstn)         ,
      .sel           (sel)        ,
      .result_sign   (result_sign)  ,
      .result_exp    (result_exp )  ,
      .result_man    (result_man )  ,
      .result_sign_1 (result_sign_1),
      .result_exp_1  (result_exp_1) ,
      .result_man_1  (result_man_1) ,
      .result_sign_2 (result_sign_2),
      .result_exp_2  (result_exp_2) ,
      .result_man_2  (result_man_2) ,
      .done_div      (done_div)     ,
      .done_add_sub  (done_add_sub_w),
      .result_sign_in(result_sign_in),
      .result_exp_in (result_exp_in) ,
      .result_man_in (result_man_in) ,
      .done_cal      (done_cal_1)   
   );
//====================PRE-NORMALIZER=====================================
   
   /*
   normalizer_1 u_normalization_1(
      .result_sign           (result_sign_in),
      .result_exp            (result_exp_in),
      .result_man            (result_man_in),
      .done_cal              (done_cal_1),
      .normalized_result_sign(normalized_result_sign),
      .normalized_result_exp (normalized_result_exp),
      .normalized_result_man (normalized_result_man),
      .overflow              (overflow_o),
      .underflow             (underflow_o),
      .done_cal_out          (done_cal_2)
   );
   */
      normalizer_1 u_normalization_1(
      .result_sign           (result_sign_in),
      .result_exp            (result_exp_in),
      .result_man            (result_man_in),
      .done_cal              (done_cal_1),
      .normalized_result_sign(normalized_result_sign),
      .normalized_result_exp (normalized_result_exp),
      .normalized_result_man (normalized_result_man),
      .overflow              (overflow),
      .underflow             (underflow),
      .done_cal_out          (done_cal_2)
   );
//===================ROUNDING=============================================   
   
   
   rounding u_round(
      .normalized_result_sign(normalized_result_sign),
      .normalized_result_exp (normalized_result_exp),
      .normalized_result_man (normalized_result_man),
      .done_cal              (done_cal_2),
      .rounded_result_sign   (rounded_result_sign),
      .rounded_result_exp    (rounded_result_exp),
      .rounded_result_man    (rounded_result_man),
      .done_cal_out          (done_cal_3),
      .round_flag            (round_flag)
   );
   


//===========================POST-NORMALIZER==============================
   /*
   normalizer_2 u_normalization_2 (
      .rounded_result_sign   (rounded_result_sign),
      .rounded_result_exp    (rounded_result_exp),
      .rounded_result_man    (rounded_result_man),
      .round_flag            (round_flag),
      .done_cal              (done_cal_3),
      .alu_out               (alu_o),
      .done_cal_out          (done_cal_4),
      .normalized_round_done (normalized_round_done_out)
   );
   */
   normalizer_2 u_normalization_2 (
      .rounded_result_sign   (rounded_result_sign),
      .rounded_result_exp    (rounded_result_exp),
      .rounded_result_man    (rounded_result_man),
      .round_flag            (round_flag),
      .done_cal              (done_cal_3),
      .alu_out               (alu_out),
      .done_cal_out          (done_cal),
      .normalized_round_done (normalized_round_done)
   );  
  
//========================================================================
/*
   dff_2 u_dff2 (
      .clk                      (clk), 
      .rstn                     (rstn), 
      .alu_in                   (alu_o),
      .overflow_in              (overflow_o),
      .underflow_in             (underflow_o),
      .done_cal_in              (done_cal_4), 
      .alu_out                  (alu_out), 
      .normalized_round_done_in (normalized_round_done_out),
      .normalized_round_done     (normalized_round_done),
      .overflow                 (overflow),
      .underflow                (underflow),
      .done_cal                 (done_cal)
   );
*/  


  
endmodule