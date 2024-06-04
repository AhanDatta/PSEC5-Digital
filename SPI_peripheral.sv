\ include "PICO.sv"
\ include "POCI.sv"

module SPI (
    input logic serial_in,
    input logic sclk,
    input logic iclk, //internal clock 
    input logic rstn, //external reset
    output logic serial_out
);

endmodule