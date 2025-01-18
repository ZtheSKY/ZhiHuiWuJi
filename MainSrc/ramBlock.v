`timescale 1ns / 1ps

module ramBlock #(
	parameter DATA_WIDTH = 8,
	parameter ADDRESS_WIDTH = 8,
	parameter BUFFER_SIZE = 3,
	parameter BUFFER_SIZE_WIDTH =	2
)(
	input wire 						clk_slow,
	input wire 						clk_fast,
	input wire 						rst,
	input wire						advanceRead1,	
	input wire						advanceRead2,	//将选中的读RAM提前两个
	input wire						advanceWrite,	
	input wire						forceRead,		//禁止写入

	input wire [DATA_WIDTH-1:0]		writeData,
	input wire [ADDRESS_WIDTH-1:0]	writeAddress,
	input wire						writeEnable,
	output [11:0]					fillCount,

	output wire [DATA_WIDTH-1:0]	readData00,		
	output wire [DATA_WIDTH-1:0]	readData01,		
	output wire [DATA_WIDTH-1:0]	readData10,		
	output wire [DATA_WIDTH-1:0]	readData11,		
	input  wire [ADDRESS_WIDTH-1:0]	readAddress
);

reg [BUFFER_SIZE-1:0] writeSelect = 1;
reg [BUFFER_SIZE-1:0] readSelect = 1;

always @(posedge clk_fast or posedge rst)
begin
	if(rst)
		readSelect <= 1;
	else
	begin
		if(advanceRead1)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-2 : 0], readSelect[BUFFER_SIZE-1]};//左移
		end
		else if(advanceRead2)
		begin
			readSelect <= {readSelect[BUFFER_SIZE-3 : 0], readSelect[BUFFER_SIZE-1:BUFFER_SIZE-2]};//左移两位
		end
		else readSelect <= readSelect;
	end
end

always @(posedge clk_slow or posedge rst)
begin
	if(rst)
		writeSelect <= 1;
	else
	begin
		if(advanceWrite)
		begin
			writeSelect <= {writeSelect[BUFFER_SIZE-2 : 0], writeSelect[BUFFER_SIZE-1]};//左移
		end
	end
end

wire [DATA_WIDTH-1:0] ramDataOutA [2**BUFFER_SIZE-1:0];
wire [DATA_WIDTH-1:0] ramDataOutB [2**BUFFER_SIZE-1:0];

generate
genvar i;
	for(i = 0; i < BUFFER_SIZE; i = i + 1)
		begin : ram_generate

			ramDualPort #(
				.DATA_WIDTH( DATA_WIDTH ),
				.ADDRESS_WIDTH( ADDRESS_WIDTH )
			) ram_inst_i(
				.clk_slow( clk_slow ),
				.clk_fast( clk_fast ),
				
				.addrA( ((writeSelect[i] == 1'b1) && !forceRead && writeEnable) ? writeAddress : readAddress ),
				.dataA( writeData ),													
				.weA( ((writeSelect[i] == 1'b1) && !forceRead) ? writeEnable : 1'b0 ),
				.qA( ramDataOutA[2**i] ),
				
				.addrB( readAddress + 1 ),
				.dataB( 0 ),
				.weB( 1'b0 ),
				.qB( ramDataOutB[2**i] )
			);
		end
endgenerate

wire [BUFFER_SIZE-1:0]	readSelect0 = readSelect;
wire [BUFFER_SIZE-1:0]	readSelect1 = (readSelect << 1) | readSelect[BUFFER_SIZE-1];

assign readData00 = ramDataOutA[readSelect0];
assign readData10 = ramDataOutA[readSelect1];
assign readData01 = ramDataOutB[readSelect0];
assign readData11 = ramDataOutB[readSelect1];

reg [11:0] write_count;
reg [11:0] read_count;

assign fillCount = write_count - read_count;

always @(posedge clk_slow or posedge rst)
begin
	if(rst)
	begin
		write_count <= 0;
	end
	else
	begin
		if(advanceWrite)
			write_count <= write_count + 1;
		else
			write_count <= write_count;
	end
end

always @(posedge clk_fast or posedge rst)
begin
	if(rst)
	begin
		read_count <= 0;
	end
	else
	begin
		if(advanceRead1)
			read_count <= read_count + 1;
		else if(advanceRead2)
			read_count <= read_count + 2;
		else
			read_count <= read_count;
	end
end

endmodule
