class axi_lite_transaction extends uvm_sequence_item;

    //============================================================
    // AXI-Lite Command Type
    //============================================================

    typedef enum {
        AXI_LITE_WRITE,
        AXI_LITE_READ
    } axi_lite_cmd_e;

    axi_lite_cmd_e cmd;

    //============================================================
    // AXI-Lite Address / Data
    //============================================================

    bit [31:0] addr;
    bit [31:0] data;
    bit [3:0]  strb;

    //============================================================
    // Response / Read Data
    //============================================================

    bit [1:0]  resp;
    bit [31:0] read_data;

    //============================================================
    // Constructor
    //============================================================

    function new(string name = "axi_lite_transaction");
        super.new(name);
    endfunction

    //============================================================
    // UVM Factory Registration
    //============================================================

    `uvm_object_utils(axi_lite_transaction)

    //============================================================
    // String Conversion
    //============================================================

    function string convert2string();

        return $sformatf(
            "CMD=%s ADDR=0x%08h DATA=0x%08h STRB=0x%0h",
            (cmd == AXI_LITE_WRITE) ? "WRITE" : "READ",
            addr,
            data,
            strb
        );

    endfunction

endclass