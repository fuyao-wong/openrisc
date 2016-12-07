`include "define.v"
module mem_wb(
    input wire                  clk,
    input wire                  rst,
    input wire [`RegAddrBus]    mem_wd,
    input wire                  mem_wreg,
    input wire [`RegBus]        mem_wdata,
	input wire [5:0] 			stall,
	//输入对特殊寄存器HILO的操作信号
	input wire					mem_whilo,
	input wire [`RegBus] 		mem_hi,
	input wire [`RegBus] 		mem_lo,
    
    output reg [`RegAddrBus]    wb_wd,
    output reg                  wb_wreg,
    output reg [`RegBus]        wb_wdata,
	//输出对特殊寄存器HILO的操作信号
	output reg					wb_whilo,
	output reg [`RegBus] 		wb_hi,
	output reg [`RegBus] 		wb_lo,
	
	//特殊加载存储寄存器sc和ll信号
	input  wire 				mem_llbit_we,
	input  wire 				mem_llbit_value,
	output reg 					wb_llbit_we,
	output reg 					wb_llbit_value
);

always @(posedge clk) begin
    if(rst==`RstEnable) begin
        wb_wd<=`NOPRegAddr;
        wb_wreg<=`WriteDisable;
        wb_wdata<=`ZeroWord;
		
		wb_whilo<=`WriteDisable;
		wb_hi<=`ZeroWord;
		wb_lo<=`ZeroWord;
		wb_llbit_we<=1'b0;
		wb_llbit_value<=1'b0;
	end else if(stall[4]==`Stop&&stall[5]==`NoStop) begin
		wb_wd<=`NOPRegAddr;
        wb_wreg<=`WriteDisable;
        wb_wdata<=`ZeroWord;
		
		wb_whilo<=`WriteDisable;
		wb_hi<=`ZeroWord;
		wb_lo<=`ZeroWord;
		
		wb_llbit_we<=1'b0;
		wb_llbit_value<=1'b0;
    end else if(stall[4]==`NoStop) begin
        wb_wd<=mem_wd;
        wb_wreg<=mem_wreg;
        wb_wdata<=mem_wdata;
		
		wb_whilo<=mem_whilo;
		wb_hi<=mem_hi;
		wb_lo<=mem_lo;
		
		wb_llbit_we<=mem_llbit_we;
		wb_llbit_value<=mem_llbit_value;
    end
end

endmodule
