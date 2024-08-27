module SPI_and_mux_tb();
    //Select if want verbose readout
    logic DBG_READOUT = 0;

    //clock for simulation
    logic clk;
    always #25 clk = ~clk; //50 ns clock period

    logic rstn;
    logic iclk;
    logic sclk;
    logic serial_in;
    logic [2:0] select_reg;
    logic [7:0] trigger_channel_mask;
    logic clk_enable;
    logic inst_rst;
    logic inst_readout;
    logic inst_start;
    logic [7:0] mode;
    logic [7:0] disc_polarity;
    logic [7:0] vco_control;
    logic [7:0] pll_div_ratio;
    logic [7:0] slow_mode;
    logic [7:0] trig_delay;
    logic [7:0] raw_serial_out; //from 8 channels, SHOULD CHANGE ON SCLK
    logic serial_out;

    //setting all values
    //can change to test if it matters (it shouldn't)
    logic [7:0] tcm_data = 8'b0010_1001;
    logic [7:0] synthetic_channel_data = 8'b0011_0011;
    logic [7:0] instruction_data = 8'b0000_0001;
    logic [7:0] INST_RST = 8'b0000_0001;
    logic [7:0] INST_READOUT = 8'b0000_0010;
    logic [7:0] INST_START = 8'b0000_0011;
    logic [7:0] mode_data = 8'b0000_0100;
    logic [7:0] disc_polarity_data = 8'b1010_1001;
    logic [7:0] vco_control_data = 8'b0011_0110;
    logic [7:0] pll_div_ratio_data = 8'b0000_0111;
    logic [7:0] slow_mode_data = 8'b0000_0000;
    logic [7:0] trig_delay_data = 8'b0000_0001;
    logic [7:0] pll_locked = 8'b0000_0001;
    logic [7:0] read_data;

    SPI_and_mux DUT (
        .sclk (sclk),
        .iclk (iclk),
        .rstn (rstn),
        .serial_in (serial_in),
        .raw_serial_out (raw_serial_out),
        .pll_locked (pll_locked),
        .select_reg (select_reg),
        .clk_enable (clk_enable),
        .inst_rst (inst_rst),
        .inst_readout (inst_readout),
        .inst_start (inst_start),
        .trigger_channel_mask (trigger_channel_mask),
        .mode (mode),
        .disc_polarity (disc_polarity),
        .vco_control (vco_control),
        .pll_div_ratio (pll_div_ratio),
        .slow_mode (slow_mode),
        .trig_delay (trig_delay),
        .serial_out (serial_out)
    );

    //external reseting the chip
    task ext_reset ();
        rstn = 0;
        @(posedge clk);
        @(negedge clk);
        rstn = 1;

        $display("External Reset -------------------------------------------------------------------------------------------------------------------------");
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
        $display("Internal Reset --------------------------------------------------------------------------------------------------------------------------");
    endtask

    //Task to send serial data and read from serial out
    task send_serial_data(input [7:0] data, output [7:0] read_data);
    for (int j = 7; j >= 0; j--) begin
        serial_in = data[j];
        @(posedge clk); //assumes sclk becomes clk
        sclk = 1;
        iclk = 1;
        @(negedge clk);
        sclk = 0;
        iclk = 0;
        read_data[7-j] = serial_out;
    end
    endtask

    //Task to listen for synthetic serial out data for mux test
    //ONLY USE WHEN ADDRESS IS ON CHANNEL REGISTER 4-59
    task listen_for_data(output [7:0] read_data);
        serial_in = 0;
        //int active_shift_reg_index;
        //active_shift_reg_index = load_cnt_ser_to_index(load_cnt_ser);
        raw_serial_out = 8'b0;
        for (int j = 0; j < 8; j++) begin
            @(posedge clk); 
            sclk = 1;
            iclk = 1;
            for (int k = 0; k < 8; k++) begin
                raw_serial_out[k] = synthetic_channel_data[j]; //Simulating some channel data getting read out
            end 
            @(negedge clk);
            sclk = 0;
            iclk = 0;
            read_data[j] = serial_out;
        end
    endtask

    function int load_cnt_ser_to_index (logic [7:0] load_cnt_ser);
        case(load_cnt_ser)
            8'b0000_0001: return 0;
            8'b0000_0010: return 1;
            8'b0000_0100: return 2;
            8'b0000_1000: return 3;
            8'b0001_0000: return 4;
            8'b0010_0000: return 5;
            8'b0100_0000: return 6;
            8'b1000_0000: return 7;
            default: return 8;
        endcase
    endfunction

    //For dbg
    always @(posedge clk, negedge clk) begin
    if (DBG_READOUT) begin
        $display(
        "time: %0d, sclk: %0b, iclk: %0b, rstn: %0b, serial_in: %0b, addr: %0b, load_cnt_ser: %0b, select_reg: %0b, tcm: %0b, inst: %0b, clk_enable: %0b, inst_rst: %0b,\n inst_readout: %0b, inst_start: %0b, mode: %0b, irstn: %0b, msgi: %0b, serial_out: %0b, readout: %0b, msg_flag: %0b",
        $time, sclk, iclk, rstn, serial_in, DUT.spi.mux_control_signal, DUT.load_cnt_ser, select_reg, trigger_channel_mask, DUT.spi.instruction, clk_enable, 
        inst_rst, inst_readout, inst_start, mode, DUT.spi.sclk_stop_rstn, DUT.spi.in.msgi, serial_out, read_data, DUT.spi.msg_flag);

        if(clk == 0) begin
            $display("--------------------------------------------------------------------------------------------------------------------------------------------------");
        end
    end
    end

    initial begin
        clk = 0;
        iclk = 0;
        rstn = 1;
        #50; //let the reset take effect
        ext_reset(); //setting up chip
        serial_in = 0;

        //Writing to address 3
        send_serial_data(8'b0000_0011, read_data);
        send_serial_data(mode_data, read_data);

        int_reset();

        //Reading from address 3
        send_serial_data(8'b0000_0011, read_data);
        send_serial_data(mode_data, read_data);
        assert(read_data == mode_data) $display("Reading from address 3: Passed");
            else $display("Reading from address 3: Failed");

        //Reading from address 4
        //Testing to see if the mux drops a bit somewhere
        listen_for_data(read_data);
        assert(read_data == synthetic_channel_data) $display("Reading from address 4: Passed");
            else $display("Reading from address 4: Failed");

        $finish;
    end

endmodule