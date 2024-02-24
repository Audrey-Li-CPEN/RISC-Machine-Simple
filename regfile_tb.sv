module regfile_tb;
  //Definition Initialization 
  reg err;
  
  reg [15:0] data_in;
  reg [2:0] writenum, readnum;
  reg write, clk;
  
  wire [15:0] data_out;
  
  //Test Instance for regfile
  regfile DUT(.data_in(data_in),.writenum(writenum),.write(write),.readnum(readnum),.clk(clk),.data_out(data_out));
  
  
  //Set clock
  initial begin 
    clk = 1'b0;
	 #5;
	 forever begin
	 clk = ~clk;
	 #5;
	 end
  end
  
  // Main Tests
  initial begin
    //Initialize required err signal to 0;
	 err= 1'b0;
	 
	 
	 //Initialize all other signals aside from clk and err;
    data_in = 16'h0000;
    writenum = 3'b000;
    readnum = 3'b000;
    write = 1'b0;
	 #10;
	  
    // Test1-8: write and read from each of the 8 registers, each R0-R7 should update
	 repeat(8) begin
	 
       data_in = writenum;#10;
       write = 1'b1; #10;  
       write = 1'b0; #10;  
       readnum = writenum; #10; 
		
		
		$display("Test Write and Read: %b", writenum);
		assert (data_out == writenum) $display("PASS");
        else begin $error("FAIL"); err = 1'b1;end
      
		$display("Registers for test: %b", writenum);
          if (writenum == 3'b000 & DUT.R0 != writenum) 
			    begin err = 1'b1; $display("R0 Wrong");end
				 else $display("R0 Pass");
			
          if (writenum == 3'b001 & DUT.R1 != writenum)
			    begin err = 1'b1; $display("R1 Wrong");end
				 else $display("R1 Pass");
				 
          if (writenum == 3'b010 & DUT.R2 != writenum)
			    begin err = 1'b1; $display("R2 Wrong");end
				  else $display("R2 Pass");
				 
          if (writenum == 3'b011 & DUT.R3 != writenum)
			    begin err = 1'b1; $display("R3 Wrong");end
				  else $display("R3 Pass");
				  
          if (writenum == 3'b100 & DUT.R4 != writenum) 
			    begin err = 1'b1; $display("R4 Wrong");end
				  else $display("R4 Pass");
				 
          if (writenum == 3'b101 & DUT.R5 != writenum)
			    begin err = 1'b1; $display("R5 Wrong");end
				  else $display("R5 Pass");
				 
          if (writenum == 3'b110 & DUT.R6 != writenum)
			    begin err = 1'b1; $display("R6 Wrong");end
				  else $display("R6 Pass");
				  
          if (writenum == 3'b111 & DUT.R7 != writenum)
			    begin err = 1'b1; $display("R7 Wrong");end
				  else $display("R7 Pass");
		 
		 writenum = writenum + 3'b001;
     end
	 
	 // Test 2: write = 0; No write No update for R0-7;
	     data_in = 16'hABCD;
		  
        writenum = 3'b000;
        write = 1'b0;
        #10;  
		  
		  //Test regardless of the register read from R0-R7, always no updates to the data_out
		  $display("Regardless of the register read from R0-R7, always no updates to the data_out");
		  
		  repeat(8) begin
        readnum = writenum;
        #10;  // Wait for 10 ns
        assert (data_out != data_in & DUT.R0 != data_in & DUT.R1 != data_in & DUT.R2 != data_in & DUT.R3 != data_in 
		          & DUT.R4 != data_in& DUT.R5 != data_in & DUT.R6 != data_in & DUT.R7 != data_in)    $display("Pass");
		  else begin err = 1; $display("Fail");end
		  
		  writenum = writenum + 3'b001;
		  end
	
	
	if (err) $display("Result: Fail!"); 
	else $display("Result: Pass");
	 
	 #80;
	 $stop;
	 
   end 
endmodule
  