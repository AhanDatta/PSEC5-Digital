`timescale 1ns/1ps

module hack_tb();
  //THE FOLLOWING CODE IS A TEMPORARY HACK
  //Want to test some special cases

  //clock for simulation
  logic clk;
  logic dbg_readout;
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
  logic [7:0] disc_polarity;
  logic [7:0] vco_control;
  logic [7:0] pll_div_ratio;
  logic [7:0] slow_mode;
  logic [7:0] trig_delay;
  logic serial_out;

  //setting all values
  //can change to test if it matters (it shouldn't)
  logic [7:0] tcm_data = 8'b0010_1001;
  logic [7:0] instruction_data = 8'b0000_0110;
  logic [7:0] mode_data = 8'b0000_0100;
  logic [7:0] disc_polarity_data = 8'b1010_1001;
  logic [7:0] vco_control_data = 8'b0011_0110;
  logic [7:0] pll_div_ratio_data = 8'b0000_0111;
  logic [7:0] slow_mode_data = 8'b0000_0000;
  logic [7:0] trig_delay_data = 8'b0000_0001;
  logic [7:0] pll_locked = 8'b0000_0001;
  logic [7:0] read_data;

  SPI DUT (
    .sclk (sclk),
    .iclk (iclk),
    .rstn (rstn),
    .serial_in (serial_in),
    .pll_locked (pll_locked),
    .load_cnt_ser (load_cnt_ser),
    .select_reg (select_reg),
    .trigger_channel_mask (trigger_channel_mask),
    .instruction (instruction),
    .mode (mode),
    .disc_polarity (disc_polarity),
    .vco_control (vco_control),
    .pll_div_ratio (pll_div_ratio),
    .slow_mode (slow_mode),
    .trig_delay (trig_delay),
    .serial_out (serial_out)
  );


  //external reseting the chip
  task ext_reset ();
    rstn = 0;
    @(posedge clk);
    @(negedge clk);
    rstn = 1;

    $display("External Reset -------------------------------------------------------------------------------------------------------------------------");
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
    $display("Internal Reset --------------------------------------------------------------------------------------------------------------------------");
  endtask

//Task to send serial data and read from serial out
task send_serial_data(input [7:0] data, output [7:0] read_data);
  for (int j = 7; j >= 0; j--) begin
    serial_in = data[j];
    @(posedge clk); //assumes sclk becomes clk
    sclk = 1;
    @(negedge clk);
    sclk = 0;
    read_data[7-j] = serial_out;
  end
endtask

//For dbg
always @(posedge clk, negedge clk) begin
  if (dbg_readout) begin
    $display(
      "time: %0d, sclk: %0b, iclk: %0b, rstn: %0b, serial_in: %0b, addr: %0b, load_cnt_ser: %0b, select_reg: %0b, tcm: %0b, inst: %0b, mode: %0b, irstn: %0b, msgi: %0b, serial_out: %0b, readout: %0b",
      $time, sclk, iclk, rstn, serial_in, DUT.mux_control_signal, load_cnt_ser, select_reg, trigger_channel_mask, instruction, mode,
      DUT.sclk_stop_rstn, DUT.in.msgi, serial_out, read_data);

    if(clk == 0) begin
      $display("--------------------------------------------------------------------------------------------------------------------------------------------------");
    end
  end
end

initial begin;
  //Select if verbose readout
  dbg_readout = 0;

  clk = 0;
  iclk = 0;
  rstn = 1;
  #50; //let the reset take effect
  ext_reset(); //setting up chip
  serial_in = 0;

  //Case 1: Writing to regs 1-3
  send_serial_data(8'b00000001, read_data); //Set addr to 1 (tcm)
  send_serial_data(tcm_data, read_data);
  send_serial_data(instruction_data, read_data);
  send_serial_data(mode_data, read_data);
  assert(trigger_channel_mask == tcm_data) $display("Writing to trigger channel mask: Passed");
    else $error("Writing to trigger channel mask: Failed");
  assert(instruction == instruction_data) $display("Writing to instruction: Passed");
    else $error("Writing to instruction: Failed");
  assert(mode == mode_data) $display("Writing to mode: Passed");
    else $error("Writing to mode: Failed");

  int_reset();

  //Case 2: Reading from registers 4-60 sequentially
  send_serial_data(8'b00000100, read_data); //Set addr to 4 (first read reg)
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
    send_serial_data(8'b0, read_data);
  end
  send_serial_data(8'b0, read_data);
  assert(read_data == pll_locked) $display("reading register 60: Passed");
    else $error("reading register 60: Failed");

  int_reset();

  //Case 3: Writing to regs 61-65
  send_serial_data(8'd61, read_data); //Set addr to 61
  send_serial_data(disc_polarity_data, read_data);
  send_serial_data(vco_control_data, read_data);
  send_serial_data(pll_div_ratio_data, read_data);
  send_serial_data(slow_mode_data, read_data);
  send_serial_data(trig_delay_data, read_data);
  assert(disc_polarity == disc_polarity_data) $display("Writing to discriminator polarity: Passed");
    else $error("Writing to discriminator polarity: Failed");
  assert(vco_control == vco_control_data) $display("Writing to VCO digital dand: Passed");
    else $error("Writing to VCO digital band: Failed");
  assert(pll_div_ratio == pll_div_ratio_data) $display("Writing to PLL division ratio: Passed");
    else $error("Writing to PLL division ratio: Failed");
  assert(slow_mode == slow_mode_data) $display("Writing to slow mode: Passed");
    else $error("Writing to slow mode: Failed");
    assert(trig_delay == trig_delay_data) $display("Writing to trigger delay: Passed");
    else $error("Writing to trigger delay: Failed");

  int_reset();

  //Case 4: Reading from regs 1-3
  send_serial_data(8'b00000001, read_data); //Set addr to 1 (tcm)
  send_serial_data(8'b0, read_data);
  assert(read_data == tcm_data) $display("Reading from trigger channel mask: Passed");
    else $error("Reading from trigger channel mask: Failed");
  send_serial_data(8'b0, read_data);
  assert(read_data == instruction_data) $display("Reading from instruction: Passed");
    else $error("Reading from instruction: Failed");
  send_serial_data(8'b0, read_data);
  assert(read_data == mode_data) $display("Reading from mode: Passed");
    else $error("Reading from mode: Failed");

  int_reset();

  //Case 5: Invalid Address
  for(int i = 60; i <= 255; i++) begin
    send_serial_data(i, read_data); //Setting invalid address
    assert(load_cnt_ser == 8'b0) $display("load_cnt_ser on reg %0d: Passed", i);
      else $display("load_cnt_ser on red %0d: Failed", i);
    assert(select_reg == 3'b111) $display("select_reg on reg %0d: Passed", i);
      else $error("select_reg on reg %0d: Failed", i);

    int_reset();
  end

  $finish;
end

endmodule