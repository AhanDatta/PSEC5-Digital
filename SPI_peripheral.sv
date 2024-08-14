//This file rolls up the whole SPI Peripheral 
//Full guide found here: https://www.overleaf.com/9261836185kyrcvjqcqhnc#db7835

//This is the full digital SPI communication section
module SPI (
    input logic serial_in,
    input logic sclk,
    input logic [7:0] pll_locked, //address 60
    input logic iclk, //internal clock 
    input logic rstn, //external reset
    output logic clk_enable, //1: START; 0: else; HELD
    output logic inst_rst, // instr == 1
    output logic inst_readout, //instr == 2
    output logic inst_start, //instr == 3
    output logic [7:0] load_cnt_ser,
    output logic [2:0] select_reg,
    output logic [7:0] trigger_channel_mask, //address 1
    output logic [7:0] mode, //address 3 
    output logic [7:0] disc_polarity, //address 61
    output logic [7:0] vco_control, //address 62
    output logic [7:0] pll_div_ratio, //address 63
    output logic [7:0] slow_mode, //address 64
    output logic [7:0] trig_delay, //address 65 
    output logic serial_out //partial serial out for addr 1-3
);
    //different kinds of reset
    logic sclk_stop_rstn;
    logic full_rstn;
    assign full_rstn = rstn & sclk_stop_rstn; 

    logic [7:0] instruction; //address 2

    //Flags from PICO
    logic msg_flag;

    //Data from PICO to registers and POCI
    logic [7:0] write_data;
    logic [7:0] mux_control_signal;
    logic [7:0] input_mux_latch_sgnl; //Uses mux_control_signal to select reg to write to
    
    //Gets the input into a usable form
    PICO in (
        .serial_in (serial_in), 
        .sclk (sclk), 
        .iclk (iclk), 
        .rstn (rstn), //full rstn is computed inside PICO
        .msg_flag (msg_flag),
        .sclk_stop_rstn (sclk_stop_rstn), 
        .write_data (write_data), 
        .mux_control_signal (mux_control_signal)
    );

    //instantiating the special registers
    //only use external rstn for these to not zero the data out after we stop writing
    latched_write_reg trigger_ch_mask_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[0]), .stored_data (trigger_channel_mask));
    latched_write_reg instruction_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[1]), .stored_data (instruction));
    latched_write_reg mode_reg (.rstn (rstn), .data (write_data), .latch_en (input_mux_latch_sgnl[2]), .stored_data (mode));
    latched_write_reg disc_polarity_reg(.rstn (rstn), .data(write_data), .latch_en (input_mux_latch_sgnl[3]), .stored_data (disc_polarity));
    latched_write_reg vco_control_reg(.rstn (rstn), .data(write_data), .latch_en (input_mux_latch_sgnl[4]), .stored_data (vco_control));
    latched_write_reg pll_div_ratio_reg(.rstn (rstn), .data(write_data), .latch_en (input_mux_latch_sgnl[5]), .stored_data (pll_div_ratio));
    latched_write_reg slow_mode_reg(.rstn (rstn), .data(write_data), .latch_en (input_mux_latch_sgnl[6]), .stored_data (slow_mode));
    latched_write_reg trig_delay_reg(.rstn (rstn), .data(write_data), .latch_en (input_mux_latch_sgnl[7]), .stored_data (trig_delay));

    input_mux write_mux (.rstn (full_rstn), .sclk (sclk), .addr (mux_control_signal), .latch_signal (input_mux_latch_sgnl));

    //logic to drive pins related to instruction
    inst_driver instruction_driver (
        .rstn(rstn), 
        .instruction(instruction), 
        .mux_control_signal (mux_control_signal), 
        .iclk (iclk), 
        .sclk (sclk),
        .msg_flag (msg_flag),
        .clk_enable (clk_enable),
        .inst_rst (inst_rst),
        .inst_readout (inst_readout),
        .inst_start (inst_start)
        );

    //Readout from registers 1-3
    W_R_reg_readout data_out (
        .trigger_channel_mask (trigger_channel_mask),
        .instruction (instruction),
        .mode (mode),
        .disc_polarity (disc_polarity),
        .vco_control (vco_control),
        .pll_div_ratio (pll_div_ratio),
        .pll_locked (pll_locked),
        .slow_mode (slow_mode),
        .trig_delay (trig_delay),
        .mux_control_signal (mux_control_signal),
        .msg_flag (msg_flag),
        .sclk (sclk),
        .rstn (full_rstn),
        .serial_out (serial_out)
    );

    //Output for the readout of regs 4-59
    convert_addr addr_out (.rstn (full_rstn), .mux_control_signal (mux_control_signal), .load_cnt_ser (load_cnt_ser), .select_reg (select_reg));
