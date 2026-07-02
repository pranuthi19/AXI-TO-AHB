class ahb_agent_cfg extends uvm_object;
        `uvm_object_utils(ahb_agent_cfg)
        `NEW_OBJ

        uvm_active_passive_enum is_active;
        virtual ahb_if vif;
endclass
