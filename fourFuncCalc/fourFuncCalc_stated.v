/*
fourFuncCalc.v

DESCRIPTION:

OUTPUTS:

INPUTS:

AUTHOR(S):
Philip David
10/23/15
*/
module fourFuncCalc_stated(ledr, hex0, hex1, hex2, hex3, hex4, hex5,
						  clk, sw, key, rst);
	output [9:0] ledr;
	output [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	input clk;
	input [9:0] sw;
	input [3:0] key;
	input rst;
	
	assign ledr[9:8] = 2'b0;
//	assign hex0 = 7'b0;
//	assign hex1 = 7'b0;
//	assign hex2 = 7'b0;
//	assign hex3 = 7'b0;
//	assign hex4 = 7'b0;
//	assign hex5 = 7'b0;
	
	reg [7:0] sramlData, sramAddress;
	wire [7:0] sramData;
	reg sramNCs, sramNOe, sramNWe;
	
	sram256x8 sram (sramData, sramAddress, sramNCs, sramNOe, sramNWe);
	
	assign sramData = (sramNOe | sramNCs) ? sramlData : 8'bZ ;
	
	reg [4:0] presState, nextState;
	
	// State parameterizations
	parameter IDLE 					= 5'b00000;
	parameter START_RUN 				= 5'b00001;
	parameter START_STROBELO 		= 5'b00010;
	parameter START_STROBEHI 		= 5'b00011;
	parameter START_DONE 			= 5'b00100;
	parameter COMPUTE_RUN 			= 5'b00101;
	parameter COMPUTE_LOAD1 		= 5'b00110;
	parameter COMPUTE_LOAD1_READ 	= 5'b00111;
	parameter COMPUTE_LOAD2 		= 5'b01000;
	parameter COMPUTE_LOAD2_READ 	= 5'b01001;
	parameter COMPUTE_RESULT 		= 5'b01010;
	parameter COMPUTE_RESULT_LOAD	= 5'b01011;
	parameter COMPUTE_WRITE 		= 5'b01100;
	parameter COMPUTE_STROBELO 	= 5'b01101;
	parameter COMPUTE_STROBEHI 	= 5'b01110;
	parameter COMPUTE_DONE 			= 5'b01111;
	parameter DISPLAY 				= 5'b10000;
	parameter DISPLAY_READ			= 5'b10001;
	
	// Function parameterizations
	parameter fnIdle 		= 2'b00;
	parameter fnStart 	= 2'b01;
	parameter fnCompute 	= 2'b10;
	parameter fnDisplay 	= 2'b11;

	// Operation parameterizations
	parameter opAdd = 2'b00;
	parameter opSub = 2'b01;
	parameter opMul = 2'b10;
	parameter opDiv = 2'b11;
	
	reg [7:0] 	computeReg1, computeReg2;
	reg [7:0] 	resultReg, remainderReg;
	reg [7:0] 	displayReg;
	
	wire [7:0] displayBus 	= displayReg;
	assign ledr[7:0]			= displayBus;
	
	seg7Control seg7 (hex0, hex1, hex2, hex3, hex4, hex5, displayBus);
	
	reg [6:0] startIndex, computeIndex;
	reg [5:0] displayIndex;
	
	initial begin
		presState = IDLE;
	
		computeReg1 	= 0;
		computeReg2 	= 0;
		resultReg 		= 0;
		remainderReg 	= 0;
		displayReg 		= 0;
	
		startIndex 		= 0;
		computeIndex 	= 0;
		displayIndex 	= 0;
	end
	
	always @(posedge clk or negedge key[0]) begin
		if (~key[0]) begin
			case (sw[1:0])
					fnIdle: 		nextState = IDLE;
					fnStart: 	nextState = START_RUN;
					fnCompute:	nextState = COMPUTE_RUN;
					fnDisplay:	nextState = DISPLAY;
					default:		nextState = IDLE;
			endcase
		end else begin
			// Assign all reg's in each branch to avoid inferred latches!
			case (presState)
				IDLE: begin
					displayReg = 8'h99;
					nextState = IDLE;
				end
				
				START_RUN: begin
					displayReg = 8'h00;
					if (startIndex > 31) begin
						nextState 	= START_DONE;
						startIndex 	= 0;
					end else begin
						sramNCs 		= 0;
						sramNOe 		= 1;
						sramNWe		= 1;
						sramAddress = startIndex;
						sramlData 	= startIndex % 11 + startIndex;
						nextState 	= START_STROBELO;
					end
				end
				
				START_STROBELO: begin
					sramNWe = 0;
					nextState = START_STROBEHI;
				end
				
				START_STROBEHI: begin
					sramNWe 		= 1;
					startIndex	= startIndex + 7'd1;
					displayReg	= startIndex;
					nextState 	= START_RUN;
				end
				
				START_DONE: begin
					sramNCs 		= 0;
					sramNOe 		= 0;
					sramNWe		= 1;
					sramAddress = 8'b0;
					sramlData	= 8'b0;
					displayReg  = 8'b1;
					nextState 	= START_DONE;
				end
				
				COMPUTE_RUN: begin
					if (computeIndex > 15) begin
						computeIndex 	= 0;
						nextState 		= COMPUTE_DONE;
					end else begin
						nextState		= COMPUTE_LOAD1;
					end
				end
				
				COMPUTE_LOAD1: begin
					sramNCs 		= 0;
					sramNOe		= 0;
					sramNWe		= 1;
					sramAddress = computeIndex;
					nextState 	= COMPUTE_LOAD1_READ;
				end
				
				COMPUTE_LOAD1_READ: begin
					computeReg1 = sramData;
					nextState	= COMPUTE_LOAD2;
				end
				
				COMPUTE_LOAD2: begin
					sramNCs 		= 0;
					sramNOe		= 0;
					sramNWe		= 1;
					sramAddress = computeIndex + 8'd16;
					nextState 	= COMPUTE_LOAD2_READ;
				end
				
				COMPUTE_LOAD2_READ: begin
					computeReg2 = sramData;
					nextState	= COMPUTE_RESULT;
				end
				
				COMPUTE_RESULT: begin
					case (sw[3:2])
						opAdd: begin
							resultReg = computeReg1 + computeReg2;
						end
						
						opSub: begin
							resultReg = computeReg1 - computeReg2;
						end
						
						opMul: begin
							resultReg = computeReg1 * computeReg2;
						end
						
						opDiv: begin
							resultReg 		= computeReg1 / computeReg2;
							remainderReg 	= computeReg1 % computeReg2;
						end
						
						default: resultReg = 8'b0;
					endcase
					
					nextState = COMPUTE_RESULT_LOAD;
				end
				
				COMPUTE_RESULT_LOAD: begin
					sramlData 	= resultReg;
					nextState	= COMPUTE_WRITE;
				end
				
				COMPUTE_WRITE: begin
					sramNCs 		= 0;
					sramNOe		= 1;
					sramNWe		= 1;
					sramAddress = computeIndex + 8'd32;
					nextState	= COMPUTE_STROBELO;
				end
				
				COMPUTE_STROBELO: begin
					sramNWe		= 0;
					nextState	= COMPUTE_STROBEHI;
				end
				
				COMPUTE_STROBEHI: begin
					sramNWe			= 1;
					computeIndex	= computeIndex + 7'd1;
					displayReg		= computeIndex;
					nextState		= COMPUTE_RUN;
				end
				
				COMPUTE_DONE: begin
					sramNCs 		= 0;
					sramNOe 		= 0;
					sramNWe		= 1;
					sramAddress = 8'b0;
					sramlData	= 8'b0;
					displayReg	= 8'b10;
					nextState 	= COMPUTE_DONE;
				end
				
				DISPLAY: begin
					if (displayIndex > 15) begin
						displayIndex = 0;
					end 
					
					sramNCs		= 0;
					sramNOe		= 0;
					sramNWe		= 1;
					sramAddress	= displayIndex + 6'd32;
					
					case (sw[3:2])
						opAdd: begin
							displayReg = resultReg;
						end
						
						opSub: begin
							displayReg = resultReg;
						end
						
						opMul: begin
							displayReg = resultReg;
						end
						
						opDiv: begin
							displayReg[7:4] = resultReg[3:0];
							displayReg[3:0] = remainderReg[3:0];
						end
					endcase
					
					nextState = DISPLAY_READ;
				end
				
				DISPLAY_READ: begin
					resultReg		= sramData;
					nextState 		= DISPLAY;
					displayIndex 	= displayIndex + 6'b1;
				end
				
				default: begin
					sramNCs 		= 0;
					sramNOe 		= 0;
					sramNWe		= 1;
					sramAddress = 8'b0;
					sramlData	= 8'b0;
					nextState 	= IDLE;
				end
			endcase
		end
		
		presState = nextState;
	end
endmodule

module fourFuncCalc_stated_testbench;
	wire [9:0] ledr;
	wire [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	reg clk;
	reg [9:0] sw;
	reg [3:0] key;
	reg rst;
	
	parameter CLOCK_PERIOD = 100;
	initial clk = 1;
	
	always begin
		#(CLOCK_PERIOD / 2);
		clk = ~clk;
	end
	
	fourFuncCalc_stated dut (ledr, hex0, hex1, hex2, hex3, hex4, hex5, clk, sw, key, rst);
	
	integer i;
	
	initial begin
		// set test operation
		sw[3:2] = 2'b00;
		
		// enter IDLE state
		sw[1:0] = 2'b00;
		@(posedge clk); key[0] = 1;
		@(posedge clk); key[0] = 0;
		@(posedge clk); key[0] = 1;
		for (i = 0; i < 10; i = i + 1) begin
			@(posedge clk);
		end
		
		// enter START state
		sw[1:0] = 2'b01;
		@(posedge clk); key[0] = 1;
		@(posedge clk); key[0] = 0;
		@(posedge clk); key[0] = 1;
		for (i = 0; i < 100; i = i + 1) begin
			@(posedge clk);
		end
		
		// enter COMPUTE state
		sw[1:0] = 2'b10;
		@(posedge clk); key[0] = 1;
		@(posedge clk); key[0] = 0;
		@(posedge clk); key[0] = 1;
		for (i = 0; i < 150; i = i + 1) begin
			@(posedge clk);
		end
		
		// enter DISPLAY state
		sw[1:0] = 2'b11;
		@(posedge clk); key[0] = 1;
		@(posedge clk); key[0] = 0;
		@(posedge clk); key[0] = 1;
		for (i = 0; i < 100; i = i + 1) begin
			@(posedge clk);
		end
		$stop;
	end
	
endmodule
