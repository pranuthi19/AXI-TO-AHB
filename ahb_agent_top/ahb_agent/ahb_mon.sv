//---------------- AHB_MONITOR --------------------
class ahb_monitor extends uvm_monitor;
        `uvm_component_utils(ahb_monitor)
        `NEW_COMP

        virtual ahb_if vif;
        ahb_agent_cfg ahb_cfg;
        ahb_xtn ahb_mon_xtn;

        uvm_analysis_port #(ahb_xtn) ahb_mon_port;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                ahb_mon_port = new("ahb_mon_port",this);

                if(!uvm_config_db #(ahb_agent_cfg)::get(this,"","ahb_agent_cfg",ahb_cfg))
                        `uvm_fatal(get_type_name(),"Failed to get ahb cfg from ENV in AHB AGENT")

        endfunction

        function void connect_phase(uvm_phase phase);
                vif = ahb_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
                forever begin
                        collect_ahb_data();
                end
        endtask

        task collect_ahb_data();
                $display("%0t ENTER collect_ahb_data",$time);
                ahb_mon_xtn = ahb_xtn::type_id::create("ahb_mon_xtn");

                // Note : If the bridge is invloved in ahb transactions that time bridge will always provide ahb transaction as non sequential even in burst mode. Non seq then seq only works when ahb master and ahb slave are communicating not when axi to ahb is there.

                //while(!(vif.ahb_mon_cb.hready && vif.ahb_mon_cb.htrans == 2'b10)) begin
                    //@(vif.ahb_mon_cb);

                wait((vif.ahb_mon_cb.hready === 1'b1) && (vif.ahb_mon_cb.htrans == 2'b10))

                // @(vif.ahb_mon_cb);

                // while(!(vif.ahb_mon_cb.hready===1'b1) && (vif.ahb_mon_cb.htrans == 2'b10))
                //         begin
                //                 @(vif.ahb_mon_cb);
                //         end
$display("??????????????????????????????? NEW AHB ADDR PHASE time=%0t haddr=%h hrdata=%h ??????????????????????????????",
          $time,
          vif.ahb_mon_cb.haddr,
          vif.ahb_mon_cb.hrdata);

                $display("AHB MON : Got hready=%0d and htrans=%0d",vif.ahb_mon_cb.hready,vif.ahb_mon_cb.htrans);
                ahb_mon_xtn.haddr       =       vif.ahb_mon_cb.haddr;
                ahb_mon_xtn.hready      =       vif.ahb_mon_cb.hready;
                ahb_mon_xtn.hsize       =       vif.ahb_mon_cb.hsize;
                ahb_mon_xtn.htrans      =       vif.ahb_mon_cb.htrans;
                ahb_mon_xtn.hresp       =       vif.ahb_mon_cb.hresp;
                ahb_mon_xtn.hburst      =       vif.ahb_mon_cb.hburst;
                ahb_mon_xtn.hwrite      =       vif.ahb_mon_cb.hwrite;

                if(ahb_mon_xtn.hwrite) begin // shouldn't make any difference
                // if(vif.ahb_mon_cb.hwrite) begin
                        @(vif.ahb_mon_cb);
                        wait(vif.ahb_mon_cb.hready == 1'b1)
                        ahb_mon_xtn.hwdata = vif.ahb_mon_cb.hwdata;
                        ahb_mon_port.write(ahb_mon_xtn);
                end
                else begin
                        @(vif.ahb_mon_cb)
                        wait(vif.ahb_mon_cb.hready == 1'b1)
                        ahb_mon_xtn.hrdata = vif.ahb_mon_cb.hrdata;
        //                 $display("AHB WRITE TO SB time=%0t haddr=%h hrdata=%h",
        //   $time,
        //   ahb_mon_xtn.haddr,
        //   ahb_mon_xtn.hrdata);

                        $display("AHB WRITE TO SB :%0t\nADDR=%h | HRDATA=%h | HREADY=%0b | HRESP=%0b",
                                    $time,
                                    vif.ahb_mon_cb.haddr,
                                    vif.ahb_mon_cb.hrdata,
                                    vif.ahb_mon_cb.hready,
                                    vif.ahb_mon_cb.hresp
                                );
                        if(ahb_mon_xtn.hrdata != 0)
                                ahb_mon_port.write(ahb_mon_xtn);
                end
                `uvm_info(get_type_name(),$sformatf("\nAhb Data Sampled at time :%0t\n%p",$time,ahb_mon_xtn.sprint()),UVM_LOW)
        endtask
endclass
