class dma_transaction extends uvm_sequence_item;

    //============================================================
    // DMA Configuration
    //============================================================

    rand bit [31:0] src_addr;
    rand bit [31:0] dst_addr;
    rand bit [31:0] transfer_length;

    //============================================================
    // Constructor
    //============================================================

    function new(string name = "dma_transaction");
        super.new(name);
    endfunction

    //============================================================
    // Field Registration
    //============================================================

    `uvm_object_utils_begin(dma_transaction)

        `uvm_field_int(src_addr,        UVM_ALL_ON)
        `uvm_field_int(dst_addr,        UVM_ALL_ON)
        `uvm_field_int(transfer_length, UVM_ALL_ON)

    `uvm_object_utils_end

    //============================================================
    // Constraints
    //============================================================

    constraint length_c {
        transfer_length inside {[1:64]};
    }

    constraint alignment_c {
        src_addr[1:0] == 2'b00;
        dst_addr[1:0] == 2'b00;
    }

endclass