endmodule

//Special registers 1-3 for trigger_ch_mask, instruction, mode
//also to hold data for serial_out
module latched_write_reg (
    input logic rstn,
    input logic [7:0] data,
    input logic latch_en,
    output logic [7:0] stored_data
);
    always_latch begin
        if (!rstn) begin
            stored_data = 8'b0;
        end
        else if (latch_en) begin
            stored_data = data;
        end
    end
endmodule

//Controls the latch for the three special regs based on address
//Synchronous mux here to stop a double write issue
//caused by address pointer incrementing too fast
module input_mux (
    input logic rstn,
    input logic [7:0] addr,
    input logic sclk, 
    output logic [7:0] latch_signal //carries the latch signal to the correct reg based on address
);
    always_ff @(posedge sclk or negedge rstn) begin
        if (!rstn) begin
            latch_signal <= '0;
        end
        else begin
            unique case (addr)
                8'd1: latch_signal <= 8'b0000_0001;
                8'd2: latch_signal <= 8'b0000_0010;
                8'd3: latch_signal <= 8'b0000_0100;
                8'd61: latch_signal <= 8'b0000_1000;
                8'd62: latch_signal <= 8'b0001_0000;
                8'd63: latch_signal <= 8'b0010_0000;
                8'd64: latch_signal <= 8'b0100_0000;
                8'd65: latch_signal <= 8'b1000_0000;
                default: latch_signal <= 8'b0000_0000;
            endcase
        end
    end
endmodule

