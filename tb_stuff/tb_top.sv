`include "interface.sv"
`include "test.sv"
`timescale 1ps/1ps

module tbench_top;

    //clock for simulation
    logic clk;
    always #10 clk = ~clk;

    intf i_intf(clk);
    test t1(i_intf);

    test_SPI spi_1(
      .sclk (i_intf.sclk),
      .iclk (i_intf.iclk),
      .rstn (i_intf.rstn),
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
      //NEED TO ADD REST HERE
      $dumpfile("dump.vcd"); $dumpvars;
    end
  
endmodule
