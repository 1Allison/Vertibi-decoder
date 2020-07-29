`include "params.v"
/*-----------------------------------*/
// Module: MMU
// File : mmu.v 
// Description : Description of MMU Unit in Viterbi Decoder 
// Simulator : Modelsim 6.5 / Windows 7/10
/*-----------------------------------*/
// Revision Number : 1 
// Description : Initial Design 
/*-----------------------------------*/
module MMU (CLOCK, Clock1, Clock2, Reset, Active, Hold, Init, ACSPage, 
ACSSegment_minusLSB, Survivors, 
DataTB, AddressTB,
RWSelect, ReadClock, WriteClock, 
RAMEnable, AddressRAM, DataRAM);
// connection from Control 控制连接
input CLOCK, Clock1, Clock2, Reset, Active, Hold, Init;
input [`WD_DEPTH-1:0] ACSPage;
input [`WD_FSM-2:0] ACSSegment_minusLSB;
// connection from ACS Unit ACS 单元连接
input [`N_ACS-1:0] Survivors;
// connection from/to TB Unit TB 单元连接
output [`WD_RAM_DATA-1:0] DataTB;
input [`WD_RAM_ADDRESS-`WD_FSM-1:0] AddressTB;
// connection from/to RAM RAM 连接
output RWSelect, ReadClock, WriteClock, RAMEnable;
output [`WD_RAM_ADDRESS-1:0] AddressRAM;
inout [`WD_RAM_DATA-1:0] DataRAM;
wire [`WD_RAM_DATA-1:0] WrittenSurvivors;
reg dummy, SurvRDY;
reg [`WD_RAM_ADDRESS-1:0] AddressRAM;
reg [`WD_DEPTH-1:0] TBPage;
wire [`WD_DEPTH-1:0] TBPage_;
wire [`WD_DEPTH-1:0] ACSPage;
wire [`WD_TB_ADDRESS-1:0] AddressTB;
// Read and Write clock
// Dummy variable used because Write Clock only occur every 2 Clocks. 
always @(posedge Clock2 or negedge Reset) 
if (~Reset) dummy <= 0;else if (Active) dummy <= ~dummy;
assign WriteClock = (Active && ~dummy) ? Clock1:0;
assign ReadClock = (Active && ~Hold) ? ~Clock1:0;
// --
// For Survivor Buffer, 
// -- The buffer used because Data Bus Width is 8, while 
// ACS output is only 4 bits at one time 
//由于数据总线宽度为 8，而 ACS 输出一次仅为 4 位，因此需要使用缓冲
always @(posedge Clock1 or negedge Reset) 
if (~Reset) SurvRDY <= 1; else if (Active) SurvRDY <= ~SurvRDY;
ACSSURVIVORBUFFER buff (Reset, Clock1, Active, SurvRDY, Survivors, 
WrittenSurvivors);
// --
// For Traceback Ops
// every negedge Clock2 : - TBPage is decreased by 1, OR 
//TB 页减一，初始化时 TB 页=ACS 页减一
// - When Init is Active, TBPage equal ACSPage - 1
always @(negedge Clock2 or negedge Reset)
begin
if (~Reset) begin
TBPage <= 0;
end
else if (Init) TBPage <= ACSPage-1;
else TBPage <= TBPage_;
end
assign TBPage_ = TBPage - 1;
// For RAMs
assign RAMEnable = 0;
assign RWSelect = (Clock2) ? 1:0;
assign DataRAM = (~Clock2) ? WrittenSurvivors:'bz;
assign DataTB = (Clock2) ? DataRAM:'bz;
// every time Clock2 changes, the Address and Enable for each RAM has to 
// be set so it will be ready when Read/Write Clock occur on the edges of 
// Clock1. 
//每当时钟 2 发生变化时，必须设置每个 RAM 的地址和使能，
//以便在时钟边缘出现读/写时钟时准备就绪。
always @(posedge CLOCK or negedge Reset)
begin
if (~Reset) AddressRAM <= 0;
else
if (Active) begin
if (Clock2 == 0) // this is when write happened
begin
AddressRAM <= {ACSPage, ACSSegment_minusLSB};
end
else // this is for read operation
begin
AddressRAM <= {TBPage [`WD_DEPTH-1:0],AddressTB};
end
end
end
//--
endmodule
/*-----------------------------------*/
module ACSSURVIVORBUFFER (Reset, Clock1, Active, SurvRDY, Survivors, 
WrittenSurvivors);
//
// To accomodate the use of 8 bit wide RAM DATA BUS, the Survivor 
// (which is only 4 on every clock) must be buffered first. 
//为了适应 8 位宽 RAM 数据总线，必须首先对留存（每个时钟上只有 4 个）进行缓冲。
/*-----------------------------------*/
input Reset, Clock1, Active, SurvRDY;
input [`N_ACS-1:0] Survivors;
output [`WD_RAM_DATA-1:0] WrittenSurvivors;
wire [`WD_RAM_DATA-1:0] WrittenSurvivors;
reg [`N_ACS-1:0] WrittenSurvivors_;
always @(posedge Clock1 or negedge Reset)
begin
if (~Reset) WrittenSurvivors_ = 0;
else if (Active)
WrittenSurvivors_ = Survivors;
end
assign WrittenSurvivors = (SurvRDY) ? {Survivors, WrittenSurvivors_}:8'bz;
endmodule