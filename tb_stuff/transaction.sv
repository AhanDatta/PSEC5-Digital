//Transaction, AKA Packet class
class transaction;

//These are the inputs to our design:
  rand logic [49:0] ch0;  
  rand logic [49:0] ch1;
  rand logic [49:0] ch2;
  rand logic [49:0] ch3;
  rand logic [49:0] ch4;
  rand logic [49:0] ch5;
  rand logic [49:0] ch6;
  rand logic [49:0] ch7;
  rand logic serial_in;
  logic serial_out;

  function void display(string tag);
    $display ("----------------");
    $display ("tag= %s", tag);
    $display ("----------------");
    $display ("ch 0 = %0d, ch 1 = %0d, ch 2 = %0d, ch 3 = %0d, ch 4 = %0d, ch 5 = %0d, ch 6 = %0d, ch 7 = %0d, ", ch0, ch1, ch2, ch3, ch4, ch5, ch6, ch7);
    $display ("serial_in = %0d, serial_out = %0d", serial_in, serial_out);

  endfunction

endclass 