`include "define.v"
module openmips(
    input wire              rst,
    input wire              clk,
    input wire [`RegBus]    rom_data_i,     //取指令数据
    output wire [`RegBus]    rom_addr_o,     //取指令地址
    output wire              rom_ce_o,        //取指令使能，rom存储器使能
	//与ram模块相连
	input wire 	[`RegBus] 	ram_data_i,
	output wire [`RegBus] 	ram_addr_o,
	output wire [`RegBus] 	ram_data_o,
	output wire [`RegBus] 	ram_we_o,
	output wire [`RegBus] 	ram_sel_o,
	output wire [`RegBus] 	ram_ce_o
 	
);

//取指阶段取得的数据以及译码阶段的输入，取指阶段需要把指令从Rom存储器中读出来
wire [`InstAddrBus]       pc;
wire [`InstAddrBus]       id_pc_i;
wire [`InstBus]         id_inst_i;

//译码阶段的输出数据，以及向执行阶段传递的数据，译码阶段需要把指令通用寄存器内
//数据读出来
wire [`AluOpBus]        id_aluop_o;
wire [`AluSelBus]       id_alusel_o;
wire [`RegBus]          id_reg1_o;
wire [`RegBus]          id_reg2_o;
wire                    id_wreg_o;
wire [`RegAddrBus]      id_wd_o;

//译码阶段输出到执行阶段的数据
wire [`AluOpBus]        ex_aluop_i;
wire [`AluSelBus]       ex_alusel_i;
wire [`RegBus]          ex_reg1_i;
wire [`RegBus]          ex_reg2_i;
wire                    ex_wreg_i;
wire [`RegAddrBus]      ex_wd_i;

//执行阶段(ex)到ex_mem访存阶段的信号
wire                    ex_wreg_o;
wire [`RegAddrBus]      ex_wd_o;
wire [`RegBus]          ex_wdata_o;

//从ex_mem的输出到mem的输入信号
wire                    mem_wreg_i;
wire [`RegAddrBus]      mem_wd_i;
wire [`RegBus]          mem_wdata_i;

//从mem模块的输出信号到mem_wb模块的输入信号
wire                    mem_wreg_o;
wire [`RegAddrBus]      mem_wd_o;
wire [`RegBus]          mem_wdata_o;

//从mem_wb模块到回写阶段的信号，即为译码阶段的通用寄存器写入操作
wire                    wb_wreg_i;
wire [`RegAddrBus]      wb_wd_i;
wire [`RegBus]          wb_wdata_i;

//连接译码阶段至通用寄存器模块(regfile)的信号
wire                    reg1_read;
wire                    reg2_read;
wire [`RegAddrBus]      reg1_addr;
wire [`RegAddrBus]      reg2_addr;
wire [`RegBus]          reg1_data;
wire [`RegBus]          reg2_data;

//特殊寄存器HILO的读写需要的信号
//从ex模块到ex_mem的输入
wire 					ex_whilo_o;
wire [`RegBus] 			ex_hi_o;
wire [`RegBus] 			ex_lo_o;
//从ex_mem模块的输出至mem模块
wire 			        mem_whilo_i;
wire [`RegBus]   		mem_hi_i;
wire [`RegBus] 			mem_lo_i;
//mem模块的输出至mem_wb模块，和ex模块
wire 			        mem_whilo_o;
wire [`RegBus]   		mem_hi_o;
wire [`RegBus] 			mem_lo_o;
//从mem_wb的输出至hilo_reg模块和ex模块
wire 					wb_whilo;
wire [`RegBus] 			wb_hi;
wire [`RegBus] 			wb_lo;					
//从hilo_reg模块传递至ex模块的输出
wire [`RegBus] 			reg_hi;
wire [`RegBus] 			reg_lo;

//流水线暂停控制模块信号
wire 					stallreq_id;
wire 					stallreq_ex;
wire [5:0] 				stall_pipe;

//
wire [`DoubleRegBus] 	ex_hilo_tmp_o;
wire [1:0] 				ex_cnt_o;
wire [`DoubleRegBus] 	ex_hilo_tmp_i;
wire [1:0] 				ex_cnt_i;

