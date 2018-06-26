`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/23 15:06:53
// Design Name: 
// Module Name: TestOfMultiCycleCPU
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


module TestOfMultiCycleCPU();
    // Inputs
	reg CLK;
	reg RST;

	// Outputs
	wire [1:0] PCSrc;
	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [31:0] DB;
	wire [31:0] result;
	wire [31:0] curPC;
    wire [31:0] nextPC;
    wire [31:0] instruction;
    wire [31:0] IRInstruction;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] dataDB;
    wire [31:0] dataA;
    wire [31:0] dataB;
    wire [31:0] dataResult;
    wire zero;
    wire PCWre;       //PC是否更改的信号量，为0时候不更改，否则可以更改
    wire ExtSel;      //立即数扩展的信号量，为0时候为0扩展，否则为符号扩展
    wire InsMemRW;    //指令寄存器的状态操作符，为0的时候写指令寄存器，否则为读指令寄存器
    wire [1:0]RegDst;      //写寄存器组寄存器的地址，为0的时候地址来自rt，为1的时候地址来自rd
    wire RegWre;      //寄存器组写使能，为1的时候可写
    wire ALUSrcA;     //控制ALU数据A的选择端的输入，为0的时候，来自寄存器堆data1输出，为1的时候来自移位数sa
    wire ALUSrcB;     //控制ALU数据B的选择端的输入，为0的时候，来自寄存器堆data2输出，为1时候来自扩展过的立即数
    wire [2:0]ALUOp;  //ALU 8种运算功能选择(000-111)
    wire mRD;         //数据存储器读控制信号，为0读
    wire mWR;         //数据存储器写控制信号，为0写
    wire WrRegDSrc;    //写入寄存器组寄存器的数据选择信号
    wire DBDataSrc;    //数据保存的选择端，为0来自ALU运算结果的输出，为1来自数据寄存器（Data MEM）的输出  
    wire WriteReg;
	// Instantiate the Unit Under Test (UUT)
	MultiCycleCPU uut  (.CLK(CLK), 
                        .RST(RST), 
                        .curPC(curPC),
                        .nextPC(nextPC),
                        .instruction(instruction),
                        .IRInstruction(IRInstruction),
                        .op(op), 
                        .rs(rs),
                        .rt(rt),
                        .rd(rd),
                        .DB(DB),
                        .dataDB(dataDB),
                        .A(A),
                        .dataA(dataA),
                        .B(B),
                        .dataB(dataB),
                        .result(result),
                        .dataResult(dataResult),
                        .PCSrc(PCSrc),
                        .zero(zero),
                        .PCWre(PCWre),
                        .ExtSel(ExtSel),
                        .InsMemRW(InsMemRW),
                        .RegDst(RegDst),
                        .RegWre(RegWre),
                        .ALUSrcA(ALUSrcA),
                        .ALUSrcB(ALUSrcB),
                        .ALUOp(ALUOp),
                        .mRD(mRD),
                        .mWR(mWR),
                        .DBDataSrc(DBDataSrc),
                        .WrRegDSrc(WrRegDSrc),
                        .WriteReg(WriteReg)
	);
	
    initial begin
        CLK = 0;
        RST = 0;
        #20 RST = 1;
        forever #20 CLK = ~CLK;
    end
endmodule
