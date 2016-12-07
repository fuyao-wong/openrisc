`include "define.v"
module llbit_reg(
	input  wire 		clk,
	input  wire 		rst,
	input  wire 		flush,
	input  wire 		we,
	input  wire 		llbit_i,
	output reg 			llbit_o
);

always @(posedge clk)	begin
	if(rst) begin
		llbit_o<=1'b0;
	end else if(flush==1'b1) begin
		llbit_o<=1'b0;
	end else if(we==`WriteEnable) begin
		llbit_o<=llbit_i;
	end
end

endmodule 