`timescale 1ns / 1ps

module datapath_tb;

// Inputs
    reg clk;
    reg [2:0] readnum;
    reg [3:0]vsel;
    reg loada;
    reg loadb;
    reg[1:0] shift;
    reg asel;
    reg bsel;
    reg[1:0] ALUop;
    reg loadc;
    reg loads;
    reg [2:0] writenum;
    reg write;
    reg[15:0] mdata;
    reg[15:0] sximm8;
    reg[8:0] PC;
    reg[15:0] sximm5;
    wire Z_out;
    wire V_out;
    wire N_out;
    wire [15:0]datapath_out;
    reg err = 1'b0;

// Instantiate the Unit Under Test (DUT)
datapath DUT (
    .mdata(mdata), 
    .sximm8(sximm8),
    .PC(PC),
    .sximm5(sximm5),
    .vsel(vsel), 
    .writenum(writenum), 
    .write(write), 
    .readnum(readnum), 
    .clk(clk), 
    .loada(loada), 
    .loadb(loadb), 
    .asel(asel), 
    .bsel(bsel), 
    .loadc(loadc), 
    .loads(loads), 
    .shift(shift), 
    .ALUop(ALUop), 
    .Z_out(Z_out), 
    .V_out(V_out),
    .N_out(N_out),
    .datapath_out(datapath_out)
);


initial begin
    // Initialize Inputs
    mdata = 16'b0;
    sximm8 = 16'b0;
    PC = 9'b0;
    sximm5 = 16'b0000000000000111; //sximm5 = 7
    vsel = 4'b0000;
    writenum = 1'b0;
    write = 1'b0;
    readnum = 1'b0;
    clk = 1'b0;
    loada = 1'b0;
    loadb = 1'b0;
    asel = 1'b0;
    bsel = 1'b0;
    loadc = 1'b0;
    loads = 1'b0;
    shift = 2'b00;
    ALUop = 2'b00;
    // Wait 100 ns for global reset to finish
    #10;

    // Test case for zero value mdata and PC
    // MOV R4, #0
    mdata = 16'b0000000000000000; 
    vsel = 4'b1000;
    writenum = 3'b100; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;
    // MOV R5, #0
    PC = 16'b0000000000000000; 
    vsel = 4'b0010;
    writenum = 3'b101; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;
    // Cycle 1
    // Read value from R4
    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b100; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;
    
    // Cycle 2
    // Read value from R5
    loadb = 1'b1; 
    readnum = 3'b100; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;
    
    // Cycle 3
    // Execute, ADD datapath_out R4, R5
    shift = 2'b00;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b00;
    loadc = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    #10;

    if (datapath_out == 16'b0000000000000000)begin
        $display("Zero Value Test Passed: 0 + 0 = 0.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
        
    else begin
        $display("Zero Value Test Failed: Expected 0, got %h", datapath_out);
        err = 1'b1;
    end
        
    // Test case for sximm8
    // MOV R1, #8
    sximm8 = 16'b0000000000001000; 
    vsel = 4'b0100;
    writenum = 3'b001; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    // MOV R2, #2
    sximm8 = 16'b0000000000000010; 
    vsel = 4'b0100;
    writenum = 3'b010; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    // Cycle 1
    // Read value from R1
    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b001; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

   
    // Cycle 2
    // Read value from R2
    loadb = 1'b1; 
    readnum = 3'b010; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    // Cycle 3
    // Execute, SUB datapath_out R1, R2
    shift = 2'b01;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b01;
    loadc = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    #10;
    if (datapath_out == 16'b0000000000000100) begin
        $display("Test Passed.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 4, got %h", datapath_out);
        err = 1'b1;
    end

    // Test case for shift 10 and ALUop 10
    // MOV R1, #8
    sximm8 = 16'b0000000000001000; 
    vsel = 4'b0100;
    writenum = 3'b001; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    // MOV R2, #2
    sximm8 = 16'b0000000000000010; 
    vsel = 4'b0100;
    writenum = 3'b010; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    // Cycle 1
    // Read value from R1
    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b001; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

   
    // Cycle 2
    // Read value from R2
    loadb = 1'b1; 
    readnum = 3'b010; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    // Cycle 3
    // Execute, AND datapath_out R1, R2
    shift = 2'b10;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b10;
    loadc = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    #10;
    if (datapath_out == 16'b0000000000000000) begin
        $display("Test Passed.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 0, got %h", datapath_out);
        err = 1'b1;
    end

    // Test case for shift 11 and ALUop 11
    // MOV R1, #8
    sximm8 = 16'b0000000000001000; 
    vsel = 4'b0100;
    writenum = 3'b001; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    // MOV R2, #2
    sximm8 = 16'b0000000000000010; 
    vsel = 4'b0100;
    writenum = 3'b010; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    // Cycle 1
    // Read value from R1
    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b001; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

   
    // Cycle 2
    // Read value from R2
    loadb = 1'b1; 
    readnum = 3'b010; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    // Cycle 3
    // Execute, ~R2
    shift = 2'b11;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b11;
    loadc = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    #10;
    if (datapath_out == 16'b1111111111111110) begin
        $display("Test Passed.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Got %h", datapath_out);
        err = 1'b1;
    end

    // Test case for sximm5   
    // MOV R4, #18
    sximm8 = 16'b0000000000010010; 
    vsel = 4'b0100;
    writenum = 3'b110; 
    write = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    // MOV R4, #200
    sximm8 = 16'b0000000011001000; 
    vsel = 4'b0100;
    writenum = 3'b001; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    // Cycle 1
    // Read value from R4
    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b110; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

    // Cycle 2
    // Read value from R5
    loadb = 1'b1; 
    readnum = 3'b001; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    // Cycle 3
    // Execute datapath_out from R4, R5
    shift = 2'b00;
    bsel = 1'b1;
    asel = 1'b1;
    ALUop = 2'b00;
    loadc = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    #10;
    if (datapath_out == 16'b0000000000000111) begin
        $display("Test Passed: 7.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 7, got %h", datapath_out);
        err = 1'b1;
    end

    // Initialize Inputs
    mdata = 16'b0;
    sximm8 = 16'b0;
    PC = 8'b0;
    sximm5 = 16'b0;
    vsel = 4'b0000;
    writenum = 1'b0;
    write = 1'b0;
    readnum = 1'b0;
    clk = 1'b0;
    loada = 1'b0;
    loadb = 1'b0;
    asel = 1'b0;
    bsel = 1'b0;
    loadc = 1'b0;
    loads = 1'b0;
    shift = 2'b00;
    ALUop = 2'b00;
    // Wait 100 ns for global reset to finish
    #10;

    // Test case for Z_out
    sximm8 = 16'b0000000110010010; 
    vsel = 4'b0100;
    writenum = 3'b110; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    sximm8 = 16'b0001100011000000; 
    vsel = 4'b0100;
    writenum = 3'b111; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b110; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

    loadb = 1'b1; 
    readnum = 3'b111; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    shift = 2'b00;
    bsel = 1'b1;
    asel = 1'b1;
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    loads = 1'b0;
    #10;
    if (Z_out == 1'b1) begin
        $display("Test Passed: 1.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 1, got %h", Z_out);
        err = 1'b1;
    end

    // Test case for N_out
    sximm8 = 16'b0000000000001110; //14
    vsel = 4'b0100;
    writenum = 3'b110; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    sximm8 = 16'b0000000000100010; //34
    vsel = 4'b0100;
    writenum = 3'b111; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b110; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

    loadb = 1'b1; 
    readnum = 3'b111; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    shift = 2'b00;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b01; //SUB
    loadc = 1'b1;
    loads = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    loads = 1'b0;
    #10;
    if (N_out == 1'b1) begin
        $display("Test Passed: 1.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 1, got %h", N_out);
        err = 1'b1;
    end

    // Test case for V_out
    sximm8 = 16'b0100000110001000;
    vsel = 4'b0100;
    writenum = 3'b110; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    #10;

    sximm8 = 16'b0110001100100010;
    vsel = 4'b0100;
    writenum = 3'b111; 
    write = 1'b1; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    write = 1'b0;
    vsel = 4'b0000;
    #10;

    loada = 1'b1; 
    loadb = 1'b0;
    readnum = 3'b110; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loada = 1'b0;
    #10;

    loadb = 1'b1; 
    readnum = 3'b111; 
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadb = 1'b0;
    #10;

    shift = 2'b00;
    bsel = 1'b0;
    asel = 1'b0;
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10;
    clk = 1'b1;
    #10; 
    clk = 1'b0;
    loadc = 1'b0;
    loads = 1'b0;
    #10;
    if (V_out == 1'b1) begin
        $display("Test Passed: 1.");
        if (err == 1'b1) begin
            err = 1'b1;
        end
        else begin
            err = 1'b0;
        end
    end
    else begin
        $display("Test Failed: Expected 1, got %h", V_out);
        err = 1'b1;
    end
        
    if (err == 1'b0)
            $display("Test passed");   
        else
            $display("Test failed");
        // End the simulation
    
end

endmodule

