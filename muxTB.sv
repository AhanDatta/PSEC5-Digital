`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Frisch Group
// Engineer: Andrew Arzac
// 
// Create Date: 08/23/2024 10:54:10 AM
// Design Name: 
// Module Name: SpiMuxTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: A
// Revision 0.01 - File Created
// Additional Comments: I hope this works :)
// 
//////////////////////////////////////////////////////////////////////////////////


//Testbench to verify SPI block's new design with MUX included
module SpiMuxTB();

parameter MSG_SIZE = 2; //Determins how many bytes serial in will be



//inputs into SPI block
reg serial_in;
reg sclk;
reg [7:0] pll_locked;
reg iclk;
reg rstn;

//Outputs from SPI block

wire clk_enable;
wire inst_rst;
wire inst_readout;
wire inst_start;
wire [7:0] load_cnt_ser;
wire [2:0] select_reg;
wire [7:0] trigger_channel_mask;
wire [7:0] mode;
wire [7:0] disc_polarity;
wire [7:0] vco_control;
wire [7:0] pll_div_ratio;
wire [7:0] slow_mode;
wire [7:0] trig_delay;
wire serial_out;
wire [7:0] mux_control_signal;

//Inputs into Jins code

reg INST_START;
reg INST_STOP;
reg INST_READOUT;
reg RSTB;
reg DISCRIMINATOR_OUTPUT;
reg SPI_CLK;
reg [9:0] CA0, CA1, CA2, CA3, CA4, CA5, CA6, CA7;
reg [9:0] CB0, CB1, CB2, CB3, CB4, CB5, CB6, CB7;
reg [9:0] CC0, CC1, CC2, CC3, CC4, CC5, CC6, CC7;
reg [9:0] CD0, CD1, CD2, CD3, CD4, CD5, CD6, CD7;
reg [9:0] CE0, CE1, CE2, CE3, CE4, CE5, CE6, CE7;
reg MODE; //Output mode from SPI block, only first 2 bits
reg DISCRIMINATOR_POLARITY; //From SPI block
reg [2:0] SELECT_REG;
reg LOAD_CNT_SER;
reg [4:0] TRIG_DELAY;
reg FCLK;

//Outputs for Jins code

wire STOP_REQUEST;
wire TRIGGERA;
wire TRIGGERB;
wire TRIGGERC;
wire TRIGGERD;
wire TRIGGERE;
wire TRIGGERAC;
wire TRIGGERBC;
wire TRIGGERCC;
wire TRIGGERDC;
wire CNT_SER0, CNT_SER1, CNT_SER2, CNT_SER3, CNT_SER4, CNT_SER5, CNT_SER6, CNT_SER7;

//Inputs into mux;

//reg sclk; //Defined Above
reg [7:0] raw_serial_out;
reg wr_serial_out;
//reg [7:0] load_cnt_ser; //Same as SPI

//Outputs Mux
wire serial_out_mux;




integer counter;
integer serial_in_counter;
reg onoff_serial_in;
reg[MSG_SIZE*8:0] total_msg;
reg sclk_onoff;

logic [7:0] readoutxx;









SPI spi(
.serial_in(serial_in),
.sclk(sclk),
.pll_locked(pll_locked),
.iclk(iclk),
.rstn(rstn),


.clk_enable(clk_enable),
.inst_rst(inst_rst),          
.inst_readout(inst_readout),       
.inst_start(inst_start),
.load_cnt_ser(load_cnt_ser),
.select_reg(select_reg),
.trigger_channel_mask(trigger_channel_mask),
.mode(mode),
.disc_polarity(disc_polarity),
.vco_control(vco_control), 
.pll_div_ratio(pll_div_ratio),
.slow_mode(slow_mode),
.trig_delay(trig_delay),
.serial_out(serial_out),
.mux_control_signal(mux_control_signal)
);











//Device fro Jins Code:

//Channel 0
PSEC5_CH_DIGITAL thingy0(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[0]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA0), //Random for each channel
.CB(CB0),
.CC(CC0),
.CD(CD0),
.CE(CE0),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[0]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER0)
);





//Channel 1
PSEC5_CH_DIGITAL thingy1(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[1]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA1), //Random for each channel
.CB(CB1),
.CC(CC1),
.CD(CD1),
.CE(CE1),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[1]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER1)
);





//Channel 2
PSEC5_CH_DIGITAL thingy2(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[2]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA2), //Random for each channel
.CB(CB2),
.CC(CC2),
.CD(CD2),
.CE(CE2),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[2]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER2)
);





//Channel 3
PSEC5_CH_DIGITAL thingy3(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[3]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA3), //Random for each channel
.CB(CB3),
.CC(CC3),
.CD(CD3),
.CE(CE3),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[3]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER3)
);





//Channel 4
PSEC5_CH_DIGITAL thingy4(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[4]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA4), //Random for each channel
.CB(CB4),
.CC(CC4),
.CD(CD4),
.CE(CE4),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[4]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER4)
);





//Channel 5
PSEC5_CH_DIGITAL thingy5(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[5]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA5), //Random for each channel
.CB(CB5),
.CC(CC5),
.CD(CD5),
.CE(CE5),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[5]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER5)
);





//Channel 6
PSEC5_CH_DIGITAL thingy6(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[6]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA6), //Random for each channel
.CB(CB6),
.CC(CC6),
.CD(CD6),
.CE(CE6),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[6]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER6)
);




//Channel 7
PSEC5_CH_DIGITAL thingy7(
//inputs

.INST_START(inst_start),
.INST_STOP(INST_STOP),
.INST_READOUT(inst_readout),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(disc_polarity[7]), //Connected to spi, 1 bit per channel
.SPI_CLK(sclk),
.CA(CA7), //Random for each channel
.CB(CB7),
.CC(CC7),
.CD(CD7),
.CE(CE7),
.FCLK(FCLK),
.MODE(mode[1:0]),
.SELECT_REG(select_reg), 
//.LOAD_CNT_SER(load_cnt_ser[7]), //Specific per channel, from spi
.TRIG_DELAY(TRIG_DELAY),

//outputs
.STOP_REQUEST(STOP_REQUEST),
.TRIGGERA(TRIGGERA),
.TRIGGERB(TRIGGERB),
.TRIGGERC(TRIGGERC),
.TRIGGERD(TRIGGERD),
.TRIGGERE(TRIGGERE),
.TRIGGERAC(TRIGGERAC),
.TRIGGERBC(TRIGGERBC),
.TRIGGERCC(TRIGGERCC),
.TRIGGERDC(TRIGGERDC),
.CNT_SER(CNT_SER7)
);


//MUX Device

serial_out_mux doodad(

//inputs
.sclk(sclk),
.raw_serial_out({CNT_SER7, CNT_SER6, CNT_SER5, CNT_SER4, CNT_SER3, CNT_SER2, CNT_SER1, CNT_SER0}),
.wr_serial_out(serial_out),
.mux_control_signal(mux_control_signal),
.rstn(rstn),

//outputs
.serial_out(serial_out_mux)

);


task send_serial_data(input [7:0] data, output [7:0] read_data);
  for (int j = 7; j >= 0; j--) begin
    serial_in = data[j];
    @(posedge iclk); //assumes sclk becomes clk
    sclk = 1;
    @(negedge iclk);
    sclk = 0;
    read_data[7-j] = serial_out;
  end
endtask



//Start adding values!!!

////SPI Clock (25ns)
//always begin
    
//    #25
    
//    if(sclk_onoff) begin

//        sclk = ~sclk;
    
//    end 
    
    
//end

always begin
    #25 iclk = ~iclk;
end

// F Clock (0.2ns)
always begin
    #0.2 FCLK = ~FCLK;
end


//Counter to keep track of total time passed in simulation
always begin
    #1 counter <= counter + 1;
end


//always @(posedge sclk) begin

//    if (onoff_serial_in > 0) begin
//            if (serial_in_counter < 8*MSG_SIZE) begin
    
//                serial_in = total_msg[serial_in_counter];
//                serial_in_counter <= serial_in_counter + 1;
//            end
            
//            else begin
            
//            onoff_serial_in <= 1'b0;
//            #5
//            serial_in_counter = 0;
//            end
            
//    end

//end


        always begin // Timed delay of DISCRIMINATOR_OUTPUT, after 25ns it flips every 2ns from there on
        #5
            if (counter > 55) begin
              DISCRIMINATOR_OUTPUT = ~DISCRIMINATOR_OUTPUT;
              end
            end




initial begin

counter <= 0;
serial_in_counter <= 0;
onoff_serial_in <= 1'b0;
sclk_onoff <= 1'b0;


//Initializing Clocks
sclk <= 1'b0;
iclk <= 1'b0;
FCLK <= 1'b0;





#25

//Global Reset
rstn <= 1'b1;
RSTB <= 1'b1;
#5
rstn <= 1'b0;
RSTB <= 1'b0;
#10
rstn <= 1'b1;
RSTB <= 1'b1;
#5






//Initializing Channel Values, CA-CE

CA0 <= 10'b0000000011;
CB0 <= 10'b0011111111;
CC0 <= 10'b1111000000;
CD0 <= 10'b0000001111;
CE0 <= 10'b1111111100;

CA1 <= 10'b0000010000;
CB1 <= 10'b0000100000;
CC1 <= 10'b0001000000;
CD1 <= 10'b0010000000;
CE1 <= 10'b0100000000;

CA2 <= 10'b1111111111;
CB2 <= 10'b1111100000;
CC2 <= 10'b0000011111;
CD2 <= 10'b1111000011;
CE2 <= 10'b1010101010;

CA3 <= 10'b1010100101;
CB3 <= 10'b1001010101;
CC3 <= 10'b0010011011;
CD3 <= 10'b0100001111;
CE3 <= 10'b0100100111;

CA4 <= 10'b0011101011;
CB4 <= 10'b0101010101;
CC4 <= 10'b0011010111;
CD4 <= 10'b1111011101;
CE4 <= 10'b1111101110;

CA5 <= 10'b0101111010;
CB5 <= 10'b0000010001;
CC5 <= 10'b0101000100;
CD5 <= 10'b0010011010;
CE5 <= 10'b0101000010;

CA6 <= 10'b0010010010;
CB6 <= 10'b1001010001;
CC6 <= 10'b0100110010;
CD6 <= 10'b0101001101;
CE6 <= 10'b1000101010;

CA7 <= 10'b1001001001;
CB7 <= 10'b1001010101;
CC7 <= 10'b0101010011;
CD7 <= 10'b1001010101;
CE7 <= 10'b0101010100;

//Remaining Input Initialization for SPI_Peripheral
pll_locked <= 8'b00000000;

//Initializing Remaining Inptus for psec5_digital_august2024
INST_STOP <= 1'b0; //Initializing values of variables in the block
//INST_READOUT <= 1'b0; 
//MODE <= 2'b00;
TRIG_DELAY <= 4'b0010;
DISCRIMINATOR_OUTPUT <= 1'b0;
SELECT_REG <= 3'b000;


//Initializing Inputs for serial_out_mux
raw_serial_out <= 8'b00000000;
wr_serial_out <= 1'b0;

#10

//Inputting serial_in values

//Writing to register 1
send_serial_data(8'b00000001, readoutxx);
send_serial_data(8'b00000011, readoutxx);

#500

//Writing to register 3
send_serial_data(8'b00000011, readoutxx);
send_serial_data(8'b00000010, readoutxx);

#500

//Writing to register 2
send_serial_data(8'b00000010, readoutxx);
send_serial_data(8'b00000011, readoutxx);

#500

//Writing to register 2
send_serial_data(8'b00000010, readoutxx);
send_serial_data(8'b00000010, readoutxx);

#500

//Reading from everything now

//Initial adress being set to 4
send_serial_data(8'b00000100, readoutxx);


//Channel 0
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 1
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 2
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 3
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 4
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 5
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 6
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

//Channel 7
send_serial_data(8'b00001010, readoutxx);
send_serial_data(8'b00110111, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b01101010, readoutxx);
send_serial_data(8'b00110101, readoutxx);
send_serial_data(8'b00110101, readoutxx);

        end

endmodule
