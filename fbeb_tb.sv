
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)

    function new(string name = "hello_test", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("hello_test", "new is called", UVM_LOW);
    endfunction

    virtual task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("hello_test", "main_phase is called", UVM_LOW);
        #100;
        `uvm_info("hello_test", "main_phase is finish", UVM_LOW);
        phase.drop_objection(this);
    endtask

endclass


module tb;

    parameter FIFO_DEPTH = 8;
    parameter FIFO_WIDTH = 8;

    reg clk;
    real clk_freq;
    reg rst_n;
    reg upstream_vld;
    reg [FIFO_WIDTH-1:0] upstream_data;
    wire upstream_rdy;
    wire [FIFO_WIDTH-1:0] downstream_data;
    wire downstream_vld;
    reg downstream_rdy;

    initial begin
        clk = 0;
        clk_freq=2;
        #1;
        forever #(1/clk_freq)clk =~clk;
        
    end

    initial begin
        rst_n = 0;
        #5
        rst_n = 1;
    end

    always@(posedge clk) begin
        upstream_vld = $random % 2;
        upstream_data = $random % 60;
        downstream_rdy = $random % 2;
    end

    initial begin;
        run_test("hello_test");
    end


initial	begin
	    $fsdbDumpfile("fbeb_tb.fsdb");//这个是产生名为tb.fsdb的文件
	    $fsdbDumpvars(0,tb);
        $fsdbDumpMDA();
end
        fbeb #(
            .DEPTH(FIFO_DEPTH),
            .DATA_WIDTH(FIFO_WIDTH))
        u_fbeb
    (
        .clk(clk),
        .rst_n(rst_n),
        .upstream_vld(upstream_vld),
        .upstream_rdy(upstream_rdy),
        .upstream_data(upstream_data),
        .downstream_vld(downstream_vld),
        .downstream_rdy(downstream_rdy),
        .downstream_data(downstream_data)
    );

endmodule