//Converts mux_control_signal into correct load_cnt_ser flag for analog reg
//Also sets select_reg to read the correct byte from the chosen analog reg
module convert_addr (
    input logic rstn,
    input logic [7:0] mux_control_signal,
    output logic [7:0] load_cnt_ser,
    output logic [2:0] select_reg
);
    always_comb begin
        if (!rstn) begin
            load_cnt_ser = 8'b0;
            select_reg = 3'b111;
        end
        else begin
            //Setting load_cnt_ser flag with LUT
            if (mux_control_signal <= 3) begin //address sent to W reg
                load_cnt_ser = 8'b0;
            end
            else if (mux_control_signal <= 10) begin
                load_cnt_ser = 8'b00000001;
            end
            else if (mux_control_signal <= 17) begin
                load_cnt_ser = 8'b00000010;
            end
            else if (mux_control_signal <= 24) begin
                load_cnt_ser = 8'b00000100;
            end
            else if (mux_control_signal <= 31) begin
                load_cnt_ser = 8'b00001000;
            end
            else if (mux_control_signal <= 38) begin
                load_cnt_ser = 8'b00010000;
            end
            else if (mux_control_signal <= 45) begin
                load_cnt_ser = 8'b00100000;
            end
            else if (mux_control_signal <= 52) begin
                load_cnt_ser = 8'b01000000;
            end
            else if (mux_control_signal <= 59) begin
                load_cnt_ser = 8'b10000000;
            end
            else begin //invalid address case
                load_cnt_ser = 8'b0;
            end

            //Sets select_reg with LUT
            //Uses formula select_reg = (mux_control_signal - 4) % 7
            //111 default because load_reg = 7 is default in psec5_digital_april2024.sv
            unique case (mux_control_signal)
                8'b00000000: select_reg = 3'b111;
                8'b00000001: select_reg = 3'b111;
                8'b00000010: select_reg = 3'b111;
                8'b00000011: select_reg = 3'b111;
                8'b00000100: select_reg = 3'b000;
                8'b00000101: select_reg = 3'b001;
                8'b00000110: select_reg = 3'b010;
                8'b00000111: select_reg = 3'b011;
                8'b00001000: select_reg = 3'b100;
                8'b00001001: select_reg = 3'b101;
                8'b00001010: select_reg = 3'b110;
                8'b00001011: select_reg = 3'b000;
                8'b00001100: select_reg = 3'b001;
                8'b00001101: select_reg = 3'b010;
                8'b00001110: select_reg = 3'b011;
                8'b00001111: select_reg = 3'b100;
                8'b00010000: select_reg = 3'b101;
                8'b00010001: select_reg = 3'b110;
                8'b00010010: select_reg = 3'b000;
                8'b00010011: select_reg = 3'b001;
                8'b00010100: select_reg = 3'b010;
                8'b00010101: select_reg = 3'b011;
                8'b00010110: select_reg = 3'b100;
                8'b00010111: select_reg = 3'b101;
                8'b00011000: select_reg = 3'b110;
                8'b00011001: select_reg = 3'b000;
                8'b00011010: select_reg = 3'b001;
                8'b00011011: select_reg = 3'b010;
                8'b00011100: select_reg = 3'b011;
                8'b00011101: select_reg = 3'b100;
                8'b00011110: select_reg = 3'b101;
                8'b00011111: select_reg = 3'b110;
                8'b00100000: select_reg = 3'b000;
                8'b00100001: select_reg = 3'b001;
                8'b00100010: select_reg = 3'b010;
                8'b00100011: select_reg = 3'b011;
                8'b00100100: select_reg = 3'b100;
                8'b00100101: select_reg = 3'b101;
                8'b00100110: select_reg = 3'b110;
                8'b00100111: select_reg = 3'b000;
                8'b00101000: select_reg = 3'b001;
                8'b00101001: select_reg = 3'b010;
                8'b00101010: select_reg = 3'b011;
                8'b00101011: select_reg = 3'b100;
                8'b00101100: select_reg = 3'b101;
                8'b00101101: select_reg = 3'b110;
                8'b00101110: select_reg = 3'b000;
                8'b00101111: select_reg = 3'b001;
                8'b00110000: select_reg = 3'b010;
                8'b00110001: select_reg = 3'b011;
                8'b00110010: select_reg = 3'b100;
                8'b00110011: select_reg = 3'b101;
                8'b00110100: select_reg = 3'b110;
                8'b00110101: select_reg = 3'b000;
                8'b00110110: select_reg = 3'b001;
                8'b00110111: select_reg = 3'b010;
                8'b00111000: select_reg = 3'b011;
                8'b00111001: select_reg = 3'b100;
                8'b00111010: select_reg = 3'b101;
                8'b00111011: select_reg = 3'b110;
                default: select_reg = 3'b111;
            endcase
        end
    end
endmodule

//8 bit message into serial
//NOTE: This is a software hack. When synthesized, becomes a regular shift reg
module W_R_reg_readout (
	input logic [7:0] trigger_channel_mask, 
    input logic [7:0] instruction,
    input logic [7:0] mode,
    input logic [7:0] disc_polarity,
    input logic [7:0] vco_control,
    input logic [7:0] pll_div_ratio,
    input logic [7:0] pll_locked,
    input logic [7:0] slow_mode,
    input logic [7:0] trig_delay,
    input logic [7:0] mux_control_signal,
    input logic msg_flag,
	input logic sclk, 
	input logic rstn, 
	output logic serial_out
	);

	logic [7:0] held_data; //data in latched register
    logic [7:0] idata;
	logic [2:0] index_pointer; //Points to the index of addr which should be output 

    //Loading the data into the readout reg
	always_comb begin
        if (!rstn) begin
            idata = 8'b0;
        end
        else begin
            unique case (mux_control_signal)
                1: idata = trigger_channel_mask;
                2: idata = instruction;
                3: idata = mode;
                60: idata = pll_locked;
                61: idata = disc_polarity;
                62: idata = vco_control;
                63: idata = pll_div_ratio;
                64: idata = slow_mode;
                65: idata = trig_delay;
                default: idata = 8'b0;
            endcase
        end
    end

    latched_write_reg latched_data (.rstn (rstn), .data (idata), .latch_en (msg_flag), .stored_data (held_data));
	
	always_ff @(posedge sclk or negedge rstn) begin
		if (!rstn) begin
			serial_out <= 0;
			index_pointer <= 3'b0;
		end
		else begin
			serial_out <= held_data[index_pointer];
			index_pointer <= index_pointer + 1;
		end
	end
