`timescale 1ps/1ps

module hack_tb();
  //THE FOLLOWING CODE IS A TEMPORARY HACK
  //Want to test some special cases

  //clock for simulation
  logic clk;
  always #10 clk = ~clk;

  logic rstn;
  logic iclk;
  logic sclk;
  logic [49:0] ch0;
  logic [49:0] ch1;
  logic [49:0] ch2;
  logic [49:0] ch3;
  logic [49:0] ch4;
  logic [49:0] ch5;
  logic [49:0] ch6;
  logic [49:0] ch7;
  logic serial_in;
  logic serial_out;

  SPI spi_1 (
    .sclk (sclk),
    .iclk (iclk),
    .rstn (rstn),
    .ch0 (ch0),
    .ch1 (ch1),
    .ch2 (ch2),
    .ch3 (ch3),
    .ch4 (ch4),
    .ch5 (ch5),
    .ch6 (ch6),
    .ch7 (ch7),
    .serial_in (serial_in),
    .serial_out (serial_out)
  );

  //external reseting the chip
  task ext_reset ();
    rstn = 0;
    @(posedge clk);
    @(negedge clk);
    rstn = 1;
  endtask

  //internal reset from iclk
  task int_reset ();
    i_intf.sclk = 0;
    for (int i = 0; i < 8; i++) begin
      @(posedge clk);
      i_intf.iclk = 1;
      @(negedge clk);
      i_intf.iclk = 0;
    end
  endtask

//Task to send serial data
task send_serial_data(input [7:0] data, input integer num_bytes, output [7:0] read_data);
  for (int i = 0; i < num_bytes; i++) begin
    for (int j = 0; j < 8; j++) begin
      serial_in = data[j];
      @(posedge clk); //assumes sclk becomes clk
      sclk = 1;
      read_data[j] = serial_out;
      @(negedge clk);
      sclk = 0;
    end
  end
endtask

initial begin;
  clk = 0;
  ext_reset();
  logic [7:0] last_read_byte;

  //setting all values
  //can change to test if it matters (it shouldn't)
  logic [7:0] tcm_data = 8'h10;
  logic [7:0] instruction_data = 8'h20;
  logic [7:0] mode_data = 8'h30;
  ch0 = 50'h2D2D2D2D2D2D3; //10 11010010 11010010 11010010 11010010 11010010 11010011
  ch1 = 50'h331CC731CC731; //11 00110001 11001100 01110011 00011100 11000111 00110001
  ch2 = 50'h0; //00 00000000 00000000 00000000 00000000 00000000 00000000
  ch3 = 50'h3FFFFFFFFFFFF; //11 11111111 11111111 11111111 11111111 11111111 11111111
  ch4 = 50'h1FC24FD9A361F; //01 11111100 00100100 11111101 10011010 00110110 00011111
  ch5 = 50'h368B1FD2849DE; //11 01101000 10110001 11111101 00101000 01001001 11011110
  ch6 = 50'h8A62B251A880; //00 10001010 01100010 10110010 01010001 10101000 10000000
  ch7 = 50'hE2E112A26C51; //00 11100010 11100001 00010010 10100010 01101100 01010001

  //Case 1: Writing to registers
  send_serial_data(8'h01, 1, last_read_byte); //set address pointer to 1
  send_serial_data(tcm_data, 1, last_read_byte); //write 0x10 to trigger_channel_mask
  send_serial_data(instruction_data, 1, last_read_byte); //write 0x20 to instruction
  send_serial_data(mode_data, 1, last_read_byte); //write 0x30 to mode
  int_reset(); //resets address pointer

  send_serial_data(8'h01, 1, last_read_byte); //sets address pointer to 1
  send_serial_data(tcm_data, 1, last_read_byte); //write 0x10 to trigger_channel_mask
  assert(tcm_data == last_read_byte);
  send_serial_data(instruction_data, 1, last_read_byte); //write 0x20 to instruction
  assert(instruction_data == last_read_byte);
  send_serial_data(mode_data, 1, last_read_byte); //write 0x30 to mode
  assert(mode_data == last_read_byte);

  int_reset(); //resets address pointer

  //Case 2: Reading from read only registers
  send_serial_data(8'h04, 1, last_read_byte); //set address pointer to 4

  //ch0
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch0[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch0[49:48]});

  //ch1
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch1[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch1[49:48]});

  //ch2
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch2[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch2[49:48]});

  //ch3
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch3[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch3[49:48]});

  //ch4
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch4[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch4[49:48]});

  //ch5
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch5[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch5[49:48]});

  //ch6
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch6[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch6[49:48]});

  //ch7
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[7:0]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[15:8]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[23:16]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[31:24]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[39:32]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == ch7[47:40]);
  send_serial_data(8'h0, 1, last_read_byte);
  assert(last_read_byte == {6'b0, ch7[49:48]});

  int_reset(); //resets address pointer

  //Case 3: Invalid address
  send_serial_data(8'h60, 1, last_read_byte); //set address pointer to 60 (invalid)
  send_serial_data(8'h0, 1, last_read_byte); //reads out what's there
  assert(last_read_byte === 8'bX); //read should return garbage

  $finish;
end

endmodule