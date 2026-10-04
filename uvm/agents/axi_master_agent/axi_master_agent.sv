class axi_master_agent extends uvm_agent;

    `uvm_component_utils(axi_master_agent)

    //============================================================
    // AXI4 agent components
    //============================================================
    axi_master_sequencer sequencer;
    axi_master_driver    driver;
    axi_master_monitor   monitor;


    //============================================================
    // Constructor
    //============================================================
    function new(string name = "axi_master_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    //============================================================
    // Build phase
    //============================================================
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Monitor is always created
        monitor = axi_master_monitor::type_id::create(
            "monitor",
            this
        );

        // Driver and sequencer are required for active agent
        if (is_active == UVM_ACTIVE) begin

            sequencer = axi_master_sequencer::type_id::create(
                "sequencer",
                this
            );

            driver = axi_master_driver::type_id::create(
                "driver",
                this
            );

        end

    endfunction


    //============================================================
    // Connect phase
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