endmodule

module inst_driver (
    input logic rstn, //external
    input logic [7:0] instruction,
    input logic [7:0] mux_control_signal,
    input logic sclk,
    input logic iclk,
    input logic msg_flag,
    output logic clk_enable, 
    output logic inst_rst,
    output logic inst_readout,
    output logic inst_start
);
    always_comb begin
        if (!rstn) begin
            clk_enable = 0;
        end
        else if (instruction == 8'b0000_0011) begin //start instruction
            clk_enable = 1;
        end
        else begin //any other instruction
            clk_enable = 0;
        end
    end

    logic [15:0] addr_prev;
    logic msg_flag_prev;
    always_ff @(posedge sclk or negedge rstn) begin
        if(!rstn) begin
            addr_prev <= 16'b0;
            msg_flag_prev <= 0;
        end
        else begin
            addr_prev <= {addr_prev[7:0], mux_control_signal};
            msg_flag_prev <= msg_flag;
        end
    end

    logic combined_msg_flag;
    assign combined_msg_flag = msg_flag || msg_flag_prev;

    pulse_synchronizer rst_synch (
        .sclk (sclk),
        .spulse(combined_msg_flag && (addr_prev[7:0] == 8'b10 || addr_prev[15:8] == 8'b10) && instruction == 8'd1),
        .rstn (rstn),
        .iclk (iclk),
        .ipulse(inst_rst)
    );

    pulse_synchronizer readout_synch (
        .sclk (sclk),
        .spulse(combined_msg_flag && (addr_prev[7:0] == 8'b10 || addr_prev[15:8] == 8'b10) && instruction == 8'd2),
        .rstn (rstn),
        .iclk (iclk),
        .ipulse(inst_readout)
    );

    pulse_synchronizer start_synch (
        .sclk (sclk),
        .spulse(combined_msg_flag && (addr_prev[7:0] == 8'b10 || addr_prev[15:8] == 8'b10) && instruction == 8'd3),
        .rstn (rstn),
        .iclk (iclk),
        .ipulse(inst_start)
    );

endmodule

module pulse_synchronizer (
  input  logic sclk,
  input  logic spulse,
  input  logic rstn,
  input  logic iclk,
  output logic ipulse
);

  logic src_pulse_1;
  logic src_pulse_2;
  
  logic dest_pulse_1;
  logic dest_pulse_2;

  // src clock domain edge detection
  always_ff @(posedge sclk or negedge rstn) begin
    if (!rstn) begin
      src_pulse_1 <= 1'b0;
      src_pulse_2 <= 1'b0;
    end else begin
      src_pulse_1 <= spulse; //tracks src_pulse 1 src_clk cycle behind
      src_pulse_2 <= (spulse & ~src_pulse_1) ^ src_pulse_2; //detects rising edge and holds
    end
  end

  sync_bits sync_Bits_to_iclk (
    .clk(iclk),
    .rstn(rstn),
    .in(src_pulse_2),
    .out(dest_pulse_1)
  );

  always_ff @(posedge iclk or negedge rstn) begin
    if (!rstn) begin
      dest_pulse_2 <= 0;
      ipulse   <= 1'b0;
    end else begin
      dest_pulse_2 <= dest_pulse_1;
      ipulse <= dest_pulse_1 ^ dest_pulse_2;
    end
  end

endmodule

module sync_bits #(parameter SYNC_STAGES = 2) (
    input logic clk,
    input logic rstn,
    input logic in,
    output logic out
);
    logic [SYNC_STAGES-1:0] sync_regs;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sync_regs <= {SYNC_STAGES{1'b0}};
        end
        else begin
            sync_regs <= {sync_regs[SYNC_STAGES-2:0], in};
            out <= sync_regs[SYNC_STAGES-1];
        end
    end
endmodule