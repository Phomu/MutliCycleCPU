`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/22 19:15:02
// Design Name: 
// Module Name: ControlUnit
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


//Control Unit
module ControlUnit(
        input CLK,
        input RST,
        input zero,         //ALU运算结果是否为0，为0时候为1
        input [5:0] op,     //指令的操作码
        output reg IRWre,       //IR的写使能信号
        output reg PCWre,       //PC是否更改的信号量，为0时候不更改，否则可以更改
        output reg ExtSel,      //立即数扩展的信号量，为0时候为0扩展，否则为符号扩展
        output reg InsMemRW,    //指令寄存器的状态操作符，为0的时候写指令寄存器，否则为读指令寄存器
        output reg WrRegDSrc,   //写入寄存器的数据选择信号
        output reg [1:0] RegDst,//写寄存器组寄存器的地址，为0的时候地址来自rt，为1的时候地址来自rd
        output reg RegWre,      //寄存器组写使能，为1的时候可写
        output reg ALUSrcA,     //控制ALU数据A的选择端的输入，为0的时候，来自寄存器堆data1输出，为1的时候来自移位数sa
        output reg ALUSrcB,     //控制ALU数据B的选择端的输入，为0的时候，来自寄存器堆data2输出，为1时候来自扩展过的立即数
        output reg [1:0]PCSrc,  //获取下一个pc的地址的数据选择器的选择端输入
        output reg [2:0]ALUOp,  //ALU 8种运算功能选择(000-111)
        output reg mRD,         //数据存储器读控制信号，为0读
        output reg mWR,         //数据存储器写控制信号，为0写
        output reg DBDataSrc    //数据保存的选择端，为0来自ALU运算结果的输出，为1来自数据寄存器（Data MEM）的输出        
    );
    
    reg [2:0] state, nextState;    //记录状态
    parameter [2:0] iniState = 3'b111,
                    sIF = 3'b000,
                    sID = 3'b001,
                    sEXE = 3'b010,
                    sMEM = 3'b100,
                    sWB = 3'b011;
    initial begin
        state = iniState;
        PCWre = 0;  
        InsMemRW = 0;  
        IRWre = 0;  
        RegWre = 0;  ;  
        ExtSel = 0;  
        PCSrc = 2'b00;  
        RegDst = 2'b11;
        ALUOp = 0;  
        ExtSel = 0;
        WrRegDSrc = 0;
        ALUSrcA = 0;
        ALUSrcB = 0;
        DBDataSrc = 0;
        mRD = 0;
        mWR = 0;
    end
    
    //状态机
    always@(posedge CLK) begin
        if(!RST) begin
            state <= sIF;
        end else begin
            state <= nextState;
        end
    end
    
    always@(state or op or zero) begin
        // 状态更新
        case(state)
            iniState : nextState = sIF;
            sIF: nextState = sID;
            sID: begin
                case(op[5:3])
                    3'b111: nextState = sIF;    //指令j,jal,jr,halt
                    default: nextState = sEXE;
                endcase
            end
            sEXE: begin 
                if((op == 6'b110100) || (op == 6'b110110)) begin
                    //beq,bltz
                    nextState = sIF;
                end else if(op == 6'b110000 || op == 6'b110001) begin
                    //sw,lw
                    nextState = sMEM;
                end else begin
                    nextState = sWB;
                end
            end
            sMEM: begin
                if(op == 6'b110000) begin
                    //sw
                    nextState = sIF;
                end else begin
                    //lw
                    nextState = sWB;
                end
            end
            sWB: nextState = sIF;
        endcase
        
        // 信号量
        // PCWre and InsMemRW 
        if(nextState == sIF && op != 6'b111111 && state != iniState) begin
            // halt
            PCWre = 1;
            InsMemRW = 1;  
        end else begin
            PCWre = 0;
            InsMemRW = 0;  
        end
        
        // IRWre
        if(state == sIF || nextState == sID) begin
            IRWre = 1;
        end else begin
            IRWre = 0;
        end
        
        // ALUSrcA
        if(op == 6'b011000) begin
            // sll
            ALUSrcA = 1;
        end else begin
            ALUSrcA = 0;
        end
        
        // ALUSrcB
        if(op == 6'b000010 || op == 6'b010010 || op == 6'b110000 || op == 6'b110001 || op == 6'b100111) begin
           // addi,ori,sw,lw,sltiu
           ALUSrcB = 1;
        end else begin
           ALUSrcB = 0;
        end
        
        // DBDataSrc
        if(op == 6'b110001) begin
            // lw
            DBDataSrc = 1;
        end else begin
            DBDataSrc = 0;
        end
        
        // RegWre and WrRegDSrc and RegDst
        if((state == sWB && op != 6'b110100 && op != 6'b110000 && op != 6'b110110) || (op == 6'b111010 && state == sID)) begin
            // 非beq，sw，bltz
            RegWre = 1;
            if(op == 6'b111010) begin
                // jal
                WrRegDSrc = 0;
                RegDst = 2'b00;
            end else begin
                WrRegDSrc = 1;
                if(op == 6'b000010 || op == 6'b010010 || op == 6'b100111 || op == 6'b110001) begin
                    // addi, ori, sltiu, lw
                    RegDst = 2'b01;
                end else begin
                    // add, sub, or, and, slt, sll
                    RegDst = 2'b10;
                end
            end
        end else begin
            RegWre = 0;
        end
        
        // InsMemRW
        if(op != 6'b111111)
            InsMemRW = 1;
        
        // mRD 
        mRD = (op == 6'b110001) ? 1 : 0; // lw
        
        // mWR
        mWR = (state == sMEM && op == 6'b110000) ? 1 : 0; // sw
        
        // ExtSel
        ExtSel = (op == 6'b000010 || op == 6'b110001 || op == 6'b110000 || op == 6'b110100 || op == 6'b110110) ? 1 : 0; // addi、lw、sw、beq、bltz
        
        // PCSrc
        if(op == 6'b111001) begin
            // jr
            PCSrc = 2'b10;
        end else if((op == 6'b110100 && zero) || (op == 6'b110110 && !zero)) begin
            // beq 和 bltz跳转
            PCSrc = 2'b01;
        end else if(op == 6'b111010 || op == 6'b111000) begin
            // j,jal
            PCSrc = 2'b11;
        end else begin
            PCSrc = 2'b00;
        end
        
        // ALUOp
        case(op)
            6'b000010: ALUOp = 3'b000;  // addi
            6'b010010: ALUOp = 3'b101;  // ori
            6'b010000: ALUOp = 3'b101;  // or
            6'b000001: ALUOp = 3'b001;  // sub
            6'b010001: ALUOp = 3'b110;  // and
            6'b011000: ALUOp = 3'b100;  // sll
            6'b110100: ALUOp = 3'b001;  // beq
            6'b100110: ALUOp = 3'b011;  // slt
            6'b100111: ALUOp = 3'b010;  // sltiu
            6'b110110: ALUOp = 3'b001;  // bltz
            6'b110001: ALUOp = 3'b000;  //sw
            6'b110000: ALUOp = 3'b000;  //lw
        endcase
    end
endmodule
