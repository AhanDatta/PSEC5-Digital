`timescale 1ns/1ps

module hack_tb();
  //THE FOLLOWING CODE IS A TEMPORARY HACK
  //Want to test some special cases

  //clock for simulation
  logic clk;
  always #25 clk = ~clk; //50 ns clock period

  logic rstn;
  logic iclk;
  logic sclk;
  logic serial_in;
  logic [7:0] load_cnt_ser;
  logic [2:0] select_reg;
  logic [7:0] trigger_channel_mask;
  logic [7:0] instruction;
  logic [7:0] mode;

  //setting all values
  //can change to test if it matters (it shouldn't)
  logic [7:0] tcm_data = 8'h10;
  logic [7:0] instruction_data = 8'b00000010;
  logic [7:0] mode_data = 8'b00000001;

  SPI DUT (
    .sclk (sclk),
    .iclk (iclk),
    .rstn (rstn),
    .serial_in (serial_in),
    .load_cnt_ser (load_cnt_ser),
    .select_reg (select_reg),
    .trigger_channel_mask (trigger_channel_mask),
    .instruction (instruction),
    .mode (mode)
  );


  //external reseting the chip
  task ext_reset ();
    rstn = 0;
    @(posedge clk);
    @(negedge clk);
    rstn = 1;

    $display("External Reset ----------------------------------------------------------------------------------------------------------");
  endtask

  //internal reset from iclk
  task int_reset ();
    sclk = 0;
    for (int i = 0; i < 8; i++) begin
      @(posedge clk);
      iclk = 1;
      @(negedge clk);
      iclk = 0;
    end
    $display("Internal Reset ----------------------------------------------------------------------------------------------------------");
  endtask

//Task to send serial data and read from serial out
task send_serial_data(input [7:0] data);
  for (int j = 7; j >= 0; j--) begin
    serial_in = data[j];
    @(posedge clk); //assumes sclk becomes clk
    sclk = 1;
    @(negedge clk);
    sclk = 0;
  end
endtask

//For dbg
// always @(posedge clk, negedge clk) begin
//   $display(
//     "time: %0d, sclk: %0b, iclk: %0b, rstn: %0b, serial_in: %0b, addr: %0b, load_cnt_ser: %0b, select_reg: %0b, tcm: %0b, inst: %0b, mode: %0b, irstn: %0b, msgi: %0b",
//     $time, sclk, iclk, rstn, serial_in, DUT.mux_control_signal, load_cnt_ser, select_reg, trigger_channel_mask, instruction, mode,
//     DUT.sclk_stop_rstn, DUT.in.msgi);

//   if(clk == 0) begin
//     $display("--------------------------------------------------------------------------------------------------------------------------------------------------");
//   end
// end

initial begin;
  clk = 0;
  iclk = 0;
  rstn = 1;
  #50; //let the reset take effect
  ext_reset(); //setting up chip
  serial_in = 0;

  //Case 1: Writing to special regs
  send_serial_data(8'b00000001); //Set addr to 1 (tcm)
  send_serial_data(tcm_data);
  send_serial_data(instruction_data);
  send_serial_data(mode_data);
  assert(trigger_channel_mask == tcm_data) $display("Writing to trigger channel mask: Passed");
    else $error("Writing to trigger channel mask: Failed");
  assert(instruction == instruction_data) $display("Writing to instruction: Passed");
    else $error("Writing to instruction: Failed");
  assert(mode == mode_data) $display("Writing to mode: Passed");
    else $error("Writing to mode: Failed");

  int_reset();

  //Case 2: Reading from registers 4-59 sequentially
  send_serial_data(8'b00000100); //Set addr to 4 (first read reg)
  for (int i = 4; i <= 59; i++) begin
    //Checking select_reg
    assert(select_reg == (i-4)%7) $display("select_reg on reg %0d: Passed", i);
      else $error("select_reg on reg %0d: Failed", i);

    //Checking load_cnt_ser
    if (i <= 10) begin
      assert(load_cnt_ser == 8'b00000001) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 17) begin
      assert(load_cnt_ser == 8'b00000010) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 24) begin
      assert(load_cnt_ser == 8'b00000100) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 31) begin
      assert(load_cnt_ser == 8'b00001000) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 38) begin
      assert(load_cnt_ser == 8'b00010000) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 45) begin
      assert(load_cnt_ser == 8'b00100000) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 52) begin
      assert(load_cnt_ser == 8'b01000000) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    else if (i <= 59) begin
      assert(load_cnt_ser == 8'b10000000) $display("load_cnt_ser on reg %0d: Passed", i);
        else $error("load_cnt_ser on reg %0d: Failed", i);
    end
    send_serial_data(8'b0);
  end

  $finish;
end

endmodule