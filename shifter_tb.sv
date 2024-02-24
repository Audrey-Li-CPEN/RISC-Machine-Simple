module shifter_tb;
   //Definition Initialization
	reg err;
  
  reg [15:0] in;
  reg [1:0] shift;
  
  wire [15:0] sout;
  
  //Module Instance for Testing
  shifter DUT(in, shift,sout);
  
  
  //Main Tests
  initial begin
  //Initialization Signals
  err =1'b0;
  in = 16'h0000;
  shift = 2'b00;
  #10;
  
  //Test 1: 00 Operation： No shift
  in = 16'hABCD;
  shift = 2'b00;
  #10;
  
  assert(sout == 16'hABCD) $display ("00 OPeration: PASS");
  else begin err=1'b1; $display("00 OPeration: FAIL"); end
  
   //Test 2: 01 Operation： Shift Left 1, Least Sig. 0;
  in = 16'b1111111100011101;
  shift = 2'b01;
  #10;
  
  assert(sout == 16'b1111111000111010) $display ("01 OPeration: PASS");
  else begin err=1'b1; $display("01 OPeration: FAIL"); end
  
  
   //Test 3: 10 Operation： Shift Right 1, MOST Sig. 0;
  in = 16'b1111111100011101;
  shift = 2'b10;
  #10;
  
  assert(sout == 16'b0111111110001110) $display ("10 OPeration: PASS");
  else begin err=1'b1; $display("10 OPeration: FAIL"); end
  
  
   //Test 4: 11 Operation： Shift Right 1, MOST Sig. B[15];
  in = 16'b1111111100011101;
  shift = 2'b11;
  #10;
  
  assert(sout == 16'b1111111110001110) $display ("11 OPeration: PASS");
  else begin err=1'b1; $display("11 OPeration: FAIL"); end
  
  if (err) $display("SOME FAIL!");
  else $display("ALL PASS!!!");
  
  #450;
  $stop;
  end
endmodule
  