//!!Added State/Cond definitions for Bonus lab Branch Instructions
`define Br 5'b00100
`define BL 5'b01011
`define BX 5'b01000
`define BLX 5'b01010

module cpu(
    input         clk,
    input         reset,     //MOFIDIED！ for lab7
    input  [15:0] read_data, // 16-bit data from memory
    input  [15:0] mdata,     // 16-bit data from datapath
    output [1:0]  mem_cmd,   // 2-bit command
    output [8:0]  mem_addr,  // 9-bit address
    output [15:0] write_data,//16-bit out to memory
    output N,
    output V,
    output Z,
    output reg haltSignal
);

//Wire/Reg Initialization
//ADDED Signals
//For instruction register
    wire load_ir;      //load instruction register ADDED!
    wire[15:0] outF_IR;
    reg [2:0] nsel;
//For FSM Inputs
    wire[2:0] opcode;
    wire[1:0] op;

//Instruction Decoder Outputs
    wire[2:0] writenum;
    wire[2:0] readnum;
    wire[1:0] shift;
    wire[15:0] sximm8;
    wire[15:0] sximm5;
    wire[1:0] ALUop;
    
//For FSM Outputs
    //wire[15:0] mdata;
    reg [3:0] vsel;
    reg write;
    reg loadc;
    reg bsel;
    reg asel;
    reg loada;
    reg loadb;
    reg loads;


   //ADDED! addr_sel MUX wires
    wire addr_sel, load_pc;
    wire[8:0] next_pc, PC, dataaddress_addrsel;

    //ADDED! DataAddress wires
    wire load_addr;

    //ADDED!
    wire[15:0] data_out;

    //ADDED!! Branch Logic Signal
    wire[8:0] br_logic;

    wire [2:0] cond, pc_sel;

    
    vDFFE #(9) Program_Counter(.clk(clk),.load(load_pc),.in(next_pc),.out(PC));

    BranchLogic BranchUnit(.opcode(opcode), .op(op),.cond(cond),.PC(PC),.sximm8(sximm8[8:0]),.N(N),.V(V),.Z(Z),.br_logic(br_logic),.data_out(data_out[8:0])); 

    MUX3H BranchMUX(.sel(pc_sel),.a2(br_logic),.a1(PC+1'b1),.a0(9'b0),.out(next_pc));

    MUX2b #(9) addrMUX(.sel(addr_sel), .a1(PC), .a0(dataaddress_addrsel), .out(mem_addr));

    vDFFE #(9) DataAddress(.clk(clk),.load(load_addr),.in(write_data[8:0]),.out(dataaddress_addrsel));

   
    Instruction_Register IR(clk, load_ir, read_data, outF_IR);
    Instruction_Decoder ID(outF_IR,nsel,opcode,op,cond, writenum,readnum,shift,sximm8,sximm5,ALUop);

    FSM Control_DP(.clk(clk), .reset(reset), .opcode(opcode), .op(op), .vsel(vsel), .nsel(nsel), .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads), .write(write), .asel(asel), .bsel(bsel),
    .load_pc(load_pc), .haltSignal(haltSignal), .addr_sel(addr_sel), .mem_cmd(mem_cmd), .load_ir(load_ir),.load_addr(load_addr), .reset_pc(reset_pc), .pc_sel(pc_sel));
   
    datapath DP(.clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), 
    .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .mdata(mdata),  .sximm8(sximm8),.PC(PC[7:0]),.sximm5(sximm5),.Z_out(Z),.V_out(V),.N_out(N),.datapath_out(write_data),.data_out(data_out));
    
endmodule

module Instruction_Register(clk, load, in_f_cpu, out_f_IR);
    input clk, load ;
    input[15:0] in_f_cpu ;
    output[15:0] out_f_IR ;
    reg[15:0] out_f_IR ;
    wire[15:0] next_out ;

    assign next_out = load ? in_f_cpu : out_f_IR;
    always @(posedge clk)
        out_f_IR = next_out;  
endmodule

module Instruction_Decoder(
    input[15:0] out_f_IR,
    input[2:0] nsel,
    output[2:0] opcode,
    output[1:0] op,
    output[2:0] cond, //ADDED!! for bonus
    output[2:0] writenum,
    output[2:0] readnum,
    output[1:0] shift,
    output[15:0] sximm8,
    output[15:0] sximm5,
    output[1:0] ALUop
);
    assign opcode = out_f_IR[15:13];
    assign op = out_f_IR[12:11];
    assign cond = out_f_IR[10:8];
    assign readnum = (nsel[2]) ? out_f_IR[10:8] : ((nsel[1]) ? out_f_IR[7:5] : out_f_IR[2:0]); //Rn, Rd, Rm
    assign writenum = readnum;
    assign shift = out_f_IR[4:3];
    assign sximm8 = {{8{out_f_IR[7]}},out_f_IR[7:0]};
    assign sximm5 = {{11{out_f_IR[4]}},out_f_IR[4:0]};
    assign ALUop = out_f_IR[12:11];
