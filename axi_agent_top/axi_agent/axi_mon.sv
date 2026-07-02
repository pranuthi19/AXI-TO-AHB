//---------------- AXI_MONITOR --------------------
class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)
    `NEW_COMP

    virtual axi_if vif;
    axi_agent_cfg axi_cfg;

    axi_xtn xtn_aw, xtn_w, xtn_b, xtn_ar, xtn_r, axi_wdata_xtn, axi_rdata_xtn;
    axi_xtn q_w[$], q_r[$]; // one for write, one for read

    uvm_analysis_port #(axi_xtn) axi_mon_port;
    uvm_analysis_port #(axi_xtn) axi_wdata_mon_port;
    uvm_analysis_port #(axi_xtn) axi_rdata_mon_port;

    // This 5 semaphores are used for synchronization between channels
    semaphore   sem_aw  = new(1);
    semaphore   sem_w   = new();
    semaphore   sem_b   = new();

    semaphore   sem_ar  = new(1);
    semaphore   sem_r   = new();

    // Used to control outstanding transactions
    semaphore   sem_w_do_not_override   = new(1);
    semaphore   sem_r_do_not_override   = new(1);

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_mon_port    = new("axi_mon_port",this);
        axi_wdata_mon_port      = new("axi_wdata_mon_port",this);
        axi_rdata_mon_port      = new("axi_rdata_mon_port",this);

        if(!uvm_config_db #(axi_agent_cfg)::get(this,"","axi_agent_cfg",axi_cfg))
            `uvm_fatal(get_type_name(),"Failed to get axi_cfg from ENV in AXI AGENT")
    endfunction

    function void connect_phase(uvm_phase phase);
        vif = axi_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect_axi_data();
        end
    endtask

    task collect_axi_data();
        fork
            begin
                sem_aw.get(1);
                write_address_channel(); // Why we don't have anything on this channel ?
                sem_w.put(1);
                sem_aw.put(1);
            end
            begin
                sem_w_do_not_override.get(1);
                sem_w.get(1);
                write_data_channel(q_w.pop_front());
                sem_b.put(1);
                sem_w_do_not_override.put(1);
            end
            begin
                sem_b.get(1);
                write_response_channel(q_w.pop_front());
            end
            begin
                sem_ar.get(1);
                read_address_channel();
                sem_r.put(1);
                sem_ar.put(1);
            end
            begin
                sem_r_do_not_override.get(1);
                sem_r.get(1);
                read_data_channel(q_r.pop_front());
                sem_r_do_not_override.put(1);
            end
        join_any
    endtask

    task write_address_channel();
        xtn_aw = axi_xtn::type_id::create("xtn_aw");
        wait(vif.axi_mon_cb.awvalid && vif.axi_mon_cb.awready)

            xtn_aw.awaddr     =   vif.axi_mon_cb.awaddr;
            xtn_aw.awburst    =   vif.axi_mon_cb.awburst;
            xtn_aw.awsize     =   vif.axi_mon_cb.awsize;
            xtn_aw.awlen      =   vif.axi_mon_cb.awlen;
            xtn_aw.awid       =   vif.axi_mon_cb.awid;
            xtn_aw.awvalid    =   vif.axi_mon_cb.awvalid;
            xtn_aw.awready    =   vif.axi_mon_cb.awready;

            q_w.push_back(xtn_aw);
            @(vif.axi_mon_cb);
    endtask



    task write_data_channel(axi_xtn xtn);
        xtn_w = axi_xtn::type_id::create("xtn_w");
        xtn_w = xtn;

        xtn_w.wdata = new[xtn_w.awlen+1];
        xtn_w.wstrb = new[xtn_w.awlen+1];

        foreach(xtn_w.wdata[i]) begin
            axi_wdata_xtn = axi_xtn::type_id::create("axi_wdata_xtn");

            wait(vif.axi_mon_cb.wvalid && vif.axi_mon_cb.wready)

                xtn_w.wready     = vif.axi_mon_cb.wready;
                xtn_w.wvalid     = vif.axi_mon_cb.wvalid;
                xtn_w.wdata[i]   = vif.axi_mon_cb.wdata;
                xtn_w.wstrb[i]   = vif.axi_mon_cb.wstrb;

                // foreach(xtn_w.wstrb[i]) begin // not working
                    // axi_wdata_xtn.temp_wdata[7:0]   = xtn_w.wstrb[i][0] ? vif.axi_mon_cb.wdata[7:0] : 0;
                    // axi_wdata_xtn.temp_wdata[15:8]  = xtn_w.wstrb[i][1] ? vif.axi_mon_cb.wdata[15:8] : 0;
                    // axi_wdata_xtn.temp_wdata[23:16] = xtn_w.wstrb[i][2] ? vif.axi_mon_cb.wdata[23:16] : 0;
                    // axi_wdata_xtn.temp_wdata[31:24] = xtn_w.wstrb[i][3] ? vif.axi_mon_cb.wdata[31:24] : 0;
                    // axi_wdata_xtn.temp_wdata[39:32] = xtn_w.wstrb[i][4] ? vif.axi_mon_cb.wdata[39:32] : 0;
                    // axi_wdata_xtn.temp_wdata[47:40] = xtn_w.wstrb[i][5] ? vif.axi_mon_cb.wdata[47:40] : 0;
                    // axi_wdata_xtn.temp_wdata[55:48] = xtn_w.wstrb[i][6] ? vif.axi_mon_cb.wdata[55:48] : 0;
                    // axi_wdata_xtn.temp_wdata[63:56] = xtn_w.wstrb[i][7] ? vif.axi_mon_cb.wdata[63:56] : 0;
                // end

                axi_wdata_xtn.temp_wdata[7:0]   = vif.axi_mon_cb.wstrb[0] ? vif.axi_mon_cb.wdata[7:0] : 0;
                axi_wdata_xtn.temp_wdata[15:8]  = vif.axi_mon_cb.wstrb[1] ? vif.axi_mon_cb.wdata[15:8] : 0;
                axi_wdata_xtn.temp_wdata[23:16] = vif.axi_mon_cb.wstrb[2] ? vif.axi_mon_cb.wdata[23:16] : 0;
                axi_wdata_xtn.temp_wdata[31:24] = vif.axi_mon_cb.wstrb[3] ? vif.axi_mon_cb.wdata[31:24] : 0;
                axi_wdata_xtn.temp_wdata[39:32] = vif.axi_mon_cb.wstrb[4] ? vif.axi_mon_cb.wdata[39:32] : 0;
                axi_wdata_xtn.temp_wdata[47:40] = vif.axi_mon_cb.wstrb[5] ? vif.axi_mon_cb.wdata[47:40] : 0;
                axi_wdata_xtn.temp_wdata[55:48] = vif.axi_mon_cb.wstrb[6] ? vif.axi_mon_cb.wdata[55:48] : 0;
                axi_wdata_xtn.temp_wdata[63:56] = vif.axi_mon_cb.wstrb[7] ? vif.axi_mon_cb.wdata[63:56] : 0;

                if(i == (xtn_w.wdata.size() - 1)) begin
                    xtn_w.wlast  = vif.axi_mon_cb.wlast;
                end
                axi_wdata_mon_port.write(axi_wdata_xtn);
                @(vif.axi_mon_cb);
        end
        q_w.push_back(xtn_w);
    endtask



    task write_response_channel(axi_xtn xtn);
        xtn_b = axi_xtn::type_id::create("xtn_b");
        xtn_b = xtn;

        wait(vif.axi_mon_cb.bvalid && vif.axi_mon_cb.bready)

        xtn_b.bready    = vif.axi_mon_cb.bready;
        xtn_b.bvalid    = vif.axi_mon_cb.bvalid;
        xtn_b.bresp     = vif.axi_mon_cb.bresp;
        xtn_b.bid       = vif.axi_mon_cb.bid;
        axi_mon_port.write(xtn_b);
        `uvm_info(get_type_name(),$sformatf("Axi Write Data Sampled at time :%0t\n%p",$time,xtn_b.sprint()),UVM_LOW)
        @(vif.axi_mon_cb);

    endtask



    task read_address_channel();

        xtn_ar = axi_xtn::type_id::create("xtn_ar");

        wait(vif.axi_mon_cb.arready && vif.axi_mon_cb.arvalid)

        xtn_ar.araddr     = vif.axi_mon_cb.araddr;
        xtn_ar.arburst    = vif.axi_mon_cb.arburst;
        xtn_ar.arsize     = vif.axi_mon_cb.arsize;
        xtn_ar.arlen      = vif.axi_mon_cb.arlen;
        xtn_ar.arid       = vif.axi_mon_cb.arid;
        xtn_ar.arvalid    = vif.axi_mon_cb.arvalid;

        $display("araddr=%0d | arburst=%0d | arsize=%0d | arlen=%0d | arid=%0d | arvalid=%0d",
                    xtn_ar.araddr,xtn_ar.arburst,xtn_ar.arsize,xtn_ar.arlen,xtn_ar.arid,xtn_ar.arvalid);

        q_r.push_back(xtn_ar);
        @(vif.axi_mon_cb);
    endtask



    task read_data_channel(axi_xtn xtn);
        xtn_r = axi_xtn::type_id::create("xtn_r");
        xtn_r = xtn;
        xtn_r.rdata = new[xtn_r.arlen + 1]; // here it was awlen
        xtn_r.rresp = new[xtn_r.arlen + 1]; // This was missing and due to that i was not getting the read data

        foreach(xtn_r.rdata[i]) begin

            //$display("++++++++++++++++++++++++++++ AXI WAIT START time=%0t i=%0d ++++++++++++++++++++++++++++",$time,i);
            wait((vif.axi_mon_cb.rready == 1'b1) && (vif.axi_mon_cb.rvalid == 1'b1))
            //$display("++++++++++++++++++++++++++++ AXI HANDSHAKE time=%0t i=%0d rdata=%h ++++++++++++++++++++++++++++",
                        //$time,i,vif.axi_mon_cb.rdata);

            axi_rdata_xtn   = axi_xtn::type_id::create("axi_rdata_xtn");

            xtn_r.rid        = vif.axi_mon_cb.rid;
            xtn_r.rready     = vif.axi_mon_cb.rready;
            xtn_r.rvalid     = vif.axi_mon_cb.rvalid;
            xtn_r.rdata[i]   = vif.axi_mon_cb.rdata;
            xtn_r.rresp[i]   = vif.axi_mon_cb.rresp;

            axi_rdata_xtn.temp_rdata = vif.axi_mon_cb.rdata;

            // $display("rid=%0d | rready=%0d | rvalid=%0d | rdata=%h | rresp=%0d",
            //             xtn_r.rid,
            //             xtn_r.rready,
            //             xtn_r.rvalid,
            //             vif.axi_mon_cb.rdata,
            //             vif.axi_mon_cb.rresp
            //         );
            //$display("############ read temp data ############# = %h",axi_rdata_xtn.temp_rdata);

            if(i == (xtn_r.rdata.size() - 1)) begin
                xtn_r.rlast = vif.axi_mon_cb.rlast;
            end

            if(axi_rdata_xtn.temp_rdata != 0)
                axi_rdata_mon_port.write(axi_rdata_xtn);
            @(vif.axi_mon_cb);

            //$display("[AXI MON] : Axi read data sent to Scoreboard from read data channel");
        end
        axi_mon_port.write(xtn_r);

        `uvm_info(get_type_name(),$sformatf("Axi Data Sampled at time :%0t\n%p",$time,xtn_r.sprint()),UVM_LOW)
    endtask
endclass
