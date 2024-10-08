`timescale 1ns/1ps

module Testbench();


//i.e 1 full message (8 bits) should have MSG_SIZE = 2;



reg INST_START;
reg INST_STOP;
reg INST_READOUT;
reg RSTB;
reg DISCRIMINATOR_OUTPUT;// This is the unsync'ed input from the discriminator, which is in the analog part of the PSEC5.
reg SPI_CLK;//I moved some of the spi shift registers into this module, for the sake of speed and simplicity.
reg [9:0] CA;//These are counter values.
reg [9:0] CB;
reg [9:0] CC;
reg [9:0] CD;
reg [9:0] CE;
reg [1:0] MODE;
reg DISCRIMINATOR_POLARITY;
reg [2:0] SELECT_REG;
reg LOAD_CNT_SER;
reg PREMATURE_TRIGGER;
reg FCLK;
reg [4:0] TRIG_DELAY;
//NOTE: The final output of the module has to be synchronized to the 5GHz clock nonetheless, to avoid metastability issues. This is not implemented in this module yet.
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
wire CNT_SER;

int counter;




PSEC5_CH_DIGITAL UUT(
//inputs

.INST_START(INST_START),
.INST_STOP(INST_STOP),
.INST_READOUT(INST_READOUT),
.RSTB(RSTB),
.DISCRIMINATOR_OUTPUT(DISCRIMINATOR_OUTPUT),
.DISCRIMINATOR_POLARITY(DISCRIMINATOR_POLARITY),
.SPI_CLK(SPI_CLK),
.CA(CA),
.CB(CB),
.CC(CC),
.CD(CD),
.CE(CE),
.FCLK(FCLK),
.MODE(MODE),
.SELECT_REG(SELECT_REG),
.LOAD_CNT_SER(LOAD_CNT_SER),
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
.CNT_SER(CNT_SER)

);


        always begin //25ns SPI_CLK
            #25 SPI_CLK = ~SPI_CLK;
            end

        always begin //0.2ns FCLK
            #0.2 FCLK = ~FCLK;
            end 

        always begin //Counter variable keeping track of total time
        #1 counter <= counter + 1;
        end
        

        always begin // Timed delay of DISCRIMINATOR_OUTPUT, after 25ns it flips every 2ns from there on
        #2
            if (counter > 25) begin
              DISCRIMINATOR_OUTPUT = ~DISCRIMINATOR_OUTPUT;
              end
            end

initial begin



counter <= 0; //Used to keep track of total time passed, and intialize timed compents at their correct intervals

RSTB <= 1'b1; //Pulsing reset
#1
RSTB <= 1'b0;
#5
RSTB <= 1'b1;
#1


CA <= 10'b0000000000; //Arbitrary values 
CB <= 10'b1111111111;         
CC <= 10'b1010101010;     
CD <= 10'b0101010101;        
CE <= 10'b1111000011; 


INST_STOP <= 1'b0; //Initializing values of variables in the block
INST_READOUT <= 1'b0;
SPI_CLK <= 1'b0; 
FCLK <= 1'b0;   
MODE <= 2'b00;
DISCRIMINATOR_POLARITY = 1;
TRIG_DELAY <= 4'b0010;
DISCRIMINATOR_OUTPUT <= 1'b0;
SELECT_REG <= 3'b010;

INST_START <= 1'b0; //Pulse INST_START
#10
INST_START <= 1'b1;
#5
INST_START <= 1'b0;
#200


INST_STOP <= 1'b0; //Pulse INST_STOP
#10
INST_STOP <= 1'b1;
#5
INST_STOP <= 1'b0;
#200

INST_READOUT <= 1'b0; //Pulse INST_READOUT
#10
INST_READOUT <= 1'b1;
#5
INST_READOUT <= 1'b0;
#200

LOAD_CNT_SER <= 1'b0; //Pulse LOAD_CNT_SER
#10
LOAD_CNT_SER <= 1'b1;
#5
LOAD_CNT_SER <= 1'b0;
     

end

endmodule
