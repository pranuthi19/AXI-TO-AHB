package axi2ahb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"


//------------------------------------DEFAULT MACROS--------------------------------------
`define NEW_OBJ \
function new(string name="");   \
        super.new(name);        \
endfunction

`define NEW_COMP        \
function new(string name="",uvm_component parent);      \
        super.new(name,parent); \
endfunction
//------------------------------------DEFAULT MACROS--------------------------------------

    // cfg classes
    `include "../axi_agent_top/axi_agent/axi_agent_cfg.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_agent_cfg.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_agent_cfg.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_agent_cfg.sv"
    `include "../tb/env_cfg.sv"

    // axi_agent_top--------------------------------------------------

    // axi_reset_agent
    `include "../axi_agent_top/axi_agent/axi_xtn.sv"
    `include "../axi_agent_top/axi_agent/axi_drv.sv"
    `include "../axi_agent_top/axi_agent/axi_mon.sv"
    `include "../axi_agent_top/axi_agent/axi_seqr.sv"
    `include "../axi_agent_top/axi_agent/axi_seqs.sv"
    `include "../axi_agent_top/axi_agent/axi_agent.sv"

    // axi_reset_agent
    `include "../axi_agent_top/axi_rst_agent/axi_rst_xtn.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_drv.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_mon.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_seqr.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_seqs.sv"
    `include "../axi_agent_top/axi_rst_agent/axi_rst_agent.sv"

    `include "../axi_agent_top/axi_agent_top.sv"

    // ahb_agent_top--------------------------------------------

    // ahb_reset_agent
    `include "../ahb_agent_top/ahb_agent/ahb_xtn.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_drv.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_mon.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_seqr.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_seqs.sv"
    `include "../ahb_agent_top/ahb_agent/ahb_agent.sv"

    // ahb_reset_agent
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_xtn.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_drv.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_mon.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_seqr.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_seqs.sv"
    `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_agent.sv"

    `include "../ahb_agent_top/ahb_agent_top.sv"

    // tb
    `include "../tb/sb.sv"
    `include "../tb/env.sv"

    // test
    `include "../test/test.sv"
endpackage
