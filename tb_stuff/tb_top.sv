`include "interface.sv"
`include "test.sv"

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
