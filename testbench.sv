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

interface mem_intf (
    input logic sclk, //spi clock
    input logic iclk, //internal clock
    input logic rstn //external reset
);

    //Simulates the data sitting in the analog registers
    // NOTE*** These were originally marked as "rand logic [49:0] ch0"
    // NOTE*** But vivado didn't understand rand, so they are no longer random, IDK what it really wants
    logic [49:0] ch0;
    logic [49:0] ch1;
    logic [49:0] ch2;
    logic [49:0] ch3;
    logic [49:0] ch4;
    logic [49:0] ch5;
    logic [49:0] ch6;
    logic [49:0] ch7;

    //Holds a variable length array of input messages
    //Gets converted to serial by the driver
        //logic [7:0] input_bytes [];
    //From the output of the DUT
    //Length should be the same as "input_bytes"
    logic [7:0] output_bytes [];
    
    //driver clocking block
    // NOTE*** Dynamic variable types are not allowing in the clocking block, so output_bytes is not a valid output type for this block
    clocking driver_cb @(posedge sclk);
      default input #1 output #1;
      output ch0;
      output ch1;
      output ch2;
      output ch3;
      output ch4;
      output ch5;
      output ch6;
      output ch7;
    endclocking

//monitor clocking block
//NOTE*** Input_bytes is commented out as it's not reccognized curerntly, unsure why
  clocking monitor_cb @(posedge sclk);
    default input #1 output #1;
   //input input_bytes;
    input ch0;
    input ch1;
    input ch2;
    input ch3;
    input ch4;
    input ch5;
    input ch6;
    input ch7;
  endclocking

  //Driver and Monitor Modports
    modport DRIVER (clocking driver_cb, input sclk, input iclk, input rstn);
    modport MONITOR (clocking monitor_cb, input sclk, input iclk, input rstn);


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
    DRIV_IF.ch0 <= 0;
    DRIV_IF.ch1 <= 0;
    DRIV_IF.ch2 <= 0;
    DRIV_IF.ch3 <= 0;
    DRIV_IF.ch4 <= 0;
    DRIV_IF.ch5 <= 0;
    DRIV_IF.ch6 <= 0;
    DRIV_IF.ch7 <= 0;
          
    wait(!mem_vif.reset);
    $display("--------- [DRIVER] Reset Ended---------");
  endtask
  
  //drive the transaction items to interface signals
  task drive;
    forever begin
      transaction trans;
       DRIV_IF.input_bytes <= 0;
       DRIV_IF.output_bytes <= 0;
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      @(posedge mem_vif.DRIVER.clk);
        DRIV_IF.ch0 <= trans.ch0;
        DRIV_IF.ch1 <= trans.ch1;
        DRIV_IF.ch2 <= trans.ch2;
        DRIV_IF.ch3 <= trans.ch3;
        DRIV_IF.ch4 <= trans.ch4;
        DRIV_IF.ch5 <= trans.ch5;
        DRIV_IF.ch6 <= trans.ch6;
        DRIV_IF.ch7 <= trans.ch7;
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

//Environment Class
//`include "transaction.sv"
//`include "generator.sv"
//`include "driver.sv"
class environment;

generator gen;
driver driv;
mailbox gen2driv;

event gen_ended;
virtual mem_intf mem_vif; // Virtual interface


function new(mem_intf);
this.mem_vif = mem_vif; // Getting the interface from the test

gen2driv = new(); // Making new mailbox with shared handle
gen = new(gen_ended); // Creating the generator
driv = new(mem_vif, gen2driv); // Creating the driver
endfunction;


//Creating tasks in order to access generator and driver more easily
task pre_test()
driv.rstn (); // reset function contained in code file, not testbench
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
task run();
    pre_test();
    test();
    post_test();
    $finish ;
endtask


endclass


// This is the code for the acutal test

//`include "environment.sv"
program test(mem_intf intf);
//create enviornment
environment env;

initial begin

  env = new(intf);


// Determines the number of transactions that are being created
env.gen.repeat_count = 10;

//Run it!
env.run();
end

endprogram




// This is the top level of the testbench
// Connects all of this shitty code
//Specifically this connects the DUT and the Testbench


//`include "interface.sv"
//`include "random_test.sv"
module tbench_top ;

//declare clock and reset
reg clk;
bit reset;

always #5 clk = ~clk;

initial begin
  reset = 1;
#5 reset = 0;
end

// Creating an instance of an interface to connect the DUT to the testcase
mem_intf intf(clk,reset);

// Testcase instance, interface handle is the argument here
test t1(intf);

//DUT instance, interface signals are connected to DUT ports

memory DUT(

.clk(intf.clk),
.reset(intf.reset),
.ch0(intf.ch0),
.ch1(intf.ch1),
.ch2(intf.ch2),
.ch3(intf.ch3),
.ch4(intf.ch4),
.ch5(intf.ch5),
.ch6(intf.ch6),
.ch7(intf.ch7),
.output_bytes(intf.output_bytes),
.input_bytes(intf.input_bytes)
);

//Wave dump
initial begin
  $dumpfile("dump.vcd"); $dumpvars;
end
endmodule





















// Here are 2 classes that may be necessary, but I'm not sure of their importance yet, so they will be commented our here until necessary
/*

class monitor;
virtual switch_if vif;
mailbox scb_mbx;
semaphore sema4;


function new();
  sema4 = new(1);
endfunction

task run();
    $display ("T=%0t [Monitor] starting... ", $time);

  fork
    sample_port("Thread0");
    sample_port("Thread1");
  join
endtask

  task sample_port(string tag="");

  forever begin
    @(posedge vif.clk);
      if (if.rstn & vif.vld) begin
        switch_item item = new;
        sema4.get();
        item.ch0 = vid.ch0;
        item.ch1 = vid.ch1;
        item.ch2 = vid.ch2;
        item.ch3 = vid.ch3;
        item.ch4 = vid.ch4;
        item.ch5 = vid.ch5;
        item.ch6 = vid.ch6;
        item.ch7 = vid.ch7;
$display ("T=%0t []Monitor %s First part over", $time, tag);

@(posedge vif.clk);
sema4.put();
item.ch0 = vif.ch0;
item.ch1 = vif.ch1
item.ch2 = vif.ch2;
item.ch3 = vif.ch3;
item.ch4 = vif.ch4;
item.ch5 = vif.ch5;
item.ch6 = vif.ch6;
item.ch7 = vif.ch7;




endclass



class scoreboard

endclass

*/
