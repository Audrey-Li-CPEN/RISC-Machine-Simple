// Define a register file module with data input, write number, write enable, read number, clock, and data output.
module regfile (
    input[15:0] data_in,
    input[2:0]writenum,
    input write,
    input[2:0]readnum,
    input clk,
    output [15:0] data_out
);

wire [7:0] Dec1_out;

reg [15:0]R0;
reg [15:0]R1;
reg [15:0]R2;
reg [15:0]R3;
reg [15:0]R4;
reg [15:0]R5;
reg [15:0]R6;
reg [15:0]R7;
wire [7:0] Dec2_out;

// Instantiate the write decoder
Dec38 Dec1(writenum,Dec1_out);
// Instantiate writeToR modules for writing data into the registers
writeToR WR0(Dec1_out[0],write,data_in,clk,R0);
writeToR WR1(Dec1_out[1],write,data_in,clk,R1);
writeToR WR2(Dec1_out[2],write,data_in,clk,R2);
writeToR WR3(Dec1_out[3],write,data_in,clk,R3);
writeToR WR4(Dec1_out[4],write,data_in,clk,R4);
writeToR WR5(Dec1_out[5],write,data_in,clk,R5);
writeToR WR6(Dec1_out[6],write,data_in,clk,R6);
writeToR WR7(Dec1_out[7],write,data_in,clk,R7);

Dec38 Dec2(readnum,Dec2_out);
// Instantiate the multiplexer to select which register to read
Mux8 mux(R0,R1,R2,R3,R4,R5,R6,R7,Dec2_out,data_out);
endmodule
// Module for writing data to a register with enable control
module writeToR ( 
    input Dec1_out,
    input write,
    input[15:0] data_in,
    input clk,
    output reg [15:0] R
);

wire load = write & Dec1_out;
// Instantiate a parameterized D flip-flop with enable (vDFFE2)
vDFFE2 #(16) vdffe(clk, load, data_in, R);

endmodule


module vDFFE2(clk, load, in, out);
  parameter n = 1;
  input clk, load ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = load ? in : out;
  // Determine the next state of the flip-flop
  always @(posedge clk)
    out = next_out;  
endmodule



module Dec38 (bin, onehot);
//     input[2:0] threebits,
//     output [7:0] eightbits
// );
//     // The output is a one-hot encoding of the input
//     // The input value selects which bit of the output is high
//     assign eightbits = 1 << threebits;
// endmodule

  parameter n = 3;
  parameter m = 8;
  
  input[n-1:0] bin;
  output [m-1:0] onehot;
  
  wire [m-1:0] onehot = 8'b1 << bin;
endmodule

module Mux8 (R0,R1,R2,R3,R4,R5,R6,R7,s,out);
    input [15:0] R0; // Input channel 0
    input [15:0] R1; // Input channel 1
    input [15:0] R2; // Input channel 2
    input [15:0] R3; // Input channel 3
    input [15:0] R4; // Input channel 4
    input [15:0] R5; // Input channel 5
    input [15:0] R6; // Input channel 6
    input [15:0] R7; // Input channel 7
    input [7:0] s;   // One-hot select signal
    output [15:0] out;
// The multiplexer logic, which selects one of the registers based on the one-hot select signal
    assign out = 
    (R0 & {16{s[0]}}) | 
    (R1 & {16{s[1]}}) |
    (R2 & {16{s[2]}}) |
    (R3 & {16{s[3]}}) |
    (R4 & {16{s[4]}}) |
    (R5 & {16{s[5]}}) |
    (R6 & {16{s[6]}}) |
    (R7 & {16{s[7]}});

endmodule


