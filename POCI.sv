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

module POCI (
	input logic rstn,
	input logic sclk,
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

	p2s_register output_reg (.mux_in (msgi), .sclk (sclk), .rstn (rstn), .serial_out (serial_out));

endmodule