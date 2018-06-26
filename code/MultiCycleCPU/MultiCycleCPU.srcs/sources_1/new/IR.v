`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/22 19:52:31
// Design Name: 
// Module Name: IR
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


module IR(
        input [31:0] instruction,
        input CLK,
        input IRWre,
        output reg[31:0] IRInstruction
    );
    
    initial begin
        IRInstruction = 0;
    end
    
    always@(posedge CLK)
    begin
        if(IRWre) begin
            IRInstruction <= instruction;
        end
    end
     
endmodule
