//---------------- AHB_rst_AGENT --------------------
class ahb_rst_agent extends uvm_agent;
    `uvm_component_utils(ahb_rst_agent)
    `NEW_COMP

    ahb_rst_agent_cfg ahb_rst_cfg;

    ahb_rst_seqr        ahb_rst_seqr_h;
    ahb_rst_driver      ahb_rst_driver_h;
    ahb_rst_monitor     ahb_rst_monitor_h;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(ahb_rst_agent_cfg)::get(this,"","ahb_rst_agent_cfg",ahb_rst_cfg))
            `uvm_fatal(get_type_name(),"Failed to get ahb rst cfg from ENV in AHB RST AGENT")

        ahb_rst_monitor_h   = ahb_rst_monitor::type_id::create("ahb_rst_monitor_h",this);

        if(ahb_rst_cfg.is_active == UVM_ACTIVE) begin
            ahb_rst_seqr_h      = ahb_rst_seqr::type_id::create("ahb_rst_seqr_h",this);
            ahb_rst_driver_h    = ahb_rst_driver::type_id::create("ahb_rst_driver_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if(ahb_rst_cfg.is_active == UVM_ACTIVE) begin
            ahb_rst_driver_h.seq_item_port.connect(ahb_rst_seqr_h.seq_item_export);
        end
    endfunction
endclass
