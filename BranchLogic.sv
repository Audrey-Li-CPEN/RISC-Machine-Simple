`define condB 3'b000
`define condBEQ 3'b001
`define condBNE 3'b010
`define condBLT 3'b011
`define condBLE 3'b100
`define Br 5'b00100
`define BL 5'b01011
`define BX 5'b01000
`define BLX 5'b01010

module BranchLogic
(input [2:0] opcode,
 input[1:0] op,
 input [2:0] cond,
input [8:0] PC,
input [8:0] sximm8,
input [8:0]data_out,
input N,
input V,
input Z,
output reg [8:0] br_logic);

 wire NVLogic =  (N == V)? 1'b0 : 1'b1;  

 always@* begin
   casex({opcode, op, cond,  NVLogic, Z})
    {`BL,5'bx}: br_logic= PC + sximm8;
    {`BLX,5'bx}, {`BX,5'bx}: br_logic = data_out;

    {`Br,`condB,2'bx},    {`Br,`condBEQ,1'bx,1'b1},   {`Br,`condBNE,1'bx,1'b0},
    {`Br,`condBLT,1'b1,1'bx},   {`Br,`condBLE,1'b1,1'bx},  {`Br,`condBLE,1'bx,1'b1}: br_logic=PC+1'b1+sximm8;

    default: br_logic= PC +1'b1; 
   endcase
 end
 endmodule

