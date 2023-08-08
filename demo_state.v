// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// Generated by Quartus Prime Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition
// Created on Thu May 04 14:11:04 2023

// synthesis message_off 10175

`timescale 1ns/1ns

module demo_state (
    reset,clock,request,
    yes);

    input reset;
    input clock;
    input request;
    tri0 reset;
    tri0 request;
    output yes;
    reg yes;
    reg reg_yes;
    reg [1:0] fstate;
    reg [1:0] reg_fstate;
    parameter IDLE=0,END_STATE=1;

    initial
    begin
        reg_yes <= 1'b0;
    end

    always @(posedge clock)
    begin
        if (clock) begin
            fstate <= reg_fstate;
            yes <= reg_yes;
        end
    end

    always @(fstate or reset or request)
    begin
        if (~reset) begin
            reg_fstate <= IDLE;
            reg_yes <= 1'b0;
        end
        else begin
            reg_yes <= 1'b0;
            case (fstate)
                IDLE: begin
                    if (~(request))
                        reg_fstate <= IDLE;
                    else if (request)
                        reg_fstate <= END_STATE;
                    // Inserting 'else' block to prevent latch inference
                    else
                        reg_fstate <= IDLE;

                    reg_yes <= 1'b0;
                end
                END_STATE: begin
                    reg_fstate <= IDLE;

                    reg_yes <= 1'b1;
                end
                default: begin
                    reg_yes <= 1'bx;
                    $display ("Reach undefined state");
                end
            endcase
        end
    end
endmodule // demo_state
