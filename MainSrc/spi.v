`timescale 1ns / 1ps

module SpiSlave16Bits_S (
    input flag,
    input SCLK,
    input SDI,

    output reg [7:0] inc_length,
    output reg [7:0] inc_width,
    output reg done,
    output [3:0] step_de
);

assign step_de = step;
reg [15:0] Read_buffer = 0;
reg [4:0] step = 0;
reg VS_delay;

    
always@(posedge SCLK or negedge flag)
  begin
  if(!flag)
  begin
    step<=0;
    done <= 0;
  end
   
  else
    begin
    
  
  if(step<=15)begin
    step <= step+1'b1;
    Read_buffer[step]<=SDI;
  end
  else if(step==19)
    begin
      step <= 0;
      inc_length <= Read_buffer[15:8];
      inc_width <= Read_buffer[7:0];
      done <= 1;
    end
  else
    step <= step+1'b1;
  end
end
    
endmodule

