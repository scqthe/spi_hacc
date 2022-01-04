`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/31/2021 07:38:30 AM
// Design Name: 
// Module Name: 7seg_led_display
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


module digit_display(
input clk,
input [31:0] digit,
output wire [7:0] cathode,
output wire [7:0] anode
    );
    //wire refresh_clock;
    wire [2:0] refreshcounter;
    wire [3:0] ONE_DIGIT;
    
    
    //wrapper for clock divider
    clock_divider refreshclock_generator(
       .clk(clk),
       .dclk(refresh_clock)
    );
    
    refreshcounter Refreshcounter_wrapper(
    .refresh_clock(refresh_clock),
    .refreshcounter(refreshcounter)
    );
    
    anode_control anoder_control_wrapper(
    .refreshcounter(refreshcounter),
    .anode(anode)
    );
    
    BCD_control BCD_control_wrapper(
    .digit1(digit[3:0]),
    .digit2(digit[7:4]),
    .digit3(digit[11:8]),
    .digit4(digit[15:12]),
    .digit5(digit[19:16]),
    .digit6(digit[23:20]),
    .digit7(digit[27:24]),
    .digit8(digit[31:28]),
    .refreshcounter(refreshcounter),
    .ONE_DIGIT(ONE_DIGIT)
    );
    
    BCD_to_cathode BCD_to_cathode_wrapper(
    .digit(ONE_DIGIT),
    .cathode(cathode)
    );
endmodule
