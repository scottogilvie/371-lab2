module fourFuncCalc(ledr, hex0, hex1, hex2, hex3, hex4, hex5,
						  clk, sw, key);
	output [9:0] ledr;
	output [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	input clk;
	input [9:0] sw;
	input [3:0] key;
	
	reg [7:0] sramlData, sramAddress;
	wire [7:0] sramData;
	reg sramNCs, sramNOe, sramNWe;
	
	sram256x8 sram (sramData, sramAddress, sramNCs, sramNOe, sramNWe);
	
	assign sramData = (sramNOe | sramNCs) ? sramlData : 8'bZ ;
	
	reg [7:0] computeReg1, computeReg2;
	reg [15:0] resultReg;
	
	parameter fnIdle 		= 2'b00;
	parameter fnStart 	= 2'b01;
	parameter fnCompute 	= 2'b10;
	parameter fnDisplay 	= 2'b11;

	parameter opAdd = 2'b00;
	parameter opSub = 2'b01;
	parameter opMul = 2'b10;
	parameter opDiv = 2'b11;
	
	assign ledr[6:0] = sw[9:3] % {sw[2:0], key[3:0]};
	
	integer i;
	
	always @(posedge key[0]) begin
		case (key[1:0])
			fnIdle: // SW[1:0] = 00 
			begin
				
			end
			
			fnStart: // SW[1:0] = 01
			// Load 32 contiguous bytes of data into SRAM
			begin
				for (i = 0; i < 32; i = i + 1) begin
					
				end
			end
			
			fnCompute: // SW[1:0] = 10
			begin
				for (i = 0; i < 32; i = i + 1) begin
					case (key[3:2]) 
						opAdd: // SW[3:2] = 00
						begin
						
						end
						
						opSub: // SW[3:2] = 01
						begin
						
						end
						
						opMul: // SW[3:2] = 10
						begin
						
						end
						
						opDiv: // SW[3:2] = 11
						begin
						
						end
					endcase
				end
			end
			
			fnDisplay: // SW[1:0] = 11
			/*
			Add or Subtract: Display the result on LEDR[7:0]
			Multiply: Display result on LEDR[7:0]
			Divide: Quotient on LEDR[7:4] and remainder on LEDR[3:0]
			*/
			begin
			
			end
		endcase
	end
endmodule
