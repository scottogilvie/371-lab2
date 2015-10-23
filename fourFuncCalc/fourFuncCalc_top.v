module fourFuncCalc_top(CLOCK_50, LEDR, SW, KEY, 
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input CLOCK_50;
	input [9:0] SW;
	input [3:0] KEY;
	
endmodule
