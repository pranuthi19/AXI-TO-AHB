//---------------------------------------- AXI_AGENT_TOP -------------------------------------------
class axi_agent_top extends uvm_agent;
    `uvm_component_utils(axi_agent_top)
    `NEW_COMP

    axi_agent       axi_agent_h;
    axi_rst_agent   axi_rst_agent_h;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi_rst_agent_h     = axi_rst_agent::type_id::create("axi_rst_agent_h",this);
        axi_agent_h         = axi_agent::type_id::create("axi_agent_h",this);
    endfunction
endclass
