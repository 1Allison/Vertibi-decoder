`include "params.v" //导入需要用到的宏定义
/*-----------------------------------*/
// Module: RAMs
// File : ram.v
// Description : The RAMs definition. 定义 RAM
// -- mainly used on functional simulation only 主要用在功能仿真
// Simulator : Modelsim 6.5 / Windows 7/10
/*-----------------------------------*/
// Revision Number : 1 
// Description : Initial Design 
/*-----------------------------------*/
/*-----------------------------------*/
module RAM (RAMEnable, AddressRAM, DataRAM, RWSelect, ReadClock, WriteClock);
//
// Survivor memory instantiation 留存存储实例化
/*-----------------------------------*/
input RAMEnable, RWSelect, ReadClock, WriteClock;
input [`WD_RAM_ADDRESS-1:0] AddressRAM; // WD_RAM_ADDRESS 11
inout [`WD_RAM_DATA-1:0] DataRAM;  //WD_RAM_DATA 8
//调用修改参数 size改成2048，DATABITS改为8，ADDRESSBITS11 将模块rammodule实例化为ram
RAMMODULE #(2048,8,11) RAM (RAMEnable, DataRAM, AddressRAM, RWSelect, ReadClock, WriteClock);
endmodule


/*-----------------------------------*/
module RAMMODULE (_Enable, Data, Address, RWSelect, RClock, WClock);
// 
// RAM Enable : Active Low 使能 RAM 低电平激活
/*-----------------------------------*/
//参数声明
parameter SIZE = 2048; //地址范围从0-2047
parameter DATABITS = 8;
parameter ADDRESSBITS = 7;
//输入输出端口声明
inout [DATABITS-1:0] Data;
input [ADDRESSBITS-1:0] Address;
//用RWSelect信号去控制到底是读数据还是写数据
input RWSelect; // 0:Write 1:Read 

input RClock,WClock,_Enable;

reg [DATABITS-1:0] Data_Regs [SIZE-1:0];
reg [DATABITS-1:0] DataBuff;

    // Write 
    //首先在WClock时钟下降沿，若enable信号有效，（它是一个低电平有效的信号）就写入数据在Data_Regs中。
    always @(negedge WClock)
    begin
        if (~_Enable) Data_Regs [Address] <= Data;
    end

    // Read
    always @(negedge RClock)
    begin
    //首先在RClock时钟下降沿，若enable信号有效，（它是一个低电平有效的信号）就读入数据放在databuff中。
        if (~_Enable) DataBuff <= Data_Regs [Address];
    end
    //当RWSelect信号为1时，将databuff中的数据放在DATA中。否则放入信号zzzz。
    assign Data = (RWSelect) ? DataBuff:'bz;
    endmodule


/*-----------------------------------*/
module METRICMEMORY (Reset, Clock1, Active, MMReadAddress, MMWriteAddress, MMBlockSelect, MMMetric, MMPathMetric);
//
// This module is used as metric memory who holds the metric values. 
//这个模块被用作储存度量值
/*-----------------------------------*/
input Reset, Clock1, Active, MMBlockSelect;

input [`WD_METR*`N_ACS-1:0] MMMetric;
//WD_FSM为6。这个是怎么算得，得回去看原理。256 (states) : 4 (ACSs) = 64 --> log2(64) = 6
input [`WD_FSM-1:0] MMWriteAddress;  
input [`WD_FSM-2:0] MMReadAddress;
//N_ACS是4 WD_METR 8  是32-1
output [`WD_METR*2*`N_ACS-1:0] MMPathMetric;

//N_ITER 64  故是一个size为64的32位存储器
reg [`WD_METR*`N_ACS-1:0] M_REG_A [`N_ITER-1:0];
reg [`WD_METR*`N_ACS-1:0] M_REG_B [`N_ITER-1:0];

reg [`WD_METR*2*`N_ACS-1:0] MMPathMetric;

always @(negedge Clock1 or negedge Reset)
    begin
    //复位信号对 M_REG_A  M_REG_B数据进行初始化
    if (~Reset)
    begin
        M_REG_A [63] <= 0;M_REG_A [62] <= 0;M_REG_A [61] <= 0;
        M_REG_A [60] <= 0;M_REG_A [59] <= 0;M_REG_A [58] <= 0;
        M_REG_A [57] <= 0;M_REG_A [56] <= 0;M_REG_A [55] <= 0;
        M_REG_A [54] <= 0;M_REG_A [53] <= 0;M_REG_A [52] <= 0;
        M_REG_A [51] <= 0;M_REG_A [50] <= 0;M_REG_A [49] <= 0;
        M_REG_A [48] <= 0;M_REG_A [47] <= 0;M_REG_A [46] <= 0;
        M_REG_A [45] <= 0;M_REG_A [44] <= 0;M_REG_A [43] <= 0;
        M_REG_A [42] <= 0;M_REG_A [41] <= 0;M_REG_A [40] <= 0;
        M_REG_A [39] <= 0;M_REG_A [38] <= 0;M_REG_A [37] <= 0;
        M_REG_A [36] <= 0;M_REG_A [35] <= 0;M_REG_A [34] <= 0;
        M_REG_A [33] <= 0;M_REG_A [32] <= 0;M_REG_A [31] <= 0;
        M_REG_A [30] <= 0;M_REG_A [29] <= 0;M_REG_A [28] <= 0;
        M_REG_A [27] <= 0;M_REG_A [26] <= 0;M_REG_A [25] <= 0;
        M_REG_A [24] <= 0;M_REG_A [23] <= 0;M_REG_A [22] <= 0;
        M_REG_A [21] <= 0;M_REG_A [20] <= 0;M_REG_A [19] <= 0;
        M_REG_A [18] <= 0;M_REG_A [17] <= 0;M_REG_A [16] <= 0;
        M_REG_A [15] <= 0;M_REG_A [14] <= 0;M_REG_A [13] <= 0;
        M_REG_A [12] <= 0;M_REG_A [11] <= 0;M_REG_A [10] <= 0;
        M_REG_A [9] <= 0;M_REG_A [8] <= 0;M_REG_A [7] <= 0;
        M_REG_A [6] <= 0;M_REG_A [5] <= 0;M_REG_A [4] <= 0;
        M_REG_A [3] <= 0;M_REG_A [2] <= 0;M_REG_A [1] <= 0;
        M_REG_A [0] <= 0;

        M_REG_B [63] <= 0;M_REG_B [62] <= 0;M_REG_B [61] <= 0;
        M_REG_B [60] <= 0;M_REG_B [59] <= 0;M_REG_B [58] <= 0;
        M_REG_B [57] <= 0;M_REG_B [56] <= 0;M_REG_B [55] <= 0;
        M_REG_B [54] <= 0;M_REG_B [53] <= 0;M_REG_B [52] <= 0;
        M_REG_B [51] <= 0;M_REG_B [50] <= 0;M_REG_B [49] <= 0;
        M_REG_B [48] <= 0;M_REG_B [47] <= 0;M_REG_B [46] <= 0;
        M_REG_B [45] <= 0;M_REG_B [44] <= 0;M_REG_B [43] <= 0;
        M_REG_B [42] <= 0;M_REG_B [41] <= 0;M_REG_B [40] <= 0;
        M_REG_B [39] <= 0;M_REG_B [38] <= 0;M_REG_B [37] <= 0;
        M_REG_B [36] <= 0;M_REG_B [35] <= 0;M_REG_B [34] <= 0;
        M_REG_B [33] <= 0;M_REG_B [32] <= 0;M_REG_B [31] <= 0;
        M_REG_B [30] <= 0;M_REG_B [29] <= 0;M_REG_B [28] <= 0;
        M_REG_B [27] <= 0;M_REG_B [26] <= 0;M_REG_B [25] <= 0;
        M_REG_B [24] <= 0;M_REG_B [23] <= 0;M_REG_B [22] <= 0;
        M_REG_B [21] <= 0;M_REG_B [20] <= 0;M_REG_B [19] <= 0;
        M_REG_B [18] <= 0;M_REG_B [17] <= 0;M_REG_B [16] <= 0;
        M_REG_B [15] <= 0;M_REG_B [14] <= 0;M_REG_B [13] <= 0;
        M_REG_B [12] <= 0;M_REG_B [11] <= 0;M_REG_B [10] <= 0;
        M_REG_B [9] <= 0;M_REG_B [8] <= 0;M_REG_B [7] <= 0;
        M_REG_B [6] <= 0;M_REG_B [5] <= 0;M_REG_B [4] <= 0;
        M_REG_B [3] <= 0;M_REG_B [2] <= 0;M_REG_B [1] <= 0;
        M_REG_B [0] <= 0;
    end
    else
        begin
            //当active信号有效时 写入数据
            if (Active) 
                case (MMBlockSelect)
                    //通过MMBlockSelect信号控制数据写入M_REG_A还是M_REG_B
                    0 : M_REG_A [MMWriteAddress] <= MMMetric; //MMBlockSelect为0时写入MMetric到M_REG_A中
                    1 : M_REG_B [MMWriteAddress] <= MMMetric; //MMBlockSelect为1时写入MMetric到M_REG_B中
                endcase
        end
    end
always @(MMReadAddress or Reset)
begin
    //复位
    if (~Reset) MMPathMetric <=0;
        else begin
        case (MMBlockSelect)
        //通过MMBlockSelect信号控制读出数据M_REG_A还是M_REG_B
        0 : case (MMReadAddress)    //MMBlockSelect为0时读出M_REG_B保存在MMPathMetric中。
            0 : MMPathMetric <= {M_REG_B [1],M_REG_B[0]};
            1 : MMPathMetric <= {M_REG_B [3],M_REG_B[2]};
            2 : MMPathMetric <= {M_REG_B [5],M_REG_B[4]}; 
            3 : MMPathMetric <= {M_REG_B [7],M_REG_B[6]};
            4 : MMPathMetric <= {M_REG_B [9],M_REG_B[8]};
            5 : MMPathMetric <= {M_REG_B [11],M_REG_B[10]}; 
            6 : MMPathMetric <= {M_REG_B [13],M_REG_B[12]}; 
            7 : MMPathMetric <= {M_REG_B [15],M_REG_B[14]};
            8 : MMPathMetric <= {M_REG_B [17],M_REG_B[16]};
            9 : MMPathMetric <= {M_REG_B [19],M_REG_B[18]};
            10 : MMPathMetric <= {M_REG_B [21],M_REG_B[20]};
            11 : MMPathMetric <= {M_REG_B [23],M_REG_B[22]};
            12 : MMPathMetric <= {M_REG_B [25],M_REG_B[24]};
            13 : MMPathMetric <= {M_REG_B [27],M_REG_B[26]};
            14 : MMPathMetric <= {M_REG_B [29],M_REG_B[28]};
            15 : MMPathMetric <= {M_REG_B [31],M_REG_B[30]};
            16 : MMPathMetric <= {M_REG_B [33],M_REG_B[32]};
            17 : MMPathMetric <= {M_REG_B [35],M_REG_B[34]};
            18 : MMPathMetric <= {M_REG_B [37],M_REG_B[36]}; 
            19 : MMPathMetric <= {M_REG_B [39],M_REG_B[38]};
            20 : MMPathMetric <= {M_REG_B [41],M_REG_B[40]};
            21 : MMPathMetric <= {M_REG_B [43],M_REG_B[42]}; 
            22 : MMPathMetric <= {M_REG_B [45],M_REG_B[44]}; 
            23 : MMPathMetric <= {M_REG_B [47],M_REG_B[46]};
            24 : MMPathMetric <= {M_REG_B [49],M_REG_B[48]};
            25 : MMPathMetric <= {M_REG_B [51],M_REG_B[50]};
            26 : MMPathMetric <= {M_REG_B [53],M_REG_B[52]}; 
            27 : MMPathMetric <= {M_REG_B [55],M_REG_B[54]};
            28 : MMPathMetric <= {M_REG_B [57],M_REG_B[56]};
            29 : MMPathMetric <= {M_REG_B [59],M_REG_B[58]}; 
            30 : MMPathMetric <= {M_REG_B [61],M_REG_B[60]}; 
            31 : MMPathMetric <= {M_REG_B [63],M_REG_B[62]};
            endcase
        1 : case (MMReadAddress) //MMBlockSelect为0时读出M_REG_B保存在MMPathMetric中。
        0 : MMPathMetric <= {M_REG_A [1],M_REG_A[0]};
        1 : MMPathMetric <= {M_REG_A [3],M_REG_A[2]};
        2 : MMPathMetric <= {M_REG_A [5],M_REG_A[4]}; 
        3 : MMPathMetric <= {M_REG_A [7],M_REG_A[6]};
        4 : MMPathMetric <= {M_REG_A [9],M_REG_A[8]};
        5 : MMPathMetric <= {M_REG_A [11],M_REG_A[10]}; 
        6 : MMPathMetric <= {M_REG_A [13],M_REG_A[12]}; 
        7 : MMPathMetric <= {M_REG_A [15],M_REG_A[14]};
        8 : MMPathMetric <= {M_REG_A [17],M_REG_A[16]};
        9 : MMPathMetric <= {M_REG_A [19],M_REG_A[18]};
        10 : MMPathMetric <= {M_REG_A [21],M_REG_A[20]};
        11 : MMPathMetric <= {M_REG_A [23],M_REG_A[22]};
        12 : MMPathMetric <= {M_REG_A [25],M_REG_A[24]};
        13 : MMPathMetric <= {M_REG_A [27],M_REG_A[26]};
        14 : MMPathMetric <= {M_REG_A [29],M_REG_A[28]};
        15 : MMPathMetric <= {M_REG_A [31],M_REG_A[30]};
        16 : MMPathMetric <= {M_REG_A [33],M_REG_A[32]};
        17 : MMPathMetric <= {M_REG_A [35],M_REG_A[34]};
        18 : MMPathMetric <= {M_REG_A [37],M_REG_A[36]}; 
        19 : MMPathMetric <= {M_REG_A [39],M_REG_A[38]};
        20 : MMPathMetric <= {M_REG_A [41],M_REG_A[40]};
        21 : MMPathMetric <= {M_REG_A [43],M_REG_A[42]}; 
        22 : MMPathMetric <= {M_REG_A [45],M_REG_A[44]}; 
        23 : MMPathMetric <= {M_REG_A [47],M_REG_A[46]};
        24 : MMPathMetric <= {M_REG_A [49],M_REG_A[48]};
        25 : MMPathMetric <= {M_REG_A [51],M_REG_A[50]};
        26 : MMPathMetric <= {M_REG_A [53],M_REG_A[52]}; 
        27 : MMPathMetric <= {M_REG_A [55],M_REG_A[54]};
        28 : MMPathMetric <= {M_REG_A [57],M_REG_A[56]};
        29 : MMPathMetric <= {M_REG_A [59],M_REG_A[58]}; 
        30 : MMPathMetric <= {M_REG_A [61],M_REG_A[60]}; 
        31 : MMPathMetric <= {M_REG_A [63],M_REG_A[62]};
            endcase
        endcase
     end
end
endmodule
