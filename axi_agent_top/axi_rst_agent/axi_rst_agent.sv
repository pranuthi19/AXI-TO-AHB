//---------------- AXI_rst_AGENT --------------------
class axi_rst_agent extends uvm_agent;
    `uvm_component_utils(axi_rst_agent)
    `NEW_COMP

    axi_rst_agent_cfg axi_rst_cfg;

    axi_rst_seqr        axi_rst_seqr_h;
    axi_rst_driver      axi_rst_driver_h;
    axi_rst_monitor     axi_rst_monitor_h;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_rst_agent_cfg)::get(this,"","axi_rst_agent_cfg",axi_rst_cfg))
            `uvm_fatal(get_type_name(),"Failed to get axi rst cfg from ENV in AXI RST AGENT")

        axi_rst_monitor_h   = axi_rst_monitor::type_id::create("axi_rst_monitor_h",this);

        if(axi_rst_cfg.is_active == UVM_ACTIVE) begin
            axi_rst_seqr_h  = axi_rst_seqr::type_id::create("axi_rst_seqr_h",this);
            axi_rst_driver_h    = axi_rst_driver::type_id::create("axi_rst_driver_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if(axi_rst_cfg.is_active == UVM_ACTIVE) begin
            axi_rst_driver_h.seq_item_port.connect(axi_rst_seqr_h.seq_item_export);
        end
    endfunction
endclass
