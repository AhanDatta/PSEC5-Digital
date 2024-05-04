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

//Buffers the message with a counter
//Only sends out final message when it is completed
//Outputs the reset message back to the shift reg
module buffer_register (
input logic [7:0] msg,
input logic sclk,
input logic full_rstn, //Reset input from the clock comparator
output logic rstn, //Goes back to the shift reg
output logic [7:0] complete_msg
);

    logic [2:0] count = 0; //For the clock divider
    always_ff @(posedge sclk or negedge full_rstn) begin
        if (!full_rstn) begin
            count <= 0;
        end
        else begin 
            count <= count + 1;
        end
    end

    //Logic for deciding when a message is complete + sending rstn to shift reg
    always_comb begin
        if (count == 7) begin
            complete_msg = msg;
            rstn = 0;
        end
        else begin
            complete_msg = 0;
            rstn = 1;
        end
    end
endmodule 

//Compares the internal clock and spi clock to see input stops coming in
//We set arbitrarily that 4 internal clock cycles of no sclk is when serial_in stops
module clock_comparator (
input logic sclk, //spi clock
input logic iclk, //internal clock from chip?
output logic full_rstn //Goes to the buffer register to reset the clock divider
);

    logic [1:0] count = 0;
    always_ff @(posedge iclk) begin
        if (sclk == 1) begin
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end 

    always_comb begin
        if (count == 3) begin
            full_rstn = 0;
        end
        else begin
            full_rstn = 1;
        end
    end
endmodule

module s2p_module (
input logic serial_in, 
input logic spi_clk,
input logic iclk, //internal clock
output logic [7:0] full_msg
);

    logic [7:0] msgi;
    logic rstin; //internal reset not from reg -> shift reg
    logic full_rstin; // internal reset not from clock comparator -> register

    s2p_shift_register shift_reg(.serial_in (serial_in), .sclk (spi_clk), .rstn (rstin), .msg (msgi));
    buffer_register register(.msg (msgi), .sclk (spi_clk), .full_rstn (full_rstin), .rstn (rstin), .complete_msg (full_msg));
    clock_comparator comparator(.sclk (spi_clk), .iclk (iclk), .full_rstn (full_rstin));
endmodule