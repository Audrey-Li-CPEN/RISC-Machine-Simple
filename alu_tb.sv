module ALU_tb;
 //Definition Initialization 
 reg err;
 
 reg [15:0] Ain, Bin;
 reg [1:0] ALUop;
 wire [15:0] out;
 wire Z;
 
 //Test Instance for regfile
 ALU DUT(Ain,Bin,ALUop,out,Z);
 
  // Main Tests
  initial begin
    //Initialize required err signal to 0;
	 err= 1'b0;
	 
	 
	 //Initialize all other signals aside from err;
    Ain = 16'h0000;
    Bin = 16'h0000;
	 #10;
	 
	 
	 
	 //1st PART Test ALUop 00 Operations with Z = 0 or 1 and Addition OverFlow or Not
	 //Test 1: Test ALUop = 00 and Ain + Bin != 16'h0000,Z=0; 
	 ALUop = 2'b00;
	 Ain = 16'h1234;
	 Bin = 16'hDC56;
	 #10;
	 
	 assert(out == 16'hEE8A & Z == 1'b0) $display("Test 00+Z=0: PASS!");
	 else begin err =1'b1; $display("Test 00+Z=0: FAIL!");end
	 
	 
	 //Test 2: Test ALUop = 00 and Ain + Bin = 16'h0000,Z=1; 
	 ALUop = 2'b00;
	 Ain = 16'h0000;
	 Bin = 16'h0000;
	 #10;
	 
	 assert(out == 16'h0000 & Z == 1'b1) $display("Test 00+Z=1: PASS!");
	 else begin err =1'b1; $display("Test 00+Z=1: FAIL!");end
	 
	 //Test 3: ALUop == 00 + Addition Overflow Edge Case;
	 ALUop = 2'b00;
	 Ain = 16'hFFFF;
	 Bin = 16'h0001;
	 #10;
	 
	 assert(out == 16'h0000 & Z == 1'b1) $display("Test Add Overflow + Z=1: PASS!");
	 else begin err =1'b1; $display("Test Add Overflow + Z=1: FAIL!");end
	 
	 //Test 4: ALUop == 00 + Addition Overflow Non Edge Case;
	 ALUop = 2'b00;
	 Ain = 16'hFFFE;
	 Bin = 16'h0003;
	 #10;
	 
	 assert(out == 16'h0001 & Z == 1'b0) $display("Test Add Overflow + Z=0: PASS!");
	 else begin err =1'b1; $display("Test Add Overflow + Z=0: FAIL!");end
	 
	 
	 
	 
	 
	 //2st PART Test ALUop 01 Operations with Z = 0 or 1 and Subtraction UnderFlow or Not
	 //Test 5: Test ALUop = 01 and Ain - Bin != 16'h0000,Z=0; 
	 ALUop = 2'b01;
	 Ain = 16'hAAAA;
	 Bin = 16'h1111;
	 #10;
	 
	 assert(out == 16'h9999 & Z == 1'b0) $display("Test 01+Z=0: PASS!");
	 else begin err =1'b1; $display("Test 01+Z=0: FAIL!");end
	 
	 
	 //Test 6: Test ALUop = 00 and Ain - Bin = 16'h0000, Z = 1; 
	 ALUop = 2'b01;
	 Ain = 16'hAAAA;
	 Bin = 16'hAAAA;
	 #10;
	 
	 assert(out == 16'h0000 & Z == 1'b1) $display("Test 01+Z=1: PASS!");
	 else begin err =1'b1; $display("Test 01+Z=1: FAIL!");end
	 
	 //Test 7: ALUop == 00 + Subtraction Underflow Edge Case;
	 ALUop = 2'b01;
	 Ain = 16'h0000;
	 Bin = 16'h0001;
	 #10;
	 
	 assert(out == 16'hFFFF & Z == 1'b0) $display("Test Underflow + Z=0: PASS!");
	 else begin err =1'b1; $display("Test Underflow + Z=0: FAIL!");end
	 
	 
	 
	 
	 
	 //3RD PART Test ALUop 10 Operations with Z = 0 or 1
	 //Test 8: Test ALUop = 10 and Ain & Bin != 16'h0000; 
	 ALUop = 2'b10;
	 Ain = 16'h0011;
	 Bin = 16'h0011;
	 #10;
	 
	 assert(out == 16'h0011 & Z == 1'b0) $display("Test 10+Z=0: PASS!");
	 else begin err =1'b1; $display("Test 10+Z=0: FAIL!");end
	 
	 
	 //Test 9: Test ALUop = 10 and Ain & Bin = 16'h0000; 
	 ALUop = 2'b10;
	 Ain = 16'h0000;
	 Bin = 16'hFFFF;
	 #10;
	 
	 assert(out == 16'h0000 & Z == 1'b1) $display("Test 10+Z=1: PASS!");
	 else begin err =1'b1; $display("Test 10+Z=1: FAIL!");end
	 
	
	
	
	
	  //4th PART Test ALUop 11 Operations with Z = 0 or 1
	 //Test 10: Test ALUop = 11 and ~Bin != 16'h0000; 
	 ALUop = 2'b11;
	 Bin = 16'h0000;
	 #10;
	 
	 assert(out == 16'hFFFF & Z == 1'b0) $display("Test 11+Z=0: PASS!");
	 else begin err =1'b1; $display("Test 11+Z=0: FAIL!");end
	 
	 
	 //Test 11: Test ALUop = 11 and Ain & Bin = 16'h0000; 
	 ALUop = 2'b11;
	 Bin = 16'hFFFF;
	 #10;
	 
	 assert(out == 16'h0000 & Z == 1'b1) $display("Test 11+Z=1: PASS!");
	 else begin err =1'b1; $display("Test 11+Z=1: FAIL!");end
	 
	
	
	
	 
	 if (err) $display("Some FAIL!!");
	 else $display("ALL PASS!!!");
	 
	 #380;
	 $stop;
	 
  end
  
endmodule