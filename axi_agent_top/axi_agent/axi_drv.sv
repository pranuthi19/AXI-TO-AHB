//---------------- AXI_DRIVER --------------------
class axi_driver extends uvm_driver #(axi_xtn);
    `uvm_component_utils(axi_driver)
    `NEW_COMP
    virtual axi_if vif;
    axi_agent_cfg axi_cfg;
    axi_xtn q_aw[$], q_w[$], q_b[$], q_ar[$], q_r[$];
    semaphore   sem_aw  = new(1);
    semaphore   sem_w   = new();
    semaphore   sem_b   = new();
    semaphore   sem_ar  = new(1);
    semaphore   sem_r   = new();
    semaphore   sem_w_do_not_override   = new(1); // This will stop the next transaction from overriding write data
    semaphore   sem_b_do_not_override   = new(1);
    semaphore   sem_r_do_not_override   = new(1);

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(axi_agent_cfg)::get(this,"","axi_agent_cfg",axi_cfg))
            `uvm_fatal(get_type_name(),"Failed to get axi_cfg from ENV in AXI AGENT")

    endfunction

     function void connect_phase(uvm_phase phase);
         vif = axi_cfg.vif;
     endfunction

    task run_phase(uvm_phase phase);
       forever begin
          seq_item_port.get_next_item(req);
          send_to_dut(req);
          seq_item_port.item_done();
       end
    endtask

     task send_to_dut(axi_xtn xtn);
         q_aw.push_back(xtn);
         q_w.push_back(xtn);
         q_b.push_back(xtn);
         q_ar.push_back(xtn);
         q_r.push_back(xtn);

         fork
             begin
                 sem_aw.get(1);
                 write_address_channel(q_aw.pop_front()); // T1 completes for address and T2 starts
                 sem_w.put(1); // this will get the key
                 sem_aw.put(1);
             end
             begin
                 sem_w_do_not_override.get(1);
                 sem_w.get(1);
                 write_data_channel(q_w.pop_front()); // Run
                 sem_b.put(1);
                 sem_w_do_not_override.put(1);
             end
             begin
                 sem_b.get(1);
                 write_response_channel(q_b.pop_front());
             end
             begin
                 sem_ar.get(1);
                 read_address_channel(q_ar.pop_front());
                 sem_r.put(1);
                 sem_ar.put(1);
             end
             begin
                 sem_r_do_not_override.get(1);
                 sem_r.get(1);
                 read_data_channel(q_r.pop_front());
                 sem_r_do_not_override.put(1);
             end
         join_any // Why join_any --> Because we want write address to happen first then only everything should run in bg
     endtask

    task write_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb)
            vif.axi_drv_cb.awaddr  <= xtn.awaddr;
            vif.axi_drv_cb.awburst <= xtn.awburst;
            vif.axi_drv_cb.awsize  <= xtn.awsize;
            vif.axi_drv_cb.awlen   <= xtn.awlen;
            vif.axi_drv_cb.awid    <= xtn.awid;
            vif.axi_drv_cb.awvalid <= xtn.awvalid;

            // while(!vif.axi_drv_cb.awready)begin
            //$display("AXI DRV : waiting for the awready = %0d at time=%ot",vif.axi_drv_cb.awready,$time);
            wait(vif.axi_drv_cb.awready)
            @(vif.axi_drv_cb);

            vif.axi_drv_cb.awvalid <= 0; // Once we get the ready from the slave - master will stop valid

            repeat(xtn.delay_cycles) // why are we waiting for this ? what is this in the first place.
                @(vif.axi_drv_cb);
    endtask




    task write_data_channel(axi_xtn xtn);
        foreach(xtn.wdata[i]) begin
            vif.axi_drv_cb.wid    <= xtn.wid;
            vif.axi_drv_cb.wdata  <= xtn.wdata[i];
            vif.axi_drv_cb.wstrb  <= xtn.wstrb[i];
            vif.axi_drv_cb.wvalid <= xtn.wvalid;

            if(i == xtn.awlen)
                vif.axi_drv_cb.wlast  <= 1;
            else
                vif.axi_drv_cb.wlast  <= 0;

            //@(vif.axi_drv_cb)
            //while(!vif.axi_drv_cb.wready)begin

            //$display("AXI DRV : Waiting for wready=%0d - at time = %0t",vif.axi_drv_cb.wready,$time);
            wait(vif.axi_drv_cb.wready)
                @(vif.axi_drv_cb);

            vif.axi_drv_cb.wvalid <= 0;
            vif.axi_drv_cb.wlast <= 0;

            repeat(xtn.delay_cycles) // why are we waiting for this ? what is this in the first place.
            @(vif.axi_drv_cb);
        end
    endtask




    task write_response_channel(axi_xtn xtn);
        vif.axi_drv_cb.bready   <= 1;

        //$display("AXI DRV : waiting for bvalid=%0d at time=%0t",vif.axi_drv_cb.bvalid,$time);
        wait(vif.axi_drv_cb.bvalid)
            @(vif.axi_drv_cb)
            vif.axi_drv_cb.bready   <= 0;

        repeat(xtn.delay_cycles)
            @(vif.axi_drv_cb);
    endtask





    task read_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb) begin
            vif.axi_drv_cb.araddr   <= xtn.araddr;
            vif.axi_drv_cb.arburst  <= xtn.arburst;
            vif.axi_drv_cb.arsize   <= xtn.arsize;
            vif.axi_drv_cb.arlen    <= xtn.arlen;
            vif.axi_drv_cb.arid     <= xtn.arid;
            vif.axi_drv_cb.arvalid  <= xtn.arvalid;

            //$display("AXI DRV : Waiting for arready=%0d at time",vif.axi_drv_cb.arready,$time);
            wait(vif.axi_drv_cb.arready == 1'b1)
                @(vif.axi_drv_cb)
                vif.axi_drv_cb.arvalid  <= 0;

            repeat(xtn.delay_cycles) // why are we waiting for this ? what is this in the first place.
                @(vif.axi_drv_cb);
         end
     endtask




    task read_data_channel(axi_xtn xtn);
        repeat(vif.axi_drv_cb.arlen+1) begin
            @(vif.axi_drv_cb)

            vif.axi_drv_cb.rready   <= 1;

            //$display("AXI DRV : waiting for rvalid=%0d at time=%0t",vif.axi_drv_cb.rvalid,$time);
            wait(vif.axi_drv_cb.rvalid == 1'b1)
                @(vif.axi_drv_cb)
                vif.axi_drv_cb.rready   <= 0;

            repeat(xtn.delay_cycles) // why are we waiting for this ? what is this in the first place.
                @(vif.axi_drv_cb);
        end
    endtask
 endclass
