`timescale 1ns / 1ps

module Scaler #(
parameter	DATA_WIDTH =			8,
parameter	CHANNELS =				3,
parameter	INPUT_X_RES_WIDTH =		11,	
parameter	INPUT_Y_RES_WIDTH =		11,
parameter	OUTPUT_X_RES_WIDTH =	11,
parameter	OUTPUT_Y_RES_WIDTH =	11,
parameter	FRACTION_BITS =			8,	

parameter	SCALE_INT_BITS =		4,	
parameter	SCALE_FRAC_BITS =		14,	
parameter	BUFFER_SIZE =			3,	

parameter	COEFF_WIDTH =			FRACTION_BITS + 1,
parameter	SCALE_BITS =			SCALE_INT_BITS + SCALE_FRAC_BITS,
parameter	BUFFER_SIZE_WIDTH =		2
)(
input wire							clk_slow,
input wire                          clk_fast,

input wire [DATA_WIDTH*CHANNELS-1:0]dIn,
input wire							dInValid,
output wire							dInReady,
input wire							start,

output reg [DATA_WIDTH*CHANNELS-1:0]
									dOut,
output reg							dOutValid = 0,
input wire [OUTPUT_X_RES_WIDTH-1:0]	outputXRes,			
input wire [OUTPUT_Y_RES_WIDTH-1:0]	outputYRes,
input wire                          nearestNeighbor
);

reg								advanceRead1 = 0;
reg								advanceRead2 = 0;
wire [SCALE_BITS-1:0]			xScale;			
wire [SCALE_BITS-1:0]			yScale;	

localparam 	inputXRes = 640 - 1;
localparam  inputYRes = 480 - 1;

assign xScale = 32'h4000 * (inputXRes + 1) / (outputXRes + 1);
assign yScale = 32'h4000 * (inputYRes + 1) / (outputYRes + 1);	

wire [DATA_WIDTH*CHANNELS-1:0]	readData00;
wire [DATA_WIDTH*CHANNELS-1:0]	readData01;
wire [DATA_WIDTH*CHANNELS-1:0]	readData10;
wire [DATA_WIDTH*CHANNELS-1:0]	readData11;
reg [DATA_WIDTH*CHANNELS-1:0]	readData00Reg = {DATA_WIDTH*CHANNELS{1'bz}};
reg [DATA_WIDTH*CHANNELS-1:0]	readData01Reg = {DATA_WIDTH*CHANNELS{1'bz}};
reg [DATA_WIDTH*CHANNELS-1:0]	readData10Reg = {DATA_WIDTH*CHANNELS{1'bz}};
reg [DATA_WIDTH*CHANNELS-1:0]	readData11Reg = {DATA_WIDTH*CHANNELS{1'bz}};

wire [INPUT_X_RES_WIDTH-1:0]	readAddress;

reg 							readyForRead = 0;		
reg [OUTPUT_Y_RES_WIDTH-1:0]	outputLine = 0;			
reg [OUTPUT_X_RES_WIDTH-1:0]	outputColumn = 0;		//正在计算的位置的横纵坐标
reg [INPUT_X_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								xScaleAmount = 0;		//用于计算的输入像素
reg [INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								yScaleAmount = 0;		
reg [INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:0]
								yScaleAmountNext = 0;	
wire [BUFFER_SIZE_WIDTH-1:0] 	fillCount;			
reg                 			lineSwitchOutputDisable = 0; 
reg								dOutValidInt = 0;

reg [COEFF_WIDTH-1:0]			xBlend = 0;
wire [COEFF_WIDTH-1:0]			yBlend = {1'b0, yScaleAmount[SCALE_FRAC_BITS-1:SCALE_FRAC_BITS-FRACTION_BITS]};

wire [INPUT_X_RES_WIDTH-1:0]	xPixInt = xScaleAmount[INPUT_X_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];
wire [INPUT_Y_RES_WIDTH-1:0]	yPixInt = yScaleAmount[INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];//分别为小数部分和整数部分
wire [INPUT_Y_RES_WIDTH-1:0]	yPixIntNext = yScaleAmountNext[INPUT_Y_RES_WIDTH-1+SCALE_FRAC_BITS:SCALE_FRAC_BITS];

wire 							allDataWritten;	
reg  [1:0]      				readState = 0;

localparam R_IDLE = 0;
localparam READ = 1;
localparam R_DONE = 2;

always @ (posedge clk_fast or posedge start)
begin
    if(start)
	begin
		outputLine <= 0;
		outputColumn <= 0;
		xScaleAmount <= 0;
		yScaleAmount <= 0;
		readState <= R_IDLE;
		dOutValidInt <= 0;
		lineSwitchOutputDisable <= 0;
		advanceRead1 <= 0;
		advanceRead2 <= 0;
		yScaleAmountNext <= 0;
	end
	else
	begin
		case (readState)
			R_IDLE:
			begin
				xScaleAmount <= 0;
				yScaleAmount <= 0;
				if(readyForRead)
				begin
					readState <= READ;
					dOutValidInt <= 1;
				end
			end

			READ:
			begin
				if(dOutValidInt)
				begin
					if(outputColumn == outputXRes)
					begin
						if(yPixIntNext == (yPixInt + 1))   
						begin
							advanceRead1 <= 1;
							if(fillCount < 3)		
								dOutValidInt <= 0;
						end
						else if(yPixIntNext > (yPixInt + 1)) 
						begin
							advanceRead2 <= 1;
							if(fillCount < 4)		
								dOutValidInt <= 0;
						end
					    
					    if(outputLine == outputYRes)
					       readState <= R_DONE;
					       
						outputColumn <= 0;
						xScaleAmount <= 0;
						outputLine <= outputLine + 1;
						yScaleAmount <= yScaleAmountNext;
						lineSwitchOutputDisable <= 1;
					end
					else
					begin
						if(lineSwitchOutputDisable == 0)
						begin
							outputColumn <= outputColumn + 1;
							xScaleAmount <= (outputColumn + 1) * xScale + 0;  
						end
						advanceRead1 <= 0;
						advanceRead2 <= 0;
						lineSwitchOutputDisable <= 0;
					end
				end
				else 
				begin
					advanceRead1 <= 0;
					advanceRead2 <= 0;
					lineSwitchOutputDisable <= 0;
				end
				
				if(fillCount >= 2 && dOutValidInt == 0 || allDataWritten)
				begin
					if((!advanceRead1 && !advanceRead2))
					begin
						dOutValidInt <= 1;
					end
				end
			end
			
			R_DONE:
			begin
				advanceRead1 <= 0;
				advanceRead2 <= 0;
				dOutValidInt <= 0;
			end
			
		endcase
		yScaleAmountNext <= (outputLine + 1) * yScale;
	end
end

assign readAddress = xPixInt;

reg dOutValid_1 = 0;
reg dOutValid_2 = 0;
reg dOutValid_3 = 0;

always @(posedge clk_fast or posedge start)
begin
    if(start)
	begin
		dOutValid_1 <= 0;
		dOutValid_2 <= 0;
		dOutValid_3 <= 0;
		dOutValid <= 0;
	end
	else
	begin
		dOutValid_1 <= dOutValidInt && !lineSwitchOutputDisable;
		dOutValid_2 <= dOutValid_1;
		dOutValid_3 <= dOutValid_2;
		dOutValid <= dOutValid_3;
	end
end

reg [COEFF_WIDTH-1:0] 	coeff00 = 0;		
reg [COEFF_WIDTH-1:0] 	coeff01 = 0;		
reg [COEFF_WIDTH-1:0]	coeff10 = 0;
reg [COEFF_WIDTH-1:0]	coeff11 = 0;		

wire [COEFF_WIDTH-1:0]	coeffOne = {1'b1, {(COEFF_WIDTH-1){1'b0}}};	

wire [COEFF_WIDTH-1:0]	coeffHalf = {2'b01, {(COEFF_WIDTH-2){1'b0}}};

wire [COEFF_WIDTH-1:0]	preCoeff00 = (((coeffOne - xBlend) * (coeffOne - yBlend) + (coeffHalf - 1)) >> FRACTION_BITS) & {{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
wire [COEFF_WIDTH-1:0]	preCoeff01 = ((xBlend * (coeffOne - yBlend) + (coeffHalf - 1)) >> FRACTION_BITS) & {{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
wire [COEFF_WIDTH-1:0]	preCoeff10 = (((coeffOne - xBlend) * yBlend + (coeffHalf - 1)) >> FRACTION_BITS) & {{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};

always @(posedge clk_fast or posedge start)
begin
    if(start)
	begin
		coeff00 <= 0;
		coeff01 <= 0;
		coeff10 <= 0;
		coeff11 <= 0;
		xBlend <= 0;
	end
	else
	begin
		xBlend <= {1'b0, xScaleAmount[SCALE_FRAC_BITS-1:SCALE_FRAC_BITS-FRACTION_BITS]};	//Changed to registered to improve timing
		if(nearestNeighbor == 1'b0)
		begin
			coeff00 <= preCoeff00;
			coeff01 <= preCoeff01;
			coeff10 <= preCoeff10;
			coeff11 <= ((xBlend * yBlend + (coeffHalf - 1)) >> FRACTION_BITS) &	{{COEFF_WIDTH{1'b0}}, {COEFF_WIDTH{1'b1}}};
			//coeff11 <= coeffOne - preCoeff00 - preCoeff01 - preCoeff10;		//Guarantee that all coefficients sum to coeffOne. Saves a multiply too. Reverted to previous method due to timing issues.
		end
		else
		begin //????? ==> ??Χ??????У?????????????????????
			coeff00 <= xBlend < coeffHalf && yBlend < coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff01 <= xBlend >= coeffHalf && yBlend < coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff10 <= xBlend < coeffHalf && yBlend >= coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
			coeff11 <= xBlend >= coeffHalf && yBlend >= coeffHalf ? coeffOne : {COEFF_WIDTH{1'b0}};
		end
	end
end


//Generate the blending multipliers
reg [(DATA_WIDTH+COEFF_WIDTH)*CHANNELS-1:0]	product00, product01, product10, product11;
reg fix = 0;

always @(posedge clk_fast)
begin
    fix <= readAddress == inputXRes;
end

generate
genvar channel;
	for(channel = 0; channel < CHANNELS; channel = channel + 1)
		begin : blend_mult_generate
			always @(posedge clk_fast or posedge start)
			begin
                if(start)
				begin
				
				end
				else
				begin
					//readDataxxReg[channel] <= readDataxx[channel];
					readData00Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData00[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					if(fix)
					    readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData00[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
				    else
				        readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData01[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					readData10Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData10[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
					if(fix)
					    readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData10[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];
				    else
				        readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <= readData11[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ];	
				        
				
					product00[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData00Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff00;
					product01[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData01Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff01;
					product10[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData10Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff10;
					product11[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel] <= readData11Reg[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] * coeff11;
					
					dOut[ DATA_WIDTH*(channel+1)-1 : DATA_WIDTH*channel ] <=
							(((product00[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) + 
							(product01[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) +
							(product10[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel]) +
							(product11[ (DATA_WIDTH+COEFF_WIDTH)*(channel+1)-1 : (DATA_WIDTH+COEFF_WIDTH)*channel])) >> FRACTION_BITS) & ({ {COEFF_WIDTH{1'b0}}, {DATA_WIDTH{1'b1}} });
				end
			end
		end
endgenerate

reg [INPUT_Y_RES_WIDTH-1:0]		writeRowCount = 0;

wire		advanceWrite;

reg [1:0]	writeState = 0;

reg [INPUT_X_RES_WIDTH-1:0] writeColCount = 0;
reg			enableNextDin = 0;
reg			forceRead = 0;

localparam W_IDLE = 0;
localparam WRITE = 1;
localparam W_DONE = 2;

always @ (posedge clk_slow or posedge start)
begin
    if(start)
	begin
		writeState <= W_IDLE;
		enableNextDin <= 0;
		readyForRead <= 0;
		writeRowCount <= 0;
		writeColCount <= 0;
		forceRead <= 0;
	end
	else
	begin
		case (writeState)
		
			W_IDLE:
			begin
				enableNextDin <= 1;
				writeState <= WRITE;
			end
			
			WRITE:
			begin
				if(dInValid & dInReady)
				begin
					if(writeColCount == inputXRes)
					begin 
						if(writeRowCount == 1)
							readyForRead <= 1;
							
						if(writeRowCount == inputYRes)	
						begin
							writeState <= W_DONE;
							enableNextDin <= 0;
							forceRead <= 1;
						end
						
						writeColCount <= 0;
						writeRowCount <= writeRowCount + 1;
					end
					else
					begin
						writeColCount <= writeColCount + 1;
					end
				end
			end
			
			W_DONE:
			begin
				//do nothing, wait for vsync
			end
			
		endcase
	end
end

assign advanceWrite =	(writeColCount == inputXRes) & dInValid & dInReady;
assign allDataWritten = writeState == W_DONE;
assign dInReady = (fillCount < BUFFER_SIZE) & enableNextDin;

//assign finish = (read_count == outputYRes)&&(read_count_reg == outputYRes - 1);

ramBlock #(
	.DATA_WIDTH( DATA_WIDTH*CHANNELS ),
	.ADDRESS_WIDTH( INPUT_X_RES_WIDTH ),	
	.BUFFER_SIZE( BUFFER_SIZE )	
) ramRB (
	.clk_slow( clk_slow ),
	.clk_fast( clk_fast ),
	.rst( start ),
	.advanceRead1( advanceRead1 ),
	.advanceRead2( advanceRead2 ),
	.advanceWrite( advanceWrite ),
	.forceRead( forceRead ),

	.writeData( dIn ),		
	.writeAddress( writeColCount ),
	.writeEnable( dInValid & dInReady & enableNextDin),
	.fillCount( fillCount ),
	
	.readData00( readData00 ),
	.readData01( readData01 ),
	.readData10( readData10 ),
	.readData11( readData11 ),
	.readAddress( readAddress )
);

endmodule