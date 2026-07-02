//---------------- AXI_AGENT --------------------
class axi_agent extends uvm_agent;
        `uvm_component_utils(axi_agent)
        `NEW_COMP

        axi_agent_cfg axi_cfg;

        axi_seqr        axi_seqr_h;
        axi_driver      axi_driver_h;
        axi_monitor     axi_monitor_h;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);


                if(!uvm_config_db #(axi_agent_cfg)::get(this,"","axi_agent_cfg",axi_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get axi cfg from ENV in AXI AGENT")

                axi_monitor_h   = axi_monitor::type_id::create("axi_monitor_h",this);

                if(axi_cfg.is_active == UVM_ACTIVE) begin
                                axi_seqr_h              = axi_seqr::type_id::create("axi_seqr_h",this);
                                axi_driver_h    = axi_driver::type_id::create("axi_driver_h",this);
                end
        endfunction

        function void connect_phase(uvm_phase phase);
                        if(axi_cfg.is_active == UVM_ACTIVE) begin
                                        axi_driver_h.seq_item_port.connect(axi_seqr_h.seq_item_export);
                        end
        endfunction
endclass
