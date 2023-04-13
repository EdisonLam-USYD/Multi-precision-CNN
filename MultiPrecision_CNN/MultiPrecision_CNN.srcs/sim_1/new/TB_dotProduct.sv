`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2023 18:33:34
// Design Name: 
// Module Name: TB_dotProduct
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define B 4
`define N 3
`define K 1


module TB_dotProduct;

    logic [`K*(`N*`N)-1:0] in_kernel;
    logic [`B*(`N*`N)-1:0] in_conv;
   
    logic [`B*(`N*`N)-1:0] out;
    logic [`B-1:0] max;
    logic [`B-1:0] sum;
    
    logic [`B-1:0] a, b, c;

    assign in_conv = {{a,b,c},{b,c,a},{c,a,b}};
    
    initial begin
        $monitor("in = %d,  kern = %d   out = %d\nin = %d,  kern = %d   out = %d\nin = %d,  kern = %d   out = %d\nSum: %d\nMax was found to be: %d", 
            test1.i_data_layers[2], test1.kernel_layers[2], test1.o_data_layers[2],
            test1.i_data_layers[1], test1.kernel_layers[1], test1.o_data_layers[1],
            test1.i_data_layers[0], test1.kernel_layers[0], test1.o_data_layers[0], sum, max);
        
        a = `B'b1100; 
        b = `B'b0100;
        c = `B'b0010;
        
        
        in_kernel = {3'b101, 3'b010, 3'b001};
        
        #10

        a = `B'b1111; 
        b = `B'b0110;
        c = `B'b1010;

        
        // $display("%b", test_max_pooling.i_data_layers[2]);
        // $display("%b", test_max_pooling.i_data_layers[1]);
        // $display("%b", test_max_pooling.i_data_layers[0]);
//        $display("%b", test1.i_data_layers);
//        $display("%b", test1.o_data_layers[1]);
    end
    
//    always @(*) begin
//        $display("in = %b,  kern = %b   out = %b", in_conv[17:12], in_kernel[8:6], out[17:12]);
//        $display("in = %b,  kern = %b   out = %b", in_conv[11:6], in_kernel[5:3], out[11:6]);
//        $display("in = %b,  kern = %b   out = %b", in_conv[5:0], in_kernel[2:0], out[5:0]);
//    end
    
    dot_NxN #(.N(`N), .BitSize(`B), .KernelBitSize(`K))     
        test1 (.kernel(in_kernel), .i_data(in_conv), .o_data(out), .sum(sum)); 
    max_pooling #(.N(`N), .BitSize(`B))
        test_max_pooling (.i_data(out), .signed_check(0), .o_max(max));
endmodule
