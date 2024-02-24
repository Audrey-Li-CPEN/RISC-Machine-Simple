
module cpu_tb;
  reg clk, reset;

  wire N,V,Z,w;
  reg  [15:0] read_data; // 16-bit data from memory
  wire [1:0]  mem_cmd;   // 2-bit command
  wire [8:0]  mem_addr;  // 9-bit address
  wire[15:0] write_data;//16-bit data to memory

  reg err;
  cpu DUT(clk,reset,read_data, mem_cmd, mem_addr, write_data,N,V,Z,w);

  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

  initial begin
   //The structure of the test bench is cited from lab7_autograder_check
   //Test 1: MOV 10 to R0: R0 should be 10 after 2 cycles
    err = 0;
    reset = 1; #50; reset = 0; #10;

    read_data = 16'b110_10_00000001010; //MOV R0,#10;
 
    if (cpu_tb.DUT.PC !== 9'h0) begin err = 1; $display("FAILED: PC should be 0.   %b", cpu_tb.DUT.PC); $stop; end

    @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X

    if (cpu_tb.DUT.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end


    @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X

    if (cpu_tb.DUT.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'd10) begin err = 1; $display("FAILED: R0 should be 10."); $stop; end  // because MOV R0, X should have occurred
   
   else $display("PASS!MOV R0, #10");
   


    //Test 2: Test Reset
    reset = 1; #50; reset = 0; #10;

    read_data = 16'b110_00_000_010_00_000; //MOV R2,R0;
    
    //Test 3: MOV R0 to R2:R2 should be 10 after 3 cycles
   if (cpu_tb.DUT.PC !== 9'h0) begin err = 1; $display("FAILED: PC should be 0, %b", cpu_tb.DUT.PC); $stop; end
    @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

    if (cpu_tb.DUT.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1.%b", cpu_tb.DUT.PC); $stop; end
    
    @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R2, R0
    
    if (cpu_tb.DUT.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd10) begin err = 1; $display("FAILED: R2 should be 10."); $stop; end  // because MOV R2, R0 should have occurred
    
    else $display("PASS!MOV R2, R0");


    //Test 3: ADD R4, R0, R2, LSL#1, R4 = 30 after  3 cycles not starting from reset stage

    read_data = 16'b101_00_000_100_01_010; //ADD R4, R0, R2, LSL#1

      @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

    if (cpu_tb.DUT.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 1.%b", cpu_tb.DUT.PC); $stop; end
    
    @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R2, R0
    
    if (cpu_tb.DUT.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    
      @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

      if (cpu_tb.DUT.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 1.%b", cpu_tb.DUT.PC); $stop; end
      
      if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'd30) begin err = 1; $display("FAILED: R2 should be 10."); $stop; end  // because MOV R2, R0 should have occurred
    
    else $display("PASS!ADD R4, R0, R2, LSL#1");



    
      //Test 4: CMP R2, R4, N flag should be on after 3 cycles not starting from reset stage
      read_data = 16'b101_01_010_000_00_100; //CMP R2, R4

      @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

      if (cpu_tb.DUT.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6.%b", cpu_tb.DUT.PC); $stop; end
      
      @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R2, R0
      
      if (cpu_tb.DUT.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
      
        @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0
  
        if (cpu_tb.DUT.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8.%b", cpu_tb.DUT.PC); $stop; end

        if (cpu_tb.DUT.DP.N !== 1'b1) begin err = 1; $display("FAILED: N should be 1."); $stop; end  // because MOV R2, R0 should have occurred
      
      else $display("PASS!CMP R2, R4");

//Test 5: AND R6, R2, R0, R6 = 10 after 4 cycles not counting from reset.
        
        read_data = 16'b101_10_010_110_00_000; //AND R6, R2, R0

        @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

        if (cpu_tb.DUT.PC !== 9'h9) begin err = 1; $display("FAILED: PC should be 9.%b", cpu_tb.DUT.PC); $stop; end

        @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R2, R0
        if (cpu_tb.DUT.PC !== 9'd10) begin err = 1; $display("FAILED: PC should be 10.%b", cpu_tb.DUT.PC); $stop; end
        
          @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0
    
          if (cpu_tb.DUT.PC !== 9'd11) begin err = 1; $display("FAILED: PC should be 11.%b", cpu_tb.DUT.PC); $stop; end

      
          if (cpu_tb.DUT.DP.REGFILE.R6 !== 16'd10) begin err = 1; $display("FAILED: R6 should be 10. out: %b", cpu_tb.DUT.DP.REGFILE.R6); $stop; end  // because MOV R2, R0 should have occurred
        
        else $display("PASS!AND R6, R2, R0");



//Test 7: MVN R4, R6; R4 = 16'hFFF5  after 2 cycles

          read_data = 16'b101_11_000_100_00_110; //MVN R4, R6
         
          @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

          if (cpu_tb.DUT.PC !== 9'd12) begin err = 1; $display("FAILED: PC should be 12.%b", cpu_tb.DUT.PC); $stop; end

            @(posedge cpu_tb.DUT.PC or negedge cpu_tb.DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R2, R0

            if (cpu_tb.DUT.PC !== 9'd13) begin err = 1; $display("FAILED: PC should be 13.%b", cpu_tb.DUT.PC); $stop; end

            if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'hFFF5) begin err = 1; $display("FAILED: R4. BUT: %b", cpu_tb.DUT.DP.REGFILE.R5); $stop; end  // because MOV R2, R0 should have occurred
          
          else $display("PASS!MVN R5, R6");


      
   $stop;

	end
endmodule