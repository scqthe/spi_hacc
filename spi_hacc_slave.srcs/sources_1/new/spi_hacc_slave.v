`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pennsylvania State University
// Engineer: Anand Rajan
// 
// Create Date: 11/23/2021 11:06:11 AM
// Design Name: SPI interface to RPI3
//
// Module Name: spi_hacc_slave
//
// Project Name: Computational Hardware Acceleration in FPGA (Prototype)
// Target Devices: NexyA7-100T (with Raspberry PI3 as the host)
// Tool Versions: Vivaldo 2020
//
// Description: 
// This file implements a simple ALU implemetation in FPGA with access through SPI
// from Raspberry PI3. This simple SPI Slave accepts 5 bytes during the MOSI cycle
// and responds with 4 byte result during the MISO cycle.
//
// MOSI Cycle:
//    5 Octets - <opcode>,<operand1>,<operand2>
//    Octet1 - OPCODE - ALU Operation to perform
//    Octet2 - OPERAND1-HI [Higher 8bits of the 16-bit OPERAND1]
//    Octet3 = OPERAND1-LO [Lower 8bits of the 16-bit OPERAND1]
//    Octet4 - OPERAND2-HI [Higher 8bits of the 16-bit OPERAND2]
//    Octet5 = OPERAND2-LO [Lower 8bits of the 16-bit OPERAND2]
// 
// MISO Cycle:
//    Returns the 32bit RESULT in 4 Octets
//    Octet1 - RESULT[31:24]
//    Octet2 - RESULT[23:16]
//    Octet3 = RESULT[15:8]
//    Octet4 - RESULT[7:0]
//
// Dependencies: 
// 
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//    Thanks to www.fpga4fun.com for the examples
//
//////////////////////////////////////////////////////////////////////////////////


module spi_hacc_slave(
    input  clk,  // System Clock
    input  SCLK, // SPI0 SCLK (GPIO11 - PIN23)
    input  MOSI, // SPI0 MOSI (GPIO10 - PIN19)
    output reg MISO,// SPI0 MISO (GPIO9  - PIN21)
    output [7:0] anode,
    output [7:0] cathode,
    input  CS // SPI0 CS0 (GPIO8 - PIN24)
    );

    // sync SCLK to the FPGA clock using a 3-bits shift register
    reg [2:0] SCLKr;  always @(posedge clk) SCLKr <= {SCLKr[1:0], SCLK};
    wire SCLK_risingedge  = (SCLKr[2:1]==2'b01);  // now we can detect SCLK rising edges
    wire SCLK_fallingedge = (SCLKr[2:1]==2'b10);  // and falling edges
    
    // same thing for CS
    reg [2:0] CSr;  always @(posedge clk) CSr <= {CSr[1:0], CS};
    wire CS_active = ~CSr[1];  // CS is active low
    wire CS_startmessage = (CSr[2:1]==2'b10);  // message starts at falling edge
    wire CS_endmessage = (CSr[1:0]==2'b01);  // message stops at rising edge
    
    // and for MOSI
    reg [1:0] MOSIr;  
    
    always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
    wire MOSI_data = MOSIr[0];
         
    // we handle SPI in 40-bit format, so we need a 6 bits counter to count the bits as they come in
    reg [5:0] bitcnt;
    reg [39:0] cmd_data_received;
    reg [31:0] result_tosend = 32'h0;
    reg [31:0] result_data = 32'h12345678;
    reg cmd_received;  // high when a byte has been received

    wire [31:0] alu_result;
    ALU alu(
        .enable(cmd_received), 
        .opcode(cmd_data_received[39:32]), 
        .op1(cmd_data_received[31:16]), 
        .op2(cmd_data_received[15:0]), 
        .result(alu_result)
    );
    
    digit_display dd(
        .clk(clk), 
        .digit(result_data),
        .cathode(cathode),
        .anode(anode)
    );
  
    // receive data from MOSI
    always @(posedge clk)
    begin
      if(~CS_active)
         bitcnt <= 6'b000000;
      else
         if(SCLK_risingedge)
         begin
            bitcnt <= bitcnt + 6'b000001;
            // implement a shift-left register (since we receive the data MSB first)
            cmd_data_received <= {cmd_data_received[38:0], MOSI_data};
         end
    end
    
    // check if all 40 bits are received
    always @(posedge clk) cmd_received <= CS_active && SCLK_risingedge && (bitcnt==6'd39);
    
    // display the digits after all the full command is received
    //always @(posedge clk) if (cmd_received) result_data = cmd_data_received[31:0];
    //always @(posedge clk) if (cmd_received) result_data = result_tosend;
    
    // populate the reg to display on the 7-seg LED
    always @(negedge clk)
    begin
        if (cmd_received) result_data = alu_result;
    end
    
    // SEND result on MISO
    // we assume that there is only one slave on the SPI bus
    // so we don't bother with a tri-state buffer for MISO
    // otherwise we would need to tri-state MISO when CS is inactive    
    integer miso_index = 6'd32;    
    always @(negedge clk)
    begin
        if (CS_startmessage) 
        begin
                MISO <= result_data[miso_index - 1'b1];
                miso_index <= miso_index - 1;
        end
		
        if(SCLK_fallingedge)
        begin
            if(miso_index != 0)
            begin
                MISO <= result_data[miso_index - 1'b1];
                miso_index <= miso_index - 1;
            end
            else
            begin
                MISO <= 1;
            end
        end
               
        if(CS_endmessage)
        begin
            miso_index <= 6'd32;
            MISO <= 0;
        end
    end
    
endmodule


