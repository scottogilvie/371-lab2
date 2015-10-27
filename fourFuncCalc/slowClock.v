module slowClock(outClock, inClock);
	input inClock;
	output reg outClock;
	reg[25:0] tBase;
	
	parameter TIMEBASE = 19;
	
	always@(posedge inClock) begin
		tBase <= tBase + 1'b1;
	end
	
	always@(posedge tBase[TIMEBASE]) begin
		outClock <= ~outClock;
	end
endmodule