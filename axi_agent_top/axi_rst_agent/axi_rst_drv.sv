//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ rst_DRV ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//---------------- AXI_rst_DRIVER -------------------- ===> AXI agents are acting as masters in out project
class axi_rst_driver extends uvm_driver #(axi_rst_xtn);
        `uvm_component_utils(axi_rst_driver)
        `NEW_COMP

        virtual axi_rst_if vif;
        virtual axi_if avif;
        axi_rst_agent_cfg axi_rst_cfg;
        axi_agent_cfg axi_cfg;

        // In axi monitor we are sampling valid signals but why are we not driving ? Monitor only drives them na. so we also need to get cfg for them.

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                if(!uvm_config_db #(axi_rst_agent_cfg)::get(this,"","axi_rst_agent_cfg",axi_rst_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get axi_rst_cfg from ENV in AXI_RST_MON")

                // We need aready signal - look ahb explaination it's the same
                if(!uvm_config_db #(axi_agent_cfg)::get(this,"","axi_agent_cfg",axi_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get axi_cfg from ENV in AXI AGENT")
        endfunction

        function void connect_phase(uvm_phase phase);
                vif = axi_rst_cfg.vif;
                avif = axi_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
                forever begin
                    //$display("Inside Axi driver run phase - start");
                    seq_item_port.get_next_item(req);
                    send_to_dut(req);
                    seq_item_port.item_done();
                    //$display("Inside Axi driver run phase - end");
                end
        endtask

        task send_to_dut(axi_rst_xtn xtn1);
                @(vif.axi_rst_drv_cb)
                vif.axi_rst_drv_cb.aresetn <= xtn1.aresetn;
                //$display("before====================================================================================================== %0t",$time);
                @(vif.axi_rst_drv_cb)
                @(vif.axi_rst_drv_cb)
                //$display("after================================================================================================== %0t",$time);
                vif.axi_rst_drv_cb.aresetn <= 1;
        endtask
endclass
