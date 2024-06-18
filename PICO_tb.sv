`timescale 1ns/1ps

module PICO_tb ();
    //clock for simulation
    logic clk;
    always #10 clk = ~clk; //20 ns clock period

    logic serial_in; //Serial message data
    logic sclk; //spi clock
    logic iclk; //internal clock
    logic rstn; //external reset
    logic sclk_stop_rstn; //From the clock comparator
    logic msg_flag; //between buffer_reg and read_write, and to readout shift reg
    logic [7:0] write_data; //Output data to write
    logic [7:0] mux_control_signal; //Output control signal for POCI mux

    //for dbg reasons only
    always @(posedge clk, negedge clk) begin
        $display("time = %0d, sclk = %b, msgi = %b, rstn = %b, irstn = %b, serial_in = %b, msg_flag = %b, write_data = %b, address_pointer = %b", 
        $time, sclk, DUT.msgi, rstn, sclk_stop_rstn, serial_in, msg_flag, write_data, mux_control_signal);
    end

    PICO DUT (
        .serial_in (serial_in),
        .sclk (sclk),
        .iclk (iclk),
        .rstn (rstn),
        .sclk_stop_rstn (sclk_stop_rstn),
        .msg_flag (msg_flag),
        .write_data (write_data),
        .mux_control_signal (mux_control_signal) 
    );

    //external reseting the chip
    task ext_reset ();
        rstn = 0;
        @(posedge clk);
        @(negedge clk);
        rstn = 1;
    endtask

    //internal reset from iclk
    task int_reset ();
        sclk = 0;
        for (int i = 0; i < 8; i++) begin
            @(posedge clk);
            iclk = 1;
            @(negedge clk);
            iclk = 0;
        end
    endtask

    //Task to send serial data and read from serial out
    task send_serial_data(input [7:0] data, input integer num_bytes);
        $display("Started Sending Data: %b", data);
        $display("-----------------------------------------------");
        for (int i = 0; i < num_bytes; i++) begin
            for (int j = 0; j < 8; j++) begin
                serial_in = data[7-j]; 
                sclk = 1;
                @(posedge clk); //assumes sclk becomes clk
                sclk = 0;
                @(negedge clk);       
            end
        end
    endtask

    initial begin
        clk = 0;
        rstn = 1;//IC to zero everything
        #20;
        iclk = 0;
        sclk = 0;
        serial_in = 0;
        ext_reset();

        //Case 1: Setting address and write
        send_serial_data(8'd1, 1); //set addr to 1
        send_serial_data(8'b10101010, 1);//write data

        $finish;
    end
endmodule