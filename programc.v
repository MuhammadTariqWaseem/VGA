module programc(
    input clk, reset,
    input [31:0] pc_in,
    output reg [31:0] pc_out);
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= pc_in;
    end
endmodule

module adder(
    input [31:0] a,b,
    output [31:0] result
);
    assign result = a + b;
endmodule

module instructmem(inst, adress);
    input [31:0] adress;
    output [31:0] inst;
    reg [7:0] memory [15:0];
    initial
    begin
        memory[0] = 8'h03;
		  memory[1] = 8'h13;
        memory[2] = 8'hc4;
        memory[3] = 8'hff;
        
        memory[4] = 8'h23;
        memory[5] = 8'ha4;
        memory[6] = 8'h64;
        memory[7] = 8'h00;
        
        memory[8] = 8'h33;
        memory[9] = 8'he2;
        memory[10] = 8'h62;
        memory[11] = 8'h00;
        
        memory[12] = 8'he3;
        memory[13] = 8'h0a;
        memory[14] = 8'h42;
        memory[15] = 8'hfe;
    end
    
    assign inst = {memory[adress + 3], memory[adress + 2], memory[adress + 1], memory[adress + 0]};
endmodule

module instruction_fetch(
    input clk, reset,
    output [31:0]I
);

wire [31:0] pc_in,pc_out;

   programc dff_0( .clk(clk), .reset(reset), .pc_in(pc_in), .pc_out(pc_out));
   instructmem int1(.inst(I), .adress(pc_out));
   adder add(.a(pc_out), .b(32'd4), .result(pc_in));

endmodule

module programc_tb;
    reg clk;
    reg reset;
    wire [31:0]I;
    
    instruction_fetch uut (
        .clk(clk),
        .reset(reset),
        .I(I)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset = 1;
        #20 reset = 0;
    end
endmodule