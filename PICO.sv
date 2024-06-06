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
input logic rstn, //Reset input from the clock comparator
output logic [7:0] complete_msg
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

    //Logic for deciding when a message is complete + sending rstn to shift reg
    always_comb begin
        if (count == 0) begin
            complete_msg = msg;
        end
        else begin
            complete_msg = 0;
        end
    end
endmodule 

//Compares the internal clock and spi clock to see input stops coming in
//We set arbitrarily that 4 internal clock cycles of no sclk is when serial_in stops
module clock_comparator (
input logic sclk, //spi clock
input logic iclk, //internal clock from chip
input logic rstn, //external reset
output logic rstn_out //Goes to the buffer register to reset the clock divider
);

    logic [2:0] count;
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

    always_comb begin
        if (count == 7) begin
            rstn_out = 0;
        end
        else begin
            rstn_out = 1;
        end
    end
endmodule

//Takes serial input and outputs 8bit msg and reset signal if input stops
module s2p_module (
input logic serial_in, 
input logic spi_clk,
input logic iclk, //internal 
input logic rstn, //external reset
output logic [7:0] full_msg,
output logic sclk_stop_rstn // reset not from clock comparator -> register
);

    logic [7:0] msgi; //Internal msg from shift register to buffer reg
    wire full_rstn = rstn && sclk_stop_rstn;

    s2p_shift_register shift_reg(.serial_in (serial_in), .sclk (spi_clk), .rstn (full_rstn), .msg (msgi));
    buffer_register register(.msg (msgi), .sclk (spi_clk), .rstn (full_rstn), .complete_msg (full_msg));
    clock_comparator comparator(.sclk (spi_clk), .iclk (iclk), .rstn (rstn), .rstn_out (sclk_stop_rstn));
endmodule

// 8bit -> logic (first 8bit -> pointer for reg number, next 8 -> data, increment register, repeat until msg stop)

//Handles main read/write and address logic
//Needs to have a reset come in to initialize values
module read_write (
input logic [7:0] msg, //message from the s2p_module
input logic rstn, //set every value to zero
input logic sclk, //Spi clock 
output logic [7:0] write_data, //the data that is output to be written
output logic [7:0] address_pointer //controls the mux which regulates reads out the chosen digital reg
);
    //Logic for addressing registers and writing
    logic address_set;
    always_ff @(msg or negedge rstn) begin //negedge to not be off by a clk cycle from buffer reg
        if (!rstn) begin
            address_set <= 0;
            write_data <= '0;
            address_pointer <= '0;
        end
        else if (msg == '0) begin //Assume that msg == 0 when it is incomplete because of the buffer_reg
        end
        else begin
            if (!address_set) begin
                address_pointer <= msg;
                write_data <= '0;
                address_set <= 1;
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
output logic [7:0] write_data, //Output data to write
output logic [7:0] mux_control_signal //Output control signal for POCI mux
); 
    logic [7:0] msgi; //internal message from s2p -> read_write
    wire full_rstn = rstn && sclk_stop_rstn; //Combines the reset signal from the clock comparator and external reset
    
    s2p_module serial_to_eight_bit (.serial_in (serial_in), .spi_clk (sclk), .iclk (iclk), .rstn (rstn), .full_msg (msgi), .sclk_stop_rstn (sclk_stop_rstn));
    read_write eight_bit_to_output (.msg (msgi), .rstn (full_rstn), .sclk (sclk), .write_data (write_data), .address_pointer (mux_control_signal));
endmodule