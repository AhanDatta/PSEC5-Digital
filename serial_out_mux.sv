module serial_out_mux (
    input logic sclk,
    input logic [7:0] raw_serial_out, //0-7 are channels
    input logic wr_serial_out, //W/R serial output
    input logic [7:0] load_cnt_ser, //control signal
    output logic serial_out
);

    logic [7:0] load_cnt_ser_prev;

    always_ff @(posedge sclk) begin
        load_cnt_ser_prev <= load_cnt_ser;
    end

    always_comb begin
        case (load_cnt_ser_prev)
            8'b0000_0000: serial_out = wr_serial_out;
            8'b0000_0001: serial_out = raw_serial_out[0];
            8'b0000_0010: serial_out = raw_serial_out[1];
            8'b0000_0100: serial_out = raw_serial_out[2];
            8'b0000_1000: serial_out = raw_serial_out[3];
            8'b0001_0000: serial_out = raw_serial_out[4];
            8'b0010_0000: serial_out = raw_serial_out[5];
            8'b0100_0000: serial_out = raw_serial_out[6];
            8'b1000_0000: serial_out = raw_serial_out[7];
            default: serial_out = 0;
        endcase
    end

endmodule