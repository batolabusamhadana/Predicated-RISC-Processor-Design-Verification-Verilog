				   // Register File
module registerFile(RA,RB,RW,RegWr,Rp,inPC,BusW,clk,BusA,BusB,BusP,outPC,PC_write,reg_dest);
	input [4:0]RA,RB,Rp,RW;
	input clk,RegWr,PC_write, reg_dest;
	input [31:0] inPC, BusW;
	output [31:0] BusA,BusB,BusP,outPC; 
	reg [31:0] registers [0:31] = '{32'd0, 32'd2, 32'd3, 32'd4, 32'd5, 32'd0, 32'd7, 32'd8, 32'd9, 32'd10, 32'd11, 32'd12, 32'd13, 32'd14, 32'd15, 32'd16, 32'd17, 32'd18, 32'd19, 32'd20, 32'd21, 32'd22, 32'd23, 32'd24, 32'd25, 32'd26, 32'd27, 32'd28, 32'd29, 32'd30, 32'd00, 32'd00};
	integer i; 	
	
	assign BusA=(RA!=5'b00000)?registers[RA]:32'b00000;
	assign BusB=(RB!=5'b00000)?registers[RB]:32'b00000;	
	assign BusP=(Rp!=5'b00000)?registers[Rp]:32'b00000;
	assign outPC=registers[30];
	
	always @(posedge clk) begin
		if (RegWr) begin
			if (RW != 5'b00000 && RW != 5'b11110)
				registers[RW] <= BusW; 		
		end	
		
		if (PC_write)
        		registers[30] <= inPC;
	end	 
endmodule

// ALU	
module ALU (
	input wire [31:0] a, b,
	input wire [2:0] ctrl,
	output reg [31:0] out
	);
	
	always @(*) begin
		case (ctrl)
			3'b000: out = a + b;  // add, addi
			3'b001: out = a - b;  // sub
			3'b010: out = a | b;  // or, ori
			3'b011: out = ~(a | b);   // nor, nori
			3'b100: out = a & b;	// and, andi 
			default: out = 32'b0;
		endcase
	end
endmodule

// Data Memory		
module data_memory (Data_out,Address,Data_in,clk,mem_read,mem_write);
	input clk,mem_read,mem_write;
	input [31:0] Data_in,Address;
	output reg [31:0] Data_out; 
	reg  [31:0] mem [0:1023];
	
	integer i;
	initial begin
  		for (i=0; i<1024; i=i+1) mem[i] = 32'b0;		 
		mem[3]=8;
		mem[8]=10;
		mem[14]=12;
	end     
	assign Data_out=(mem_read)?mem[Address[9:0]]:32'bx; 
	
	
	always @(posedge clk)
		begin 
			if (mem_write)
				mem[Address[9:0]]<=Data_in;
			//if(mem_read)
			//	Data_out<=mem[Address];
		end		
endmodule
	
// Instruction Memory 
module inst_mem (
    input  wire [31:0] addr,  
    output wire [31:0] instr
	);

    reg [31:0] memory [0:1023];
	integer i;
	initial begin
  		for (i=0; i<1024; i=i+1)
			  memory[i] = 32'b0;	  
// Predicated Execution
    memory[0] = 32'b01001_11100_00100_00010_000000000000; // LW R4, 107(R0)
    memory[1] = 32'b01010_00000_00101_00100_000000000000; // SW R5, 0(R4)
    memory[2] = 32'b00000000000000000000000000000000; // NOP
		end
    assign instr = memory[addr[9:0]];

endmodule 

// Immediate Extend
module immExt(
    	input wire [11:0] imm, 
		input wire extOp,
    	output reg [31:0] ext
	);
	
    always @(*) 
		begin
			case (extOp)  
            	1'b0: ext = {20'b0, imm};
            	1'b1: ext = {{20{imm[11]}}, imm};
       		endcase
    	end
endmodule

// Calculate Jump Address
module jump_calc(
    	input wire [21:0] offset, 
	input wire [31:0] old_address, 
    	output wire [31:0] new_address
	);
	
	wire [31:0] w1;	 
	
	assign w1= {{10{offset[21]}}, offset}; 
	
	assign new_address = old_address + w1 - 32'b1;		
endmodule

// 4x1 MUX
module mux_4x1(F,A,B,C,D,sel);	 
	
	input [31:0] A,B,C,D;
	input [1:0]sel;
	output reg[31:0] F;	 
	
	always @(*) 
		case (sel)
			2'b00:F = A;
			2'b01:F = B;
			2'b10:F = C;
			2'b11:F = D;
			default: F = A;
		endcase
endmodule 
	
// 2x1 MUX
module mux2x1(F,A,B,sel);
	
	input [4:0] A,B;
	input sel;
	output reg[4:0] F;
	
	always @(*) 
		case (sel)
			1'b0:F = A;
			1'b1:F = B;
		default: F = A;
		endcase
endmodule  

module mux2x1_1(F,A,B,sel);
	
	input A,B;
	input sel;
	output reg F;
	
	always @(*) 
		case (sel)
			1'b0:F = A;
			1'b1:F = B;
		default: F = A;
		endcase
endmodule

module mux2x1_2(F,A,B,sel);
	
	input [1:0] A,B;
	input sel;
	output reg[1:0] F;
	
	always @(*) 
		case (sel)
			1'b0:F = A;
			1'b1:F = B;
		default: F = A;
		endcase
endmodule 	  

module mux2x1_3(F,A,B,sel);
	
	input [31:0] A,B;
	input sel;
	output reg[31:0] F;
	
	always @(*) 
		case (sel)
			1'b0:F = A;
			1'b1:F = B;
		default: F = A;
		endcase
endmodule 

// Control Unit with ALU Control	
module Controller(clk,rst,opcode,reg_dest,reg_write,ext_op,WB_data,mem_read,mem_write,PC_write,pc_src,IR_write,ALU_ctrl, ALU_srcB,reg_src, state);
	
	input clk, rst;
    	input [4:0] opcode;										  
	output [2:0] state;
    	output reg reg_dest, reg_write, ext_op, mem_read, mem_write, PC_write, IR_write,reg_src,ALU_srcB;
    	output reg [2:0] ALU_ctrl;
    	output reg [1:0] pc_src, WB_data;
	reg [2:0] prstate, nxtstate;                                    
		
	assign state = prstate;
	parameter [2:0] 	
		fetch = 3'b000,
    	decode = 3'b001,
    	address_comp = 3'b010,
    	data_read = 3'b011,
    	data_write = 3'b100,
    	execute = 3'b101,
   		wb = 3'b110,
		jump = 3'b111;
						
	always @(posedge clk, negedge rst) begin 
		if (~rst)
			prstate=fetch;	
		else
			prstate=nxtstate;
		end  
		always @(*) 
			begin 
	    case (prstate)		 
			
	        fetch: nxtstate = decode; 
			
	        decode: 
			begin
				case (opcode)
	               	5'b01001: nxtstate = address_comp ; 
	                	5'b01010: nxtstate = address_comp;
					5'b01011: nxtstate = jump;   
					5'b01100: nxtstate = wb;  
					5'b01101: nxtstate = jump;
	                default:  nxtstate = execute;  
	            endcase
			end	  
			
        		address_comp: 
			begin
				if (opcode == 5'b01001)       
                	nxtstate =  data_read;
				else if (opcode == 5'b01010)  
                	nxtstate = data_write;
				else
                	nxtstate = fetch;
			end
        
        	data_read: nxtstate = wb;
			
        	wb: 
			begin 
				if (opcode==5'b01100)
					nxtstate = jump;
				else nxtstate = fetch;	
			end 		
			
		data_write: nxtstate = fetch; 
			
        	execute: nxtstate = wb;  
			
        	jump: nxtstate = fetch;
			
		//call:  nxtstate = wb;
    endcase
	end

	always @(*) begin
    	reg_dest = 1'b0;
    	reg_write = 1'b0;
    	ext_op = 1'b0;
    	mem_read = 1'b0;
    	mem_write = 1'b0;
    	WB_data = 2'b00;
    	PC_write = 1'b0;
    	pc_src = 2'b00;
    	IR_write = 1'b0;
    	ALU_ctrl= 3'b000;
    	ALU_srcB = 1'b0;
    	reg_src=1'b0;
    case (prstate)
		fetch: 
		begin
            	IR_write = 1'b1;      
            	PC_write = 1'b1;
			pc_src = 2'b00;
			reg_write = 1'b0;
        end	
		
		//decode sign extenstion op go back later
		decode:  
		begin
			IR_write = 1'b0; 
			PC_write=1'b0;
			if(opcode==5'b01001||opcode==5'b01010||opcode==5'b00101) 
				ext_op = 1;
			else 
				ext_op = 0;	

		end 
	    
		address_comp: 
		begin
	       	ALU_srcB = 1'b1; // use sign-extended immediate			
		   	ALU_ctrl = 3'b000; 
			
		end      
		
		data_read: mem_read = 1'b1;
		
      	data_write:
		  begin
			  reg_src=1'b1;
			  mem_write = 1'b1; 
			  ALU_ctrl = 3'b000;
		  end 
		  
		execute: 
		begin
			if (opcode<=5'b00100) 
				begin
					ALU_srcB = 1'b0;    //  register B
					case (opcode)
						5'd0 : ALU_ctrl = 3'b000;//add
						5'd1 : ALU_ctrl = 3'b001;//sub
						5'd2 : ALU_ctrl = 3'b010;//or
						5'd3 : ALU_ctrl = 3'b011;//nor				   
						5'd4 : ALU_ctrl = 3'b100;//ande
					endcase
				end
			else if (opcode<=5'b01000)
			begin 
				ALU_srcB = 1'b1;    //  immediate
			case(opcode)
				5'd5 : ALU_ctrl = 3'b000;//addi
				5'd6 : ALU_ctrl = 3'b010;//ori
				5'd7 : ALU_ctrl = 3'b011;//nori				   
				5'd8 : ALU_ctrl = 3'b100;//andi
			endcase
			end
		end 
		
		wb: 
		begin
			reg_write = 1'b1;
			if (opcode == 5'b01100) begin
				WB_data = 2'b10;//from pc	
				reg_dest = 1'b1;
				end
			else if (opcode == 5'b01001) WB_data = 2'b01;	 //from data memory
			else WB_data = 2'b00;	 // from alu
		end 
		
		//call: reg_dest = 1'b1; //destination is register 31  
		
		jump: 
		begin  	
			PC_write = 1'b1; 
			reg_write = 1'b0;
			if (opcode == 5'b01100 || opcode == 5'b01011)
				pc_src = 2'b01;	
				
			else if(opcode == 5'b01101)
				pc_src =	2'b10;
			else pc_src =2'b00;
		end
	endcase
	end 
endmodule

// Instruction Register	 
module inst_reg (
	input clk,
    input reset,
   	input [31:0] inst,
	input IR_write,
	output [4:0]opcode,Rp,Rd,Rs,Rt,
	output [11:0]imm,
	output [21:0]offset,
	output [31:0] curr_instr
	); 

	reg [31:0] r;			   

    	always @(posedge clk or negedge reset) 
		begin
			if (~reset)
            	r <= 32'b0;
       		else if (IR_write)
            	r <= inst; // Write operation
		end

    // Continuous assignment to read the value
    assign opcode = r[31:27];
	assign Rp = r[26:22];
	assign Rd = r[21:17];
	assign Rs = r[16:12];
	assign Rt = r[11:7];
	assign imm = r[11:0]; 
	assign offset = r[21:0];	
	assign curr_instr = r;
endmodule	 

// Generic Register
module register (
    	input clk,
    	input reset,
    	input [31:0] Bus,
		output [31:0] Data_out
		); 

    	reg [31:0] r;

    	always @(posedge clk or negedge reset) 
		begin
			if (~reset)
            	r <= 32'b0;
        	else
            	r <= Bus; // Write operation
    		end

    	// Continuous assignment to read the value
	assign Data_out = r;
endmodule	   

// Zero Comparator for Rp
module comparator(
	input [31:0] in_data,
	output reg Zero
	);
	
	always @(*)
		begin 
			if (in_data == 0)
				Zero = 1;
			else 
				Zero = 0;		
		end 
endmodule 	 

module comparatorR(
	input [4:0] in_data,
	output reg Zero
	);
	
	always @(*)
		begin 
			if (in_data == 0)
				Zero = 1;
			else 
				Zero = 0;		
		end 
endmodule 	

module add1(
	input [31:0] PC,
	output [31:0] PC_inc
	); 
	
	assign PC_inc = PC + 32'b1;	  
	
endmodule