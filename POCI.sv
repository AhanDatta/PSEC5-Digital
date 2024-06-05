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
module p2s_register (input logic [7:0] mux_in, input logic sclk, input logic rstn, output logic serial_out);

	logic [2:0] index_pointer; //Points to the index of addr which should be output 
	
	always_ff @(posedge sclk or negedge rstn) begin
		if (!rstn) begin
			serial_out <= 0;
			index_pointer <= '0;
		end
		else begin
			serial_out <= mux_in[index_pointer];
			index_pointer <= index_pointer + 1;
		end
	end

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
    assign byte6 = data_in[49:48]; // Only the 2 most significant bits remain

endmodule



// This commented out section was a test bench used for verification

//Test Bench to test the 8 channel splitter
/*	module tb_split_50bit(
    input  logic [49:0] ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
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
*/






// This takes 8 50 bit inputs, and will channel them all through the mux
// currently the address, reset, and channels 1-3 on the mux are their own individual inputs
// as they will come internally from elsewhere in the future
	module ch_mux (   
	 input  logic [49:0] ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7,
	 input logic [7:0] addr,
	 input logic rstn,
	 input logic [7:0] x1, x2, x3,
	 output logic [7:0] mux_msg);



 logic [7:0] d00, d01, d02, d03, d04, d05, d06;
 logic [7:0] d10, d11, d12, d13, d14, d15, d16;
 logic [7:0] d20, d21, d22, d23, d24, d25, d26;
 logic [7:0] d30, d31, d32, d33, d34, d35, d36;
 logic [7:0] d40, d41, d42, d43, d44, d45, d46;
 logic [7:0] d50, d51, d52, d53, d54, d55, d56;
 logic [7:0] d60, d61, d62, d63, d64, d65, d66;
 logic [7:0] d70, d71, d72, d73, d74, d75, d76;




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






	mux_59_to_1 mkx(rstn, addr, x1, x2, x3, 
	d00, d01, d02, d03, d04, d05, d06,
	d10, d11, d12, d13, d14, d15, d16,
	d20, d21, d22, d23, d24, d25, d26,
	d30, d31, d32, d33, d34, d35, d36,
	d40, d41, d42, d43, d44, d45, d46,
	d50, d51, d52, d53, d54, d55, d56,
	d60, d61, d62, d63, d64, d65, d66,
	d70, d71, d72, d73, d74, d75, d76,
	mux_msg);

	endmodule
