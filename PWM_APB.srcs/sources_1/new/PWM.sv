`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amaan Rehman Shah
// 
// Create Date: 06/28/2024 02:51:15 PM
// Module Name: PWM
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module PWM
(
  input logic        PCLK,
  input logic        PRESETn,
  input logic [31:0] period,
  input logic [31:0] pulse,
  input logic [31:0] enable,

  output logic       PWM
);

logic [31:0] count;

always_ff @ (posedge PCLK) begin
  if (!PRESETn || count == period)
    count <= 32'd0;
  else if (enable[0])
    count <= count + 1;
end

always @ (*) begin
  if (count < pulse && enable[0])
    PWM = 1'b1;
  else
    PWM = 1'b0;
end

endmodule
