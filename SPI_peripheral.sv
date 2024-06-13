//Special registers 1-3 for trigger_ch_mask, instruction, mode
module latched_write_reg (
    input logic rstn,
    input logic [7:0] data,
    input logic latch_en,
    output logic [7:0] stored_data
);
    always_latch begin
        if (!rstn) begin
            stored_data = '0;
        end
        else if (latch_en) begin
            stored_data = data;
        end
    end
endmodule

//Controls the latch for the three special regs based on address
//Synchronous mux here to stop a double write issue
//caused by address pointer incrementing too fast
module input_mux (
    input logic rstn,
    input logic [7:0] addr,
    input logic sclk, 
    output logic [2:0] latch_signal //carries the latch signal to the correct reg based on address
);
    always_ff @(posedge sclk or negedge rstn) begin
        if (!rstn) begin
            latch_signal <= '0;
        end
        else begin
            unique case (addr)
                8'd1: latch_signal <= 3'b001;
                8'd2: latch_signal <= 3'b010;
                8'd3: latch_signal <= 3'b100;
                default: latch_signal <= 3'b000;
            endcase
        end
    end
endmodule

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
    logic [2:0] input_mux_latch_sgnl; 
    logic full_rstn = rstn && sclk_stop_rstn;

    //data in the special registers 
    logic [7:0] trigger_channel_mask; //address 1
    logic [7:0] instruction; //address 2
    logic [7:0] mode; //address 3

    //instantiating the special w/r registers
    latched_write_reg trigger_ch_mask_reg (.rstn (full_rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[0]), .stored_data (trigger_channel_mask));
    latched_write_reg instruction_reg (.rstn (full_rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[1]), .stored_data (instruction));
    latched_write_reg mode_reg (.rstn (full_rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[2]), .stored_data (mode));

    input_mux write_mux (.rstn (full_rstn), .sclk (sclk), .addr (mux_control_signal), .latch_signal (input_mux_latch_sgnl));

    PICO in (
        .serial_in (serial_in), 
        .sclk (sclk), 
        .iclk (iclk), 
        .rstn (rstn), //full rstn is computed inside PICO
        .sclk_stop_rstn (sclk_stop_rstn), 
        .write_data (write_data), 
        .mux_control_signal (mux_control_signal)
    );

    POCI out (
        .rstn (full_rstn), .sclk (sclk), .control_signal (mux_control_signal), .trigger_channel_mask (trigger_channel_mask), .instruction (instruction), .mode (mode),
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