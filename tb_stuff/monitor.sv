class monitor;

  virtual intf vif;

  mailbox mon2scb;

    function new(virtual intf vif, mailbox mon2scb);
      this.vif = vif;
      this.mon2sbc = mon2scb;

    endfunction



    task main();
      repeat (1)
        #5;
      begin
        transaction trans;
        trans = new();
        
        trans.ch0 = vif.ch0;
        trans.ch1 = vif.ch1;
        trans.ch2 = vif.ch2;
        trans.ch3 = vif.ch3;
        trans.ch4 = vif.ch4;
        trans.ch5 = vif.ch5;
        trans.ch6 = vif.ch6;
        trans.ch7 = vif.ch7;
        trans.serial_in = vif.serial_in;
        trans.serial_out = vif.serial_out;

        mon2scb.put(trans);
        trans.display("Monitor");
      end

    endtask

endclass