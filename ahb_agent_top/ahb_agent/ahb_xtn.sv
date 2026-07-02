// AHB Transaction
class ahb_xtn extends uvm_sequence_item;
        `uvm_object_utils(ahb_xtn)
        `NEW_OBJ

        bit [31:0] haddr;
        bit [1:0] htrans;
        bit [2:0] hburst;
        bit [3:0] hsize;
        bit hwrite;

        bit [3:0] hmaster;
        rand bit [2:0] delay_cycle;

        // Unused in out project
        bit hmastlock; // locks master and slave for the transaction
        bit hprot; // Protect the control info

        // bus access signals
        bit hbusreq;
        bit hlock;

        // Data signals
        bit [63:0] hwdata;
        rand bit [63:0] hrdata; // This will be sent to master so rand

        // Handshake/Response
        rand bit hready;
        rand bit [1:0] hresp; // handshake signals will be sent to master so both rand

        rand enum {okay, okay_with_wait, error} resp;

        constraint delay_c{delay_cycle inside {[2:5]};};
        constraint hresp_c{hresp inside {[0:1]};};

        function void do_print(uvm_printer printer);
           printer.print_field("haddr",         this.haddr,     32,     UVM_HEX);
           printer.print_field("htrans",        this.htrans,    2,      UVM_HEX);
           printer.print_field("hburst",        this.hburst,    8,      UVM_HEX);
           printer.print_field("hsize",         this.hsize,     8,      UVM_HEX);
           printer.print_field("hwrite",        this.hwrite,    1,      UVM_HEX);
           printer.print_field("hmastlock",     this.hmastlock, 1,      UVM_HEX);
           printer.print_field("hprot",         this.hprot,     1,      UVM_HEX);
           printer.print_field("hwdata",        this.hwdata,    32,     UVM_HEX);
           printer.print_field("hrdata",        this.hrdata,    32,     UVM_HEX);
           printer.print_field("hready",        this.hready,    1,      UVM_HEX);
           printer.print_field("hresp",         this.hresp,     1,      UVM_HEX);
        endfunction
endclass
