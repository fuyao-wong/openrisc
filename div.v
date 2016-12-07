`include "define.v"
module div(
	input  wire 		clk,
	input  wire 		rst,
	input  wire 		signed_div_i,
	input  wire [31:0]	opdata1_i,
	input  wire	[31:0]	opdata2_i,
	input  wire 		start_i,
	input  wire 		annul_i,
	
	output reg [63:0] 	result_o,
	output reg 			ready_o
	
);

wire [32:0]  div_tmp;           
reg  [5:0] 	 cnt;
reg  [64:0]  dividend;
reg  [1:0]   state;
reg  [31:0]  divisor;
reg  [31:0]  temp_op1;
reg  [31:0]  temp_op2;

assign div_tmp={1'b0,dividend[63:32]}-{1'b0,divisor};      //减法操作结果

always @(posedge clk) begin 
	if(rst==`RstEnable) begin
		state<=`DivFree;
		ready_o<=`DivResultNotReady;
		result_o<={`ZeroWord,`ZeroWord};
	end else begin
		case(state)
			`DivFree:	begin                                         //初始状态
				if(start_i==`DivStart&&annul_i==1'b0) begin         //除法开始，并且未取消指令
					if(opdata2_i==`ZeroWord) begin             //除数为0的情况
						state<=`DivByZero;
					end else begin
						state<=`DivOn;                      //除法开始
						cnt<=6'b000000;                                
						if(signed_div_i==1'b1&&opdata1_i[31]) begin     //有符号除法判断，被除数是不是负数
							temp_op1=~opdata1_i+1'b1;
						end else begin
							temp_op1=opdata1_i;
						end
						if(signed_div_i==1'b1&&opdata2_i[31]) begin      //有符号除法，判断除数是不是负数
							temp_op2=~opdata2_i+1'b1;
						end else begin
							temp_op2=opdata2_i;
						end
						dividend<={`ZeroWord,`ZeroWord};                 
						dividend[32:1]<=temp_op1;                   //被除数赋值
						divisor<=temp_op2;							//除数赋值
					end
				end else begin                     //除法取消或不进行除法计算
					ready_o<=`DivResultNotReady;
					result_o<={`ZeroWord,`ZeroWord};
				end
			end
			`DivByZero:	begin                 //除数为零的情况
				dividend<={`ZeroWord,`ZeroWord};
				state<=`DivEnd;
			end
			`DivOn:	begin				//除法进行中
				if(annul_i==1'b0) begin
					if(cnt!=6'b100000) begin        //除法未完成
						if(div_tmp[32]==1'b1) begin      //减法小于0则商0，商放在尾部，余数放在前部
							dividend<={dividend[63:0],1'b0};
						end else begin					//减法大于0则商1
							dividend<={div_tmp[31:0],dividend[31:0],1'b1};
						end
						cnt<=cnt+1;
					end else begin              //除法完成
					    //有符号除法，除数与被除数异号，则商为负
						if(signed_div_i==1'b1&&((opdata1_i[31]^opdata2_i[31])==1'b1)) begin
							dividend[31:0]<=~dividend[31:0]+1;
						end 
						//有符号除法，余数必须与被除数符号相同，当被除数与余数异号时，需要更改余数符号
						if((signed_div_i==1'b1)&&((opdata1_i[31]^dividend[64])==1'b1)) begin
							dividend[64:33]<=~dividend[64:33]+1;
						end
						state<=`DivEnd;
						cnt<=6'b000000;
					end
				end else begin
					state<=`DivFree;
				end
			end
			`DivEnd:	begin				//除法结束
				result_o<={dividend[64:33],dividend[31:0]};		//商放在尾部，余数放在前部
				ready_o<=`DivResultReady;
				if(start_i==`DivStop) begin 	//除法停止
					state<=`DivFree;
					ready_o<=`DivResultNotReady;
					result_o<={`ZeroWord,`ZeroWord};
				end
 			end
			default: begin
			end
			endcase
	end
end
 

endmodule 