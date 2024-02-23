module ALU(
    input [15:0] Ain,
    input [15:0] Bin,
    input [1:0] ALUop,
    output reg [15:0] actually_out,
    output reg Z,
    output reg V,
    output reg N
);
    reg[16:0] out;

    always_comb begin 
        case (ALUop)
            2'b00: // Addition
            begin 
                actually_out = Ain + Bin;
                // Check for overflow
                V = (actually_out[15] != Ain[15])&&(Ain[15] == Bin[15]);
            end
            2'b01: // Subtraction
            begin 
                actually_out = Ain - Bin;
                // Check for overflow
                V = (actually_out[15] != Ain[15])&&(Ain[15] != Bin[15]);
            end 
            2'b10: // Bitwise AND
            begin 
                actually_out = Ain & Bin;
                V = 1'b0; // No overflow
            end 
            2'b11: // Bitwise NOT on Bin
            begin 
                actually_out = ~Bin;
                V = 1'b0; // No overflow
            end 
        endcase
        // Set Zero Flag
        Z = (actually_out == 16'b0) ? 1'b1 : 1'b0;
        // Set Negative Flag
        N = actually_out[15];
    end
endmodule

