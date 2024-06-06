//The following includes the analog register
//for SIMULATION ONLY

\ include SPI_peripheral.sv

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
    assign byte6 = data_in[49:48]; // Only the 2 most significant bits remain

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
	output logic [7:0] d70, d71, d72, d73, d74, d75, d76,
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
    input logic [7:0] ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
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