//exe模块与div模块信号
wire 					signed_div;
wire [`RegBus] 			div_opdata1;
wire [`RegBus] 			div_opdata2;
wire 					div_start;
wire [`DoubleRegBus] 	div_result;
wire 					div_ready;

//转移指令添加从id模块至pc_reg模块
wire [`RegBus] 			branch_target_address;
wire 					branch_flag;
//从id模块至id_ex模块
wire 					id_is_in_delayslot;
wire [`RegBus] 			id_link_address;
wire 					id_next_inst_in_delayslot;
//从id_ex至ex模块
wire 					ex_is_in_delayslot;
wire [`RegBus] 			ex_link_address;
//从id_ex至id模块
wire 					is_in_delayslot;


//加载存储指令
//从id模块至id_ex模块
wire [`RegBus]			id_inst_o;
//从id_ex模块至ex模块
wire [`RegBus] 			ex_inst_o;
//从ex模块至ex_mem模块
wire [`AluOpBus] 		ex_aluop_o;
wire [`RegBus] 			ex_mem_addr_o;
wire [`RegBus] 			ex_reg2_o;
//从ex_mem模块至mem模块
wire [`AluOpBus] 		mem_aluop_i;
wire [`RegBus] 			mem_mem_addr_i;
wire [`RegBus] 			mem_reg2_i;
//特殊加载存储寄存器sc和ll
//从mem到mem_wb模块
wire 					mem_llbit_we_o;
wire 					mem_llbit_value_o;
//从mem_wb模块到llbit模块和mem模块
wire 					wb_llbit_we_i;
wire 					wb_llbit_value_i;
//从llbit模块到mem模块
wire 					llbit;

pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),
	.stall(stall_pipe),
    .pc(pc),               //输出取指指令地址
    .ce(rom_ce_o),          //输出rom使能信号
	//转移指令信号
	.branch_target_address_i(branch_target_address),
	.branch_flag_i(branch_flag)
);
assign rom_addr_o=pc;      //Rom存储器的输入地址即为pc

if_id if_id0(
    .clk(clk),
    .rst(rst),
	.stall(stall_pipe),
    //输入数据
    .if_pc(pc),             //输入指令地址　　　　　　　
    .if_inst(rom_data_i),   //输入指令数据
    //输出数据
    .id_pc(id_pc_i),        //输出指令地址
    .id_inst(id_inst_i)     //输出指令数据
);

id id0(
    .rst(rst),
    .pc_i(id_pc_i),
	.stallreq(stallreq_id),
    //译码数据输入
    .inst_i(id_inst_i),             //读取的指令数据输入
    .reg1_data_i(reg1_data),        //指令中通用寄存器１的数据读入
    .reg2_data_i(reg2_data),        //指令中通用寄存器２的数据读入
    //为读取通用寄存器内值的输出
    .reg1_read_o(reg1_read),        //通用寄存器１读使能
    .reg1_addr_o(reg1_addr),        //通用寄存器１读地址
    .reg2_read_o(reg2_read),        //通用寄存器２读使能
    .reg2_addr_o(reg2_addr),        //通用寄存器２读地址
    //输出至id_ex模块的信号
    .aluop_o(id_aluop_o),           //指令操作符         
    .alusel_o(id_alusel_o),         //指令操作类型
    .reg1_o(id_reg1_o),             //源操作数１输出
    .reg2_o(id_reg2_o),             //源操作数２输出
    .wd_o(id_wd_o),                 //目的寄存器地址
    .wreg_o(id_wreg_o),              //写目的寄存器使能
	
	//从执行阶段传递回来的要写回目的寄存器的数据及地址信息
	.ex_wreg_i(ex_wreg_o),
	.ex_wd_i(ex_wd_o),
	.ex_wdata_i(ex_wdata_o),
	
	//从访存阶段传递回来的要写回目的寄存器的数据及地址信息
	.mem_wreg_i(mem_wreg_o),
	.mem_wd_i(mem_wd_o),
	.mem_wdata_i(mem_wdata_o),
	
	//转移指令信号
	.is_in_delayslot_i(is_in_delayslot),
	.branch_flag_o(branch_flag),
	.branch_target_address_o(branch_target_address),
	.is_in_delayslot_o(id_is_in_delayslot),
	.link_addr_o(id_link_address),
	.next_inst_in_delayslot_o(id_next_inst_in_delayslot),
	
	//加载存储指令
	.ex_aluop_i(ex_aluop_o),
	.inst_o(id_inst_o)

);


