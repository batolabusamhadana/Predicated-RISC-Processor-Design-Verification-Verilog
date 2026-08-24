module MultiCycle (
	input clk,
	input rst, 
	output [31:0] Data_out, OpB, inPC,outPC,DataALU2,curr_instr,
	output [2:0] state 
	);
	assign DataALU2=DataALU;
	//Reg File 
	wire [4:0]RA,RB,Rp;
	wire RegWr;
	wire [4:0] RW, Rs;
	wire [31:0]BusA,BusB,BusP;//outPC; 
	//ALU
	wire [31:0] a;
	wire [31:0] b;
	wire [2:0] ctrl;
	wire [31:0] out; 
	// Data Mem
	wire [31:0] Address;
	wire [31:0] mem [0:1000];
	//intruction Mem
	wire [31:0] addr;  
   // wire [31:0] instr;
	//Immidiate Extend
	wire [11:0] imm; 
	wire extOp;
    wire [31:0] ext;
	//Jump Calc
	wire [21:0] offset,old_address; 
	//Mux 4x1
	wire [1:0]sel;
	wire [31:0] F;
	//Controller
    wire [4:0] opcode;
    wire reg_dest, reg_write, ext_op, mem_read, mem_write, PC_write, IR_write,reg_src,ALU_srcB;
    wire [1:0] WB_data, pc_src;
    wire [2:0] ALU_ctrl;	  
	//Instruction Reg
    wire [31:0] inst;
    wire [4:0] Rd,Rt;
	// Register
    wire [31:0] Bus;  
	wire zero, memWR;
	wire [31:0] OpA;//OpB; 
	wire [4:0] w1;
	wire uncond,regWR; 	
	wire [31:0] pc_plus1 = outPC + 32'd1;  
	wire [31:0] Mem_out, instr, jump_address,DataALU;   
	wire PC_en;


	//wire [31:0] inc_pc;	
	// Module Calls							
	inst_mem instMem (outPC, instr); //	done
	inst_reg instReg (clk, rst, instr, IR_write, opcode, Rp, Rd, Rs, Rt, imm, offset,curr_instr); 	  
	
	registerFile regFile (Rs,w1,RW,regWR,Rp,inPC,BusW,clk,BusA,BusB,BusP,outPC,PC_en,reg_dest);
	
	register registerA (clk, rst, BusA, OpA); 
	
	register registerB (clk, rst, BusB, OpB);
	
	assign uncond=(Rp==5'b00000)?1'b1:1'b0;	 
	
	assign regWR = (zero==1'b0 || uncond==1'b1)?reg_write:1'b0;
	
	assign RW = (reg_dest == 1'b0)?Rd:5'b11111;//reg 31			
	
	assign zero = (BusP==32'b0)?1'b1:1'b0;	// enable with Rp	   
	
	assign w1=(reg_src==1'b0)?Rt:Rd;						
	
	mux_4x1 Mux4x1PC (inPC,pc_plus1,jump_address,OpA,32'bx,sel); //choose PC between PC+1, jump address, R31, X 
	
	assign sel = (zero==0||uncond==1'b1)?pc_src: 2'b00; 

	assign b=(ALU_srcB)?ext:OpB;// choose second ALU op
											   
	ALU alu (OpA, b, ALU_ctrl, out);  	 
	
	register registerALU (clk, rst, out, DataALU); 
	
	data_memory dataMem (Data_out,DataALU,OpB,clk,mem_read,memWR);
		
	register Register (clk, rst, Data_out, Mem_out); 
	
	mux_4x1 Mux4x1WB (BusW,DataALU,Mem_out,outPC,32'bx,WB_data);	
	assign memWR = (zero==1'b0||uncond==1'b1)?mem_write:1'b0;	  
	
	assign PC_en = (zero==1'b0||uncond==1'b1)?PC_write:1'b0;
	
	Controller controller(clk,rst,opcode,reg_dest,reg_write,ext_op,WB_data,mem_read,mem_write,PC_write,pc_src,IR_write,ALU_ctrl,ALU_srcB,reg_src, state);
	
	immExt ImmExt(imm, ext_op, ext);	 
	
	jump_calc jumpCalc (offset,outPC,jump_address); 

endmodule