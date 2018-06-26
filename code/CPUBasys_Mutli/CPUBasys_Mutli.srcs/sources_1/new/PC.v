`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/22 19:13:14
// Design Name: 
// Module Name: PC
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


module PC(
       input CLK,               //时钟
       input RST,             //是否重置地址。0-初始化PC，否则接受新地址
       input PCWre,             //是否接受新的地址。0-不更改；1-可以更改
       input [31:0] nextPC,  //新指令地址
       output reg[31:0] curPC //当前指令的地址
    );
    
    initial begin
        curPC <= 0;
    end

    always@(posedge CLK or negedge RST)
    begin
        if(!RST) // Reset == 0, PC = 0
            begin
                curPC <= 0;
            end
        else 
            begin
                if(PCWre) // PCWre == 1
                    begin 
                        curPC <= nextPC;
                    end
                else    // PCWre == 0, halt
                    begin
                        curPC <= curPC;
                    end
            end
    end
endmodule