//通用寄存器模块
regfile regfile0(
    .clk(clk),
    .rst(rst),
    //回写阶段目标寄存器数据写入
    .we(wb_wreg_i),                 //目的寄存器写入使能
    .waddr(wb_wd_i),                //目的寄存器写入地址
    .wdata(wb_wdata_i),             //目的寄存器写入数据
    //通用寄存器reg1数据读取
    .re1(reg1_read),               //寄存器１读取使能输入
    .raddr1(reg1_addr),             //读寄存器１地址输入
    .rdata1(reg1_data),             //读取寄存器１的数据输出
    //通用寄存器reg2数据读取
    .re2(reg2_read),               //寄存器２读取使能输入
    .raddr2(reg2_addr),             //寄存器２地址输入
    .rdata2(reg2_data)             //读取寄存器２的数据输出
);

id_ex id_ex0(
    .clk(clk),
    .rst(rst),
    //从id模块输入的数据
    .id_aluop(id_aluop_o),      //指令操作符
    .id_alusel(id_alusel_o),    //指令操作类型
    .id_reg1(id_reg1_o),        //由寄存器１中读出的数据
    .id_reg2(id_reg2_o),        //由寄存器２中读出的数据
    .id_wd(id_wd_o),            //输入写入目的寄存器的地址
    .id_wreg(id_wreg_o),        //输入是否写入目的寄存器
	.stall(stall_pipe),					//是否暂停流水线
    //数据输出至执行阶段ex
    .ex_aluop(ex_aluop_i),        //输出指令操作符
    .ex_alusel(ex_alusel_i),    //输出指令类型
    .ex_reg1(ex_reg1_i),        //输出源操作数１
    .ex_reg2(ex_reg2_i),        //输出源操作数２
    .ex_wd(ex_wd_i),            //输出写目的寄存器地址
    .ex_wreg(ex_wreg_i),         //输出是否写入目的寄存器数据
	
	//转移指令信号
	.id_link_address(id_link_address),
	.id_is_in_delayslot(id_is_in_delayslot),
	.next_inst_in_delayslot(id_next_inst_in_delayslot),
	.ex_link_address(ex_link_address),
	.ex_is_in_delayslot(ex_is_in_delayslot),
	.is_in_delayslot_o(is_in_delayslot),
	
	//加载存储指令
	.id_inst(id_inst_o),
	.ex_inst(ex_inst_o)
);

//执行模块
ex ex0(
    .rst(rst),
    //由译码阶段输入的执行指令所需要的数据，包括指令和数据
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    //执行结果，包括写入寄存器地址，是否写入目的寄存器以及执行的数据结果
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
	
	//从hilo_reg模块传递过来的数据
	.hi_i(reg_hi),
	.lo_i(reg_lo),
	//位于mem访存阶段对hilo_reg寄存器读写情况
	.mem_whilo_i(mem_whilo_o),
	.mem_hi_i(mem_hi_o),
	.mem_lo_i(mem_lo_o),
	//位于wb回写阶段对hilo_reg寄存器的读写情况
	.wb_whilo_i(wb_whilo),
	.wb_hi_i(wb_hi),
	.wb_lo_i(wb_lo),
	
	//对寄存器修改情况的输出
	.whilo_o(ex_whilo_o),
	.hi_o(ex_hi_o),
	.lo_o(ex_lo_o),
	
	//复杂算术操作指令执行控制，多于一个时钟周期的指令
	.hilo_temp_i(ex_hilo_tmp_i),
	.cnt_i(ex_cnt_i),
	.hilo_temp_o(ex_hilo_tmp_o),
	.cnt_o(ex_cnt_o),
	.stallreq_from_ex(stallreq_ex),
	
	//除法指令新增信号
	.div_result_i(div_result),
	.div_ready_i(div_ready),
	.signed_div_o(signed_div),
	.div_opdata1_o(div_opdata1),
	.div_opdata2_o(div_opdata2),
	.div_start_o(div_start),
	
	//转移指令信号
	.is_in_delayslot_i(ex_is_in_delayslot),
	.link_address_i(ex_link_address),
	
	//加载存储指令
	.inst_i(ex_inst_o),
	.aluop_o(ex_aluop_o),
	.mem_addr_o(ex_mem_addr_o),
	.reg2_o(ex_reg2_o)
	
);

