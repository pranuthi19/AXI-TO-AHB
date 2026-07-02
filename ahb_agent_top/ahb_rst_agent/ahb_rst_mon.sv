//---------------- AHB_rst_MONITOR --------------------
class ahb_rst_monitor extends uvm_monitor;
        `uvm_component_utils(ahb_rst_monitor)
        `NEW_COMP

        virtual ahb_rst_if vif;
        virtual ahb_if hvif;

        ahb_rst_agent_cfg ahb_rst_cfg;
        ahb_agent_cfg ahb_cfg;

        ahb_rst_xtn ahb_xtn;
        uvm_analysis_port #(ahb_rst_xtn) ahb_rst_mon_port;

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ahb_rst_mon_port = new("ahb_rst_mon_port",this);

            if(!uvm_config_db #(ahb_rst_agent_cfg)::get(this,"","ahb_rst_agent_cfg",ahb_rst_cfg))
                    `uvm_fatal(get_type_name(),"Failed to get ahb_rst_cfg from ENV in AHB_RST_MON")

            if(!uvm_config_db #(ahb_agent_cfg)::get(this,"","ahb_agent_cfg",ahb_cfg))
                    `uvm_fatal(get_type_name(),"Failed to get ahb cfg from ENV in AHB AGENT")
        endfunction

        function void connect_phase(uvm_phase phase);
                vif = ahb_rst_cfg.vif;
                hvif = ahb_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
                forever begin
                        collect();
                end
        endtask

        task collect();
            ahb_xtn = ahb_rst_xtn::type_id::create("ahb_xtn");


            wait(vif.ahb_rst_mon_cb.hresetn ==0);

            ahb_xtn.hresetn = vif.ahb_rst_mon_cb.hresetn; // Why we are collecting hready in ahb_mon
            ahb_xtn.htrans  = hvif.ahb_mon_cb.htrans;
           // $display("ahb_rst_mon : htrans = %0d at time=%0t",ahb_xtn.htrans,$time);

                @(vif.ahb_rst_mon_cb);
            ahb_rst_mon_port.write(ahb_xtn); // Send to sb

        //    `uvm_info(get_type_name(),$sformatf("Inside Ahb Monitor : Ahb Reset data sampled :\n",ahb_xtn.sprint()),UVM_LOW);
        endtask
endclass
