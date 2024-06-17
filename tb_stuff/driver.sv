class driver;

  virtual intf vif; //creates virtual interface for communication

  mailbox gen2driv; //creates mailbox to pull information from

    function new(virtual intf vif, mailbox gen2driv); //creating objects of these handles
      this.vif = vif;
      this.gen2driv = gen2driv;
    endfunction



  task main();
    repeat(1)
    begin
        transaction trans;

        gen2driv.get(trans);

        vif.ch0 <= trans.ch0;
        vif.ch1 <= trans.ch1;
        vif.ch2 <= trans.ch2;
        vif.ch3 <= trans.ch3;
        vif.ch4 <= trans.ch4;
        vif.ch5 <= trans.ch5;
        vif.ch6 <= trans.ch6;
        vif.ch7 <= trans.ch7;
        vif.serial_in <= trans.serial_in;


        trans.serial_out = vif.serial_out;

        trans.display("Driver");
    end

  endtask
    
endclass