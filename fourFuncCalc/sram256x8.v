// sram256x8
//
// Description:
//    Verilog representation of a 256x8 sram
//
// Inputs:
//    add[7:0] - 8 bit address
//    nOe - active low output enable 
//    nWe - 
//
// In / Out:
//    data[7:0] - 8 bit data
//		
// Authors: Scott Ogilvie
// Date:

module sram256x8(data, add, nCs, nOe, nWe);
    inout [7:0] data;
    input [7:0] add;
    input nCs;          // Chip Select active low
    input nOe;          // Output Enable active low
    input nWe;          // Write Enable active low
    reg [7:0] mem [0:255];  // Address, data

    assign data = (!nOe & !nCs) ? mem[add] : 8'bZ ;
	
    always@ (!nWe & !nCs)
    begin
        mem[add] = data;
    end
	
endmodule
