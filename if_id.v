`include "define.v"
module if_id(
	input wire 						clk,
	input 							rst,
	input wire [5:0] 				stall,
	
	//取指阶段输出信号
	input wire [`InstAddrBus] 		if_pc,
	input wire [`InstBus]			if_inst,

	//对应译码阶段输入信号
	output reg [`InstAddrBus]		id_pc,
	output reg [`InstBus]			id_inst

);

	always @(posedge clk) begin
		if(rst==`RstEnable)	begin
			id_pc<=`ZeroWord;
			id_inst<=`ZeroWord;
		end else if(stall[1]==`Stop&&stall[2]==`NoStop) begin
			id_pc<=`ZeroWord;
			id_inst<=`ZeroWord;
		end else if(stall[1]==`NoStop) begin
			id_pc<=if_pc;
			id_inst<=if_inst;
		end
	end

endmodule 