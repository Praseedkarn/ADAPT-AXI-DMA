
class axi_lite_agent extends uvm_agent;

    `uvm_component_utils(axi_lite_agent)

    //============================================================
    // Components
    //============================================================

    axi_lite_sequencer sequencer;
    axi_lite_driver    driver;
    axi_lite_monitor   monitor;

    //============================================================
    // Constructor
    //============================================================

    function new(
        string name = "axi_lite_agent",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction

    //============================================================
    // Build Phase
    //============================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        monitor = axi_lite_monitor::type_id::create(
            "monitor",
            this
        );

        if (is_active == UVM_ACTIVE) begin

            sequencer = axi_lite_sequencer::type_id::create(
                "sequencer",
                this
            );

            driver = axi_lite_driver::type_id::create(
                "driver",
                this
            );

        end

    endfunction

    //============================================================
    // Connect Phase
    //============================================================

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE) begin

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass
