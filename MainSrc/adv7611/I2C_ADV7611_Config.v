/*-------------------------------------------------------------------------
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo.www.cnblogs.com/crazybingo
(C) COPYRIGHT 2012 CrazyBingo. ALL RIGHTS RESERVED
Filename : I2C_SC130GS_12801024_Config.v
Author : CrazyBingo
Date : 2019-08-03
Version : 1.0
Description : I2C Configure Data of AR0135.
Modification History :
Date By Version Change Description
===========================================================================
19/08/03 CrazyBingo 1.0 Original
--------------------------------------------------------------------------*/

`timescale 1ns/1ns

module I2C_ADV7611_Config //1920*1080
(
 input [8:0] LUT_INDEX, 
 output reg [23:0] LUT_DATA, 
 output [8:0] LUT_SIZE
);
assign LUT_SIZE = 181 + 1;

//-----------------------------------------------------------------
///////////////////// Config Data LUT ////////////////////////// 

//	1. Changed crystal to 27MHz. 
//	2. Invert HS, VS. 
//	3. Use SDR clock. 

always@(*)
begin
 case(LUT_INDEX)
	0: 	LUT_DATA = {8'h98, 8'hF4, 8'h80}; //Manufacturer ID Byte - High (Read only)
	1: 	LUT_DATA = {8'h98, 8'hF5, 8'h7c}; //Manufacturer ID Byte - Low (Read only)
	2: 	LUT_DATA = {8'h98, 8'hF8, 8'h4c}; // BIT[7]-Reset all the Reg 
	3: 	LUT_DATA = {8'h98, 8'hF9, 8'h64}; //DC offset for analog process
	4: 	LUT_DATA = {8'h98, 8'hFA, 8'h6c}; //COM10: 	href/vsync/pclk/data reverse(Vsync H valid)
	5: 	LUT_DATA = {8'h98, 8'hFB, 8'h68}; //VGA: 	8'h22; QVGA: 	8'h3f;
	6: 	LUT_DATA = {8'h98, 8'hFD, 8'h44}; //VGA: 	8'ha4; QVGA: 	8'h50;
	7: 	LUT_DATA = {8'h98, 8'h01, 8'h05}; //VGA: 	8'h07; QVGA: 	8'h03;
	8: 	LUT_DATA = {8'h98, 8'h00, 8'h13}; //VGA: 	8'hf0; QVGA: 	8'h78;
	9: 	LUT_DATA = {8'h98, 8'h02, 8'hF7}; //HREF / 8'h80
	10: 	LUT_DATA = {8'h98, 8'h03, 8'h40}; //	0x40:SDR. 0x60:DDR. 
	11: 	LUT_DATA = {8'h98, 8'h04, 8'h60}; //	[2:1]0:27MHz. 1:28.63MHz. 2:24.576MHz. 3:24MHz. [7:5]010:BGR, 011:RGB
	12: 	LUT_DATA = {8'h98, 8'h05, 8'h28}; //
	13: 	LUT_DATA = {8'h98, 8'h06, 8'ha6}; //	HS / VS Inverted. CLK / DE Not Inverted. Track rising edge of CLK. 
	14: 	LUT_DATA = {8'h98, 8'h0b, 8'h44}; //BIT[6]: 	0:VGA; 1;QVGA
	15: 	LUT_DATA = {8'h98, 8'h0C, 8'h42}; //
	16: 	LUT_DATA = {8'h98, 8'h15, 8'h80}; //
	17: 	LUT_DATA = {8'h98, 8'h19, 8'h80}; //	LLC_DLL_PHASE. [7]En, [4:0]Phase. 
	18: 	LUT_DATA = {8'h98, 8'h33, 8'h40}; //
	19: 	LUT_DATA = {8'h98, 8'h14, 8'h3f}; //
	20: 	LUT_DATA = {8'h44, 8'hba, 8'h01}; //
	21: 	LUT_DATA = {8'h44, 8'h7c, 8'h01}; // 
	22: 	LUT_DATA = {8'h64, 8'h40, 8'h81}; //DSP_Ctrl4:00/01: 	YUV or RGB; 10: 	RAW8; 11: 	RAW10 
	23: 	LUT_DATA = {8'h68, 8'h9b, 8'h03}; //ADI recommanded setting
	24: 	LUT_DATA = {8'h68, 8'hc1, 8'h01}; //ADI recommanded setting
	25: 	LUT_DATA = {8'h68, 8'hc2, 8'h01}; //ADI recommanded setting
	26: 	LUT_DATA = {8'h68, 8'hc3, 8'h01}; //ADI recommanded setting
	27: 	LUT_DATA = {8'h68, 8'hc4, 8'h01}; //ADI recommanded setting
	28: 	LUT_DATA = {8'h68, 8'hc5, 8'h01}; //ADI recommanded setting
	29: 	LUT_DATA = {8'h68, 8'hc6, 8'h01}; //ADI recommanded setting
	30: 	LUT_DATA = {8'h68, 8'hc7, 8'h01}; //ADI recommanded setting
	31: 	LUT_DATA = {8'h68, 8'hc8, 8'h01}; //ADI recommanded setting
	32: 	LUT_DATA = {8'h68, 8'hc9, 8'h01}; //ADI recommanded settin g
	33: 	LUT_DATA = {8'h68, 8'hca, 8'h01}; //ADI recommanded setting
	34: 	LUT_DATA = {8'h68, 8'hcb, 8'h01}; //ADI recommanded setting
	35: 	LUT_DATA = {8'h68, 8'hcc, 8'h01}; //ADI recommanded setting
	36: 	LUT_DATA = {8'h68, 8'h00, 8'h00}; //Set HDMI input Port A
	37: 	LUT_DATA = {8'h68, 8'h83, 8'hfe}; //terminator for Port A
	38: 	LUT_DATA = {8'h68, 8'h6f, 8'h08}; //ADI recommended setting
	39: 	LUT_DATA = {8'h68, 8'h85, 8'h1f}; //ADI recommended setting
	40: 	LUT_DATA = {8'h68, 8'h87, 8'h70}; //ADI recommended setting
	41: 	LUT_DATA = {8'h68, 8'h8d, 8'h04}; //LFG
	42: 	LUT_DATA = {8'h68, 8'h8e, 8'h1e}; //HFG
	43: 	LUT_DATA = {8'h68, 8'h1a, 8'h8a}; //unmute audio
	44: 	LUT_DATA = {8'h68, 8'h57, 8'hda}; // ADI recommended setting
	45: 	LUT_DATA = {8'h68, 8'h58, 8'h01};
	46: 	LUT_DATA = {8'h68, 8'h75, 8'h10}; 
	47: 	LUT_DATA = {8'h68, 8'h6c, 8'ha3};//enable manual HPA
	48: 	LUT_DATA = {8'h98, 8'h20, 8'h70};//HPD low
	49: 	LUT_DATA = {8'h64, 8'h74, 8'h00};//disable internal EDID 
	//edid 
	//0: 	LUT_DATA = {8'h68, 8'h6c, 8'ha3};//// enable manual HPA
	//1: 	LUT_DATA = {8'h98, 8'h20, 8'h70};//HPD low
	//2: 	LUT_DATA = {8'h64, 8'h74, 8'h00};//disable internal EDID 
	//edid par
	50: 	LUT_DATA = {8'h6c, 8'd0, 8'h00}; 
	51: 	LUT_DATA = {8'h6c, 8'd1, 8'hFF}; 
	52: 	LUT_DATA = {8'h6c, 8'd2, 8'hFF}; 
	53: 	LUT_DATA = {8'h6c, 8'd3, 8'hFF}; 
	54: 	LUT_DATA = {8'h6c, 8'd4, 8'hFF}; 
	55: 	LUT_DATA = {8'h6c, 8'd5, 8'hFF}; 
	56: 	LUT_DATA = {8'h6c, 8'd6, 8'hFF}; 
	57: 	LUT_DATA = {8'h6c, 8'd7, 8'h00}; 
	58: 	LUT_DATA = {8'h6c, 8'd8, 8'h3E}; 
	59: 	LUT_DATA = {8'h6c, 8'd9, 8'hD3}; 
	60: 	LUT_DATA = {8'h6c, 8'd10, 8'h11}; 
	61: 	LUT_DATA = {8'h6c, 8'd11, 8'h11}; 
	62: 	LUT_DATA = {8'h6c, 8'd12, 8'hE0}; 
	63: 	LUT_DATA = {8'h6c, 8'd13, 8'hC5}; 
	64: 	LUT_DATA = {8'h6c, 8'd14, 8'h09}; 
	65: 	LUT_DATA = {8'h6c, 8'd15, 8'h00}; 
	66: 	LUT_DATA = {8'h6c, 8'd16, 8'h01}; 
	67: 	LUT_DATA = {8'h6c, 8'd17, 8'h21}; 
	68: 	LUT_DATA = {8'h6c, 8'd18, 8'h01}; 
	69: 	LUT_DATA = {8'h6c, 8'd19, 8'h03}; 
	70: 	LUT_DATA = {8'h6c, 8'd20, 8'h80}; 
	71: 	LUT_DATA = {8'h6c, 8'd21, 8'h40}; 
	72: 	LUT_DATA = {8'h6c, 8'd22, 8'h30}; 
	73: 	LUT_DATA = {8'h6c, 8'd23, 8'h78}; 
	74: 	LUT_DATA = {8'h6c, 8'd24, 8'h02}; 
	75: 	LUT_DATA = {8'h6c, 8'd25, 8'h1F}; 
	76: 	LUT_DATA = {8'h6c, 8'd26, 8'h65}; 
	77: 	LUT_DATA = {8'h6c, 8'd27, 8'hA4}; 
	78: 	LUT_DATA = {8'h6c, 8'd28, 8'h55}; 
	79: 	LUT_DATA = {8'h6c, 8'd29, 8'h50}; 
	80: 	LUT_DATA = {8'h6c, 8'd30, 8'h9F}; 
	81: 	LUT_DATA = {8'h6c, 8'd31, 8'h26}; 
	82: 	LUT_DATA = {8'h6c, 8'd32, 8'h0C}; 
	83: 	LUT_DATA = {8'h6c, 8'd33, 8'h50}; 
	84: 	LUT_DATA = {8'h6c, 8'd34, 8'h54}; 
	85: 	LUT_DATA = {8'h6c, 8'd35, 8'h20}; 
	86: 	LUT_DATA = {8'h6c, 8'd36, 8'h00}; 
	87: 	LUT_DATA = {8'h6c, 8'd37, 8'h00}; 
	88: 	LUT_DATA = {8'h6c, 8'd38, 8'h31}; 
	89: 	LUT_DATA = {8'h6c, 8'd39, 8'h40}; 
	90: 	LUT_DATA = {8'h6c, 8'd40, 8'h01}; 
	91: 	LUT_DATA = {8'h6c, 8'd41, 8'h00}; 
	92: 	LUT_DATA = {8'h6c, 8'd42, 8'h01}; 
	93: 	LUT_DATA = {8'h6c, 8'd43, 8'h00}; 
	94: 	LUT_DATA = {8'h6c, 8'd44, 8'h01}; 
	95: 	LUT_DATA = {8'h6c, 8'd45, 8'h00}; 
	96: 	LUT_DATA = {8'h6c, 8'd46, 8'h01}; 
	97: 	LUT_DATA = {8'h6c, 8'd47, 8'h00}; 
	98: 	LUT_DATA = {8'h6c, 8'd48, 8'h01}; 
	99: 	LUT_DATA = {8'h6c, 8'd49, 8'h00}; 
	100: 	LUT_DATA = {8'h6c, 8'd50, 8'h01}; 
	101: 	LUT_DATA = {8'h6c, 8'd51, 8'h00}; 
	102: 	LUT_DATA = {8'h6c, 8'd52, 8'h01}; 
	103: 	LUT_DATA = {8'h6c, 8'd53, 8'h00}; 
	104: 	LUT_DATA = {8'h6c, 8'd54, 8'hD8}; 
	105: 	LUT_DATA = {8'h6c, 8'd55, 8'h09}; 
	106: 	LUT_DATA = {8'h6c, 8'd56, 8'h80}; 
	107: 	LUT_DATA = {8'h6c, 8'd57, 8'hA0}; 
	108: 	LUT_DATA = {8'h6c, 8'd58, 8'h20}; 
	109: 	LUT_DATA = {8'h6c, 8'd59, 8'hE0}; 
	110: 	LUT_DATA = {8'h6c, 8'd60, 8'h2D}; 
	111: 	LUT_DATA = {8'h6c, 8'd61, 8'h10}; 
	112: 	LUT_DATA = {8'h6c, 8'd62, 8'h10}; 
	113: 	LUT_DATA = {8'h6c, 8'd63, 8'h20}; 
	114: 	LUT_DATA = {8'h6c, 8'd64, 8'hA2}; 
	115: 	LUT_DATA = {8'h6c, 8'd65, 8'h00}; 
	116: 	LUT_DATA = {8'h6c, 8'd66, 8'h80}; 
	117: 	LUT_DATA = {8'h6c, 8'd67, 8'hE0}; 
	118: 	LUT_DATA = {8'h6c, 8'd68, 8'h21}; 
	119: 	LUT_DATA = {8'h6c, 8'd69, 8'h00}; 
	120: 	LUT_DATA = {8'h6c, 8'd70, 8'h00}; 
	121: 	LUT_DATA = {8'h6c, 8'd71, 8'h1E}; 
	122: 	LUT_DATA = {8'h6c, 8'd72, 8'h00}; 
	123: 	LUT_DATA = {8'h6c, 8'd73, 8'h00}; 
	124: 	LUT_DATA = {8'h6c, 8'd74, 8'h00}; 
	125: 	LUT_DATA = {8'h6c, 8'd75, 8'h10}; 
	126: 	LUT_DATA = {8'h6c, 8'd76, 8'h00}; 
	127: 	LUT_DATA = {8'h6c, 8'd77, 8'h00}; 
	128: 	LUT_DATA = {8'h6c, 8'd78, 8'h00}; 
	129: 	LUT_DATA = {8'h6c, 8'd79, 8'h00}; 
	130: 	LUT_DATA = {8'h6c, 8'd80, 8'h00}; 
	131: 	LUT_DATA = {8'h6c, 8'd81, 8'h00}; 
	132: 	LUT_DATA = {8'h6c, 8'd82, 8'h00}; 
	133: 	LUT_DATA = {8'h6c, 8'd83, 8'h00}; 
	134: 	LUT_DATA = {8'h6c, 8'd84, 8'h00}; 
	135: 	LUT_DATA = {8'h6c, 8'd85, 8'h00}; 
	136: 	LUT_DATA = {8'h6c, 8'd86, 8'h00}; 
	137: 	LUT_DATA = {8'h6c, 8'd87, 8'h00}; 
	138: 	LUT_DATA = {8'h6c, 8'd88, 8'h00}; 
	139: 	LUT_DATA = {8'h6c, 8'd89, 8'h00}; 
	140: 	LUT_DATA = {8'h6c, 8'd90, 8'h00}; 
	141: 	LUT_DATA = {8'h6c, 8'd91, 8'h00}; 
	142: 	LUT_DATA = {8'h6c, 8'd92, 8'h00}; 
	143: 	LUT_DATA = {8'h6c, 8'd93, 8'h10}; 
	144: 	LUT_DATA = {8'h6c, 8'd94, 8'h00}; 
	145: 	LUT_DATA = {8'h6c, 8'd95, 8'h00}; 
	146: 	LUT_DATA = {8'h6c, 8'd96, 8'h00}; 
	147: 	LUT_DATA = {8'h6c, 8'd97, 8'h00}; 
	148: 	LUT_DATA = {8'h6c, 8'd98, 8'h00}; 
	149: 	LUT_DATA = {8'h6c, 8'd99, 8'h00}; 
	150: 	LUT_DATA = {8'h6c, 8'd100, 8'h00}; 
	151: 	LUT_DATA = {8'h6c, 8'd101, 8'h00}; 
	152: 	LUT_DATA = {8'h6c, 8'd102, 8'h00}; 
	153: 	LUT_DATA = {8'h6c, 8'd103, 8'h00}; 
	154: 	LUT_DATA = {8'h6c, 8'd104, 8'h00}; 
	155: 	LUT_DATA = {8'h6c, 8'd105, 8'h00}; 
	156: 	LUT_DATA = {8'h6c, 8'd106, 8'h00}; 
	157: 	LUT_DATA = {8'h6c, 8'd107, 8'h00}; 
	158: 	LUT_DATA = {8'h6c, 8'd108, 8'h00}; 
	159: 	LUT_DATA = {8'h6c, 8'd109, 8'h00}; 
	160: 	LUT_DATA = {8'h6c, 8'd110, 8'h00}; 
	161: 	LUT_DATA = {8'h6c, 8'd111, 8'h10}; 
	162: 	LUT_DATA = {8'h6c, 8'd112, 8'h00}; 
	163: 	LUT_DATA = {8'h6c, 8'd113, 8'h00}; 
	164: 	LUT_DATA = {8'h6c, 8'd114, 8'h00}; 
	165: 	LUT_DATA = {8'h6c, 8'd115, 8'h00}; 
	166: 	LUT_DATA = {8'h6c, 8'd116, 8'h00}; 
	167: 	LUT_DATA = {8'h6c, 8'd117, 8'h00}; 
	168: 	LUT_DATA = {8'h6c, 8'd118, 8'h00}; 
	169: 	LUT_DATA = {8'h6c, 8'd119, 8'h00}; 
	170: 	LUT_DATA = {8'h6c, 8'd120, 8'h00}; 
	171: 	LUT_DATA = {8'h6c, 8'd121, 8'h00}; 
	172: 	LUT_DATA = {8'h6c, 8'd122, 8'h00}; 
	173: 	LUT_DATA = {8'h6c, 8'd123, 8'h00}; 
	174: 	LUT_DATA = {8'h6c, 8'd124, 8'h00}; 
	175: 	LUT_DATA = {8'h6c, 8'd125, 8'h00}; 
	176: 	LUT_DATA = {8'h6c, 8'd126, 8'h01}; 
	177: 	LUT_DATA = {8'h6c, 8'd127, 8'hDB}; 

	178: 	LUT_DATA = {8'h64, 8'h74, 8'h01};// enable internal EDID
	179: 	LUT_DATA = {8'h98, 8'h20, 8'hf0};// HPD high
	180: 	LUT_DATA = {8'h68, 8'h6c, 8'ha2};// disable manual HPA 
	181: 	LUT_DATA = {8'h98, 8'hf4, 8'h00};
	default:LUT_DATA =0;
	endcase
end



endmodule
