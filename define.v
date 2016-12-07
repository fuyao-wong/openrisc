//全局变量定义
`define RstEnable 		1'b1			//复位信号有效
`define RstDisable		1'b0			//复位信号无效
`define ZeroWord 		32'h00000000	//数值0
`define WriteEnable		1'b1			//写信号使能
`define WriteDisable	1'b0			//写禁止
`define ReadEnable		1'b1			//读信号使能
`define ReadDisable		1'b0			//读禁止
`define AluOpBus		7:0				//译码阶段aluop_o的宽度
`define AluSelBus		2:0				//译码阶段alusel_o的宽度
`define	InstValid		1'b0			//指令有效
`define	InstInvalid		1'b1			//指令无效
`define	True_v			1'b1			//逻辑真
`define False_v			1'b0			//逻辑假
`define ChipEnable		1'b1			//芯片使能
`define ChipDisable		1'b0			//芯片禁止

`define Stop 			1'b1 			//流水线暂停
`define NoStop 			1'b0 			//流水线不暂停

//DIV模块中的定义
`define DivFree 		2'b00
`define DivByZero 		2'b01
`define DivOn 			2'b10
`define DivEnd 			2'b11
`define DivResultReady  1'b1
`define DivResultNotReady 1'b0
`define DivStart 		1'b1
`define DivStop  		1'b0

//分支指令
`define Branch 			1'b1
`define NoBranch		1'b0


//与具体指令相关的定义
//逻辑操作指令
`define EXE_ORI			6'b001101		//指令ori
`define EXE_AND 		6'b100100 		//and指令的功能码
`define EXE_OR 			6'b100101 		//or指令
`define EXE_XOR 		6'b100110 		//xor
`define EXE_NOR 		6'b100111 		//nor
`define EXE_ANDI 		6'b001100 		//andi
`define EXE_XORI 		6'b001110 		//xori
`define EXE_LUI 		6'b001111 		//lui
//移位操作指令
`define EXE_SLL 		6'b000000 		//sll
`define EXE_SLLV 		6'b000100 		//sllv
`define EXE_SRL 		6'b000010 		//srl
`define EXE_SRLV 		6'b000110 		//srlv
`define EXE_SRA 		6'b000011 		//sra
`define EXE_SRAV 		6'b000111 		//srav
//移动操作指令
`define EXE_MOVN 		6'b001011 		//movn
`define EXE_MOVZ 		6'b001010 		//movz
`define EXE_MFHI 		6'b010000 		//mfhi
`define EXE_MFLO 		6'b010010 		//mflo
`define EXE_MTHI 		6'b010001 		//mthi
`define EXE_MTLO 		6'b010011 		//mtlo
//简单算术操作指令
`define EXE_ADD 		6'b100000 		//add
`define EXE_ADDU 		6'b100001 		//addu
`define EXE_SUB 		6'b100010 		//sub
`define EXE_SUBU 		6'b100011 		//subu
`define EXE_SLT 		6'b101010 		//slt
`define EXE_SLTU 		6'b101011 		//sltu

`define EXE_ADDI 		6'b001000 		//addi
`define EXE_ADDIU 		6'b001001		//addiu
`define EXE_SLTI 		6'b001010 		//slti
`define EXE_SLTIU 		6'b001011 		//sltiu
`define EXE_CLZ 		6'b100000 		//clz
`define EXE_CLO 		6'b100001 		//clo
`define EXE_MUL 		6'b000010   	//mul
`define EXE_MULT 		6'b011000 		//mult
`define EXE_MULTU 		6'b011001		//multu`
 //复杂算术指令
`define EXE_MADD 		6'b000000 		//madd
`define EXE_MADDU 		6'b000001 		//maddu
`define EXE_MSUB 		6'b000100 		//msub
`define EXE_MSUBU		6'b000101		//msub

`define EXE_SYNC 		6'b001111 		//sync
`define EXE_PREF 		6'b110011 		//pref

