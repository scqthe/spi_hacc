`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2022 12:10:00 PM
// Design Name: 
// Module Name: tb_alu
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


module tb_alu();


    reg clk_tb = 0;
    reg SCLK = 0;
    reg MOSI = 0;
    reg CS = 0;
    wire dclk;
    wire MISO;
    integer ii;
    wire [31:0] alu_result;

    reg [15:0] op1 = 16'h23;
    reg [15:0] op2 = 16'h19;


    
    // unit under test (uut)
    ALU dut (
        .enable(CS),
        .opcode(8'd2),
        .op1(op1),
        .op2(op2),
        .result(alu_result)
    );
    
    initial forever #1 clk_tb = ~clk_tb; 
    initial forever #100 SCLK = (~SCLK & ~CS);
    initial 
    begin
            
        #100
        CS = 0;
        
        #50
        CS = 1;
        
        #1000
        CS = 0;
        
    end         


endmodule
