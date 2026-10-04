`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class smoke_test extends uvm_test;

    `uvm_component_utils(smoke_test)

    function new(string name = "smoke_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("SMOKE",
                  "UVM + Verilator smoke test is running!",
                  UVM_LOW)

        #100;

        `uvm_info("SMOKE",
                  "UVM smoke test completed successfully!",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass


module uvm_smoke;

    initial begin
        run_test("smoke_test");
    end

endmodule
