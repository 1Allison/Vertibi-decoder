`include "params.v"
/*-----------------------------------*/
// Module: TBU
// File : tbu.v 
// Description : Description of TBU Unit in Viterbi Decoder 
// Simulator : Modelsim 6.5 / Windows 7/10
/*-----------------------------------*/
// Revision Number : 1 
// Description : Initial Design 
/*-----------------------------------*/
//路径回溯模块
module TBU (Reset, Clock1, Clock2, TB_EN, Init, Hold, InitState, DecodedData, DataTB, AddressTB);
input Reset, Clock1, Clock2, Init, Hold;
input [`WD_STATE-1:0] InitState; //WD_STATE 8
input TB_EN;
input [`WD_RAM_DATA-1:0] DataTB; //WD_RAM_DATA 8 

output [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB; //WD_RAM_ADDRESS 11 WD_FSM 6 11-6-1=4
output DecodedData;

wire [`WD_STATE-1:0] OutStateTB;
//实例化
TRACEUNIT tb (Reset, Clock1, Clock2, TB_EN, InitState, Init, Hold, DataTB, AddressTB, OutStateTB);
assign DecodedData = OutStateTB [`WD_STATE-1];
endmodule

/*-----------------------------------*/
module TRACEUNIT (Reset, Clock1, Clock2, Enable, InitState, Init, Hold, Survivor, AddressTB, OutState);
/*-----------------------------------*/
input Reset, Clock1, Clock2, Enable;
input [`WD_STATE-1:0] InitState;
input Init, Hold;
input [`WD_RAM_DATA-1:0] Survivor;

output [`WD_STATE-1:0] OutState;
output [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB;

reg [`WD_STATE-1:0] CurrentState; //当前状态
reg [`WD_STATE-1:0] NextState;  //下一状态
reg [`WD_STATE-1:0] OutState;  //输出状态
wire SurvivorBit;

    always @(negedge Clock1 or negedge Reset)
    begin
        //首先复位 初始化信号
        if (~Reset) 
        begin
            CurrentState <=0; OutState <=0;
        end
        else if (Enable) //使能信号有效
            begin
                //若数据完成了64次迭代，那么当前状态为初始状态
                //init=1，开始处理，把输入的初始状态赋值给当前状态。
                if (Init) CurrentState <= InitState;
                //数据在处理迭代的过程，当前状态即下一状态。
                else CurrentState <= NextState;
                //若一个信号处理完毕，输出下一状态。
                if (Hold) OutState <= NextState;
            end
    end

    //当前的状态[7:3]前四位 输出AddressTB 为地址
    assign AddressTB = CurrentState [`WD_STATE-1:`WD_STATE-5];

    always @(negedge Clock2 or negedge Reset)
    begin
        //初始化
        if (~Reset) NextState <= 0;
            else 
            //若使能信号有效，当前状态左移一位，最后一位用幸存值填充。
                if (Enable) NextState <= {CurrentState [`WD_STATE-2:0],SurvivorBit};
    end
    //当两个clock都为1且未完成一次信号迭代时，幸存值为 Survivor [CurrentState [2:0]]
 //   assign SurvivorBit = (Clock1 && Clock2 && ~Init) ? Survivor [CurrentState [2:0]]:'bz;
//根据当前状态从幸存单元中读出幸存值
always @（CurrentState or Clock1 or Clock2 or Init or Survivor ）
    begin
        case（CurrentState[2:0]）
        3'b000: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [0]:'bz;
        3'b001: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [1]:'bz;
        3'b010: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [2]:'bz;
        3'b011: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [3]:'bz;
        3'b100: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [4]:'bz;
        3'b101: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [5]:'bz;
        3'b110: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [6]:'bz;
        3'b111: SurvivorBit <= (Clock1 && Clock2 && ~Init) ? Survivor [7]:'bz;
        endcase
    end
endmodule