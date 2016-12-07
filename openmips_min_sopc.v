`include "define.v"
module openmips_min_sopc(
		input wire clk,
		input wire rst
);	
wire [`InstAddrBus] inst_addr;
wire [`InstBus] 	inst;
wire 				rom_ce;

wire [`RegBus] 		ram_datai;
wire [`RegBus] 		ram_datao;
wire [`RegBus] 		ram_addr;
wire 				ram_we;
wire 				ram_ce;
wire [3:0]			ram_sel;

openmips openmips0(
	.clk(clk),
	.rst(rst),
	.rom_addr_o(inst_addr),
	.rom_data_i(inst),
	.rom_ce_o(rom_ce),
	
	.ram_data_i(ram_datai),
	.ram_addr_o(ram_addr),
	.ram_data_o(ram_datao),
	.ram_we_o(ram_we),
	.ram_sel_o(ram_sel),
	.ram_ce_o(ram_ce)
);

inst_rom inst_rom0(
	.ce(rom_ce),
	.addr(inst_addr),
	.inst(inst)
);

//ram数据存储模块
data_ram data_ram0(
	.clk(clk),
	.rst(rst),
	.ce(ram_ce),
	.we(ram_we),
	.addr(ram_addr),
	.sel(ram_sel),
	.data_i(ram_datao),
	.data_o(ram_datai)
);

endmodule 