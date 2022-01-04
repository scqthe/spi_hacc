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



module BCD_to_cathode (
input [3:0] digit,
output reg [7:0] cathode
);
always@(digit) 
begin
    cathode[7] = 1'b1;
	case(digit)
		4'h0:
			cathode[6:0] = 7'b1000000;	// zero
		4'h1:
			cathode[6:0] = 7'b1111001;	// one
		4'h2:
			cathode[6:0] = 7'b0100100;	// two
		4'h3:
			cathode[6:0] = 7'b0110000;	// three
		4'h4:
			cathode[6:0] = 7'b0011001;	// four
		4'h5:
			cathode[6:0] = 7'b0010010;	// five
		4'h6:
			cathode[6:0] = 7'b0000010;	// six
		4'h7:
			cathode[6:0] = 7'b1111000;	// seven
		4'h8:
			cathode[6:0] = 7'b0000000;	// eight
		4'h9:
			cathode[6:0] = 7'b0010000;	// nine
		4'ha:
			cathode[6:0] = 7'b0001000;	// a
		4'hb:
			cathode[6:0] = 7'b0000011;	// b
		4'hc:
			cathode[6:0] = 7'b1000110;	// c
		4'hd:
			cathode[6:0] = 7'b0100001;	// d
		4'he:
			cathode[6:0] = 7'b0000110;	// e
		4'hf:
			cathode[6:0] = 7'b0001110;	// f
		default:
			cathode[6:0] = 7'b1000000;	// zero in any other cases
	endcase
end
endmodule