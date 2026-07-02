//~~~~~~~~~~~~~~ axi seq

class axi_seq_base extends uvm_sequence #(axi_xtn);
     `uvm_object_utils(axi_seq_base)
     `NEW_OBJ

     env_cfg env_cfg_h; // Why env_cfg here ?
     int temp;  // why temp ?
endclass

class axi_seq extends axi_seq_base; // this is for fixed and incr
      `uvm_object_utils(axi_seq)
      `NEW_OBJ

      task body();
          req = axi_xtn::type_id::create("req");
          if(!uvm_config_db #(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
              `uvm_fatal(get_type_name(),"Failed to get env_cfg from TEST in axi_seq")

          temp = env_cfg_h.axi_length.pop_front(); // axi_length is inside env_cfg and we will pop from this queue.

          start_item(req);
          assert(req.randomize() with { // master is sending the transactions (all the signals that go from master to slave)
              arlen   == temp;
              arvalid == 1;
              awlen   == temp;
              awvalid == 1;
              wvalid  == 1;
              awburst inside {[0:1]};}); // why ar and aw valid are 1 here ? how it is working ?
          finish_item(req);
      endtask
endclass

class axi_wr_burst_seq extends axi_seq_base;  // wrap we check here
      `uvm_object_utils(axi_wr_burst_seq)
      `NEW_OBJ

      task body();
          $display("-------------------------------------- Axi Write Burst Seq Started --------------------------------------");
          req = axi_xtn::type_id::create("req");

          if(!uvm_config_db #(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
              `uvm_fatal(get_type_name(),"Failed to get env_cfg from TEST in axi_burst_seq")

          temp = env_cfg_h.axi_length.pop_front();

          start_item(req);
          assert(req.randomize() with { // master is sending the transactions (all the signals that go from master to slave)
              arlen   == temp;
              arvalid == 0;    // Why arvalid is 0 ?
              awlen   == temp;
              awvalid == 1;
              wvalid  == 1;
              awburst == 2;});
          finish_item(req);
          $display("-------------------------------------- Axi Write Burst Seq Ended --------------------------------------");
      endtask
endclass


class axi_rd_burst_seq extends axi_seq_base;
    `uvm_object_utils(axi_rd_burst_seq)
    `NEW_OBJ

    task body();
        $display("-------------------------------------- Axi Read Burst Seq Started --------------------------------------");

        req = axi_xtn::type_id::create("req");

        if(!uvm_config_db #(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"Failed to get env_cfg from TEST in axi_burst_seq")

        temp = env_cfg_h.axi_length.pop_front();
        `uvm_info(get_type_name(),$sformatf("\nNo of transfers in AXI TRANSACTION (Length) : %0d",temp),UVM_NONE);

        start_item(req);
        assert(req.randomize() with { // master is sending the transactions (all the signals that go from master to slave)
            arlen   == temp;
            arvalid == 1;
            awlen   == temp;
            awvalid == 0;
            wvalid  == 0;
            arsize  inside {[0:3]}; // here it was awsize and awburst so
            arburst inside {[0:2]};});
        finish_item(req);
        $display("-------------------------------------- Axi Read Burst Seq Ended --------------------------------------");
    endtask
endclass
