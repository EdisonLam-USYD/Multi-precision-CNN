`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2023 22:14:21
// Design Name: 
// Module Name: convolution_stage
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


// note: N is the size of the kernel - might make it during run-time rather than compilation
// Some features to add after: - stride steps, increased number of data loaded in at once (parameterised)
// convolution_stage #(.NumberOfK(), .N(), .BitSize(), .KernelBitSize(), .ImageWidth()) conv_s (.clk(), .res_n(), .in_valid(), .kernel(), .in_data(), .out_ready(), .out_valid(), .out_data());
module convolution_stage #(NumberOfK = 1, N = 3, BitSize=32, KernelBitSize = 4, ImageWidth = 4)
		(
    		input 							clk,
            input                           res_n,
        	input 							in_valid,     // enable

          	input [NumberOfK*KernelBitSize*(N*N)-1:0] kernel,
          	input [BitSize-1:0] 			in_data,
      
      		output logic 						out_ready,
        	output logic 						out_valid,
          	output logic [NumberOfK*BitSize-1:0] 			out_data
      	     
      	
    );
  
  	localparam StreamSize = 	(ImageWidth+2)*2+(N+1); // only works for N = 3
  
  	logic [StreamSize-1:0][BitSize-1:0] data_stream_r;
  	integer 					image_pos_r;
  	integer						image_pos_c;
  
  	logic [N*N-1:0][BitSize-1:0] dot_product_in_c;
    
  	integer stream_index;

  
  	/* verilator lint_off LATCH */
  	always_comb
	/* verilator lint_on LATCH */
      begin
		dot_product_in_c = 0;
		out_ready = 0;
        out_valid = 0;
		stream_index = 0;
    	image_pos_c = image_pos_r;
        if(in_valid) begin
			if (image_pos_c < ImageWidth+2) begin
				data_stream_r[image_pos_c % StreamSize] = '0;
				out_ready = 0;
			end
			else if((image_pos_c%(ImageWidth+2) == 0) | (image_pos_c%(ImageWidth+2) == ImageWidth+1)) begin
				data_stream_r[image_pos_c % StreamSize] = '0;
				out_ready = 0;
			end
			else begin
        		data_stream_r[image_pos_c % StreamSize] = in_data;
				out_ready = 1;
			end
			
        	if((image_pos_c >= StreamSize) & ((image_pos_c %(ImageWidth+2)) >1))
        	    begin
        	        int i;
        	        int j;
        	        for (i = 0; i < N; i= i + 1)
        	        begin
        	            for (j = 0; j < N; j= j + 1)
        	            begin
        	              stream_index = (image_pos_c - ((N-1-i)*ImageWidth -(N-1-j))) % StreamSize;
        	              dot_product_in_c[i*N+j] = data_stream_r[stream_index];                
        	            end
        	        end
        	      	out_valid = 1;
        		end
        	image_pos_c = image_pos_c + 1;
        end
		else if((image_pos_c < (ImageWidth+2)*(ImageWidth+2)) & (image_pos_c!=0)) begin
			out_ready = 0;
			data_stream_r[image_pos_c % StreamSize] = '0;

			if((image_pos_c >= StreamSize) & ((image_pos_c %(ImageWidth+2)) >1))
        	    begin
        	        int i;
        	        int j;
        	        for (i = 0; i < N; i= i + 1)
        	        begin
        	            for (j = 0; j < N; j= j + 1)
        	            begin
        	              stream_index = (image_pos_c - ((N-1-i)*ImageWidth -(N-1-j))) % StreamSize;
        	              dot_product_in_c[i*N+j] = data_stream_r[stream_index];                
        	            end
        	        end
        	      	out_valid = 1;
        		end
        	image_pos_c = image_pos_c + 1;
		end
    end
  
  dot_NxN #(.N(N), .BitSize(BitSize), .KernelBitSize(KernelBitSize)) dot_product (.kernel(kernel), .in_data(dot_product_in_c), .out_data(), .sum(out_data));
  
  	always@(posedge clk) begin
    	if(!res_n)
      	begin
        image_pos_r <= 0;
      	end
    	else
      	begin
        	image_pos_r <= image_pos_c;
        end
  	end
endmodule