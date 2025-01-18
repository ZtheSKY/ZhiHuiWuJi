`timescale 1ns / 1ps

//Dual port RAM
module ramDualPort #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8
)(
	input wire [(DATA_WIDTH-1):0] dataA, dataB,
	input wire [(ADDRESS_WIDTH-1):0] addrA, addrB,
	input wire weA, weB, clk_fast,clk_slow,
	output reg [(DATA_WIDTH-1):0] qA, qB
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDRESS_WIDTH-1:0];

	//Port A
	always @ (posedge clk_slow)
	begin
		if (weA) //1写0读
			ram[addrA] <= dataA;
	end 

	//Port B
	always @ (posedge clk_fast)
	begin
		if (!weA) 
			qA <= ram[addrA];
		if (!weB) 
			qB <= ram[addrB];
	end

endmodule //ramDualPort
