//Controls the output of 56 reg long green buffer using mux_control_signal
module mux (
	input logic [7:0] mux_control_signal, //From the PICO
	input logic [7:0][7:0] mux_input, //address * 8 bit per reg
	input logic rstn,
	output logic [7:0] selected_msg //goes to p2s shift reg
);

	always_comb begin
		if (!rstn) begin
			selected_msg = '0;
		end	
		else begin
			if (mux_control_signal = '0) begin
				//Does nothing because this is the reserved address
			end
			else if (mux_control_signal > 59) begin
				//Catches edge case where mux_control_signal points to reg out of bounds
			end
			else begin
				logic [7:0] address_pointer = (mux_control_signal - 1) * 8; //-1 because of reserved address
				selected_msg = mux_input[]
			end
		end
	end

endmodule

//8 bit message into serial

module p2s_shift_register (input logic [7:0] addr, input logic sclk, input logic rstn, output logic serial_out);

// addr is the 7 bit input, being turned serial
// rstn is the reset

logic [7:0]q;

always_ff @(posedge sclk or negedge rstn) begin
	if (!rstn) begin
 		q<= 8'b00000000;
 	end
 	else begin
		serial_out <= q[0];
		q <= q >> 1;
	end
end

endmodule