module SPI_and_mux (
    input logic serial_in,
    input logic sclk,
    input logic [7:0] pll_locked, //address 60
    input logic iclk, //internal clock 
    input logic rstn, //external reset
    input logic [7:0] raw_serial_out,
    output logic clk_enable, //1: START; 0: else; HELD
    output logic inst_rst, // instr == 1
    output logic inst_readout, //instr == 2
    output logic inst_start, //instr == 3
    output logic [2:0] select_reg,
    output logic [7:0] trigger_channel_mask, //address 1
    output logic [7:0] mode, //address 3 
    output logic [7:0] disc_polarity, //address 61
    output logic [7:0] vco_control, //address 62
    output logic [7:0] pll_div_ratio, //address 63
    output logic [7:0] slow_mode, //address 64
    output logic [7:0] trig_delay, //address 65 
    output logic serial_out 
);

    logic [7:0] load_cnt_ser;
    logic wr_serial_out;

    SPI spi (
        .rstn (rstn),
        .serial_in (serial_in),
        .sclk (sclk),
        .pll_locked (pll_locked),
        .iclk (iclk),
        .inst_rst (inst_rst),
        .inst_readout (inst_readout),
        .inst_start (inst_start),
        .load_cnt_ser (load_cnt_ser),
        .select_reg (select_reg),
        .trigger_channel_mask (trigger_channel_mask),
        .mode (mode),
        .disc_polarity (disc_polarity),
        .vco_control (vco_control),
        .pll_div_ratio (pll_div_ratio),
        .slow_mode (slow_mode),
        .trig_delay (trig_delay),
        .serial_out (wr_serial_out),
        .clk_enable (clk_enable)
    );

    serial_out_mux out (
        .sclk (sclk),
        .raw_serial_out (raw_serial_out),
        .wr_serial_out (wr_serial_out),
        .load_cnt_ser (load_cnt_ser),
        .serial_out (serial_out)
    );

endmodule