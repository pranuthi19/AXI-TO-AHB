
//---------------------------------------- ENV -------------------------------------------
class env extends uvm_env;
    `uvm_component_utils(env)
        `NEW_COMP

        ahb_agent_top   ahb_agent_top_h[];
        axi_agent_top   axi_agent_top_h[];
        sb                          sbh[];

        env_cfg                 env_cfg_h;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                $display("######################## Env Build Phase #####################");
                if(!uvm_config_db #(env_cfg)::get(this,"","env_cfg",env_cfg_h))
                        `uvm_fatal(get_type_name(),"Failed to get env_cfg from TEST in ENV")

                create_comps();

        endfunction

        function void create_comps();
                if(env_cfg_h.has_axi_agent) begin
                        axi_agent_top_h = new[env_cfg_h.no_of_duts];

                        foreach(axi_agent_top_h[i]) begin
                                axi_agent_top_h[i] = axi_agent_top::type_id::create($sformatf("axi_agent_top_h[%0d]",i),this);
                                uvm_config_db #(axi_agent_cfg)::set(this,"*","axi_agent_cfg",env_cfg_h.axi_cfg[i]);
                                uvm_config_db #(axi_rst_agent_cfg)::set(this,"*","axi_rst_agent_cfg",env_cfg_h.axi_rst_cfg[i]);
                        end
                end

                if(env_cfg_h.has_ahb_agent) begin
                        ahb_agent_top_h = new[env_cfg_h.no_of_duts];

                        foreach(ahb_agent_top_h[i]) begin
                                ahb_agent_top_h[i] = ahb_agent_top::type_id::create($sformatf("ahb_agent_top_h[%0d]",i),this);
                                uvm_config_db #(ahb_agent_cfg)::set(this,"*","ahb_agent_cfg",env_cfg_h.ahb_cfg[i]);
                                uvm_config_db #(ahb_rst_agent_cfg)::set(this,"*","ahb_rst_agent_cfg",env_cfg_h.ahb_rst_cfg[i]);
                        end
                end

                if(env_cfg_h.has_sb) begin
                        sbh = new[env_cfg_h.no_of_duts];

                        foreach(sbh[i]) begin
                                sbh[i] = sb::type_id::create($sformatf("sbh[%0d]",i),this);
                        end
                end
        endfunction

        function void connect_phase(uvm_phase phase);
                foreach(axi_agent_top_h[i]) begin
                    axi_agent_top_h[i].axi_agent_h.axi_monitor_h.axi_mon_port.connect(sbh[i].fifo_axi_ctrl_h.analysis_export);
                    axi_agent_top_h[i].axi_agent_h.axi_monitor_h.axi_wdata_mon_port.connect(sbh[i].fifo_axi_wdata_h.analysis_export);
                    axi_agent_top_h[i].axi_agent_h.axi_monitor_h.axi_rdata_mon_port.connect(sbh[i].fifo_axi_rdata_h.analysis_export);
                    axi_agent_top_h[i].axi_rst_agent_h.axi_rst_monitor_h.axi_rst_mon_port.connect(sbh[i].fifo_axi_rst_h.analysis_export);
                end

                foreach(ahb_agent_top_h[i]) begin
                    ahb_agent_top_h[i].ahb_agent_h.ahb_monitor_h.ahb_mon_port.connect(sbh[i].fifo_ahb_data_h.analysis_export);
                    ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_monitor_h.ahb_rst_mon_port.connect(sbh[i].fifo_ahb_rst_h.analysis_export);
                end
        endfunction
endclass
