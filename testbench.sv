//Define what is input and output for DUT
class transaction;

    //Simulates the data sitting in the analog registers
    rand logic [49:0] ch0;
    rand logic [49:0] ch1;
    rand logic [49:0] ch2;
    rand logic [49:0] ch3;
    rand logic [49:0] ch4;
    rand logic [49:0] ch5;
    rand logic [49:0] ch6;
    rand logic [49:0] ch7;

    //Holds a variable length array of input messages
    //Gets converted to serial by the driver
    logic [7:0] input_bytes [];
    //From the output of the DUT
    //Length should be the same as "input_bytes"
    logic [7:0] output_bytes [];

endclass

class generator;

    rand transaction trans;

endclass