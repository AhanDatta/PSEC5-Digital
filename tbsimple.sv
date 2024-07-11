`timescale 100ps/100ps

module testbench;

parameter MSG_SIZE = 5; //How many messages you want to send, (Must add 1 to include space for address)
//i.e 1 full message (8 bits) should have MSG_SIZE = 2;

reg serial_in; //input
reg sclk; //input
reg iclk; //internal clock, input
reg rstn; //external reset, input
wire [7:0] load_cnt_ser; //output
wire [2:0] select_reg; //output
wire [7:0] trigger_channel_mask; //address 1, output
wire [7:0] instruction; //address 2, output
wire [7:0] mode; //address 3, W/R reg, output

reg [MSG_SIZE*8:0] total_message; 
int counter;


SPI_real UUT(

//inputs
.serial_in(serial_in),
.sclk(sclk),
.iclk(iclk),
.rstn(rstn),

//outputs
.load_cnt_ser(load_cnt_ser),
.select_reg(select_reg),
.trigger_channel_mask(trigger_channel_mask),
.instruction(instruction),
.mode(mode)
);


        always begin
            #25 sclk = ~sclk;
            end
            
        always begin
            #25 iclk = ~iclk;
        end 

        always @(posedge sclk) begin


              if (counter < 8*MSG_SIZE) begin
          serial_in <= total_message[counter];
              end


            counter++;

        end

initial begin
        counter = 0;
        sclk <= 0;
        iclk <=0 ;
        serial_in = 1'b0;
        total_message = 16'b0000011101010101111111110000000010101010;
        rstn <= 1'b1;
        #5
        rstn <= 1'b0;
        #5
        rstn <= 1'b1;
        #5

//            while (counter < 8*MSG_SIZE) begin

//                serial_in <= total_message[counter];

//            end




    // //address data
    //     serial_in <= 1'b0;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b0;
    //      //message
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b0;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b1;
    //     #50 serial_in <= 1'b1;

    #1
    $display ("[$display] time = %0t, load_cnt_ser = %0b, select_reg = %0b, trigger_channel_mask = %0b, instruction = %0b, mode = %0b", $time, load_cnt_ser, select_reg, trigger_channel_mask, instruction, mode);

end



endmodule