endmodule

//opcode_op_case Encoding
//opcode encoding derived from lab 6
 // state encoding for case in the encoding structure

  `define RST                    4'b0000
  `define IF1                    4'b0001
  `define IF2                    4'b0010
  `define UpdatePC               4'b0011
  `define Decode                 4'b0100

  `define GetA                   4'b0101
  `define GetB                   4'b0110
 `define ALUOP                   4'b0111
  `define WriteReg               4'b1000
  `define Branch1                4'b1001
  `define Branch2                4'b1010
  `define HALT                   4'b1011
  
  `define GetAddr                4'b1100
  `define LoadRd_B               4'b1101
    `define UpdateDPOut            4'b1110
    `define WriteMem               4'b1111

`define MREAD       2'b01
`define MWRITE      2'b10

module FSM(
    input  clk,
    input  reset,
    input[2:0]  opcode,
    input[1:0]  op,
    output[3:0]  vsel,
    output  write,
    output  loada,
    output  loadb,
    output  asel,
    output  bsel,
    output  loadc,
    output  loads,
    output[2:0]  nsel,
    output  haltSignal, //! Change w to halt stage signal
    output  load_ir,
    output  load_addr,
    output  load_pc,
    output reset_pc,
    output [2:0] pc_sel,//!!Modify reset_pc to choose between reset, add 1, and add imm8
    output  addr_sel,
    output[1:0]  mem_cmd
);//ADDED: clk,reset,opcode,op,vsel,write,loada,loadb,asel,bsel,loadc,loads,nsel,w, load_ir,load_addr,load_pc,reset_pc,addr_sel,mem_cmd
wire [3:0] PresentState;
wire [3:0] State_Reset_or_Next;
wire [3:0] Next_State;
reg [27:0] Next_Control;//!MODIFIED For Bonus
// DFF for control FSM
vDFF #(4) STATE(clk,State_Reset_or_Next,PresentState);

