class ahb_rst_agent_cfg extends uvm_object;
    `uvm_object_utils(ahb_rst_agent_cfg)
    `NEW_OBJ

    uvm_active_passive_enum is_active;
    virtual ahb_rst_if vif;
endclass
