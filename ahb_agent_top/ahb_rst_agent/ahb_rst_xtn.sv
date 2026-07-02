//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ rst XTN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ahb_rst_xtn extends uvm_sequence_item;
    `uvm_object_utils(ahb_rst_xtn)
    `NEW_OBJ

    rand bit hresetn;
    bit hready;
    logic [1:0] htrans;

    function void do_print(uvm_printer printer);
       printer.print_field("hresetn", this.hresetn, 1, UVM_DEC);
    endfunction
endclass
