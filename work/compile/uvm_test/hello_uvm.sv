`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class hello_test extends uvm_test;

    `uvm_component_utils(hello_test)

    function new(string name = "hello_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        `uvm_info("HELLO_UVM",
                  "UVM environment is working!",
                  UVM_LOW)
    endfunction

endclass


module tb_top;

    initial begin
        run_test("hello_test");
    end

endmodule

