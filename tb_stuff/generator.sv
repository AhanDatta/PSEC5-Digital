class generator;

transaction trans; //transaction class handle

mailbox gen2driv; //Mailbox that will be used to transport packets from generator to dirver class


// This function takes in outside mailbox information, and assigns it to this classes mailbox
  function new (mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction

  task main();

    repeat(1) //Determines the # of packets that will be generated
      begin
        trans = new();                //Creates object of transaction class
        trans.randomize;              //Randomizes a new packet
        trans.display("Generator");   //For checking purposes, displays the packet information
        gen2driv.put(trans);          //puts the new packet into the mailbox
      end

  endtask

endclass