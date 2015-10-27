// sram256x8TestBench.v
//
// Description:
// Test bench
//
// Inputs:
// Outputs:
//    mySram256x8.vcd
//    vars from mySram256x8
//    Displays add, data, nOe, nWe, time
//
// Authors: Scott Ogilvie
// Date:

//`include "sram256x8.v"
module testBench;
    //  connect the two modules
    wire [7:0] data;
    wire [7:0] add;     // Address
    wire nCs;           // Chip select active low
    wire nOe;           // Output enable active low
    wire nWe;           // Write enable active low

    sram256x8 mySram256x8(data, add, nCs, nOe, nWe);
    tester aTester (data, add, nCs, nOe, nWe);

    initial             // For gtkwave
    begin
        $dumpfile("mySram256x8.vcd");
        $dumpvars(1, mySram256x8);
    end
endmodule

module tester (data, add, nCs, nOe, nWe);
    inout [7:0] data;
    output [7:0] add;   // Address
    output nCs;         // Chip Select active low
    output nOe;         // Output Enable active low
    output nWe;         // Write Enable active low
    reg [7:0] ldata;
    reg [7:0] add;
    reg nCs;
    reg nOe;
    reg nWe;

    reg [8:0] index;    // Counters 1 bigger than address
    reg [7:0] value;    // Used for data
                        // so that for loop will exit
    assign data = (nOe | nCs) ? ldata : 8'bZ ;

    parameter STIMDELAY = 5;
    parameter SIMTIME = 256;
    parameter MAXADDR = 8'hFF;
    parameter MINADDR = 8'h00;
    parameter MAXDATA = 8'hFF;
    parameter MINDATA = 8'h00;

    initial             // Response
    begin
        $display("\t add \t ldata \t nCs \t nOe \t nWe \t\t Time \n");
        $monitor("\t %x \t %x \t %b \t %b \t %b \t %d\n", add, data,
            nCs, nOe, nWe, $time);
    end

    initial             // Stimulus
    begin

        value= 8'hFF;
        #STIMDELAY nCs = 1'b1;
        #STIMDELAY nCs = 1'b0;

        for (index = MINADDR; index<=MAXADDR; index = index + 9'h01)
        begin           // Fill add[0] with 127 to add[127] with 0
            nOe = 1'b1;
            nWe = 1'b1;
            #STIMDELAY add = index[7:0];
            #STIMDELAY ldata = value;
            #STIMDELAY nWe = 1'b0;
            #STIMDELAY nWe = 1'b1;
            value = value - 8'h01;
        end

        value= 8'hFF;
        for (index = MINADDR; index<=MAXADDR; index = index + 9'h01)
        begin           // Read add[0] with 127 to add[127]
            nWe = 1'b1;
            nOe = 1'b0;
            #STIMDELAY add = index[7:0];
            #(STIMDELAY*2);
            // Test data value here
            if (data != value)
            begin
                $display("Error: data: %h != expected %h at time %d\n",
                    data, value, $time);
            end
            #STIMDELAY nOe = 1'b1;
            #STIMDELAY;
            value = value - 8'h01;
        end

        #(SIMTIME*STIMDELAY+4*STIMDELAY);   // needed to see END of simulation
        $finish;                            // finish simulation
    end
endmodule

