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
.serial_out(serial_out) 
);











//Device fro Jins Code:

//Channel 0
PSEC5_CH_DIGITAL thingy0(
//inputs

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[0]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[1]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[2]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[3]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[4]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[5]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[6]), //Specific per channel, from spi
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

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
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
.SELECT_REG(SELECT_REG), 
.LOAD_CNT_SER(load_cnt_ser[7]), //Specific per channel, from spi
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
.raw_serial_out({CNT_SER0, CNT_SER1, CNT_SER2, CNT_SER3, CNT_SER4, CNT_SER5, CNT_SER6, CNT_SER7}),
.wr_serial_out(serial_out),
.load_cnt_ser(load_cnt_ser),

//outputs
.serial_out(serial_out_mux)

);






//Start adding values!!!

//SPI Clock (25ns)
always begin
    #25 sclk = ~sclk;
end

// F Clock (0.2ns)
always begin
    #0.2 FCLK = ~FCLK;
end

always begin
    #1 counter <= counter + 1;
end



endmodule
