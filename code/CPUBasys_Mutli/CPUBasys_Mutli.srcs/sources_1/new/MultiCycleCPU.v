`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/22 19:21:34
// Design Name: 
// Module Name: MultiCycleCPU
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


module MultiCycleCPU(
       input CLK,
        input RST,
        output [31:0] curPC,
        output [31:0] nextPC,
        output [31:0] instruction,
        output [31:0] IRInstruction,
        output [5:0] op,
        output [4:0] rs,
        output [4:0] rt,
        output [4:0] rd,
        output [31:0] DB,
        output [31:0] dataDB,
        output [31:0] A,
        output [31:0] dataA,
        output [31:0] B,
        output [31:0] dataB,
        output [31:0] result,
        output [31:0] dataResult,
        output [1:0] PCSrc
    );
    wire zero;
    wire PCWre;       //PC是否更改的信号量，为0时候不更改，否则可以更改
    wire ExtSel;      //立即数扩展的信号量，为0时候为0扩展，否则为符号扩展
    wire InsMemRW;    //指令寄存器的状态操作符，为0的时候写指令寄存器，否则为读指令寄存器
    wire [1:0] RegDst;      //写寄存器组寄存器的地址，为0的时候地址来自rt，为1的时候地址来自rd
    wire RegWre;     //寄存器组写使能，为1的时候可写
    wire ALUSrcA;    //控制ALU数据A的选择端的输入，为0的时候，来自寄存器堆data1输出，为1的时候来自移位数sa
    wire ALUSrcB;    //控制ALU数据B的选择端的输入，为0的时候，来自寄存器堆data2输出，为1时候来自扩展过的立即数
    wire [2:0]ALUOp; //ALU 8种运算功能选择(000-111)
    wire mRD;        //数据存储器读控制信号，为0读
    wire mWR;         //数据存储器写控制信号，为0写
    wire DBDataSrc;   //数据保存的选择端，为0来自ALU运算结果的输出，为1来自数据寄存器（Data MEM）的输出  
    wire WrRegDSrc;    //写入寄存器组寄存器的数据选择信号
    wire WriteReg;     //写回寄存器地址
    wire [31:0] extend;
    wire [31:0] DataOut;
    wire[4:0] sa;
    wire[15:0] immediate;
    wire[25:0] addr;
    
    ControlUnit ControlUnit(.CLK(CLK),
                            .RST(RST),
                            .zero(zero),
                            .op(op),
                            .IRWre(IRWre),
                            .PCWre(PCWre),
                            .ExtSel(ExtSel),
                            .InsMemRW(InsMemRW),
                            .WrRegDSrc(WrRegDSrc),
                            .RegDst(RegDst),
                            .RegWre(RegWre),
                            .ALUSrcA(ALUSrcA),
                            .ALUSrcB(ALUSrcB),
                            .PCSrc(PCSrc),
                            .ALUOp(ALUOp),
                            .mRD(mRD),
                            .mWR(mWR),
                            .DBDataSrc(DBDataSrc));
    
    pcAdd pcAdd(.RST(RST),
                .PCSrc(PCSrc),
                .immediate(extend),
                .addr(addr),
                .curPC(curPC),
                .rs(A),
                .nextPC(nextPC));
                    
    PC PC(.CLK(CLK),
          .RST(RST),
          .PCWre(PCWre),
          .nextPC(nextPC),
          .curPC(curPC));
                              
    InsMEM InsMEM(.IAddr(curPC), 
                  .InsMemRW(InsMemRW), 
                  .IDataOut(instruction));

    IR IR(.instruction(instruction),
          .CLK(CLK),
          .IRWre(IRWre),
          .IRInstruction(IRInstruction));
          
    InstructionCut InstructionCut(.instruction(IRInstruction),
                                  .op(op),
                                  .rs(rs),
                                  .rt(rt),
                                  .rd(rd),
                                  .sa(sa),
                                  .immediate(immediate),
                                  .addr(addr));
    
    SignZeroExtend SignZeroExtend(.immediate(immediate),
                                  .ExtSel(ExtSel),
                                  .extendImmediate(extend));
                                  
    RegisterFile RegisterFile(.CLK(CLK),
                              .ReadReg1(rs),
                              .ReadReg2(rt),
                              .rd(rd),
                              .WriteData(WrRegDSrc ? dataDB : curPC + 4),
                              .RegDst(RegDst),
                              .RegWre(RegWre),
                              .ReadData1(A),
                              .ReadData2(B),
                              .WriteReg(WriteReg));
                              
    TempReg ADR(.CLK(CLK),
                .IData(A),
                .OData(dataA));
                
    TempReg BDR(.CLK(CLK),
                .IData(B),
                .OData(dataB));
                
    ALU alu(.ALUSrcA(ALUSrcA),
            .ALUSrcB(ALUSrcB),
            .ReadData1(dataA),
            .ReadData2(dataB),
            .sa(sa),
            .extend(extend),
            .ALUOp(ALUOp),
            .zero(zero),
            .result(result));
                            
    TempReg ALUoutDR(.CLK(CLK),
                     .IData(result),
                     .OData(dataResult));
    
    DataMEM DataMEM(.mRD(mRD),
                    .mWR(mWR),
                    .DBDataSrc(DBDataSrc),
                    .DAddr(result),
                    .DataIn(dataB),
                    .DataOut(DataOut),
                    .DB(DB));
                    
    TempReg DBDR(.CLK(CLK),
                 .IData(DB),
                 .OData(dataDB));
                 
endmodule
