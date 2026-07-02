//-------------- rst CFG
class axi_rst_agent_cfg extends uvm_object;
    `uvm_object_utils(axi_rst_agent_cfg)
    `NEW_OBJ

    uvm_active_passive_enum is_active;
    virtual axi_rst_if vif;
endclass
