module fourFuncCalc_testbench;
	wire [9:0] ledr;
	wire [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	wire clk;
	wire [9:0] sw;
	wire [3:0] key;
	
	fourFuncCalc dut (ledr, hex0, hex1, hex2, hex3, hex4, hex5,
							clk, sw, key);
	tester ffcTester (ledr, hex0, hex1, hex2, hex3, hex4, hex5,
							clk, sw, key);
							
	initial begin
		$dumpfile("fourFuncCalc_testbench.vcd");
		$dumpvars(1, dut);
	end
endmodule

module ffcTester (
	ledr, hex0, hex1, hex2, hex3, hex4, hex5,
	clk, sw, key
);

	input [9:0] ledr;
	input [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	output reg clk;
	output reg [9:0] sw;
	output reg [3:0] key;
	
	parameter stimDelay = 100;
	
	initial begin
		$display("");
		$monitor("");
	end
	
	initial begin
		
	end	

endmodule
