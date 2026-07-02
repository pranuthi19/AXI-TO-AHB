
class base_test extends uvm_test;
    `uvm_component_utils(base_test)
        `NEW_COMP

        env_cfg env_cfg_h;
        env envh;

        int has_axi_agent = 1;
        int has_ahb_agent = 1;
        int has_axi_rst_agent = 1;
        int has_ahb_rst_agent = 1;
        int has_sb = 1;

        int no_of_duts = 1;

        axi_agent_cfg axi_cfg[];
        ahb_agent_cfg ahb_cfg[];

        axi_rst_agent_cfg axi_rst_cfg[];
        ahb_rst_agent_cfg ahb_rst_cfg[];

        //--------------------------------------------------------------------
            rand int length[]; // For setting the length for the transactions
            int no_of_transactions = 1;

            constraint transaction_len {
                foreach(length[i])
                    length[i] inside {[1:15]}; // as size of awlen or arlen is [3:0] so there can be max 16 transfers in one transactions.
            }
        //--------------------------------------------------------------------


        function void build_phase(uvm_phase phase);
                $display("##################### Test Base Build Phase Started ####################");
                super.build_phase(phase);

                env_cfg_h = env_cfg::type_id::create("env_cfg_h");

                if(has_axi_agent) begin
                        env_cfg_h.axi_cfg = new[no_of_duts];
                end

                if(has_ahb_agent) begin
                        env_cfg_h.ahb_cfg = new[no_of_duts];
                end

                // Reset agents
                if(has_axi_rst_agent) begin
                        env_cfg_h.axi_rst_cfg = new[no_of_duts];
                end

                if(has_ahb_rst_agent) begin
                        env_cfg_h.ahb_rst_cfg = new[no_of_duts];
                end

                create_config();

                uvm_config_db #(env_cfg)::set(this,"*","env_cfg",env_cfg_h);

                envh = env::type_id::create("envh",this);
                //uvm_top.print_topology();     // build phase top down approach, and end of elaboration runs after all the components are created so topology we print in elaboration
        endfunction

        function void create_config();
                if(has_axi_agent) begin
                        axi_cfg = new[no_of_duts];
                        foreach(axi_cfg[i]) begin
                                axi_cfg[i] = axi_agent_cfg::type_id::create($sformatf("axi_cfg[%0d]",i));
                        end

                        foreach(axi_cfg[i]) begin
                                if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("axi_IF[%0d]",i),axi_cfg[i].vif))
                                        `uvm_fatal(get_type_name(),$sformatf("Failed to get axi_IF[%0d] from TOP in TEST",i))

                                axi_cfg[i].is_active = UVM_ACTIVE;
                                env_cfg_h.axi_cfg[i] = axi_cfg[i];
                        end
                end

                if(has_axi_rst_agent) begin
                        axi_rst_cfg = new[no_of_duts];
                        foreach(axi_rst_cfg[i]) begin
                                axi_rst_cfg[i] = axi_rst_agent_cfg::type_id::create($sformatf("axi_rst_cfg[%0d]",i));
                        end

                        foreach(axi_rst_cfg[i]) begin
                                if(!uvm_config_db #(virtual axi_rst_if)::get(this,"",$sformatf("axi_rst_IF[%0d]",i),axi_rst_cfg[i].vif))
                                        `uvm_fatal(get_type_name(),$sformatf("Failed to get axi_rst_IF[%0d] from TOP in TEST",i))

                                axi_rst_cfg[i].is_active = UVM_ACTIVE;
                                env_cfg_h.axi_rst_cfg[i] = axi_rst_cfg[i];
                        end
                end

                // AHB ---------------------------
                if(has_ahb_agent) begin
                        ahb_cfg = new[no_of_duts];
                        foreach(ahb_cfg[i]) begin
                                ahb_cfg[i] = ahb_agent_cfg::type_id::create($sformatf("ahb_cfg[%0d]",i));
                        end

                        foreach(ahb_cfg[i]) begin
                                if(!uvm_config_db #(virtual ahb_if)::get(this,"",$sformatf("ahb_IF[%0d]",i),ahb_cfg[i].vif))
                                        `uvm_fatal(get_type_name(),$sformatf("Failed to get ahb_IF[%0d] from TOP in TEST",i))

                                ahb_cfg[i].is_active = UVM_ACTIVE;
                                env_cfg_h.ahb_cfg[i] = ahb_cfg[i];
                        end
                end

                if(has_ahb_rst_agent) begin
                        ahb_rst_cfg = new[no_of_duts];
                        foreach(ahb_rst_cfg[i]) begin
                                ahb_rst_cfg[i] = ahb_rst_agent_cfg::type_id::create($sformatf("ahb_rst_cfg[%0d]",i));
                        end

                        foreach(ahb_rst_cfg[i]) begin
                                if(!uvm_config_db #(virtual ahb_rst_if)::get(this,"",$sformatf("ahb_rst_IF[%0d]",i),ahb_rst_cfg[i].vif))
                                        `uvm_fatal(get_type_name(),$sformatf("Failed to get ahb_rst_IF[%0d] from TOP in TEST",i))

                                ahb_rst_cfg[i].is_active = UVM_ACTIVE;
                                env_cfg_h.ahb_rst_cfg[i] = ahb_rst_cfg[i];
                        end
                end

        //----------------------------------- Length randomization logic ------------------------------------
            // We are randomizing the length variable which is inside the test and here we set the length size using no of trans
        this.randomize() with {length.size() == no_of_transactions;}; // How it is working ??

        foreach(length[i]) begin
            env_cfg_h.ahb_length.push_back(length[i]);
            env_cfg_h.axi_length.push_back(length[i]);
        end
        //---------------------------------------------------------------------------------------------------



                env_cfg_h.has_axi_agent                 = has_axi_agent;
                env_cfg_h.has_ahb_agent                 = has_ahb_agent;
                env_cfg_h.has_axi_rst_agent             = has_axi_rst_agent;
                env_cfg_h.has_ahb_rst_agent             = has_ahb_rst_agent;
                env_cfg_h.has_sb                        = has_sb;

                env_cfg_h.no_of_duts                    = no_of_duts;

        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                //uvm_top.print_topology();
        endfunction
endclass


// Axi2Ahb Bridge Reset
class axi2ahb_reset extends base_test;
        `uvm_component_utils(axi2ahb_reset)
        `NEW_COMP

        axi_rst_seq     axi_rst_seqh;
        ahb_rst_seq ahb_rst_seqh;

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

        endfunction

        task run_phase(uvm_phase phase);
            $display("##################### Reset Test Started ####################");
            axi_rst_seqh    = axi_rst_seq::type_id::create("axi_rst_seqh");
            ahb_rst_seqh    = ahb_rst_seq::type_id::create("ahb_rst_seqh");

            phase.raise_objection(this);

            foreach(envh.axi_agent_top_h[i])
                axi_rst_seqh.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);

            foreach(envh.ahb_agent_top_h[i])
                ahb_rst_seqh.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);

            #100;
            phase.drop_objection(this);
        endtask
