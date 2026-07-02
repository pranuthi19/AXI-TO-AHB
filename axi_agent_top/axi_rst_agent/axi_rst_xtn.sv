class axi_rst_xtn extends uvm_sequence_item;
    `uvm_object_utils(axi_rst_xtn)
    `NEW_OBJ

    rand bit aresetn;
    logic bvalid;
    logic rvalid;

    function void do_print(uvm_printer printer);
       printer.print_field("aresetn",   this.aresetn,   1, UVM_DEC);
       printer.print_field("bvalid",    this.bvalid,    1, UVM_DEC);
       printer.print_field("rvalid",    this.rvalid,    1, UVM_DEC);
    endfunction
 endclass
