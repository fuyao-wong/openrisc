`include "define.v"
module mem(
    input wire                  rst,
    input wire [`RegAddrBus]    wd_i,
    input wire                  wreg_i,
    input wire [`RegBus]        wdata_i,
	//对特殊寄存器HILO的操作信号输入
	input wire					whilo_i,
	input wire [`RegBus] 		hi_i,
	input wire [`RegBus] 		lo_i,

    output reg [`RegAddrBus]    wd_o,
    output reg                  wreg_o,
    output reg [`RegBus]        wdata_o,
	//对特殊寄存器HILO的操作信号输出
	output reg					whilo_o,
	output reg [`RegBus] 		hi_o,
	output reg [`RegBus] 		lo_o,
	
	//加载存储指令信号
	input wire [`AluOpBus]		aluop_i,
	input wire [`RegBus] 		mem_addr_i,
	input wire [`RegBus] 		reg2_i,
	input wire [`RegBus] 		mem_data_i,
	output reg [`RegBus] 		mem_addr_o,
	output wire 				mem_we_o,
	output reg [3:0] 			mem_sel_o,
	output reg [`RegBus] 		mem_data_o,
	output reg 					mem_ce_o,
	
	//特殊存储加载指令ll和sc信号
	input  wire 				llbit_i,
	input  wire 				wb_llbit_we_i,
	input  wire 				wb_llbit_value_i,
	output reg 					llbit_we_o,
	output reg 					llbit_value_o
	
);

wire [`RegBus] 	zero32;
reg 			mem_we;
assign mem_we_o=mem_we;
assign zero32=`ZeroWord;

reg llbit;

always @(*) begin
	if(rst==`RstEnable) begin
		llbit<=1'b0;
	end else if(wb_llbit_we_i==1'b1) begin
		llbit<=wb_llbit_value_i;
	end else begin
		llbit<=llbit_i;
	end
end


always @(*) begin
    if(rst==`RstEnable) begin
        wd_o<=`NOPRegAddr;
        wreg_o<=`WriteDisable;
        wdata_o<=`ZeroWord;
		
		whilo_o<=`WriteDisable;
		hi_o<=`ZeroWord;
		lo_o<=`ZeroWord;
		
		mem_addr_o<=`ZeroWord;
		mem_we<=`WriteDisable;
		mem_sel_o<=4'b0000;
		mem_data_o<=`ZeroWord;
		mem_ce_o<=`ChipDisable;
		llbit_we_o<=`WriteDisable;
		llbit_value_o<=1'b0;
    end else begin
        wd_o<=wd_i;
        wreg_o<=wreg_i;
        wdata_o<=wdata_i;
		
		whilo_o<=whilo_i;
		hi_o<=hi_i;
		lo_o<=lo_i;
		
		mem_addr_o<=`ZeroWord;
		mem_we<=`WriteDisable;
		mem_sel_o<=4'b1111;
		mem_data_o<=`ZeroWord;
		mem_ce_o<=`ChipDisable;
		llbit_we_o<=`WriteDisable;
		llbit_value_o<=1'b0;
		case(aluop_i)
			`EXE_LB_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<={{24{mem_data_i[31]}},mem_data_i[31:24]};
						mem_sel_o<=4'b1000;
					end
					2'b01:	begin
						wdata_o<={{24{mem_data_i[23]}},mem_data_i[23:16]};
						mem_sel_o<=4'b0100;
					end
					2'b10:	begin
						wdata_o<={{24{mem_data_i[15]}},mem_data_i[15:8]};
						mem_sel_o<=4'b0010;
					end
					2'b11:	begin
						wdata_o<={{24{mem_data_i[7]}},{mem_data_i[7:0]}};
						mem_sel_o<=4'b0001;
					end
					default:	begin
					end
				endcase
			end
			`EXE_LBU_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<={{24{1'b0}},{mem_data_i[31:24]}};
						mem_sel_o<=4'b1000;
					end
					2'b01:	begin
						wdata_o<={{24{1'b0}},{mem_data_i[23:16]}};
						mem_sel_o<=4'b0100;
					end
					2'b10:	begin
						wdata_o<={{24{1'b0}},{mem_data_i[15:8]}};
						mem_sel_o<=4'b0010;
					end
					2'b11:	begin
						wdata_o<={{24{1'b0}},{mem_data_i[7:0]}};
						mem_sel_o<=4'b0001;
					end
					default:	begin
					end
				endcase
			end
			`EXE_LH_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<={{16{mem_data_i[31]}},{mem_data_i[31:16]}};
						mem_sel_o<=4'b1100;
					end
					2'b10:	begin
						wdata_o<={{16{mem_data_i[15]}},{mem_data_i[15:0]}};
						mem_sel_o<=4'b0011;
					end
					default:	begin
						wdata_o<=`ZeroWord;
					end
				endcase
			end
			`EXE_LHU_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<={{16{1'b0}},{mem_data_i[31:16]}};
						mem_sel_o<=4'b1100;
					end
					2'b10:	begin
						wdata_o<={{16{1'b0}},{mem_data_i[15:0]}};
						mem_sel_o<=4'b0011;
					end
					default:	begin
						wdata_o<=`ZeroWord;
					end
				endcase
			end
			`EXE_LW_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				wdata_o<=mem_data_i;
				mem_sel_o<=4'b1111;
			end
			`EXE_LWL_OP:	begin
				mem_addr_o<={mem_addr_i[31:2],2'b00};
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				mem_sel_o<=4'b1111;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<=mem_data_i;
					end
					2'b01:	begin
						wdata_o<={mem_data_i[23:0],reg2_i[7:0]};
					end
					2'b10:	begin
						wdata_o<={mem_data_i[15:0],reg2_i[15:0]};
					end
					2'b11:	begin
						wdata_o<={mem_data_i[7:0],reg2_i[23:0]};
					end
					default:	begin
						wdata_o<=`ZeroWord;
					end
				endcase
			end
			`EXE_LWR_OP:	begin
				mem_addr_o<={mem_addr_i[31:2],2'b00};
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				mem_sel_o<=4'b1111;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						wdata_o<={reg2_i[31:8],mem_data_i[31:24]};
					end
					2'b01:	begin
						wdata_o<={reg2_i[31:16],mem_data_i[31:16]};
					end
					2'b10:	begin
						wdata_o<={reg2_i[31:24],mem_data_i[31:8]};
					end
					2'b11:	begin
						wdata_o<=mem_data_i;
					end
					default:	begin
						wdata_o<=`ZeroWord;
					end
				endcase
			end
			`EXE_SB_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteEnable;
				mem_ce_o<=`ChipEnable;
				mem_data_o<={reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						mem_sel_o<=4'b1000;
					end
					2'b01:	begin
						mem_sel_o<=4'b0100;
					end
					2'b10:	begin
						mem_sel_o<=4'b0010;
					end
					2'b11:	begin
						mem_sel_o<=4'b0001;
					end
					default:	begin
						mem_sel_o<=4'b0000;
					end
				endcase
			end
			`EXE_SH_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteEnable;
				mem_ce_o<=`ChipEnable;
				mem_data_o<={reg2_i[15:0],reg2_i[15:0]};
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						mem_sel_o<=4'b1100;
					end
					2'b10:	begin
						mem_sel_o<=4'b0011;
					end
					default:	begin
						mem_sel_o<=4'b0000;
					end
				endcase
			end
			`EXE_SW_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteEnable;
				mem_ce_o<=`ChipEnable;
				mem_data_o<=reg2_i;
				mem_sel_o<=4'b1111;
			end
			`EXE_SWL_OP:	begin
				mem_addr_o<={mem_addr_i[31:2],2'b00};
				mem_we<=`WriteEnable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						mem_data_o<=reg2_i;
						mem_sel_o<=4'b1111;
					end
					2'b01:	begin
						mem_data_o<={zero32[7:0],reg2_i[31:8]};
						mem_sel_o<=4'b0111;
					end
					2'b10:	begin
						mem_data_o<={zero32[15:0],reg2_i[31:16]};
						mem_sel_o<=4'b0011;
					end
					2'b11:	begin
						mem_data_o<={zero32[23:0],reg2_i[31:24]};
						mem_sel_o<=4'b0001;
					end
					default:	begin
						mem_sel_o<=4'b0000;
					end
				endcase
			end
			`EXE_SWR_OP:	begin
				mem_addr_o<={mem_addr_i[31:2],2'b00};
				mem_we<=`WriteEnable;
				mem_ce_o<=`ChipEnable;
				case(mem_addr_i[1:0]) 
					2'b00:	begin
						mem_data_o<={reg2_i[7:0],zero32[23:0]};
						mem_sel_o<=4'b1000;
					end
					2'b01:	begin
						mem_data_o<={reg2_i[15:0],zero32[15:0]};
						mem_sel_o<=4'b1100;
					end
					2'b10:	begin
						mem_data_o<={reg2_i[23:0],zero32[7:0]};
						mem_sel_o<=4'b1110;
					end
					2'b11:	begin
						mem_data_o<=reg2_i;
						mem_sel_o<=4'b1111;
					end
					default:	begin
						mem_sel_o<=4'b0000;
					end
				endcase
			end
			`EXE_LL_OP:	begin
				mem_addr_o<=mem_addr_i;
				mem_we<=`WriteDisable;
				mem_ce_o<=`ChipEnable;
				wdata_o<=mem_data_i;
				mem_sel_o<=4'b1111;
				
				llbit_value_o<=1'b1;
				llbit_we_o<=1'b1;			
			end
			`EXE_SC_OP:	begin
				if(llbit==1'b1) begin
					mem_addr_o<=mem_addr_i;
					mem_we<=`WriteEnable;
					mem_ce_o<=`ChipEnable;
					mem_data_o<=reg2_i;
					mem_sel_o<=4'b1111;
					
					wdata_o<=32'd1;
					
					llbit_value_o<=1'b0;
					llbit_we_o<=1'b1;	
				end else begin
					wdata_o<=32'b0;
				end
			end
			default:	begin
			end
		endcase
    end
end

endmodule
