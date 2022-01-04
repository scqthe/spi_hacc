`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2021 06:59:59 PM
// Design Name: 
// Module Name: ALU
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


module ALU(input enable, input [7:0] opcode, input [15:0] op1, input [15:0] op2,  output reg [31:0] result = 32'h0);
    // Not dependent on clock; performs different ops based on aluc
    
   always @(*) begin
        result <= 32'h0;
        if(enable) 
        begin
            case(opcode) 
                8'h0: // AND
                    begin
                        result <= (op1 && op2) & 32'hFFFFFFFF;              
                    end
                
                8'h1: // OR
                    begin
                        result <= op1 || op2;
                    end
                    
                8'h2: // add
                    begin
                        result <=  op1 + op2;
                    end
                    
                8'h3: // subtract
                    begin
                        result <= op1 - op2;
                    end         
					
                8'h4: // set on less than
                    begin
                        if (op1 < op2) begin
                            result <= 32'b1;
                        end else begin
                            result <= 32'b0;
                        end
                    end
                    
                8'h5: // NOR
                    begin
                        result <= ~(op1 || op2);
                    end
                    
                8'h6: // multiply
                    begin
                        result <= (op1 * op2);
                    end
                    
                8'h7: // divide -- optimize out with shifts where possible
                    begin
                        result <= (op1 / op2);
                    end                                           
                default:
                    begin
                        result <= 32'h0;
                    end    
            endcase
         end
     end
endmodule
