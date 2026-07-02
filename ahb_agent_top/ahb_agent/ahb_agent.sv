//---------------- AHB_AGENT --------------------
class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)
        `NEW_COMP

        ahb_agent_cfg ahb_cfg;

        ahb_seqr                ahb_seqr_h;
        ahb_driver              ahb_driver_h;
        ahb_monitor     ahb_monitor_h;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                if(!uvm_config_db #(ahb_agent_cfg)::get(this,"","ahb_agent_cfg",ahb_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get ahb cfg from ENV in AHB AGENT")

                ahb_monitor_h   = ahb_monitor::type_id::create("ahb_monitor_h",this);

                if(ahb_cfg.is_active == UVM_ACTIVE) begin
                        ahb_seqr_h              = ahb_seqr::type_id::create("ahb_seqr_h",this);
                        ahb_driver_h    = ahb_driver::type_id::create("ahb_driver_h",this);
                end
        endfunction

        function void connect_phase(uvm_phase phase);
                if(ahb_cfg.is_active == UVM_ACTIVE) begin
                        ahb_driver_h.seq_item_port.connect(ahb_seqr_h.seq_item_export);
                end
        endfunction
endclass
