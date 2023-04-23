`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.04.2023 13:38:55
// Design Name: 
// Module Name: TB_pooling_layer
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


module TB_pooling_layer;

    localparam BitSize = 2;
    localparam N = 2;
    localparam ImageWidth = 4;

    logic clk;
    logic res_n;
    logic in_valid;
    logic [BitSize-1:0] in_data;
    logic out_ready;
    logic out_valid;
    logic [BitSize-1:0] out_data;

    max_pooling_layer #(.N(N), .ImageWidth(ImageWidth), .BitSize(BitSize), .Stride(N)) pooling_layer 
        (.clk(clk), .res_n(res_n), .in_valid(in_valid), .in_data(in_data), .out_ready(out_ready), .out_valid(out_valid), .out_data(out_data));

    logic [ImageWidth*ImageWidth-1:0][BitSize-1:0] test_image;
    logic [BitSize-1:0] a;
    logic [BitSize-1:0] b;
    logic [BitSize-1:0] c;
    logic [BitSize-1:0] d;
    
    logic [BitSize-1:0] pooling [N*N-1:0];
    logic [BitSize-1:0] data_stream_r [pooling_layer.StreamSize-1:0];
    logic [BitSize-1:0] data_stream_c [pooling_layer.StreamSize-1:0];
    assign {>>BitSize{data_stream_r}} = pooling_layer.data_stream_r;
    assign {>>BitSize{data_stream_c}} = pooling_layer.data_stream_c;
    assign {>>BitSize{pooling}} = pooling_layer.pooling_data;
    initial begin
        a = 2'b11;
        b = 2'b10;
        c = 2'b01;
        d = 2'b00;
        test_image =   {a, b, b, c,
                        d, d, c, a,
                        c, b, d, d,
                        c, d, d, d};
        res_n = 0;
        clk = 1;
        #2
        res_n = 1;
        clk = 0;

        $monitor("@ %0t:\tbuffer_r = %p\n\t\t\tbuffer_c = %p\n\t\t\tpooling_data = %p\n\t\t\tout = %b, out_valid = %b", $time, data_stream_r, data_stream_c, pooling, out_data, out_valid);
        
        for (int counter = 1; counter <= ImageWidth*ImageWidth; counter = counter) begin
            #10
            clk = 1;
            in_data = test_image[ImageWidth*ImageWidth - counter];
            in_valid = 1;
            #10
            clk = 0;
            if (out_ready) begin
                counter = counter + 1;
            end
          
        end
    end

    // always @(*) begin

    // end



endmodule
