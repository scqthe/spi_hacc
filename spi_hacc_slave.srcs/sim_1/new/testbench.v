`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2021 10:42:06 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();


    reg clk_tb = 0;
    reg SCLK = 0;
    reg MOSI = 0;
    reg CS = 1;
    wire dclk;
    wire MISO;
    integer ii;

    reg [39:0] hh = 40'h0200230019;

    // reg [3:0] opcode = 4'd7;
    wire [7:0] cathode;
    wire [7:0] anode;
    
    // unit under test (uut)
    spi_hacc_slave dut (
        .clk(clk_tb),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .cathode(cathode),
        .anode(anode),
        .CS(CS)
    );
    
    initial forever #1 clk_tb = ~clk_tb; 
    initial forever #100 SCLK = (~SCLK & ~CS);
    initial 
    begin
            
        #100
        CS = 0;
        
        #50
        for (ii=0; ii<40; ii=ii+1)
        begin
          MOSI = hh[39-ii];
          $display("Time %2d: MOSI data at Index %1d is %2d", $time, ii, hh[ii]);
          #200;
        end
        CS = 1;
        
        #1000
        CS = 0;
        
        #50
        hh = 40'h0200010002;
        for (ii=0; ii<32; ii=ii+1)
        begin
          MOSI = hh[39-ii];
          $display("Time %2d: MOSI data at Index %1d is %2d", $time, ii, hh[ii]);
          #200;
        end
        CS = 1;
    end         
endmodule
