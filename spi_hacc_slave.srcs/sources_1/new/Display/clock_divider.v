`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2021 08:09:37 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
	input wire clk,								// 50 MHz
	output reg dclk = 0
);
localparam div_value = 24999;
//	division_value = 50 MHz / (2 * desired Frequency) - 1
// counter
integer counter_value = 0; 					// 32 bit wide reg bus

always@ (posedge clk)							// rising edge 0-1
begin
	// keep counting until div value
	if (counter_value == div_value)
		counter_value <= 0;						// reset value
	else
		counter_value <= counter_value + 1; // count up
end

// divide clock
always@ (posedge clk)
begin
	if(counter_value == div_value)
		dclk <= ~dclk;			// flip the signal
	else
		dclk <= dclk;			// store value
end

endmodule 