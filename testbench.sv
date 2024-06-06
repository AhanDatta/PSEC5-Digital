//Define what is input and output for DUT
class transaction;

    //Simulates the data sitting in the analog registers
    rand logic [49:0] ch0;
    rand logic [49:0] ch1;
    rand logic [49:0] ch2;
    rand logic [49:0] ch3;
    rand logic [49:0] ch4;
    rand logic [49:0] ch5;
    rand logic [49:0] ch6;
    rand logic [49:0] ch7;

    //Holds a variable length array of input messages
    //Gets converted to serial by the driver
    logic [7:0] input_bytes [];
    //From the output of the DUT
    //Length should be the same as "input_bytes"
    logic [7:0] output_bytes [];

endclass

class generator;

    rand transaction trans;

    //object which will sent transaction to driver
    mailbox gen2driv;

    //event to signify end of transaction generation
    event ended; 

    //repeat count for testing
    int repeat_count;

    function  new (mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    //main task, generates(create and randomizes) the packets and puts into mailbox
    task main();
        repeat (repeat_count) begin
            trans = new();
            if( !trans.randomize() ) $fatal("Gen:: trans randomization failed"); 
            gen2driv.put(trans);
        end
        -> ended; //end of generation
  endtask

endclass

