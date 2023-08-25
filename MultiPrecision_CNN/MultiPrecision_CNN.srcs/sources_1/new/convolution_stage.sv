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

//implement buffer based on image width (ImageWidth/sqrt(CyclesPerPixel))
//process each pixel over CPP cycles.
//ourput is number of kernels  


module convolution_stage #(NumberOfK = 1, N = 3, BitSize=32, KernelBitSize = 4, ImageWidth = 4, CyclesPerPixel = 2)
		(
    		input 							clk,
            input                           res_n,
        	input 							in_valid,     // enable
          	input [NumberOfK-1:0][KernelBitSize*(N*N)-1:0] kernel,
          	input [(N*N)*BitSize-1:0] 			in_data,      
      		output logic 						out_ready,
        	output logic 						out_valid,
          	output logic [NumberOfK-1:0][BitSize-1:0] 			out_data // Have to update to number of prtocessing elements  
      	
    );

	localparam BufferSize = ImageWidth;
	localparam ProcessingElements = NumberOfK/CyclesPerPixel;


	logic [BufferSize-1:0] [(N*N)*BitSize-1:0] buffer_c;
	logic [BufferSize-1:0] [(N*N)*BitSize-1:0] buffer_r;

	integer buffer_count_c;
	integer buffer_count_r;

	integer cycle_count_c;
	integer cycle_count_r;


	//make sure output is lined up properly
	genvar i;
	generate;
		for (i = 0; i < CyclesPerPixel; i = i + 1) begin
			 dot_NxN #(.N(N), .BitSize(BitSize), .KernelBitSize(KernelBitSize)) dot_product (.kernel(kernel[i+(cycle_count_c*ProcessingElements)]), .in_data(buffer_c[0]), .out_data(), .sum(out_data[i]));
		end
	endgenerate


  	always_comb
    begin
	buffer_c 		= buffer_r;
	buffer_count_c 	= buffer_count_r;
	cycle_count_c 	= cycle_count_r;
		if(in_valid)
		begin
			// read into the correct count on the register
			buffer_c[buffer_count_c] 	= in_data;
			buffer_count_c				= buffer_count_c + 1;
		end

		// update cycle count and move through kernels, then shift out of buffer reduce buffer count
		if(cycle_count_c < CyclesPerPixel)
		begin
			buffer_c = buffer_c << (CyclesPerPixel*BitSize);
			cycle_count_c 		= cycle_count_c - CyclesPerPixel;
						
		end
    end


	always_ff@(posedge clk) begin
    	if(!res_n)
      	begin
			buffer_r <= '0;
			buffer_count_r <= '0;
			cycle_count_r <= '0;

      	end
    	else
      	begin
        	buffer_r <= buffer_c;
			buffer_count_r <= buffer_count_c;
			cycle_count_r <= cycle_count_c;
        end
  	end

    
endmodule