assign State_Reset_or_Next = ((reset) ? `RST : Next_State);
// {next_state, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, pc_sel, addr_sel, mem_cmd, load_ir, load_addr,haltSignal} =  Next Control
// 9           1      1      1       1     1       4    3      1     1      1       3       1        2       1         1          1             34
//Structure of State: opcode_op_case
always_comb 
begin
     casex ({opcode, op, PresentState})

      //RESET: load_pc  =1, select pc = 9'b0
     {5'bx, `RST} : Next_Control = { `IF1, 14'b0, 1'b1, 3'b001, 6'b0};
     
     //IF1: MREAD, pc + 1, addr_sel = 1
     {5'bx, `IF1} : Next_Control = { `IF2, 15'b0,3'b010, 1'b1, `MREAD, 3'b0};

     //IF2: compare to IF, loadir = 1.
     {5'bx, `IF2} : Next_Control = { `UpdatePC, 15'b0,3'b010, 1'b1, `MREAD, 1'b1, 2'b0};

      //*******************************Update PC************************************//
     {`Br, `UpdatePC} : Next_Control = { `IF1, 14'b0, 1'b1, 3'b100, 6'b0};
     {`BLX, `UpdatePC}, {`BL, `UpdatePC} : Next_Control = { `Branch1, 14'b0, 1'b1, 3'b010, 6'b0};
     {`BX, `UpdatePC} : Next_Control = { `IF1, 9'b0,3'b010 , 2'b0, 1'b1, 3'b100, 6'b0};
     { 5'bx, `UpdatePC} : Next_Control = { `Decode, 14'b0,1'b1, 3'b100 , 6'b0 }; //PC select branch
     //! mofidy 
     //{ 5'b111xx, `UpdatePC},  { 5'b110xx, `UpdatePC},  { 5'b101xx, `UpdatePC}, { 5'b011xx, `UpdatePC}, { 5'b100xx, `UpdatePC} : Next_Control = { `Decode, 14'b0,1'b1, 3'b100 , 6'b0 }; //PC select branch
     //! mofidy 
     //************************Branch:WriteReg*********************************************************************// 
     {`BL, `Branch1} : Next_Control =  { `IF1, 4'b0, 1'b1, 4'b0010, 3'b100,2'b0, 1'b1, 3'b100, 6'b0};
     {`BLX, `Branch1} : Next_Control =  { `Branch2, 4'b0, 1'b1, 4'b0010, 3'b100,3'b0, 3'b100, 6'b0}; // write on, select PC,  select Rn
 
    //Branch2: WriteReg
        {`BLX, `Branch2} : Next_Control =  { `IF1, 9'b0, 3'b010, 2'b0, 1'b1, 3'b100, 6'b0}; // load pc,  select Rd
   
   //*******************************HALT!!*********************************//
        {5'bx, `HALT} : Next_Control =  { `HALT, 15'b0, 3'b010, 5'b0,1'b1};

//*******************************Decode************************************//
   //**Halt:
        {5'b111xx, `Decode} : Next_Control = { `HALT, 15'b0,  3'b010, 6'b0};
   //MOV Rn imm8
        {5'b11010, `Decode} : Next_Control = { `WriteReg, 15'b0, 3'b010, 6'b0};
  //MOV Rd Rm <shift> or MVN
        {5'b11000, `Decode},{5'b10111, `Decode} : Next_Control = { `GetB, 15'b0, 3'b010, 6'b0};
  //Others ADD,AND,CMP,STR,LDR:
         {5'b1010x, `Decode},{5'b10110, `Decode}, {5'b01100, `Decode}, {5'b10000, `Decode} : Next_Control = { `GetA, 15'b0, 3'b010, 6'b0};

    //*************************GetB*********************************************//
     //loadb =1 , select Rm
        {5'bx, `GetB} : Next_Control = { `ALUOP, 1'b0,1'b1, 7'b0, 3'b001, 3'b0,3'b010, 6'b0};
   
     //***************************Get_A**********************************************//
      //All except LDR STR loada = 1, and select Rn
        {5'b11010,`GetA }, {5'b11000, `GetA} , {5'b101xx, `GetA} : Next_Control = {{opcode, op}, `GetB, 1'b1, 8'b0, 3'b100, 3'b0, 3'b010, 6'b0};
       
         {5'b01100, `GetA}, {5'b10000, `GetA} : Next_Control = {{opcode, op}, `ALUOP, 1'b1, 8'b0, 3'b100, 3'b0, 3'b010, 6'b0};

     //**************************ALUOP Stage************************************************//
        //For ADD AND
        {5'b10100, `ALUOP}, {5'b10110, `ALUOP}: Next_Control = { `WriteReg, 2'b0, 1'b1, 12'b0, 3'b010, 6'b0};

        //For CMP
        {5'b10101, `ALUOP}: Next_Control = { `IF1, 3'b0, 1'b1, 11'b0, 3'b010, 6'b0};

        //For MOV MVN asel = 1, load c = 1
        {5'b11000, `ALUOP}, {5'b10111, `ALUOP}: Next_Control = { `WriteReg, 2'b0, 1'b1, 9'b0, 1'b1, 2'b0, 3'b010, 6'b0};

       //For LDR STR
        {5'b01100, `ALUOP}, {5'b10000, `ALUOP}: Next_Control = { `GetAddr, 2'b0, 1'b1, 1'b1,  9'b0,  1'b1, 1'b0, 3'b010, 6'b0};


        //**************************GetAddr Stage************************************************//
        //For ldr load_addr = 1
        {5'b01100, `GetAddr} : Next_Control = { `WriteMem, 15'b0, 3'b010, 4'b0, 1'b1, 1'b0};

        //For STR next to load B, 
        {5'b10000, `GetAddr} : Next_Control = { `LoadRd_B, 15'b0, 3'b010, 4'b0, 1'b1, 1'b0};


        //**************************LoadRd_B Stage************************************************//
        {5'b10000, `LoadRd_B} : Next_Control = { `UpdateDPOut, 1'b0,1'b1, 7'b0, 3'b010, 3'b0, 3'b010, 6'b0};


        //**************************UpdateDPOut Stage************************************************//
        {5'b10000, `UpdateDPOut} : Next_Control = { `WriteMem, 2'b0,1'b1, 9'b0, 1'b1, 2'b0, 3'b010, 6'b0};

 
        //**************************WriteMem Stage************************************************//
        {5'b10000, `WriteMem} : Next_Control = { `IF1, 15'b0, 3'b010, 1'b0, `MWRITE,  3'b0};

        //For LDR:
        {5'b01100, `WriteMem} : Next_Control = { `WriteReg, 15'b0, 3'b010, 1'b0, `MREAD,  3'b0};

     //*********************Write Back************************************************************// 
 //select Rn, sximm for sign extended MOV
     {5'b11010, `WriteReg} : Next_Control = { `IF1, 4'b0,1'b1, 4'b0100, 3'b100,3'b0, 3'b010, 6'b0};
  //select Rd, mdata
     {5'b01100, `WriteReg} : Next_Control = { `IF1, 4'b0,1'b1, 4'b1000, 3'b010,3'b0, 3'b010, 1'b0, `MREAD, 3'b0};
    //select Rd, datapath_out
     {5'bx, `WriteReg} : Next_Control = { `IF1, 4'b0,1'b1, 4'b0001, 3'b010,3'b0, 3'b010, 6'b0};
             
     default:   Next_Control = 28'bx;

 endcase
end

  assign {Next_State, loada, loadb, loadc, loads, write, vsel, nsel, asel, bsel, load_pc, pc_sel, addr_sel, mem_cmd, load_ir, load_addr,haltSignal} = Next_Control ;

endmodule

