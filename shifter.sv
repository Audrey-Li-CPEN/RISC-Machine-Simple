// Define a shifter module with a 16-bit signed input, a 2-bit shift operation code, and a 16-bit output.
module shifter(
    input signed [15:0] in,
    input [1:0] shift,
    output reg [15:0] sout 
);
    // Combinational always block that will execute whenever inputs change.
    always_comb begin
        // Select the shift operation based on the shift opcode.
        case (shift)
            2'b00: sout = in;                 // 00: No shift, output equals input
            2'b01: sout = in << 1;            // 01: Logical left shift by 1 bit
            2'b10: sout = {1'b0, in[15:1]};   // 10: Logical right shift by 1 bit, MSB set to 0
            2'b11: sout = {in[15], in[15:1]}; // 11: Arithmetic right shift by 1 bit, MSB remains
            default: sout = 16'bx;             // If none of the above, output is undefined (x)
        endcase
    end
endmodule // End of shifter module
