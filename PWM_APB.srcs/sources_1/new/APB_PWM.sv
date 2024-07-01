`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amaan Rehman Shah
// 
// Create Date: 06/28/2024 02:51:15 PM
// Design Name: Pulse Width Mmonitor
// Module Name: APB_PWM
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

module APB_PWM
(
  input logic         PCLK,
  input logic         PRESETn,
  input logic [31:0]  PADDR,
  input logic         PSEL,
  input logic         PENABLE,
  input logic         PWRITE,
  input logic [31:0]  PWDATA,

  output logic        PREADY,
  output logic [31:0] PRDATA,
  output logic        PSLAVEERR,

  output logic        PWM
);

logic [31:0] period, pulse, enable;
logic en0, en1, en2, en3;

always_ff @ (posedge PCLK) begin // REGISTER PERIOD
  if (!PRESETn)
    period <= 32'd0;
  else if (PRESETn && en0) begin // WRITE REGISTER
    period <= PWDATA;
    PREADY <= 1'b1;
  end else if (PRESETn && !PWRITE && PSEL && PENABLE) begin // READ REGISTER
    PRDATA <= period;
    PREADY <= 1'b1;
  end
end

always_ff @ (posedge PCLK) begin // REGISTER PULSE
  if (!PRESETn)
    pulse <= 32'd0;
  else if (PRESETn && en1) begin // WRITE REGISTER
    pulse <= PWDATA;
    PREADY <= 1'b1;
  end else if (PRESETn && !PWRITE && PSEL && PENABLE) begin // READ REGISTER
    PRDATA <= pulse;
    PREADY <= 1'b1;
  end
end

always_ff @ (posedge PCLK) begin // REGISTER ENABLE
  if (!PRESETn)
    enable <= 32'd0;
  else if (PRESETn && en3) begin // WRITE REGISTER
    enable <= {31'd0, PWDATA[0]};
    PREADY <= 1'b1;
  end else if (PRESETn && !PWRITE && PSEL && PENABLE) begin // READ REGISTER
    PRDATA <= enable;
    PREADY <= 1'b1;
  end
end

always @ (PSEL or PENABLE or PADDR or PWRITE) begin
  en0 = 1'b0;
  en1 = 1'b0;
  en2 = 1'b0;
  en3 = 1'b0;
  PSLAVEERR = 1'b0;
  case (PADDR[3:0])
    4'b0000:
      if (PENABLE && PWRITE)
        en0 = 1'b1;
    4'b0100:
      if (PENABLE && PWRITE)
        en1 = 1'b1;
    4'b1100:
      if (PENABLE && PWRITE)
        en3 = 1'b1;
    default:
      PSLAVEERR = 1'b1;
  endcase
end

PWM pwm_inst(.PCLK(PCLK), .PRESETn(PRESETn), .period(period), .pulse(pulse), .enable(enable), .PWM(PWM));

endmodule
