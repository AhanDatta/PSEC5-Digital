`timescale 1ps/1ps

//The following includes the analog register
//attatches to the synthesizable digital SPI block
//for SIMULATION ONLY


//Controls the output of 56 reg long green buffer using mux_control_signal
module mux_59_to_1 (
	input logic rstn,
    input logic [7:0] control_signal,
    input logic [7:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9,
    input logic [7:0] reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19,
    input logic [7:0] reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29,
    input logic [7:0] reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39,
    input logic [7:0] reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49,
    input logic [7:0] reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59,
    output logic [7:0] out
);

    always_comb begin
		if (!rstn) begin
			out = '0;
		end
		else begin
			unique case (control_signal)
				8'd0: out = 8'd0; //Catches the reserved address
				8'd1: out = reg1;
				8'd2: out = reg2;
				8'd3: out = reg3;
				8'd4: out = reg4;
				8'd5: out = reg5;
				8'd6: out = reg6;
				8'd7: out = reg7;
				8'd8: out = reg8;
				8'd9: out = reg9;
				8'd10: out = reg10;
				8'd11: out = reg11;
				8'd12: out = reg12;
				8'd13: out = reg13;
				8'd14: out = reg14;
				8'd15: out = reg15;
				8'd16: out = reg16;
				8'd17: out = reg17;
				8'd18: out = reg18;
				8'd19: out = reg19;
				8'd20: out = reg20;
				8'd21: out = reg21;
				8'd22: out = reg22;
				8'd23: out = reg23;
				8'd24: out = reg24;
				8'd25: out = reg25;
				8'd26: out = reg26;
				8'd27: out = reg27;
				8'd28: out = reg28;
				8'd29: out = reg29;
				8'd30: out = reg30;
				8'd31: out = reg31;
				8'd32: out = reg32;
				8'd33: out = reg33;
				8'd34: out = reg34;
				8'd35: out = reg35;
				8'd36: out = reg36;
				8'd37: out = reg37;
				8'd38: out = reg38;
				8'd39: out = reg39;
				8'd40: out = reg40;
				8'd41: out = reg41;
				8'd42: out = reg42;
				8'd43: out = reg43;
				8'd44: out = reg44;
				8'd45: out = reg45;
				8'd46: out = reg46;
				8'd47: out = reg47;
				8'd48: out = reg48;
				8'd49: out = reg49;
				8'd50: out = reg50;
				8'd51: out = reg51;
				8'd52: out = reg52;
				8'd53: out = reg53;
				8'd54: out = reg54;
				8'd55: out = reg55;
				8'd56: out = reg56;
				8'd57: out = reg57;
				8'd58: out = reg58;
				8'd59: out = reg59;
				default: out = 'x;
			endcase
		end
    end

endmodule

//8 bit message into serial
//NOTE: This is a software hack. When synthesized, becomes a regular shift reg
module p2s_register (
	input logic [7:0] mux_in, 
	input logic sclk, 
	input logic rstn, 
	input logic msg_flag, //from PICO msg_flag_gen
	output logic serial_out
	);

	logic [7:0] held_data; //data in latched register
	logic [2:0] index_pointer; //Points to the index of addr which should be output 
	latched_write_reg latched_data (.rstn (rstn), .data (mux_in), .latch_en (msg_flag), .stored_data (held_data));
	
	always_ff @(posedge sclk or negedge rstn) begin
		if (!rstn) begin
			serial_out <= 0;
			index_pointer <= '0;
		end
		else begin
			serial_out <= held_data[index_pointer];
			index_pointer <= index_pointer + 1;
		end
	end

endmodule

module POCI (
	input logic rstn,
	input logic sclk,
	input logic msg_flag, //for output shift reg
    input logic [7:0] control_signal, //this is the mux select
	input logic [7:0] trigger_channel_mask, //address 1
	input logic [7:0] instruction, //address 2
	input logic [7:0] mode, //address 3
    input logic [7:0] reg4, reg5, reg6, reg7, reg8, reg9, //we designate reg 1-3 as special w/r
    input logic [7:0] reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, //all else are read only
    input logic [7:0] reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29,
    input logic [7:0] reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39,
    input logic [7:0] reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49,
    input logic [7:0] reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59,
	output logic serial_out
);

	logic [7:0] msgi; //internal data from mux -> p2s reg

	//Logic for reading out the data
	mux_59_to_1 mkx (.rstn (rstn), .control_signal (control_signal), .reg1 (trigger_channel_mask), .reg2 (instruction), .reg3(mode),
		.reg4 (reg4), .reg5 (reg5), .reg6 (reg6), .reg7 (reg7), .reg8 (reg8), .reg9 (reg9), .reg10 (reg10),
		.reg11 (reg11), .reg12 (reg12), .reg13 (reg13), .reg14 (reg14), .reg15 (reg15), .reg16 (reg16), .reg17 (reg17),
		.reg18 (reg18), .reg19 (reg19), .reg20 (reg20), .reg21 (reg21), .reg22 (reg22), .reg23 (reg23), .reg24 (reg24),
		.reg25 (reg25), .reg26 (reg26), .reg27 (reg27), .reg28 (reg28), .reg29 (reg29), .reg30 (reg30), .reg31 (reg31),
		.reg32 (reg32), .reg33 (reg33), .reg34 (reg34), .reg35 (reg35), .reg36 (reg36), .reg37 (reg37), .reg38 (reg38),
		.reg39 (reg39), .reg40 (reg40), .reg41 (reg41), .reg42 (reg42), .reg43 (reg43), .reg44 (reg44), .reg45 (reg45),
		.reg46 (reg46), .reg47 (reg47), .reg48 (reg48), .reg49 (reg49), .reg50 (reg50), .reg51 (reg51), .reg52 (reg52),
		.reg53 (reg53), .reg54 (reg54), .reg55 (reg55), .reg56 (reg56), .reg57 (reg57), .reg58 (reg58), .reg59 (reg59),
		.out (msgi)
	);

	p2s_register output_reg (.mux_in (msgi), .sclk (sclk), .rstn (rstn), .msg_flag (msg_flag), .serial_out (serial_out));

endmodule

//This is the overview for the logic in this file
//Each packet of information comes in a byte, organized and sent to places on the following scheme
//serial in -> packed into byte sized message -> (if address pntr not set), set address pntr, (else), write the data and increment address pntr
//Top level module at the bottom to put everything together

//At each clock pulse, adds the serial input to the end of the current 8bit message
module s2p_shift_register (
input logic serial_in,
input logic sclk,
input logic rstn,
output logic [7:0] msg
);
    always_ff @(posedge sclk or negedge rstn) begin
        if (!rstn) begin
            msg <= '0;
        end
        else begin
            msg <= {msg[6:0], serial_in};
        end
    end
endmodule

//outputs a flag signal when a msg is complete
module msg_flag_gen (
input logic sclk,
input logic rstn, //Reset input from the clock comparator
output logic msg_flag
);

    logic [2:0] count; //For the clock divider
    always_ff @(posedge sclk or negedge rstn) begin
        if (!rstn) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

    assign msg_flag = (count == 0);
endmodule

//Compares the internal clock and spi clock to see input stops coming in
//We set arbitrarily that 7 internal clock cycles of no sclk is when serial_in stops
module clock_comparator (
input logic sclk, //spi clock
input logic iclk, //internal clock from chip
input logic rstn, //external reset
output logic rstn_out //Goes to the buffer register to reset the clock divider
);

    logic [2:0] count; //how many iclk cycles since last sclk
    logic rstn_done; //tracks if a reset has already been sent out after some transaction
    always_ff @(posedge iclk, posedge sclk, negedge rstn) begin
        if (!rstn) begin
            count <= 0;
        end
        else if (sclk == 1) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

    //reset logic based on count
    always_comb begin
        if (rstn_done) begin
            rstn_out = 1;
        end
        else if (count == 7) begin
            rstn_out = 0;
        end
        else begin
            rstn_out = 1;
        end
    end

    //tracks if a reset has already been sent for this transaction
    always_latch begin
        if (!rstn) begin
            rstn_done = 0;
        end
        else if (sclk) begin
            rstn_done = 0;
        end
        else if (count == 7) begin
            rstn_done = 1;
        end
    end
endmodule

//Takes serial input and outputs 8bit msg and reset signal if input stops
module s2p_module (
input logic serial_in,
input logic spi_clk,
input logic iclk, //internal clock for comparator
input logic rstn, //external reset
output logic [7:0] full_msg,
output logic sclk_stop_rstn, // reset not from clock comparator -> register
output logic msg_flag //to the read_write module
);
    logic full_rstn = rstn && sclk_stop_rstn;

    s2p_shift_register shift_reg(.serial_in (serial_in), .sclk (spi_clk), .rstn (full_rstn), .msg (full_msg));
    msg_flag_gen buffer_reg(.sclk (spi_clk), .rstn (full_rstn), .msg_flag (msg_flag));
    clock_comparator comparator(.sclk (spi_clk), .iclk (iclk), .rstn (rstn), .rstn_out (sclk_stop_rstn));
endmodule

//Handles main read/write and address logic
//Needs to have a reset come in to initialize values
module read_write (
input logic [7:0] msg, //message from the s2p_module
input logic rstn, //set every value to zero
input logic msg_flag, //flags when the msg from buffer reg changes
output logic [7:0] write_data, //the data that is output to be written
output logic [7:0] address_pointer //controls the mux which regulates reads out the chosen digital reg
);
    //Logic for addressing registers and writing
    always_ff @(posedge msg_flag or negedge rstn) begin //this is one clock cycle off from buffer reg; NEED TO FIX
        if (!rstn) begin
            //write_data <= '0; Don't want this because want to maintain data in w/r regs after transaction
            address_pointer <= '0;
        end
        else begin
            if (address_pointer == '0) begin
                address_pointer <= msg;
                write_data <= '0;
            end
            else begin
                write_data <= msg;
                address_pointer <= address_pointer + 1;
            end
        end
    end
endmodule

module PICO (
input logic serial_in, //Serial message data
input logic sclk, //spi clock
input logic iclk, //internal clock
input logic rstn, //external reset
output logic sclk_stop_rstn, //From the clock comparator
output logic msg_flag, //between buffer_reg and read_write, and to readout shift reg
output logic [7:0] write_data, //Output data to write
output logic [7:0] mux_control_signal //Output control signal for POCI mux
); 
    logic [7:0] msgi; //internal message from s2p -> read_write
    logic full_rstn = rstn && sclk_stop_rstn; //Combines the reset signal from the clock comparator and external reset

    s2p_module serial_to_eight_bit (
        .serial_in (serial_in),
        .spi_clk (sclk),
        .iclk (iclk),
        .rstn (rstn),
        .full_msg (msgi),
        .sclk_stop_rstn (sclk_stop_rstn),
        .msg_flag (msg_flag)
        );

    read_write eight_bit_to_output (
        .msg (msgi),
        .rstn (full_rstn),
        .msg_flag (msg_flag),
        .write_data (write_data),
        .address_pointer (mux_control_signal)
        );
endmodule

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
    //only use external rstn for these to not zero the data out after we stop writing
    latched_write_reg trigger_ch_mask_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[0]), .stored_data (trigger_channel_mask));
    latched_write_reg instruction_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[1]), .stored_data (instruction));
    latched_write_reg mode_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[2]), .stored_data (mode));

    input_mux write_mux (.rstn (full_rstn), .sclk (sclk), .addr (mux_control_signal), .latch_signal (input_mux_latch_sgnl));

    logic msg_flag; //from msg_flag_gen for readout

    PICO in (
        .serial_in (serial_in), 
        .sclk (sclk), 
        .iclk (iclk), 
        .rstn (rstn), //full rstn is computed inside PICO
        .sclk_stop_rstn (sclk_stop_rstn), 
        .msg_flag (msg_flag),
        .write_data (write_data), 
        .mux_control_signal (mux_control_signal)
    );

    POCI out (
        .rstn (full_rstn), .sclk (sclk), .msg_flag (msg_flag),
        .control_signal (mux_control_signal), .trigger_channel_mask (trigger_channel_mask), .instruction (instruction), .mode (mode),
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

//This module takes in a 50 bit input, and splits it up into 7 bytes. 
//Note that the last byte will only have 2 bits inside of it, so the remaining 6 bits will default to 0.

module split_50bit (
    input  logic [49:0] data_in,
    output logic [7:0]  byte0,
    output logic [7:0]  byte1,
    output logic [7:0]  byte2,
    output logic [7:0]  byte3,
    output logic [7:0]  byte4,
    output logic [7:0]  byte5,
    output logic [7:0]  byte6
);

    // Split the 50-bit integer into sequential 8-bit and 2-bit integers
    assign byte0 = data_in[7:0];
    assign byte1 = data_in[15:8];
    assign byte2 = data_in[23:16];
    assign byte3 = data_in[31:24];
    assign byte4 = data_in[39:32];
    assign byte5 = data_in[47:40];
    assign byte6 = {6'b0,data_in[49:48]}; // Only the 2 most significant bits remain

endmodule

// This takes 8 50 bit inputs from analog reg, and will split them
//into the mixed reg to be fed into POCI
module analog_to_mixed_reg (   
	input logic [49:0] ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
	output logic [7:0] d00, d01, d02, d03, d04, d05, d06,
	output logic [7:0] d10, d11, d12, d13, d14, d15, d16,
	output logic [7:0] d20, d21, d22, d23, d24, d25, d26,
	output logic [7:0] d30, d31, d32, d33, d34, d35, d36,
	output logic [7:0] d40, d41, d42, d43, d44, d45, d46,
	output logic [7:0] d50, d51, d52, d53, d54, d55, d56,
	output logic [7:0] d60, d61, d62, d63, d64, d65, d66,
	output logic [7:0] d70, d71, d72, d73, d74, d75, d76
);

// Splitting of Channel 0
    split_50bit set0 (
        .data_in(ch0),
        .byte0(d00),
        .byte1(d01),
        .byte2(d02),
        .byte3(d03),
        .byte4(d04),
        .byte5(d05),
        .byte6(d06)
    );

// Splitting of Channel 1
    split_50bit set1 (
        .data_in(ch1),
        .byte0(d10),
        .byte1(d11),
        .byte2(d12),
        .byte3(d13),
        .byte4(d14),
        .byte5(d15),
        .byte6(d16)
    );

// Splitting of Channel 2
    split_50bit set2 (
        .data_in(ch2),
        .byte0(d20),
        .byte1(d21),
        .byte2(d22),
        .byte3(d23),
        .byte4(d24),
        .byte5(d25),
        .byte6(d26)
    );

// Splitting of Channel 3
    split_50bit set3 (
        .data_in(ch3),
        .byte0(d30),
        .byte1(d31),
        .byte2(d32),
        .byte3(d33),
        .byte4(d34),
        .byte5(d35),
        .byte6(d36)
    );

// Splitting of Channel 4
    split_50bit set4 (
        .data_in(ch4),
        .byte0(d40),
        .byte1(d41),
        .byte2(d42),
        .byte3(d43),
        .byte4(d44),
        .byte5(d45),
        .byte6(d46)
    );

// Splitting of Channel 5
    split_50bit set5 (
        .data_in(ch5),
        .byte0(d50),
        .byte1(d51),
        .byte2(d52),
        .byte3(d53),
        .byte4(d54),
        .byte5(d55),
        .byte6(d56)
    );

// Splitting of Channel 6
    split_50bit set6 (
        .data_in(ch6),
        .byte0(d60),
        .byte1(d61),
        .byte2(d62),
        .byte3(d63),
        .byte4(d64),
        .byte5(d65),
        .byte6(d66)
    );

// Splitting of Channel 7
    split_50bit set7 (
        .data_in(ch7),
        .byte0(d70),
        .byte1(d71),
        .byte2(d72),
        .byte3(d73),
        .byte4(d74),
        .byte5(d75),
        .byte6(d76)
    );

endmodule


module test_SPI (
    input logic [49:0] ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
    input logic serial_in,
    input logic sclk, 
    input logic iclk,
    input logic rstn,
    output logic serial_out
);

    //Registers for the SPI Block
    logic [7:0] reg4, reg5, reg6, reg7, reg8, reg9; //we designate reg 1-3 as special w/r
    logic [7:0] reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19; //all else are read only
    logic [7:0] reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29;
    logic [7:0] reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39;
    logic [7:0] reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49;
    logic [7:0] reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59;
    
    analog_to_mixed_reg step_one (
        ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
        reg4, reg5, reg6, reg7, reg8, reg9, 
        reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19,
        reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29,
        reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39,
        reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49,
        reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59
    );

    SPI DUT (
        serial_in, sclk, iclk, rstn,
        reg4, reg5, reg6, reg7, reg8, reg9, 
        reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19,
        reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29,
        reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39,
        reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49,
        reg50, reg51, reg52, reg53, reg54, reg55, reg56, reg57, reg58, reg59,
        serial_out
    );

endmodule