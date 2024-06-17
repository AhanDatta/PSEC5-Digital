class scoreboard;

mailbox mon2scb;


  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main();
        transaction trans;
    repeat(1)
    begin
        mon2scb.get(trans);
        $display("Everything went through! We need to include logic here to verify the codes validity tho");
        trans.display("Scoreboard");
    end

  endtask

endclass