endclass

// Axi writing to Ahb
class write_to_slave_test extends base_test;
        `uvm_component_utils(write_to_slave_test)
        `NEW_COMP

        axi_wr_burst_seq axi_wr_burst_seqh;
        ahb_seq          ahb_seqh;

        axi_rst_seq      axi_rst_seqh;
        ahb_rst_seq      ahb_rst_seqh;

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

        endfunction

        task run_phase(uvm_phase phase);
            $display("##################### Test Write Burst Started ####################");
            axi_wr_burst_seqh       = axi_wr_burst_seq::type_id::create("axi_wr_burst_seqh");
            ahb_seqh                = ahb_seq::type_id::create("ahb_seqh");
            axi_rst_seqh            = axi_rst_seq::type_id::create("axi_rst_seqh");
            ahb_rst_seqh            = ahb_rst_seq::type_id::create("ahb_rst_seqh");

                phase.raise_objection(this);

                foreach(envh.axi_agent_top_h[i])
                    axi_rst_seqh.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);

                foreach(envh.ahb_agent_top_h[i])
                    ahb_rst_seqh.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);

                foreach(envh.axi_agent_top_h[i])
                    axi_wr_burst_seqh.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);

                foreach(envh.ahb_agent_top_h[i])
                        ahb_seqh.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
                #100;
                phase.drop_objection(this);
        endtask
endclass

class read_from_slave_test extends base_test;
    `uvm_component_utils(read_from_slave_test)
    `NEW_COMP

    axi_rst_seq      axi_rst_seqh;
    ahb_rst_seq      ahb_rst_seqh;

    axi_rd_burst_seq axi_rd_burst_seqh;
    ahb_seq          ahb_seqh;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        $display("##################### Test Read Burst Started ####################");
        axi_rst_seqh            = axi_rst_seq::type_id::create("axi_rst_seqh");
        ahb_rst_seqh            = ahb_rst_seq::type_id::create("ahb_rst_seqh");
        axi_rd_burst_seqh       = axi_rd_burst_seq::type_id::create("axi_rd_burst_seqh");
        ahb_seqh                = ahb_seq::type_id::create("ahb_seqh");

            phase.raise_objection(this);

            foreach(envh.axi_agent_top_h[i])
                axi_rst_seqh.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);

            foreach(envh.ahb_agent_top_h[i])
                ahb_rst_seqh.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);

            foreach(envh.axi_agent_top_h[i])
                axi_rd_burst_seqh.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);

            foreach(envh.ahb_agent_top_h[i])
                    ahb_seqh.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
            #100;
            phase.drop_objection(this);
    endtask
endclass

/*
class read_from_slave_test extends base_test;
    `uvm_component_utils(read_from_slave_test)
    `NEW_COMP

    axi_rst_seq      axi_rst_seqh;
    ahb_rst_seq      ahb_rst_seqh;

    axi_rd_burst_seq axi_rd_burst_seqh;
    ahb_seq          ahb_seqh;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        $display("##################### Test Read Burst Started ####################");
        axi_rst_seqh            = axi_rst_seq::type_id::create("axi_rst_seqh");
        ahb_rst_seqh            = ahb_rst_seq::type_id::create("ahb_rst_seqh");
        axi_rd_burst_seqh       = axi_rd_burst_seq::type_id::create("axi_rd_burst_seqh");
        ahb_seqh                = ahb_seq::type_id::create("ahb_seqh");

            phase.raise_objection(this);

            foreach(envh.axi_agent_top_h[i])
                axi_rst_seqh.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);

            foreach(envh.ahb_agent_top_h[i])
                ahb_rst_seqh.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);

            foreach(envh.axi_agent_top_h[i])
                axi_rd_burst_seqh.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);

            foreach(envh.ahb_agent_top_h[i])
                    ahb_seqh.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
            #100;
            phase.drop_objection(this);
    endtask
endclass
*/