`define EXE_SPECIAL_INST 	6'b000000   //
`define EXE_REGIMM_INST 	6'b000001 	//
`define EXE_SPECIAL2_INST 	6'b011100 	//

//除法指令
`define EXE_DIV 		6'b011010 		//
`define EXE_DIVU 		6'b011011 		//
 
 //转移指令
`define EXE_J 			6'b000010		//
`define EXE_JAL 		6'b000011 		//
`define EXE_JALR 		6'b001001 		//
`define EXE_JR 			6'b001000		//
`define EXE_BEQ 		6'b000100		//
`define EXE_BGEZ 		5'b00001 		//
`define EXE_BGEZAL 		5'b10001 		//
`define EXE_BGTZ 		6'b000111 		//
`define EXE_BLEZ 		6'b000110 		//
`define EXE_BLTZ 		5'b00000 		//
`define EXE_BLTZAL 		5'b10000 		//
`define EXE_BNE 		6'b000101 		//

//加载存储指令
`define EXE_LB 			6'b100000		//
`define EXE_LBU 		6'b100100 		//
`define EXE_LH 			6'b100001 		//
`define EXE_LHU 		6'b100101 		//
`define EXE_LW 			6'b100011 		//
`define EXE_LWL 		6'b100010		//
`define EXE_LWR 		6'b100110 		//
`define EXE_SB 			6'b101000		//
`define EXE_SH 			6'b101001 		//
`define EXE_SW 			6'b101011 		//
`define EXE_SWL 		6'b101010 		//
`define EXE_SWR 		6'b101110 		//

//特殊加载存储指令
`define EXE_LL 			6'b110000 		//
`define EXE_SC 			6'b111000 		//


//延迟槽技术
`define InDelaySlot 	1'b1 			//
`define NotInDelaySlot 	1'b0			//

  
`define EXE_NOP			6'b000000		//空指令
`define SSNOP 			32'b0000_0000_0000_0000_0000_0000_0100_0000

//AluOp
//逻辑操作指令
`define EXE_OR_OP		8'b00100101		//
`define EXE_NOP_OP		8'b00000000		//
`define EXE_AND_OP 		8'b00100100 	//
`define EXE_XOR_OP    	8'b00100110 	//
`define EXE_NOR_OP 		8'b00100111 	//
`define EXE_ANDI_OP 	8'b01011001 	//
`define EXE_ORI_OP 		8'b01011010	  	//
`define EXE_XORI_OP 	8'b01011011 	//
`define EXE_LUI_OP 		8'b01011100 	//
//移位指令
`define EXE_SLL_OP  	8'b01111100 	//
`define EXE_SLLV_OP  	8'b00000100 	//
`define EXE_SRL_OP  	8'b00000010 	//
`define EXE_SRLV_OP 	8'b00000110 	//
`define EXE_SRA_OP 		8'b00000011 	//
`define EXE_SRAV_OP 	8'b00000111 	//
//移动指令
`define EXE_MOVN_OP 	8'b00001011		//
`define EXE_MOVZ_OP 	8'b00001010 	//
`define EXE_MFHI_OP 	8'b00010000 	//
`define EXE_MFLO_OP 	8'b00010010 	//
`define EXE_MTHI_OP 	8'b00010001 	//
`define EXE_MTLO_OP 	8'b00010011 	//
//简单算术操作指令
`define EXE_ADD_OP 		8'b00100000 	//add
`define EXE_ADDU_OP 	8'b00100001 	//addu
`define EXE_SUB_OP 		8'b00100010 	//sub
`define EXE_SUBU_OP 	8'b00100011 	//subu
`define EXE_SLT_OP 		8'b00101010 	//slt
`define EXE_SLTU_OP 	8'b00101011 	//sltu

