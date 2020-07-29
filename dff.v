/******************************************************/
module pDFF(DATA,QOUT,CLOCK,RESET);
/******************************************************/
parameter WIDTH = 1; 
input [WIDTH-1:0] DATA;
input CLOCK, RESET;
output [WIDTH-1:0] QOUT;
reg [WIDTH-1:0] QOUT;
always @(posedge CLOCK or negedge RESET)
if (~RESET) QOUT <= 0; //active low reset 使用低电平复位
else QOUT <= DATA;
endmodule