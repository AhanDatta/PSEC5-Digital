//New and Improved Testbench

//Transaction class, AKA: Packet class
//Contains all of the information of each "packet" that will be tested and verified with the rest of the code
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
