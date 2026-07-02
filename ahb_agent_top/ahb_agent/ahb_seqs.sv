//----------------- AHB Sequence
class ahb_seq_base extends uvm_sequence #(ahb_xtn);
    `uvm_object_utils(ahb_seq_base)
    `NEW_OBJ
    env_cfg env_cfg_h;
endclass


class ahb_seq extends ahb_seq_base;
    `uvm_object_utils(ahb_seq)
    `NEW_OBJ
    int transaction_length;

    task body();
        $display("xxxxxxxxxxxxxxxxxxxxxxxx Ahb Sequence started xxxxxxxxxxxxxxxxxxxxxxxx");
        if(!uvm_config_db #(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"Failed to get env_config from TEST in ahb_seq")

        transaction_length = env_cfg_h.ahb_length.pop_front();
        `uvm_info(get_type_name(),$sformatf("\nNo of transfers in AHB TRANSACTION (Length) : %0d",transaction_length),UVM_NONE);

        repeat(2*(transaction_length)) begin // 2* because ahb takes 2 cc to complete 1 transfer
            req = ahb_xtn::type_id::create("req");

            start_item(req);
            assert(req.randomize() with {delay_cycle == 2;});
            finish_item(req);
        end
        $display("xxxxxxxxxxxxxxxxxxxxxxxx Ahb Sequence started xxxxxxxxxxxxxxxxxxxxxxxx");
    endtask
endclass



class ahb_read_seq extends ahb_seq_base;
    `uvm_object_utils(ahb_read_seq)
    `NEW_OBJ

    task body();
        if(!uvm_config_db #(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"Failed to get env_config from TEST in ahb_seq")

        repeat(2*(env_cfg_h.ahb_length.pop_front())) begin // 2* because ahb takes 2 cc to complete 1 transfer
            req = ahb_xtn::type_id::create("req");

            start_item(req);
            assert(req.randomize() with {delay_cycle == 2;});
            finish_item(req);
        end
    endtask
endclass
