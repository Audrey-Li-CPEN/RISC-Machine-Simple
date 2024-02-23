//-------------vesl changed to 4bits-------------------
//    input [15:0]datapath_in,     was deleted
//    input[15:0] mdata, was added
//    input[15:0] sximm8, was added
//    input[7:0] PC, was added
//    input[15:0] sximm5, was added
//    output V_out, was added
//    output N_out, was added
module datapath (
    input clk,
    input [2:0] readnum,
    input [3:0]vsel,
    input loada,
    input loadb,
    input[1:0] shift,
    input asel,
    input bsel,
    input[1:0] ALUop,
    input loadc,
    input loads,
    input [2:0] writenum,
    input write,
    input[15:0] mdata,
    input[15:0] sximm8,
    input[7:0] PC,
    input[15:0] sximm5,
    output Z_out,
    output V_out,
    output N_out,
    output [15:0]datapath_out,
    output [15:0] data_out
);//clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,writenum,write,read_data,sximm8,PC,sximm5,Z,V,N,out

wire [15:0]data_in;

wire [15:0]out_A;
wire [15:0]out_B;
wire [15:0]sout;

wire[15:0] Ain;
wire[15:0] Bin;

wire[15:0] ALU_out;
wire Z;
wire V;
wire N;

// 2-to-1 multiplexer to select between two inputs based on the vsel signal.
Mux4 M9(mdata,sximm8,{8'b0,PC},datapath_out,vsel,data_in);

// Register file which stores data and allows read and write operations.
regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);

vDFFE #(16) LA(clk, loada, data_out, out_A);
vDFFE #(16) LB(clk, loadb, data_out, out_B);
// Shifter module to perform shift operations on the data from B register.
shifter SFT(out_B, shift, sout);

assign Ain = (asel) ? {16'b0} : out_A;
assign Bin = (bsel) ? sximm5 : sout;
// ALU for performing arithmetic and logical operations.
ALU Alu(Ain,Bin,ALUop,ALU_out,Z,V,N);

vDFFE #(16) LC(clk, loadc, ALU_out, datapath_out);
vDFFE LZ(clk, loads, Z, Z_out);
vDFFE LV(clk, loads, V, V_out);
vDFFE LN(clk, loads, N, N_out);

endmodule

module vDFFE(clk, load, in, out);
  parameter n = 1;
  input clk, load ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = load ? in : out;
  
  always @(posedge clk)
    out = next_out;  
endmodule

// 4-to-1 multiplexer module to select between two 16-bit inputs.
// ------------------Mux also changed to 4 inputs-----------------
module Mux4 (in1, in2, in3, in4, s, out);
    input [15:0] in1;  // Input channel 1000
    input [15:0] in2;  // Input channel 0100
    input [15:0] in3;  // Input channel 0010
    input [15:0] in4;  // Input channel 0001
    input [3:0] s;           // Select signal
    output [15:0] out; // Output data
    // Multiplexer logic to select the output based on the select signal
    assign out = (s[3]) ? in1 : ((s[2]) ? in2 : ((s[1]) ? in3 : in4));
endmodule

//ADDED for bonus:
module MUX3H (a0, a1, a2, sel, out);
    input [8:0] a0;  // Input channel 001
    input [8:0] a1;  // Input channel 010
    input [8:0] a2;  // Input channel 100
    input [2:0] sel;           // Select signal
    output [8:0] out; // Output data

    // Multiplexer logic to select the output based on the select signal
    assign out = (sel[2]) ? a2 : ((sel[1]) ? a1 : a0);
endmodule

//Added DFlipdlop module for FSM
module vDFF(clk, in, out);
parameter n = 2;
  input clk;
  input[n-1:0] in;
    output[n-1:0] out;
    reg[n-1:0] out;

    always @(posedge clk)
        out = in;

endmodule //vDFF
 


//MUX2b module for PC_Reset MUX and addr_sel MUX
module MUX2b (sel, a1, a0, out);
  parameter n = 2;
  input sel;
  input [n-1:0] a1,a0;
  output reg [n-1:0] out;

  always_comb begin : blockName
    case (sel)
      1'b0: out = a0;
      1'b1: out = a1;
      default: out = 2'bx;
    endcase
  end

endmodule