`define EXE_ADDI_OP 	8'b01010101		//addi
`define EXE_ADDIU_OP 	8'b01010110		//addiu
`define EXE_SLTI_OP 	8'b01010111 	//slti
`define EXE_SLTIU_OP 	8'b01011000 	//sltiu
`define EXE_CLZ_OP 		8'b10110000 	//clz
`define EXE_CLO_OP 		8'b10110001 	//clo
`define EXE_MUL_OP 		8'b10101001   	//mul
`define EXE_MULT_OP 	8'b00011000 	//mult
`define EXE_MULTU_OP 	8'b00011001		//multu

//复杂算术操作指令
`define EXE_MADD_OP 	8'b10100110 	//madd
`define EXE_MADDU_OP 	8'b10101000 	//maddu
`define EXE_MSUB_OP 	8'b10101010 	//msub
`define EXE_MSUBU_OP	8'b10101011		//msub

//除法指令
`define EXE_DIV_OP 		8'b00011010		//div
`define EXE_DIVU_OP  	8'b00011011  	//divu

`define EXE_NOP_OP   	8'b00000000

//转移指令
`define EXE_J_OP 		8'b01001111		//
`define EXE_JAL_OP 		8'b01010000 	//
`define EXE_JALR_OP 	8'b00001001 	//
`define EXE_JR_OP 		8'b00001000		//
`define EXE_BEQ_OP 		8'b01010001		//
`define EXE_BGEZ_OP 	8'b01000001 	//
`define EXE_BGEZAL_OP 	8'b01001011 	//
`define EXE_BGTZ_OP 	8'b01010100 	//
`define EXE_BLEZ_OP 	8'b01010011 	//
`define EXE_BLTZ_OP 	8'b00000 		//
`define EXE_BLTZAL_OP 	8'b01000000 	//
`define EXE_BNE_OP 		8'b01010010 	//

//加载存储指令
`define EXE_LB_OP 		8'b11100000 	//
`define EXE_LBU_OP 		8'b11100100 	//
`define EXE_LH_OP 		8'b11100001 	//
`define EXE_LHU_OP 		8'b11100101 	//
`define EXE_LW_OP 		8'b11100011 	//
`define EXE_LWL_OP 		8'b11100010 	//
`define EXE_LWR_OP 		8'b11100110 	//
`define EXE_SB_OP 		8'b11101000 	//
`define EXE_SH_OP 		8'b11101001 	//
`define EXE_SW_OP 		8'b11101011 	//
`define EXE_SWL_OP 		8'b11101010 	//
`define EXE_SWR_OP 		8'b11101110 	//

//特殊加载存储指令
`define EXE_LL_OP 		8'b11110000 	//
`define EXE_SC_OP 		8'b11111000 	//

//AluSel
`define EXE_RES_LOGIC	3'b001			//
`define EXE_RES_NOP		3'b000			//
`define EXE_RES_SHIFT 	3'b010 			//
`define EXE_RES_MOVE  	3'b011 			//
`define EXE_RES_MUL 	3'b101 			//
`define EXE_RES_ARITHMETIC    3'b100 	//
`define EXE_RES_JUMP_BRANCH	  3'b110 	//
`define EXE_RES_LOAD_STORE 	  3'b111 	//


//与Rom相关指令定义
`define InstAddrBus		31:0			//Rom地址宽度
`define InstBus			31:0			//Rom数据宽度
`define InstMemNum 		131071			//Rom深度实际存储数据的多少
`define InstMemNumLog2	17				//Rom实际使用的地址线宽度

//Ram存储器参数
`define DataAddrBus 	31:0 			//Ram存储地址宽度
`define DataBus 		31:0 			//Ram存储数据宽度
`define DataMemNum 		131071 			//Ram深度
`define DataMemNumLog2  17				//Ram深度表示的位
`define ByteWidth 		7:0 			//Ram一字节

//与通用寄存Regfile相关的指令宏定义
`define RegAddrBus		4:0				//寄存器地址总线宽度
`define RegBus			31:0			//寄存器数据总线宽度
`define RegWidth		32				//寄存器宽度
`define DoubleRegWidth	64				//两倍寄存器宽度
`define DoubleRegBus	63:0			//两倍寄存器数据宽度
`define RegNum 			32				//通用寄存器数量
`define RegNumLog2		5				//通用寄存器地址位数
`define NOPRegAddr		5'b00000		//空寄存器地址，默认寄存器地址






