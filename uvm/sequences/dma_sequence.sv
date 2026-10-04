class dma_sequence extends uvm_sequence #(axi_lite_transaction);

    `uvm_object_utils(dma_sequence)

    //============================================================
    // DMA configuration
    //============================================================

    rand bit [31:0] src_addr;
    rand bit [31:0] dst_addr;
    rand bit [31:0] transfer_length;

    constraint alignment_c {
        src_addr[1:0] == 2'b00;
        dst_addr[1:0] == 2'b00;
    }

    constraint length_c {
        transfer_length inside {[4:64]};
    }


    //============================================================
    // Constructor
    //============================================================

    function new(string name = "dma_sequence");
        super.new(name);
    endfunction


    //============================================================
    // AXI-Lite WRITE
    //============================================================

    task automatic write_reg(
        input bit [31:0] addr,
        input bit [31:0] data
    );

        axi_lite_transaction tr;

        tr = axi_lite_transaction::type_id::create(
            "axi_lite_write"
        );

        start_item(tr);

      tr.cmd = axi_lite_transaction::AXI_LITE_WRITE;
        tr.addr = addr;
        tr.data = data;
        tr.strb = 4'b1111;

        finish_item(tr);

    endtask


    //============================================================
    // DMA configuration sequence
    //============================================================

    task body();

        `uvm_info(
            "DMA_SEQ",
            $sformatf(
                "DMA CONFIG: SRC=0x%08h DST=0x%08h LENGTH=%0d",
                src_addr,
                dst_addr,
                transfer_length
            ),
            UVM_MEDIUM
        )


        //========================================================
        // SOURCE ADDRESS
        // 0x08
        //========================================================

        write_reg(
            32'h0000_0008,
            src_addr
        );


        //========================================================
        // DESTINATION ADDRESS
        // 0x0C
        //========================================================

        write_reg(
            32'h0000_000C,
            dst_addr
        );


        //========================================================
        // TRANSFER LENGTH
        // 0x10
        //========================================================

        write_reg(
            32'h0000_0010,
            transfer_length
        );


        //========================================================
        // CONTROL / START
        // 0x00
        //========================================================

        write_reg(
            32'h0000_0000,
            32'h0000_0001
        );


        `uvm_info(
            "DMA_SEQ",
            "DMA START command issued",
            UVM_MEDIUM
        )

    endtask

endclass

