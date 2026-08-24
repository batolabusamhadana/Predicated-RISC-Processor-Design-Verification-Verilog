`timescale 1ms/1ps

module tb;

    // Clock & reset
    reg clk, rst;

    // Processor signals
    wire [31:0] DataALU, Data_out, Data_in;
    wire [31:0] inPC, outPC, instruction, jump_address, out;
    wire [2:0] state;  
	wire [2:0] ALU_ctrl;


    // Instantiate MultiCycle processor
    MultiCycle Datapath(
        .clk(clk),
        .rst(rst),
        .Data_out(Data_out),
        .OpB(Data_in),
        .inPC(inPC),
        .outPC(outPC),
        .DataALU2(DataALU),
        .curr_instr(instruction),
        .state(state)
		);

    initial clk = 1'b0;
    always #10 clk = ~clk;

    initial begin
        rst = 1'b1;
        #1 rst = 1'b0;   // release reset
        #1 rst = 1'b1;   // assert reset again

        $monitor("Time:%0t | instruction: %b | state: %b | Data_out: %b | Data_in: %b | DataALU: %b | next_PC: %b | curr_PC: %b \n",
                 $time, instruction, state, Data_out, Data_in, DataALU, inPC, outPC);

        #300 $finish;
    end

endmodule