//除法模块
div div0(
	.clk(clk),
	.rst(rst),
	.signed_div_i(signed_div),
	.opdata1_i(div_opdata1),
	.opdata2_i(div_opdata2),
	.start_i(div_start),
	.annul_i(1'b0),
	
	.result_o(div_result),
	.ready_o(div_ready)
	
);

//ex_mem模块
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
	.stall(stall_pipe),		//
    //输入指令执行结果，目的寄存器地址及是否写入目的寄存器
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
	//从ex模块输入的需要写入特殊寄存器HILO的信号
	.ex_whilo(ex_whilo_o),
	.ex_hi(ex_hi_o),
	.ex_lo(ex_lo_o),
    //输出指令执行结果
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
	//输出值mem模块的对特殊寄存器HILO操作的信号
	.mem_whilo(mem_whilo_i),
	.mem_hi(mem_hi_i),
	.mem_lo(mem_lo_i),
	
	//复杂算术操作指令执行控制，多于一个时钟周期的指令
	.hilo_i(ex_hilo_tmp_o),
	.cnt_i(ex_cnt_o),
	.hilo_o(ex_hilo_tmp_i),
	.cnt_o(ex_cnt_i),
	
	//加载存储指令
	.ex_aluop(ex_aluop_o),
	.ex_mem_addr(ex_mem_addr_o),
	.ex_reg2(ex_reg2_o),
	.mem_aluop(mem_aluop_i),
	.mem_mem_addr(mem_mem_addr_i),
	.mem_reg2(mem_reg2_i)
);

//mem模块
mem mem0(
    .rst(rst),
    //执行阶段输入的指令执行结果
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
	//对特殊寄存器HILO的操作信号输入
	.whilo_i(mem_whilo_i),
	.hi_i(mem_hi_i),
	.lo_i(mem_lo_i),
    //访存输出
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
	//对特殊寄存器HILO的操作信号输出
	.whilo_o(mem_whilo_o),
	.hi_o(mem_hi_o),
	.lo_o(mem_lo_o),
	
	//加载存储指令
	.aluop_i(mem_aluop_i),
	.mem_addr_i(mem_mem_addr_i),
	.reg2_i(mem_reg2_i),
	.mem_data_i(ram_data_i),
	.mem_addr_o(ram_addr_o),
	.mem_we_o(ram_we_o),
	.mem_sel_o(ram_sel_o),
	.mem_data_o(ram_data_o),
	.mem_ce_o(ram_ce_o),
	//特殊加载存储寄存器sc和ll信号
	.llbit_i(llbit),
	.wb_llbit_we_i(wb_llbit_we_i),
	.wb_llbit_value_i(wb_llbit_value_i),
	.llbit_we_o(mem_llbit_we_o),
	.llbit_value_o(mem_llbit_value_o)
);

mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
	.stall(stall_pipe),			//
    //mem模块输出数据
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
	//输入对特殊寄存器HILO的操作信号
	.mem_whilo(mem_whilo_o),
	.mem_hi(mem_hi_o),
	.mem_lo(mem_lo_o),
    //回写指令输出
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),
	//输出对特殊寄存器HILO的操作信号
	.wb_whilo(wb_whilo),
	.wb_hi(wb_hi),
	.wb_lo(wb_lo),
	//特殊加载存储寄存器sc和ll信号
	.mem_llbit_we(mem_llbit_we_o),
	.mem_llbit_value(mem_llbit_value_o),
	.wb_llbit_we(wb_llbit_we_i),
	.wb_llbit_value(wb_llbit_value_i)
);
//HILO寄存器控制模块
hilo_reg hilo_reg0(
	.clk(clk),
	.rst(rst),
	
	.we(wb_whilo),
	.hi_i(wb_hi),
	.lo_i(wb_lo),
	
	.hi_o(reg_hi),
	.lo_o(reg_lo)
);

llbit_reg llbit_reg0(
	.clk(clk),
	.rst(rst),
	.flush(1'b0),
	.we(wb_llbit_we_i),
	.llbit_i(wb_llbit_value_i),
	.llbit_o(llbit)
);

//流水线暂停控制模块
ctrl ctrl0(
	.rst(rst),
	.stallreq_from_id(stallreq_id),
	.stallreq_from_ex(stallreq_ex),
	.stall(stall_pipe)
);

endmodule 
