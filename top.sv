module lab7bonus_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
input [3:0] KEY;
input [9:0] SW;
input CLOCK_50;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

//CONSTANT DEFINITIONS:
`define MREAD 2'b01
`define MWRITE 2'b10
parameter file = "data.txt";


//Change to trigger push
//WIRE Initialization:
//CPU Out/Inputs
wire [1:0] mem_cmd; 
wire [8:0] mem_addr;
wire [15:0] read_data, write_data; 
wire N, V, Z;//Status Flags Negative Overfloe Zero
wire halt;


//RAM Out
wire [15:0] dout;



//Equal Comparison Outputs:
wire eqMRead; //Result of equal comparison for MREAD
wire eqMWrite;//Result of equal comparison for MWRITE
wire msel;    //Result of equal comparison for MSEL



//Module Instantiation:

//CPU
cpu CPU(.clk(CLOCK_50), .reset(~KEY[1]), .read_data(read_data), .mdata(read_data), .mem_cmd(mem_cmd),
        .mem_addr(mem_addr), .write_data(write_data),.N(N),.V(V),.Z(Z),.haltSignal(halt));

//RAM
RAM #(16, 8, file)MEM(.clk(CLOCK_50), .read_address(mem_addr[7:0]), .write_address(mem_addr[7:0]),
        .write(msel && eqMWrite), .din(write_data), .dout(dout));//256 locations is enough

		  

//Equality Comparators - MSEL, MREAD, MWRITE:
  eq #(1) EqualityMsel(1'b0, mem_addr[8], msel);
  eq #(2) EqualityMREAD(`MREAD, mem_cmd, eqMRead);   
  eq #(2) EqualityMWRITE(`MWRITE, mem_cmd, eqMWrite);


 
//triStateBuffer:
  triStateDriver #(16) TriDout(dout, msel && eqMRead, read_data);
      


//!!STAGE3: MAP I/O to Switch , LEDs and HEX Displays

 //Assign SSEG Cited from lab6_top.sv
  assign HEX5[0] = ~Z;
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;
  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(write_data[3:0],   HEX0);
  sseg H1(write_data[7:4],   HEX1);
  sseg H2(write_data[11:8],  HEX2);
  sseg H3(write_data[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = halt;

//!!SWITCHES 
  wire enSW;
//Assign combination logic for the condition to read input with two tri-State Drivers 
  assign enSW = (mem_cmd==`MREAD & mem_addr==9'h140) ? 1'b1:1'b0;
  //TriStateDriver for SW[15:0] Simplified from two tri-state drivers to one
  triStateDriver #(16) triReadSW({8'h00,SW[7:0]}, enSW, read_data);


//!!LEDs
  wire load_LED;
//Assign combination logic for the condition to write output with one LoadEnable
  assign load_LED = (mem_cmd==`MWRITE & mem_addr==9'h100) ? 1'b1:1'b0;
//Module Instantiation for LoadEnable
  vDFFE #(8) EnableLED(CLOCK_50, load_LED, write_data[7:0], LEDR[7:0]);

endmodule


/*************************************************************************/
//RAM Memory Module Cited from Slide 11:
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 9;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule



//Equal Comparator Module:
module eq(a, b, out);
  parameter  n = 1;
  input [n-1:0] a, b;
  output out;

  assign out = ((a==b) ? 1'b1:1'b0);
endmodule

//Tri-State Driver Module:
module triStateDriver(in, enable, out);
  parameter n = 16;
  input [n-1:0] in;
  input enable;
  output [n-1:0] out;

  assign out = enable ? in : {n{1'bz}}; //Cited from Slide 12
endmodule


//The 7-7segment display module from lab6_top.sv
module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
  
  reg[6:0] segs; 
  always_comb begin
   case(in) 
       4'b0000: segs=   7'b1000000;
       4'b0001: segs = 7'b1111001;
	    4'b0010: segs =    7'b0100100;
	    4'b0011: segs=  7'b0110000;
	    4'b0100: segs=  7'b0011001;
	    4'b0101:  segs= 7'b0010010;
	    4'b0110: segs=   7'b0000010;
	    4'b0111: segs =  7'b1111000;
	   4'b1000: segs =  7'b0000000;
	   4'b1001: segs =   7'b0010000;
		
		4'b1010: segs = 7'b0001000;
		4'b1011: segs = 7'b0000000;
		4'b1100: segs = 7'b1000110;
		4'b1101: segs = 7'b1000000;
		4'b1110: segs = 7'b0000110;
		4'b1111: segs = 7'b0001110;  
		default: segs = 7'b1111111;
		endcase
  end 
endmodule