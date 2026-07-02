//---------------------------------------- SB -------------------------------------------
class sb extends uvm_scoreboard;
        `uvm_component_utils(sb)

        // Coverage purpose
        uvm_tlm_analysis_fifo #(axi_rst_xtn) fifo_axi_rst_h;
        uvm_tlm_analysis_fifo #(axi_xtn) fifo_axi_ctrl_h; // write address, write resp and read_address receiver port

        uvm_tlm_analysis_fifo #(ahb_rst_xtn) fifo_ahb_rst_h;
        uvm_tlm_analysis_fifo #(ahb_xtn) fifo_ahb_data_h;

        // comparision purpose
        uvm_tlm_analysis_fifo #(axi_xtn) fifo_axi_rdata_h;
        uvm_tlm_analysis_fifo #(axi_xtn) fifo_axi_wdata_h;

        axi_xtn axi_wdata_q[$], axi_rdata_q[$]; // whatever data axi_monitor samples that will be stored here after fifo_data ports receives it.

        // For debugging
        int axi_wdata[$], axi_rdata[$];
        int ahb_wdata[$], ahb_rdata[$];

        axi_rst_xtn axi_rst_xtn_h;
        axi_rst_xtn axi_rst_cov_xtn_h;
        ahb_rst_xtn ahb_rst_xtn_h;
        ahb_rst_xtn ahb_rst_cov_xtn_h;

        axi_xtn axi_xtn_h, axi_xtn_wdata_h, axi_xtn_rdata_h;
        axi_xtn axi_xtn_cov_h;

        ahb_xtn ahb_xtn_h;
        ahb_xtn ahb_xtn_cov_h;

        env_cfg env_cfg_h;

        covergroup axi_rst_cg;
                AXI_RST : coverpoint axi_rst_cov_xtn_h.aresetn{bins axi_rst = {0,1};}
        endgroup

        covergroup ahb_rst_cg;
                AHB_RST : coverpoint ahb_rst_cov_xtn_h.hresetn{bins ahb_rst = {0,1};}
        endgroup

        covergroup axi_cg;
            option.per_instance = 1;
            // Write address channel
            CP_AXI_AWID : coverpoint axi_xtn_cov_h.awid{bins low = {[0:$]};}

            CP_AXI_AWADDR : coverpoint axi_xtn_cov_h.awaddr{    bins slave1 = {[32'h0000_0000 : 32'h4444_4444]};
                                                                bins slave2 = {[32'h4444_4445 : 32'h8888_8888]};
                                                                bins slave3 = {[32'h8888_8889 : 32'hcccc_cccc]};
                                                                bins slave4 = {[32'hcccc_cccd : 32'hffff_ffff]};
                                                            }

            CP_AXI_AWBURST : coverpoint axi_xtn_cov_h.awburst{bins awburst = {0,1,2};}      // awburst is [1:0]
            CP_AXI_AWSIZE  : coverpoint axi_xtn_cov_h.awsize {bins awsize  = {0,1,2,3};} // awsize is [1:0]
            CP_AXI_AWLEN   : coverpoint axi_xtn_cov_h.awlen  {bins awlen   = {[0:15]};} // awlen in axi3 is [3:0]

            // Write channel
            CP_AXI_WID         : coverpoint axi_xtn_cov_h.wid{bins wid = {[0:$]};}
            CP_AXI_WLAST   : coverpoint axi_xtn_cov_h.wlast{bins wlast = {0,1};}

            // Response channel
            CP_AXI_BID         : coverpoint axi_xtn_cov_h.bid{bins bid = {[0:$]};}
            CP_AXI_BREST   : coverpoint axi_xtn_cov_h.bresp{bins bresp = {0,1};}

            // Read address channel
            CP_AXI_ARID        : coverpoint axi_xtn_cov_h.arid{bins arid = {[0:$]};}

            CP_AXI_ARADDR : coverpoint axi_xtn_cov_h.awaddr{bins slave1 = {[32'h0000_0000 : 32'hffff_ffff]};} // read address can be random, but we can mimic what we wrote in awaddr

            CP_AXI_ARBURST : coverpoint axi_xtn_cov_h.arburst{bins arburst = {0,1,2};}      // awburst is [1:0]
            CP_AXI_ARSIZE  : coverpoint axi_xtn_cov_h.arsize {bins arsize  = {0,1,2,3};} // awsize is [1:0]
            CP_AXI_ARLEN   : coverpoint axi_xtn_cov_h.arlen  {bins arlen   = {[0:15]};} // awlen in axi3 is [3:0]

            // Read channel
            CP_AXI_RID         : coverpoint axi_xtn_cov_h.rid{bins rid = {[0:$]};}
            CP_AXI_RLAST   : coverpoint axi_xtn_cov_h.rlast{bins rlast = {0,1};}
        endgroup

        // write and read data
        covergroup axi_wdata_cg with function sample(int i); // we are checking depth using i, because wdata and rdata uses i.
            CG_AXI_WDATA : coverpoint axi_xtn_cov_h.wdata[i]{bins wdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};}

            CG_AXI_WSTRB : coverpoint axi_xtn_cov_h.wstrb[i]{bins wstrb[] = {1,2,4,8,16,32,64,128,3,12,15,49,192,240,255};}
        endgroup

        covergroup axi_rdata_cg with function sample(int i);
            CG_AXI_RDATA : coverpoint axi_xtn_cov_h.rdata[i]{bins rdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};}

            CG_AXI_RRESP : coverpoint axi_xtn_cov_h.rresp[i]{bins rstrb[] = {0};}
        endgroup

        // Ahb slave coverage
        covergroup ahb_cg;
            CP_AHB_HADDR : coverpoint ahb_xtn_cov_h.haddr   {   bins slave1 = {[32'h0000_0000 : 32'h4444_4444]};
                                                                bins slave2 = {[32'h4444_4445 : 32'h8888_8888]};
                                                                bins slave3 = {[32'h8888_8889 : 32'hcccc_cccc]};
                                                                bins slave4 = {[32'hcccc_cccd : 32'hffff_ffff]};
                                                            }
            CP_AHB_HBURST : coverpoint ahb_xtn_cov_h.hburst {bins hburst = {[2:0]};}
            CP_AHB_HSIZE  : coverpoint ahb_xtn_cov_h.hsize  {bins hsize  = {0,1,2,3};}
            CP_AHB_HWRITE : coverpoint ahb_xtn_cov_h.hwrite {bins hwrite = {0,1};}
            CP_AHB_HRESP  : coverpoint ahb_xtn_cov_h.hburst {bins hburst = {0,1};}
            CP_AHB_HREADY : coverpoint ahb_xtn_cov_h.hready {bins hready = {1};}

            CP_AHB_HWDATA : coverpoint ahb_xtn_cov_h.hwdata {bins hwdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};}
            CP_AHB_HRDATA : coverpoint ahb_xtn_cov_h.hrdata {bins hrdata = {[64'h0000_0000_0000_0000 : 64'hffff_ffff_ffff_ffff]};}
        endgroup

        function new(string name="sb",uvm_component parent);
            super.new(name,parent);

            axi_rst_cg      = new();
            ahb_rst_cg      = new();
            axi_cg          = new();
            ahb_cg          = new();
            axi_wdata_cg    = new();
            axi_rdata_cg    = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            fifo_axi_rst_h          = new("fifo_axi_rst_h",this);
            fifo_ahb_rst_h          = new("fifo_ahb_rst_h",this);
            fifo_axi_ctrl_h         = new("fifo_axi_ctrl_h",this);
            fifo_ahb_data_h         = new("fifo_ahb_data_h",this);
            fifo_axi_wdata_h        = new("fifo_axi_wdata_h",this);
            fifo_axi_rdata_h        = new("fifo_axi_rdata_h",this);
            // foreach(fifo_axi_rdata_h
            //      fifo_axi_rdata_h[i] = new($sformatf("fifo_axi_rdata_h[%0d]",i),this);
            // foreach(fifo_axi_wdata_h[i])
            //      fifo_axi_wdata_h[i] = new($sformatf("fifo_axi_wdata_h[%0d]",i),this);
        endfunction

        task run_phase(uvm_phase phase);
            fork
                    begin : get_axi_rst_data
                        forever begin
                            fifo_axi_rst_h.get(axi_rst_xtn_h);
                            axi_rst_check(axi_rst_xtn_h);
                            axi_rst_cov_xtn_h = axi_rst_xtn_h;
                            axi_rst_cg.sample();
                        end
                    end

                    begin : get_ahb_rst_data
                        forever begin
                            fifo_ahb_rst_h.get(ahb_rst_xtn_h);
                            ahb_rst_check(ahb_rst_xtn_h);

                            ahb_rst_cov_xtn_h = ahb_rst_xtn_h;
                            ahb_rst_cg.sample();
                        end
                    end

                    begin : get_axi_ctrl_data
                        forever begin
                            fifo_axi_ctrl_h.get(axi_xtn_h);

                            axi_xtn_cov_h = axi_xtn_h;
                            axi_cg.sample();

                            foreach(axi_xtn_cov_h.wdata[i])
                                    axi_wdata_cg.sample(i);
                            foreach(axi_xtn_cov_h.rdata[i])
                                    axi_rdata_cg.sample(i);
                        end
                    end

                    begin : get_ahb_data
                        forever begin
                            fifo_ahb_data_h.get(ahb_xtn_h);
                            axi_ahb_data_compare(ahb_xtn_h);

                            ahb_xtn_cov_h = ahb_xtn_h;
                            ahb_cg.sample();
                        end
                    end

                    begin : get_axi_wdata
                        forever begin
                            fifo_axi_wdata_h.get(axi_xtn_wdata_h);
                            axi_wdata_q.push_back(axi_xtn_wdata_h);
                                //axi_xtn_cov_h = axi_xtn_wdata_h; // since we assign wdata_h to cov_h - cov has access to axi_xtn

                                    // foreach(axi_xtn_cov_h.temp_wdata[i])
                                    //      axi_wdata_cg.sample(i);
                        end
                    end

                    begin : get_axi_rdata
                        forever begin
                                //foreach(fifo_axi_rdata_h[i])
                                //fifo_axi_rdata_h[i].get(axi_xtn_rdata_h);
                            fifo_axi_rdata_h.get(axi_xtn_rdata_h);
                            axi_rdata_q.push_back(axi_xtn_rdata_h);
                            //axi_xtn_cov_h = axi_xtn_rdata_h;

                                        // foreach(axi_xtn_cov_h.temp_rdata[i])
                                        // axi_rdata_cg.sample(i);
                        end
                    end
                join
        endtask

        task axi_rst_check(axi_rst_xtn rst_xtn);
                if(rst_xtn.aresetn == 1'b0) begin
                    if(rst_xtn.bvalid == 0 && rst_xtn.rvalid == 0) begin// how valid 0 ? it should be 1 right ?
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_info(get_type_name(),$sformatf("Axi Slave Reset Successful"),UVM_LOW)
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
                    end
                    else begin
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_error(get_type_name(),$sformatf("Axi Slave Reset Failed"))
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
                    end
                end
        endtask

        task ahb_rst_check(ahb_rst_xtn rst_xtn);
                $display("Inside Scoreboard : Entered into 'Ahb' reset check task");
                if(rst_xtn.hresetn == 1'b0) begin
                    if(rst_xtn.htrans == 2'b00) begin // If htrans becomes IDLE after reset then only RESET PASS
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_info(get_type_name(),$sformatf("Ahb Master Reset Successful"),UVM_LOW)
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
                    end
                    else begin
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_error(get_type_name(),$sformatf("Ahb Master Reset Failed"))
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
                    end
                end
        endtask

        task axi_ahb_data_compare(ahb_xtn ahb_xtn); // we can give the same handle name as type
                axi_xtn axi_xtn_h;

                if(ahb_xtn.hwrite == 1) begin // if master writing to slave
                    wait(axi_wdata_q.size() != 0)

                    axi_xtn_h = axi_wdata_q.pop_front();

                    //-----------------------------------------------------------------------------
                    axi_wdata.push_back(axi_xtn_h.temp_wdata);
                    ahb_wdata.push_back(ahb_xtn.hwdata);
                    $display("axi write data in queue : %p",axi_wdata);
                    $display("ahb write data in queue : %p",ahb_wdata);
                    //-----------------------------------------------------------------------------

                    if(axi_xtn_h.temp_wdata == ahb_xtn.hwdata) begin// we can directly pop here, but then we can't print it as once pop it will be removed from queue
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_info(  get_type_name(),
                                    $sformatf("Data Match Successful :\nAXI Write data = %0d\nAHB Write data = %0d",axi_xtn_h.temp_wdata, ahb_xtn.hwdata),
                                    UVM_LOW)
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    end
                    else begin
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_error( get_type_name(),
                                    $sformatf("Data Mismatch!\nAXI Write data = %0d\nAHB Write data = %0d",axi_xtn_h.temp_wdata, ahb_xtn.hwdata))
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    end
                end

                else begin
                    wait(axi_rdata_q.size() != 0)

                    axi_xtn_h = axi_rdata_q.pop_front();

                    //-----------------------------------------------------------------------------
                    axi_rdata.push_back(axi_xtn_h.temp_rdata);
                    ahb_rdata.push_back(ahb_xtn.hrdata);
                    $display("axi read data in queue : %p",axi_rdata);
                    $display("ahb read data in queue : %p",ahb_rdata);
                    //-----------------------------------------------------------------------------

                    if(axi_xtn_h.temp_rdata == ahb_xtn.hrdata) begin// we can directly pop here, but then we can't print it as once pop it will be removed from queue
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_info(  get_type_name(),
                                    $sformatf("Data Match Successful :\nAXI Read data = %0d\nAHB Read data = %0d",axi_xtn_h.temp_rdata, ahb_xtn.hrdata),
                                    UVM_LOW)
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    end
                    else begin
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                        `uvm_error( get_type_name(),
                                    $sformatf("Data Mismatch!\nAXI Read data = %0d\nAHB Read data = %0d",axi_xtn_h.temp_rdata, ahb_xtn.hrdata))
                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    end
                end
        endtask

endclass
