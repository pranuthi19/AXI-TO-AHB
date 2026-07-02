//---------------- AXI_rst_MONITOR --------------------
class axi_rst_monitor extends uvm_monitor;
    `uvm_component_utils(axi_rst_monitor)
    `NEW_COMP

    virtual axi_rst_if vif;
    axi_rst_agent_cfg axi_rst_cfg;

    virtual axi_if avif;
    axi_agent_cfg axi_cfg;

    axi_rst_xtn axi_xtn;

    uvm_analysis_port #(axi_rst_xtn) axi_rst_mon_port;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi_rst_mon_port = new("axi_rst_mon_port",this);

        if(!uvm_config_db #(axi_rst_agent_cfg)::get(this,"","axi_rst_agent_cfg",axi_rst_cfg))
            `uvm_fatal(get_type_name(),"Failed to get axi_rst_cfg from ENV in AXI_RST_MON")

        if(!uvm_config_db #(axi_agent_cfg)::get(this,"","axi_agent_cfg",axi_cfg))
            `uvm_fatal(get_type_name(),"Failed to get axi_cfg from ENV in AXI AGENT")
    endfunction

    function void connect_phase(uvm_phase phase);
        vif = axi_rst_cfg.vif;
        avif = axi_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect();
        end
    endtask

    task collect();
        axi_xtn = axi_rst_xtn::type_id::create("axi_xtn",this);

        //$display("Axi reset monitor : --------------- waiting for aresetn");
        wait(vif.axi_rst_mon_cb.aresetn==0)
            //$display("After wait : aresetn=%0d time=%0t",vif.axi_rst_mon_cb.aresetn,$time);


        // $display("After @cb : aresetn=%0d time=%0t",vif.axi_rst_mon_cb.aresetn,$time);
        // $display("Axi reset monitor : --------------- reset has happened == time=%0t",$time);
        // $display("aresetn value in axi rst monitor -------> %0d at time = %0t",vif.axi_rst_mon_cb.aresetn,$time);
        axi_xtn.aresetn     = vif.axi_rst_mon_cb.aresetn;
        axi_xtn.bvalid      = avif.axi_mon_cb.bvalid;
        axi_xtn.rvalid      = avif.axi_mon_cb.rvalid;
        // $display("axi reset monitor : aresetn = %0d",axi_xtn.aresetn);
        // $display("axi reset monitor : bvalid = %0d",axi_xtn.bvalid);
        // $display("axi reset monitor : rvalid = %0d",axi_xtn.rvalid);

        @(vif.axi_rst_mon_cb);

          axi_rst_mon_port.write(axi_xtn);

    //      `uvm_info(get_type_name(),$sformatf("Inside Ahb Monitor : Axi Reset data sampled :\n",axi_xtn.sprint()),UVM_LOW);

    endtask
endclass
