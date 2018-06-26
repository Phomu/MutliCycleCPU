`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/22 20:06:44
// Design Name: 
// Module Name: TempReg
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


module TempReg(
        input CLK,
        input [31:0] IData,
        output reg[31:0] OData
    );
    
    initial begin 
        OData = 0;
    end
    
    always@(posedge CLK) begin
        OData <= IData;
    end
endmodule
