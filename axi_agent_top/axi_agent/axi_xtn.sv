
class axi_xtn extends uvm_sequence_item;
    `uvm_object_utils(axi_xtn)
    `NEW_OBJ

        bit             aresetn;
        bit [63:0]      temp_wdata;
        bit [63:0]      temp_rdata;

        // Write address channel
        rand bit [31:0] awaddr;
        rand bit [1:0]  awburst;
        rand bit [2:0]  awsize;
        rand bit [2:0]  awprot;
        rand bit [7:0]  awlen; // axi4 supports [7:0] but axi3 only [3:0]
        rand bit [1:0]  awlock; // axi4 supports 1 bit
        rand bit [7:0]  awid;
        rand bit [3:0]  awcache;
        rand bit        awvalid;
        bit             awready; // Ask sir how ready will go to master if the channel is unidirectional or it goes only to interconnect/bridge

        // Write data channel
        rand bit [63:0] wdata[]; // ?? ask sir
        rand bit [7:0]  wid;
        bit [7:0]       wstrb[];
        bit             wready;
        rand bit        wvalid;
        bit             wlast;

        // Write Response channel
        bit [1:0]       bresp; // Why not dynamic ?
        bit             bready;
        bit             bvalid;
        bit [7:0]       bid;

        // Read address channel
        rand bit [31:0] araddr;
        rand bit [1:0]  arburst;
        rand bit [2:0]  arsize;
        rand bit [2:0]  arprot;
        rand bit [7:0]  arlen; // axi4 supports [7:0]
        rand bit [1:0]  arlock; // axi4 supports 1 bit
        rand bit [7:0]  arid;
        rand bit [3:0]  arcache;
        rand bit        arvalid;
        bit             arready;

        // Write data channel
        bit [63:0]      rdata[]; // ?? ask sir
        bit [1:0]       rresp[];
        bit             rready;
        bit             rvalid;
        bit [7:0]       rid;
        bit             rlast;

        int delay_cycles; // Why we need this ?

        constraint same_ids {
                wid == awid;
                wid == bid;
                rid == arid;
        }

        constraint write_burst{awburst inside {0,1,2};}
        // 3 is reserved in axi burst as it only has fixed, incr, wrap (AHB has single, incr, incr4, incr8 ..... and wrap, wrap4 and so on)

        constraint read_burst{arburst inside {0,1,2};}

        constraint awsizeee {awsize inside {0,1,2,3};}
        constraint arsizeee {arsize inside {0,1,2,3};}

        // We are only calculating the start address as Axi will send only the first address
        constraint wr_start_valid_adr1 {((awburst == 2'b10 || awburst == 2'b00) && (awsize == 1)) -> awaddr%2 == 0;}
        constraint wr_start_valid_adr2 {((awburst == 2'b10 || awburst == 2'b00) && (awsize == 2)) -> awaddr%4 == 0;}
        constraint wr_start_valid_adr3 {((awburst == 2'b10 || awburst == 2'b00) && (awsize == 3)) -> awaddr%8 == 0;}

        constraint rd_start_valid_adr1 {((arburst == 2'b10 || arburst == 2'b00) && (arsize == 1)) -> araddr%2 == 0;}
        constraint rd_start_valid_adr2 {((arburst == 2'b10 || arburst == 2'b00) && (arsize == 2)) -> araddr%4 == 0;}
        constraint rd_start_valid_adr3 {((arburst == 2'b10 || arburst == 2'b00) && (arsize == 3)) -> araddr%8 == 0;}

        // Wdata is the all the data in transactions so if awlen is 7 and awsize is 4 bytes then 7x4 = 28 bytes.
        constraint wdata_total {wdata.size() == awlen+1;} // Ask sir why +1.

        function void post_randomize();
                int j=0;
                bit [31:0] start_address = awaddr; // Assigning randomized awaddr to start address
                int no_of_bytes = 2**awsize; // int because we don't know the actual size (it can be anything based on awsize)
                int burst_length = awlen+1; // int for same reason as above, why +1 ask sir.

                bit [31:0] aligned_address = (start_address/no_of_bytes)*no_of_bytes; // won't it be same as start address ?
                wstrb = new[awlen+1]; // why +1 and how exactly wstrb works ? ask sir

                for(int i=(start_address%8); i<((start_address%8)+no_of_bytes); i++) begin
                    wstrb[j][i] = 1;
                end

                for(int k=1; k<burst_length; k++)begin
                    aligned_address = aligned_address + no_of_bytes;
                    j++;
                    for(int l=(aligned_address%8); l<((start_address%8)+no_of_bytes); l++)
                    wstrb[j][l] = 1;
                end
        endfunction

    function void do_print(uvm_printer printer);
        // Write address channel
        printer.print_field("awaddr",   this.awaddr,    32, UVM_HEX);
        printer.print_field("awburst",  this.awburst,   2,  UVM_HEX);
        printer.print_field("awsize",   this.awsize,    3,  UVM_HEX);
        printer.print_field("awlen",    this.awlen,     8,  UVM_HEX);
        printer.print_field("awid",     this.awid,      8,  UVM_HEX);
        printer.print_field("awready",  this.awready,   1,  UVM_HEX);
        printer.print_field("awvalid",  this.awvalid,   1,  UVM_HEX);

        // Write data channel
        foreach(wdata[i])
                printer.print_field($sformatf("wdata[%0d]",i),  this.wdata[i],  64, UVM_HEX);
        foreach(wstrb[i])
            printer.print_field($sformatf("wstrb[%0d]",i),  this.wstrb[i],      8,  UVM_HEX);

        printer.print_field("wid",      this.wid,       8,  UVM_HEX);
        printer.print_field("wready",   this.wready,    1, UVM_HEX);
        printer.print_field("wvalid",   this.wvalid,    1, UVM_HEX);
        printer.print_field("wlast",    this.wlast,     1, UVM_HEX);

        // Write resp channel
        printer.print_field("bready",   this.bready,    1, UVM_HEX);
        printer.print_field("bvalid",   this.bvalid,    1, UVM_HEX);
        printer.print_field("bresp",    this.bresp,     2, UVM_HEX);
        printer.print_field("bid",      this.bid,       8, UVM_HEX);

        // Read address channel
        printer.print_field("araddr",   this.araddr,    32, UVM_HEX);
        printer.print_field("arburst",  this.arburst,   2,  UVM_HEX);
        printer.print_field("arsize",   this.arsize,    3,  UVM_HEX);
        printer.print_field("arlen",    this.arlen,     8,  UVM_HEX);
        printer.print_field("arid",     this.arid,      8,  UVM_HEX);
        printer.print_field("arready",  this.arready,   1,  UVM_HEX);
        printer.print_field("arvalid",  this.arvalid,   1,  UVM_HEX);

        // Read data channel
        foreach(rdata[i])
                printer.print_field($sformatf("rdata[%0d]",i),  this.rdata[i],  64, UVM_DEC);
        foreach(rresp[i])
                printer.print_field($sformatf("rresp[%0d]",i),  this.rresp[i],  2, UVM_DEC);

        printer.print_field("rid",      this.rid,       8, UVM_HEX);
        printer.print_field("rready",   this.rready,    1, UVM_HEX);
        printer.print_field("rvalid",   this.rvalid,    1, UVM_HEX);
        printer.print_field("rlast",    this.rlast,     1, UVM_HEX);
    endfunction
endclass
