class env_cfg extends uvm_object;
        `uvm_object_utils(env_cfg)
        `NEW_OBJ

        axi_agent_cfg axi_cfg[];
        ahb_agent_cfg ahb_cfg[];

        axi_rst_agent_cfg axi_rst_cfg[];
        ahb_rst_agent_cfg ahb_rst_cfg[];

        int has_sb = 1;

        int has_axi_agent = 1;
        int has_ahb_agent = 1;
        int has_axi_rst_agent = 1;
        int has_ahb_rst_agent = 1;

        int no_of_duts = 1;

        int ahb_length[$];
        int axi_length[$]; // Using this we will set the length for transactions (we set in test)
endclass
