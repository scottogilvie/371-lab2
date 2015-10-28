/*
seg7Control.v

DESCRIPTION:

INPUTS:

OUTPUTS:

AUTHOR(S):
Philip David
10/27/2015
*/
module seg7Control(
	ho0, ho1, ho2, ho3, ho4, ho5,
	in, en
);

	output [6:0] ho0, ho1, ho2, ho3, ho4, ho5;
	input [7:0]	in;
	input [2:0] en;
	
	wire [7:0] lsnResult0 = (en == 3'b111) ? in[3:0] % 10 : 8'b11111111;
	wire [7:0] lsnResult1 = (en == 3'b111) ? in[3:0] % 100 / 10 : 8'b11111111;
	wire [7:0] lsnResult2 = (en == 3'b111) ? in[3:0] % 1000 / 100 : 8'b11111111;
	seg7 s0 (.bcd(lsnResult0), .leds(ho0));
	seg7 s1 (.bcd(lsnResult1), .leds(ho1));
	seg7 s2 (.bcd(lsnResult2), .leds(ho2));
	
	wire [7:0] msnResult0 = (en == 3'b111) ? in[7:4] % 10 : 8'b11111111;
	wire [7:0] msnResult1 = (en == 3'b111) ? in[7:4] % 100 / 10 : 8'b11111111;
	wire [7:0] msnResult2 = (en == 3'b111) ? in[7:4] % 1000 / 100 : 8'b11111111;
	seg7 s3 (.bcd(msnResult0), .leds(ho3));
	seg7 s4 (.bcd(msnResult1), .leds(ho4));
	seg7 s5 (.bcd(msnResult2), .leds(ho5));

endmodule

module seg7 (bcd, leds);
	 input [7:0] bcd;
	 output reg [6:0] leds;

	 always @(*)
		 case (bcd)
		 // Light: 6543210
		 8'b00000000: leds = ~7'b0111111; // 0
		 8'b00000001: leds = ~7'b0000110; // 1
		 8'b00000010: leds = ~7'b1011011; // 2
		 8'b00000011: leds = ~7'b1001111; // 3
		 8'b00000100: leds = ~7'b1100110; // 4
		 8'b00000101: leds = ~7'b1101101; // 5
		 8'b00000110: leds = ~7'b1111101; // 6
		 8'b00000111: leds = ~7'b0000111; // 7
		 8'b00001000: leds = ~7'b1111111; // 8
		 8'b00001001: leds = ~7'b1101111; // 9
		 8'b11111111: leds = ~7'b0000000;
		 default: leds = 7'b0;
	 endcase
endmodule 

module seg7Control_testbench;

endmodule
