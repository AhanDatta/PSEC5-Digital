//New and Improved Testbench

//Transaction class, AKA: Packet class
//Contains all of the information of each "packet" that will be tested and verified with the rest of the code
<<<<<<< HEAD
=======
class transaction;

//These are the inputs to our design:
  rand logic [49:0] ch0;  
  rand logic [49:0] ch1;
  rand logic [49:0] ch2;
  rand logic [49:0] ch3;
  rand logic [49:0] ch4;
  rand logic [49:0] ch5;
  rand logic [49:0] ch6;
  rand logic [49:0] ch7;
  rand logic serial_in;
  logic serial_out;

  function void display(string tag);
    $display ("----------------");
    $display ("tag= %s", tag);
    $display ("----------------");
    $display ("ch 0 = %0d, ch 1 = %0d, ch 2 = %0d, ch 3 = %0d, ch 4 = %0d, ch 5 = %0d, ch 6 = %0d, ch 7 = %0d, ", ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7);
    $display ("serial_in = %0d, serial_out = %0d", serial_in, serial_out);

  endfunction

endclass 


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




// Interface with DUT to the rest of the system, includes all inputs and outputs
interface intf(input logic clk);

  logic rstn;
  logic iclk;
  logic ch0;
  logic ch1;
  logic ch2;
  logic ch3;
  logic ch4;
  logic ch5;
  logic ch6;
  logic ch7;
  logic serial_in;
  logic serial_out;

//***NEED TO INCLUDE CLOCKING BLOCKS AND MODPORTS!!!


endinterface






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



class environment; 
  
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;

  mailbox m1;
  mailbox m2;

  virtual intf vif;

  function new(virtual intf vif);
  this.vif = vif;
    m1 = new();
    m2 = new();
    gen = new(m1);
    driv = new(vif,m1);
    mon = new(vif,m2);
    scb = new(m2);
  endfunction

  task test();
    fork

      gen.main();
      driv.main();
      mon.main();
      scb.main();

    join
  endtask


  task run();
    test();
    $finish;
  endtask

endclass





program test(intf i_intf);

  environment env;

    initial 
    begin
      env = new(i_intf);
      env.run();
    end

endprogram


module tbench_top;

    intf i_intf;
    test t1(i_intf);

    SPI spi_1(
      .ch0(i_intf.ch0),
      .ch1(i_intf.ch1),
      .ch2(i_intf.ch2),
      .ch3(i_intf.ch3),
      .ch4(i_intf.ch4),
      .ch5(i_intf.ch5),
      .ch6(i_intf.ch6),
      .ch7(i_intf.ch7),
      .serial_in(i_intf.serial_in),
      .serial_out(i_intf.serial_out)
    );


    initial begin;
    $dumpfile("dump.vcd"); $dumpvars;
    end
  
endmodule















































































































































































//OLD TB
/*

//Define what is input and output for DUT
>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9
class transaction;

//These are the inputs to our design:
  rand logic [49:0] ch0;  
  rand logic [49:0] ch1;
  rand logic [49:0] ch2;
  rand logic [49:0] ch3;
  rand logic [49:0] ch4;
  rand logic [49:0] ch5;
  rand logic [49:0] ch6;
  rand logic [49:0] ch7;
  rand logic serial_in;
  logic serial_out;

<<<<<<< HEAD
  function void display(string tag);
    $display ("----------------");
    $display ("tag= %s", tag);
    $display ("----------------");
    $display ("ch 0 = %0d, ch 1 = %0d, ch 2 = %0d, ch 3 = %0d, ch 4 = %0d, ch 5 = %0d, ch 6 = %0d, ch 7 = %0d, ", ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7);
    $display ("serial_in = %0d, serial_out = %0d", serial_in, serial_out);

  endfunction

endclass 
=======

    //Holds a variable length array of input messages
    //Gets converted to serial by the driver
    logic [7:0] input_bytes [];
    //From the output of the DUT
    //Length should be the same as "input_bytes"
    logic [7:0] output_bytes [];
>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9


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

<<<<<<< HEAD



// Interface with DUT to the rest of the system, includes all inputs and outputs
interface intf(input logic clk);

  logic rstn;
  logic iclk;
  logic ch0;
  logic ch1;
  logic ch2;
  logic ch3;
  logic ch4;
  logic ch5;
  logic ch6;
  logic ch7;
  logic serial_in;
  logic serial_out;

//***NEED TO INCLUDE CLOCKING BLOCKS AND MODPORTS!!!


endinterface






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



class monitor;

  virtual intf vif;

  mailbox mon2scb;

    function new(virtual intf vif, mailbox mon2scb);
      this.vif = vif;
      this.mon2sbc = mon2scb;

=======
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
>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9
    endfunction



    task main();
<<<<<<< HEAD
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



class environment; 
  
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;

  mailbox m1;
  mailbox m2;

  virtual intf vif;

  function new(virtual intf vif);
  this.vif = vif;
    m1 = new();
    m2 = new();
    gen = new(m1);
    driv = new(vif,m1);
    mon = new(vif,m2);
    scb = new(m2);
  endfunction

  task test();
    fork

      gen.main();
      driv.main();
      mon.main();
      scb.main();

    join
  endtask


  task run();
    test();
    $finish;
  endtask
=======

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


//OLD TB
/*


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

    //OLD TB
    /*
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

>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9

endclass


<<<<<<< HEAD



program test(intf i_intf);

  environment env;

    initial 
    begin
      env = new(i_intf);
      env.run();
    end
=======
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
>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9

endprogram


<<<<<<< HEAD
module tbench_top;

    intf i_intf;
    test t1(i_intf);

    SPI spi_1(
      .ch0(i_intf.ch0),
      .ch1(i_intf.ch1),
      .ch2(i_intf.ch2),
      .ch3(i_intf.ch3),
      .ch4(i_intf.ch4),
      .ch5(i_intf.ch5),
      .ch6(i_intf.ch6),
      .ch7(i_intf.ch7),
      .serial_in(i_intf.serial_in),
      .serial_out(i_intf.serial_out)
    );


    initial begin;
    $dumpfile("dump.vcd"); $dumpvars;
    end
  
endmodule
=======


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

>>>>>>> 196c796d45a5e3251feb8915183ba6852ce394a9
