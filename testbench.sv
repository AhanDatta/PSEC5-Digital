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

interface intf (
    input logic sclk, //spi clock
    input logic iclk, //internal clock
    input logic rstn, //external reset
);

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
    
endinterface








//______________


// This is the generator class which is used to generate a random number
// of transactions with random adresses and data whih can be driven
/*class generator;

    rand transaction trans;

//declaring the mailbox
    mailbox dirve_mbx;
int num = 20; // Declares how many packets to be created
event drv_done; // Eevent to signify ending of generation process


    function new(mailbox drive_mbx);
this.drive_mbx = drive_mbx;
this.drv_done = drv_done;
    endfunction



    task main();

        repeat(num) begin

            trans = new();
            if (!trans.randomize() )
                drive_mbx.put(item);
        end
            item.randomize();
            
          -> drv_done;

    endtask
endclass
*/

// This class takes the transactions that are ready and drives them to the DUT
// So they can then do what they need to do

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual mem_intf mem_vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual mem_intf mem_vif,mailbox gen2driv);
    //getting the interface
    this.mem_vif = mem_vif;
    //getting the mailbox handle from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(mem_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.ch0 <= 0;
    `DRIV_IF.ch1 <= 0;
    `DRIV_IF.ch2 <= 0;
    `DRIV_IF.ch3 <= 0;
    `DRIV_IF.ch4 <= 0;
    `DRIV_IF.ch5 <= 0;
    `DRIV_IF.ch6 <= 0;
    `DRIV_IF.ch7 <= 0;
          
    wait(!mem_vif.reset);
    $display("--------- [DRIVER] Reset Ended---------");
  endtask
  
  //drive the transaction items to interface signals
  task drive;
    forever begin
      transaction trans;
      `DRIV_IF.input_bytes <= 0;
      `DRIV_IF.output_bytes <= 0;
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      @(posedge mem_vif.DRIVER.clk);
        `DRIV_IF.ch0 <= trans.ch0;
        `DRIV_IF.ch1 <= trans.ch1;
        `DRIV_IF.ch2 <= trans.ch2;
        `DRIV_IF.ch3 <= trans.ch3;
        `DRIV_IF.ch4 <= trans.ch4;
        `DRIV_IF.ch5 <= trans.ch5;
        `DRIV_IF.ch6 <= trans.ch6;
        `DRIV_IF.ch7 <= trans.ch7;
     /* if(trans.input_bytes) begin
        `DRIV_IF.input_bytes <= trans.input_bytes;
        $display("\tADDR = %0h \tWDATA = %0h",trans.ch0,trans.ch1, trans.ch2,  trans.ch3,  trans.ch4,  trans.ch5,  trans.ch6,  trans.ch7,);
        @(posedge mem_vif.DRIVER.clk);
      end
      if(trans.rd_en) begin
        `DRIV_IF.rd_en <= trans.rd_en;
        @(posedge mem_vif.DRIVER.clk);
        `DRIV_IF.rd_en <= 0;
        @(posedge mem_vif.DRIVER.clk);
        trans.rdata = `DRIV_IF.rdata;
        $display("\tADDR = %0h \tRDATA = %0h",trans.addr,`DRIV_IF.rdata);
      end
      */
      $display("-----------------------------------------");
      no_transactions++;
    end
  endtask
         
endclass







//monitor class
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
class environment;

generator gen;
driver driv;
mailbox gen2driv;

event gen_ended;
virtual mem_intf, mem_vif; // Virtual interface


function new(virtual mem_intf, mem_vif);
this.mem_vif = mem_vif; // Getting the interface from the test

gen2driv = new(); // Making new mailbox with shared handle
gen = new(gen2driv, gen_ended); // Creating the generator
driv = new(mem_vif, gen2driv); // Creating the driver
endfunction;


//Creating tasks in order to access generator and driver more easily
task pre_test()
driv.reset();
endtask

task test();
    fork 
        gen.main();
        driv.main();
    join_any
endtask

task post_test();
    wait(gen_ended.triggered);
    wait(gen.reoeat_count == driv.no_transactions);
endtask

// Run everything
task run;
    pre_test();
    test();
    post_test()
    $finish
endtask


endclass
