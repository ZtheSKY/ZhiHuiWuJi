`timescale 1ns/1ps

module algorithm_block
(
  input clk_hdmi,
  //input clk_slow,
  input clk_fast,
  input vsync_in,
  input write_en,
  input [23:0] data_in,
  input [OUTPUT_X_RES_WIDTH-1:0] outputXRes,
  input [OUTPUT_Y_RES_WIDTH-1:0] outputYRes,
  input mode,

  output doutvalid,
  output [31:0] data_out
  //output start,
  //output scaler_re,
  //output fifo_dataValid
  //output empty,
  //output full,
  //output [11:0] count,
  //output [23:0] fifo_data
  //output finish 
);

    parameter DATA_WIDTH = 8;
    parameter CHANNELS = 3;
    parameter BUFFER_SIZE = 3;			 // Number of RAMs in RAM ring buffer
    parameter DISCARD_CNT_WIDTH = 2;
    
    parameter INPUT_X_RES_WIDTH = 11;
    parameter INPUT_Y_RES_WIDTH = 11;
    parameter OUTPUT_X_RES_WIDTH = 11;
    parameter OUTPUT_Y_RES_WIDTH = 11;
    
    parameter FRACTION_BITS =	8;        // Don't modify
    parameter SCALE_INT_BITS = 4;	      // Don't modify
    parameter SCALE_FRAC_BITS = 14;      // Don't modify
    parameter SCALE_BITS = SCALE_INT_BITS + SCALE_FRAC_BITS;
    
    parameter IN_LENGTH = 640;
    parameter IN_WIDTH = 480;

    wire [23:0] fifo_data;
    wire fifo_dataValid;
    wire scaler_re;
    wire [23:0] scaler_data;
    
    reg [12:0] cnt;
    
    always@(posedge clk_hdmi)begin
      if(!vsync_in)
        cnt <= 0;
      else
      begin
        if(cnt < 1968)
          cnt <= cnt + 1;
        else
          cnt <= cnt;
      end
    end
    
    assign start = !(cnt == 1968);
    wire rst;
    assign rst = cnt == 1;

    assign data_out = {8'b00000000, scaler_data};

Scaler #(
    .DATA_WIDTH( DATA_WIDTH ),
    .CHANNELS( CHANNELS ),
    //.DISCARD_CNT_WIDTH( DISCARD_CNT_WIDTH ),
    .INPUT_X_RES_WIDTH( INPUT_X_RES_WIDTH ),
    .INPUT_Y_RES_WIDTH( INPUT_Y_RES_WIDTH ),
    .OUTPUT_X_RES_WIDTH( OUTPUT_X_RES_WIDTH ),
    .OUTPUT_Y_RES_WIDTH( OUTPUT_Y_RES_WIDTH ),
    .BUFFER_SIZE( BUFFER_SIZE ),				   //Number of RAMs in RAM ring buffer
    .FRACTION_BITS(FRACTION_BITS),
    .SCALE_INT_BITS(SCALE_INT_BITS),
    .SCALE_FRAC_BITS(SCALE_FRAC_BITS)
) scaler_inst (
    .clk_slow        ( clk_hdmi ),
    .clk_fast        ( clk_fast ),
    
    .dIn        ( fifo_data ),
    .dInValid   ( fifo_dataValid ),
    .dInReady    ( scaler_re ),
    .start      ( start ),
    
    .dOut       ( scaler_data ),
    .dOutValid  ( doutvalid ),
    //.nextDout   ( 1 ),
    
    //Control
    .outputXRes         ( outputXRes - 1 ),	 //Resolution of output data
    .outputYRes         ( outputYRes - 1 ),
 
    .nearestNeighbor    ( ~mode )
    //.inputDiscardCnt    ( 0 ),	         //Number of input pixels to discard before processing data. Used for clipping
    //.leftOffset         ( 0 ),
    //.topFracOffset      ( 0 )
    //.finish             (finish)
);


FIFO_scaler  u_FIFO_scaler(
  .almost_full_o ( ),
  .prog_full_o ( ),
  .full_o ( full ),
  .overflow_o ( ),
  .wr_ack_o (  ),
  .empty_o ( empty ),
  .almost_empty_o ( ),
  .underflow_o (  ),
  .rd_valid_o ( fifo_dataValid ),
  .wr_clk_i ( clk_hdmi ),
  .rd_clk_i ( clk_hdmi ),
  .wr_en_i ( write_en ),
  .rd_en_i ( scaler_re  ),
  .wdata ( data_in ),
  .wr_datacount_o ( count ),
  .rst_busy (  ),
  .rdata ( fifo_data ),
  .rd_datacount_o (  ),
  .a_rst_i  (rst)
);

endmodule