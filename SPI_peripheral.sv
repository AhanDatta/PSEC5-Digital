//This file rolls up the whole SPI Peripheral 
//Serial data is sent into PICO
//packaged data comes out, and is used to read and write.
//The writing logic is handled in this file under SPI using standard latched regs
//The read logic is handled by the POCI block. 

//Special registers 1-3 for trigger_ch_mask, instruction, mode
//also to hold data for serial_out
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

//Converts mux_control_signal into correct load_cnt_ser flag for analog reg
//Also sets select_reg to read the correct byte from the chosen analog reg
module convert_addr (
    input logic rstn,
    input logic [7:0] mux_control_signal,
    output logic [7:0] load_cnt_ser,
    output logic [2:0] select_reg
);
    always_comb begin
        if (!rstn) begin
            load_cnt_ser = 8'b0;
            select_reg = 3'b0;
        end
        else begin
            //Setting load_cnt_ser flag with LUT
            if (mux_control_signal <= 3) begin //address sent to W reg
                load_cnt_ser = 8'b0;
            end
            else if (mux_control_signal <= 10) begin
                load_cnt_ser = 8'b00000001;
            end
            else if (mux_control_signal <= 17) begin
                load_cnt_ser = 8'b00000010;
            end
            else if (mux_control_signal <= 24) begin
                load_cnt_ser = 8'b00000100;
            end
            else if (mux_control_signal <= 31) begin
                load_cnt_ser = 8'b00001000;
            end
            else if (mux_control_signal <= 38) begin
                load_cnt_ser = 8'b00010000;
            end
            else if (mux_control_signal <= 45) begin
                load_cnt_ser = 8'b00100000;
            end
            else if (mux_control_signal <= 52) begin
                load_cnt_ser = 8'b01000000;
            end
            else if (mux_control_signal <= 59) begin
                load_cnt_ser = 8'b10000000;
            end
            else begin //invalid address case
                load_cnt_ser = 8'b0;
            end

            //Sets select_reg with LUT
            //Uses formula select_reg = (mux_control_signal - 4) % 7
            //111 default because load_reg = 7 is default in psec5_digital_april2024.sv
            unique case (mux_control_signal)
                8'b00000000: select_reg = 3'b111;
                8'b00000001: select_reg = 3'b111;
                8'b00000010: select_reg = 3'b111;
                8'b00000011: select_reg = 3'b111;
                8'b00000100: select_reg = 3'b000;
                8'b00000101: select_reg = 3'b001;
                8'b00000110: select_reg = 3'b010;
                8'b00000111: select_reg = 3'b011;
                8'b00001000: select_reg = 3'b100;
                8'b00001001: select_reg = 3'b101;
                8'b00001010: select_reg = 3'b110;
                8'b00001011: select_reg = 3'b000;
                8'b00001100: select_reg = 3'b001;
                8'b00001101: select_reg = 3'b010;
                8'b00001110: select_reg = 3'b011;
                8'b00001111: select_reg = 3'b100;
                8'b00010000: select_reg = 3'b101;
                8'b00010001: select_reg = 3'b110;
                8'b00010010: select_reg = 3'b000;
                8'b00010011: select_reg = 3'b001;
                8'b00010100: select_reg = 3'b010;
                8'b00010101: select_reg = 3'b011;
                8'b00010110: select_reg = 3'b100;
                8'b00010111: select_reg = 3'b101;
                8'b00011000: select_reg = 3'b110;
                8'b00011001: select_reg = 3'b000;
                8'b00011010: select_reg = 3'b001;
                8'b00011011: select_reg = 3'b010;
                8'b00011100: select_reg = 3'b011;
                8'b00011101: select_reg = 3'b100;
                8'b00011110: select_reg = 3'b101;
                8'b00011111: select_reg = 3'b110;
                8'b00100000: select_reg = 3'b000;
                8'b00100001: select_reg = 3'b001;
                8'b00100010: select_reg = 3'b010;
                8'b00100011: select_reg = 3'b011;
                8'b00100100: select_reg = 3'b100;
                8'b00100101: select_reg = 3'b101;
                8'b00100110: select_reg = 3'b110;
                8'b00100111: select_reg = 3'b000;
                8'b00101000: select_reg = 3'b001;
                8'b00101001: select_reg = 3'b010;
                8'b00101010: select_reg = 3'b011;
                8'b00101011: select_reg = 3'b100;
                8'b00101100: select_reg = 3'b101;
                8'b00101101: select_reg = 3'b110;
                8'b00101110: select_reg = 3'b000;
                8'b00101111: select_reg = 3'b001;
                8'b00110000: select_reg = 3'b010;
                8'b00110001: select_reg = 3'b011;
                8'b00110010: select_reg = 3'b100;
                8'b00110011: select_reg = 3'b101;
                8'b00110100: select_reg = 3'b110;
                8'b00110101: select_reg = 3'b000;
                8'b00110110: select_reg = 3'b001;
                8'b00110111: select_reg = 3'b010;
                8'b00111000: select_reg = 3'b011;
                8'b00111001: select_reg = 3'b100;
                8'b00111010: select_reg = 3'b101;
                8'b00111011: select_reg = 3'b110;
                default: select_reg = 3'b111;
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
    output logic [7:0] load_cnt_ser,
    output logic [2:0] select_reg,
    output logic [7:0] trigger_channel_mask, //address 1
    output logic [7:0] instruction, //address 2
    output logic [7:0] mode //address 3, W/R reg
);
    //different kinds of reset
    logic sclk_stop_rstn;
    logic full_rstn;
    always_comb begin
        full_rstn = rstn & sclk_stop_rstn; 
    end

    //Data from PICO to registers and POCI
    logic [7:0] write_data;
    logic [7:0] mux_control_signal;
    logic [2:0] input_mux_latch_sgnl; //Uses mux_control_signal to select reg to write to

    //instantiating the special w/r registers
    //only use external rstn for these to not zero the data out after we stop writing
    latched_write_reg trigger_ch_mask_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[0]), .stored_data (trigger_channel_mask));
    latched_write_reg instruction_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[1]), .stored_data (instruction));
    latched_write_reg mode_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[2]), .stored_data (mode));

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

    convert_addr out (.rstn (full_rstn), .mux_control_signal (mux_control_signal), .load_cnt_ser (load_cnt_ser), .select_reg (select_reg));
endmodule