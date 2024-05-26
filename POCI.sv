//8 bit message into serial

module address (input logic [7:0] addr, input logic sclk, input logic rstn, output logic serial_out);

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
