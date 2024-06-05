\ include "PICO.sv"
\ include "POCI.sv"

module SPI (
    input logic serial_in,
    input logic sclk,
    input logic iclk, //internal clock 
    input logic rstn, //external reset
    output logic serial_out
);

    logic sclk_stop_rstn;
    logic [7:0] write_data;
    logic [7:0] mux_control_signal;
    wire full_rstn = rstn && sclk_stop_rstn;

    PICO input (
        .serial_in (serial_in), 
        .sclk (sclk), 
        .iclk (iclk), 
        .rstn (rstn), 
        .sclk_stop_rstn (sclk_stop_rstn), 
        .write_data (write_data), 
        .mux_control_signal (mux_control_signal)
    );


endmodule