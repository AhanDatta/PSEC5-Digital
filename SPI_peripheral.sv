\ include "PICO.sv"
\ include "POCI.sv"

//This is the full digital SPI communication section
module SPI (
    input logic serial_in,
    input logic sclk,
    input logic iclk, //internal clock 
    input logic rstn, //external reset
    input logic [7:0] reg4, reg5, reg6, reg7, reg8, reg9, //we designate reg 1-3 as special w/r
    input logic [7:0] reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, //all else are read only
    input logic [7:0] reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29,
    input logic [7:0] reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39,
    input logic [7:0] reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49,
    input logic [7:0] reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59,
    output logic serial_out
);

    logic sclk_stop_rstn;
    logic [7:0] write_data;
    logic [7:0] mux_control_signal;
    wire full_rstn = rstn && sclk_stop_rstn;

    PICO in (
        .serial_in (serial_in), 
        .sclk (sclk), 
        .iclk (iclk), 
        .rstn (rstn), 
        .sclk_stop_rstn (sclk_stop_rstn), 
        .write_data (write_data), 
        .mux_control_signal (mux_control_signal)
    );

    POCI out (
        .rstn (sclk), .sclk (sclk), .control_signal (mux_control_signal), .write_data (write_data),
        .reg4 (reg4), .reg5 (reg5), .reg6 (reg6), .reg7 (reg7), .reg8 (reg8), .reg9 (reg9), .reg10 (reg10),
		.reg11 (reg11), .reg12 (reg12), .reg13 (reg13), .reg14 (reg14), .reg15 (reg15), .reg16 (reg16), .reg17 (reg17),
		.reg18 (reg18), .reg19 (reg19), .reg20 (reg20), .reg21 (reg21), .reg22 (reg22), .reg23 (reg23), .reg24 (reg24),
		.reg25 (reg25), .reg26 (reg26), .reg27 (reg27), .reg28 (reg28), .reg29 (reg29), .reg30 (reg30), .reg31 (reg31),
		.reg32 (reg32), .reg33 (reg33), .reg34 (reg34), .reg35 (reg35), .reg36 (reg36), .reg37 (reg37), .reg38 (reg38),
		.reg39 (reg39), .reg40 (reg40), .reg41 (reg41), .reg42 (reg42), .reg43 (reg43), .reg44 (reg44), .reg45 (reg45),
		.reg46 (reg46), .reg47 (reg47), .reg48 (reg48), .reg49 (reg49), .reg50 (reg50), .reg51 (reg51), .reg52 (reg52),
		.reg53 (reg53), .reg54 (reg54), .reg55 (reg55), .reg56 (reg56), .reg57 (reg57), .reg58 (reg58), .reg59 (reg59),
        .serial_out (serial_out)
    );

endmodule

