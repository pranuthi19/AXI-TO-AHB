//-------------- CFG
class axi_agent_cfg extends uvm_object;
        `uvm_object_utils(axi_agent_cfg)
        `NEW_OBJ

        uvm_active_passive_enum is_active;
        virtual axi_if vif;
endclass
