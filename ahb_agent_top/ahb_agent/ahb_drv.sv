//---------------- AHB_DRIVER --------------------
class ahb_driver extends uvm_driver#(ahb_xtn);
    `uvm_component_utils(ahb_driver)
    `NEW_COMP

    virtual ahb_if vif;
    ahb_agent_cfg ahb_cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(ahb_agent_cfg)::get(this,"","ahb_agent_cfg",ahb_cfg))
            `uvm_fatal(get_type_name(),"Failed to get ahb cfg from ENV in AHB AGENT")

    endfunction

    function void connect_phase(uvm_phase phase);
        vif = ahb_cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
        end
    endtask
 /*
    task send_to_dut(ahb_xtn xtn);
        vif.ahb_drv_cb.hmaster <= 4'b0; // Only 1 master (which is brigde)
            if(xtn.resp == 0) begin // Okay with no wait state
                if(vif.ahb_drv_cb.hwrite) begin
                    vif.ahb_drv_cb.hready <= 1; // Because 1 transfer takes 2 cycle to complete in AHB (address + data phase)
                    vif.ahb_drv_cb.hresp  <= 0;
                    @(vif.ahb_drv_cb)
                    vif.ahb_drv_cb.hready <= 1; // we send 2 times ready and response to master
                    vif.ahb_drv_cb.hresp  <= 0;
                    @(vif.ahb_drv_cb);
                end
                else if(vif.ahb_drv_cb.hwrite == 0) begin
                    vif.ahb_drv_cb.hresp  <= 0;
                    @(vif.ahb_drv_cb); // Go to next cycle
                    vif.ahb_drv_cb.hready <= 1; // Here only once bcoz it's read operation and there will be only addr phase incoming no data pahse
                    vif.ahb_drv_cb.hresp  <= 0;
                    vif.ahb_drv_cb.hrdata <= xtn.hrdata; // send the data to master (This is AHB slave - master requested read so we send data to master when master writes we only send hready and hresp to master)
                    @(vif.ahb_drv_cb); // Go to next cycle
                end
            end
            else if(xtn.resp == 1) begin // Okay with wait state
                if(vif.ahb_drv_cb.hwrite) begin
                    vif.ahb_drv_cb.hready <= 1'b0; // to make it behave as wait state
                    vif.ahb_drv_cb.hresp  <= 2'b00; // don't need to send response (as ready is not high anyways but still we can send)
                    repeat(xtn.delay_cycle)
                        @(vif.ahb_drv_cb);

                    //@(vif.ahb_drv_cb);
                    vif.ahb_drv_cb.hready <= 1'b1; // Address phase
                    vif.ahb_drv_cb.hresp  <= 2'b00;
                    @(vif.ahb_drv_cb);
                    vif.ahb_drv_cb.hready <= 1'b1; // Data Phase
                    vif.ahb_drv_cb.hresp  <= 2'b00;

                    @(vif.ahb_drv_cb);
                    vif.ahb_drv_cb.hready <= 1'b0; // again ready 0 to add wait state before moving to next transfer
                end
                else if(vif.ahb_drv_cb.hwrite == 0) begin
                    vif.ahb_drv_cb.hready <= 1'b0; // to make it behave as wait state
                    vif.ahb_drv_cb.hresp  <= 2'b00; // Even if slave ready or not it has to send the response to master (mandetory)
                    repeat(xtn.delay_cycle)
                        @(vif.ahb_drv_cb);

                    //@(vif.ahb_drv_cb);
                    vif.ahb_drv_cb.hready <= 1'b1; // Address phase
                    vif.ahb_drv_cb.hresp  <= 2'b00;
                    vif.ahb_drv_cb.hrdata <= xtn.hrdata;
                    @(vif.ahb_drv_cb); // uncommentned

                    @(vif.ahb_drv_cb);
                    vif.ahb_drv_cb.hready <= 1'b0; // again ready 0 to add wait state before moving to next transfer
                end
            end
            else if(xtn.resp == 2) begin // Error
                if(vif.ahb_drv_cb.hwrite) begin
                    @(vif.ahb_drv_cb) //==========> Why are we moving to next cycle ?

                    if(vif.ahb_drv_cb.htrans == 2'b10) begin // 00 - idle, 01 - busy, 10 - non seq, 11 - seq (Why are we terminating tranfer here ? If there is error even is sequential the transfer should be terminated right ?)
                        vif.ahb_drv_cb.hready <= 1'b0; // Address phase - Terminate the address phase (if error so hready = 0)
                        vif.ahb_drv_cb.hresp  <= 2'b01; // Error response
                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 1'b1; // Ready high - terminate the transfer (if ready not high then error response won't be accepted by master ????? check with sir)
                        vif.ahb_drv_cb.hresp  <= 2'b01; // Error response

                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 0;
                    end

                    else if(vif.ahb_drv_cb.htrans == 2'b11) begin // Why will we accept if sequential (It can also be terminated if error)
                        vif.ahb_drv_cb.hready <= 1'b1; // Address phase
                        vif.ahb_drv_cb.hresp  <= 2'b00; // send okay (we are accepting but why ? ask sir)
                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 1'b1; // Data phase
                        vif.ahb_drv_cb.hresp  <= 2'b00;

                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 1'b0; // Why we ready 0 after accepting data from master ? How to decide when to use this ?
                    end
                end

                else if(vif.ahb_drv_cb.hwrite == 0) begin
                    @(vif.ahb_drv_cb)
                    if(vif.ahb_drv_cb.htrans == 2'b10) begin // 00 - idle, 01 - busy, 10 - non seq, 11 - seq (Why are we terminating tranfer here ? If there is error even is sequential the transfer should be terminated right ?)
                        vif.ahb_drv_cb.hready <= 1'b0; // Address phase - Terminate the address phase (if error so hready = 0)
                        vif.ahb_drv_cb.hresp  <= 2'b01; // Error response
                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 1'b1; // Ready high - terminate the transfer (if ready not high then error response won't be accepted by master ????? check with sir)
                        vif.ahb_drv_cb.hresp  <= 2'b01; // Error response

                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 0;
                    end

                    else if(vif.ahb_drv_cb.htrans == 2'b11) begin // Why will we accept if sequential (It can also be terminated if error)
                        vif.ahb_drv_cb.hready <= 1'b1; // Address phase
                        vif.ahb_drv_cb.hresp  <= 2'b00; // send okay (we are accepting but why ? ask sir)
                        vif.ahb_drv_cb.hresp  <= xtn.hrdata; // send data to master if sequential transfer

                        @(vif.ahb_drv_cb);
                        vif.ahb_drv_cb.hready <= 1'b0; // Why we ready 0 after accepting data from master ? How to decide when to use this ?
                    end
                end
            end
    endtask
endclass
*/
    task send_to_dut(ahb_xtn xtn);

      vif.ahb_drv_cb.hmaster <= 4'b0;  //master code : is this for multiple masters?

      if(xtn.resp == 0)   // okay transaction (hresp : 0 - okay)----> hready high for 2 cc (for the transfer to be done)
        begin

            if(vif.ahb_drv_cb.hwrite == 1'b1)         //write trans - no hrdata
                repeat(2) begin
                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                end

            else if(vif.ahb_drv_cb.hwrite == 1'b0)  //read trans - hrdata  // slave wont be sending hready in read trans so
                begin
                    vif.ahb_drv_cb.hready <= 1'b1; //no need right?
                    vif.ahb_drv_cb.hresp  <= 2'b0;
                    vif.ahb_drv_cb.hrdata <= xtn.hrdata;
                    @(vif.ahb_drv_cb);

                end
        end

    else if(xtn.resp == 1)  // okay with wait states (hresp : 0 -- its still okay state) --> after delay make hready 1
      begin

         if(vif.ahb_drv_cb.hwrite == 1'b1)  // write trans
            begin
                vif.ahb_drv_cb.hready <= 1'b0;

                repeat(xtn.delay_cycle)    //delay
                @(vif.ahb_drv_cb);

                repeat(2) begin
                    vif.ahb_drv_cb.hready <= 1'b1;     //asserted after delay
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                end

                vif.ahb_drv_cb.hready <= 1'b0;
            end

        else if(vif.ahb_drv_cb.hwrite == 1'b0)   //read trans
            begin
                vif.ahb_drv_cb.hready <= 1'b0;

                repeat(xtn.delay_cycle)
                    @(vif.ahb_drv_cb);

                // repeat(2) begin
                vif.ahb_drv_cb.hready <= 1'b1;
                vif.ahb_drv_cb.hresp  <= 2'b0;
                vif.ahb_drv_cb.hrdata <= xtn.hrdata;

                @(vif.ahb_drv_cb);
                vif.ahb_drv_cb.hready <= 1'b1;
                vif.ahb_drv_cb.hresp  <= 2'b0;
                vif.ahb_drv_cb.hrdata <= xtn.hrdata;

                @(vif.ahb_drv_cb);
                // end

                vif.ahb_drv_cb.hready <= 1'b0;
            end
      end
       else if(xtn.resp == 2)
      begin

         if(vif.ahb_drv_cb.hwrite == 1'b1)
            begin
                @(vif.ahb_drv_cb);    //

                if(vif.ahb_drv_cb.htrans == (2'b10))
                    begin
                        vif.ahb_drv_cb.hready <= 1'b0;    // first cc hready should be 0
                        vif.ahb_drv_cb.hresp  <= 2'b01;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b1;  // next cc hready should be 1
                        vif.ahb_drv_cb.hresp  <= 2'b01;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b0;
                    end

                else   // if htrans is not non seq then error response wont be sent
                    begin
                        @(vif.ahb_drv_cb);
                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b1;
                        vif.ahb_drv_cb.hresp  <= 2'b0;

                        @(vif.ahb_drv_cb);

                        vif.ahb_drv_cb.hready <= 1'b0;
                    end

            end

        else if(vif.ahb_drv_cb.hwrite == 1'b0)
         begin
            @(vif.ahb_drv_cb);

            if(vif.ahb_drv_cb.htrans == (2'b10))
                begin
                    vif.ahb_drv_cb.hready <= 1'b0;
                    vif.ahb_drv_cb.hresp  <= 2'b01;

                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b01;

                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b0;
                end

            else
                begin
                    @(vif.ahb_drv_cb);
                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b1;
                    vif.ahb_drv_cb.hresp  <= 2'b0;

                    @(vif.ahb_drv_cb);
                    @(vif.ahb_drv_cb);

                    vif.ahb_drv_cb.hready <= 1'b0;
                end

         end

      end

   endtask

endclass
