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
    always_ff @(posedge iclk, posedge sclk) begin
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

//Takes serial input and outputs 8bit msg and reset signal if input stops
module s2p_module (
input logic serial_in, 
input logic spi_clk,
input logic iclk, //internal clock
output logic [7:0] full_msg,
output logic msg_stop_rstn // reset not from clock comparator -> register
);

    logic [7:0] msgi;
    logic rstin; //internal reset not from reg -> shift reg 

    s2p_shift_register shift_reg(.serial_in (serial_in), .sclk (spi_clk), .rstn (rstin), .msg (msgi));
    buffer_register register(.msg (msgi), .sclk (spi_clk), .full_rstn (msg_stop_rstn), .rstn (rstin), .complete_msg (full_msg));
    clock_comparator comparator(.sclk (spi_clk), .iclk (iclk), .full_rstn (msg_stop_rstn));
endmodule

// 8bit -> logic (first 8bit -> pointer for reg number, next 8 -> data, increment register, repeat until msg stop)

//Shift reg to write to for simulation
module eight_bit_reg (
input logic [7:0] data,
input logic sclk,
input logic rstn,
output logic [7:0] out
);
    always_ff @(posedge sclk or negedge rstn) begin
        if (!rstn) begin
            out <= '0;
        end
        else begin
            out <= data;
        end
    end
endmodule

//Simple synch register to fix the msg as non-zero 
module synch_reg (
input logic [7:0] d,
input logic en, 
input logic sclk,
input logic rstn,
output logic [7:0] q
);
    always_ff @(negedge sclk or negedge rstn) begin
        if (!rstn) begin
            q <= '0;
        end
        else begin
            if (en) begin
                q <= d;
            end
        end
    end
endmodule

//Handles main read/write and address logic
//Also latches signal from previous block
module read_write (
input logic [7:0] msg, //message from the s2p_module
input logic rstn, //from the clock comparator to clear the address pointer
input logic sclk, //Spi clock 
output logic [7:0] mux_control_signal //controls the mux which regulates reads out the chosen digital reg
);
    //"latched_msg" is the last non-zero value of msg
    //Name is a little misleading but forgive me
    logic [7:0] latched_msg;
    logic latch_en = (msg != '0);
    synch_reg msg_latcher (.d (msg), .en (latch_en), .sclk (sclk), .rstn (rstn), .q (latched_msg));

    //Logic for addressing registers and writing
    //UNFINISHED
    logic [7:0] address_pointer = '0;
endmodule