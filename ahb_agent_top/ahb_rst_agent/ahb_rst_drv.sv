//---------------- AHB_rst_DRIVER -------------------- ===> AHB agents are acting as slaves in out project
class ahb_rst_driver extends uvm_driver #(ahb_rst_xtn);
        `uvm_component_utils(ahb_rst_driver)
        `NEW_COMP

        virtual ahb_rst_if vif;
        virtual ahb_if hvif;
        ahb_rst_agent_cfg ahb_rst_cfg;
        ahb_agent_cfg ahb_cfg;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                if(!uvm_config_db #(ahb_rst_agent_cfg)::get(this,"","ahb_rst_agent_cfg",ahb_rst_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get ahb_rst_cfg from ENV in AHB_RST_MON")

                // reset signal should be active till hready is asserted, so we need hready is not present in ahb reset if - to get that we need to use ahb_cfg ka vif. so from here we can get the hready. WHY not present in rst if? because in top we cannot declare same signal twice till now we never had another agent which had reset in another if - but here we do so that's why we have to get vif which holds the ready signal. (reset to not there in main if of ahb or even axi so that we can directly take from rst if)
                if(!uvm_config_db #(ahb_agent_cfg)::get(this,"","ahb_agent_cfg",ahb_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get ahb cfg from ENV in AHB AGENT")
        endfunction

        function void connect_phase(uvm_phase phase);
                hvif = ahb_cfg.vif;
                vif = ahb_rst_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
                forever begin
                        seq_item_port.get_next_item(req);
                        send_to_dut(req);
                        seq_item_port.item_done();
                end
        endtask

        task send_to_dut(ahb_rst_xtn req);
                @(vif.ahb_rst_drv_cb)
                vif.ahb_rst_drv_cb.hresetn <= req.hresetn;
                hvif.ahb_drv_cb.hready <= 1;  // To start the transfer in ahb we need to have hready high (this ready we take from main interface)
                @(vif.ahb_rst_drv_cb)
                @(vif.ahb_rst_drv_cb);
                vif.ahb_rst_drv_cb.hresetn <= 1;
                hvif.ahb_drv_cb.hready <= 0;
                @(vif.ahb_rst_drv_cb);
                @(vif.ahb_rst_drv_cb);
        endtask
endclass
