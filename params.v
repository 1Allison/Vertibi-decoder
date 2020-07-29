// global parameters for Viterbi Decoder
// decoder specs : 
// K = 9, 
// RATE = 1/2, 
// DEPTH = 63,
// number of ACS = 4
// PARAMETER VALUES BITS ORDER WIDTH PARS
// input symbol bit 2 `WD_CODE
// number of states 256 8 `WD_STATE
// iterations each data 256 : 4 = 64 6 `WD_FSM
// iterations until depth 63 6 `WD_DEPTH
// Surv mem. data bus 8 3 `WD_DATA
// Surv mem. address bus 256x1x64/8 = 2048 11 `WD_ADDR 
// simulation parameters 仿真参数
`define HALF 100     //在测试文件中用到
`define FULL 200 
`define DPERIOD (`FULL*128)
// decoder parameters 解码器参数
`define CONSTRAINT 9 // K 约束长度为9
`define N_ACS 4 // 4 ACSs 一共使用了4个ACS处理器
`define N_STATE 256 //  256种状态
`define N_ITER 64 //  一共进行64次迭代
`define WD_STATE 8 // 状态位宽为8
`define WD_CODE 2 // width of Decoder Input 解码输入位宽为2
`define WD_FSM 6 // 256 (states) : 4 (ACSs) = 64 --> log2(64) = 6
`define WD_DEPTH 6 // depth has to be at least 5*(K-1). 深度至少为 5*(K-1).
`define WD_DIST 2 // Width of Calculated Distance 计算距离位宽
`define WD_METR 8 // width of metric. 度量位宽
// For survivor memory 
`define WD_RAM_DATA 8 // width of RAM Data Bus RAM 数据总线位宽
`define WD_RAM_ADDRESS 11 // width of RAM Address Bus RAM 地址总线位宽
`define WD_TB_ADDRESS 5 // width of Address Bus 地址线位宽
// between TB and MMU
// --> `WD_RAM_ADDRESS - `WD_DEPTH