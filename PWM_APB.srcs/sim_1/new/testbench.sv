`timescale 1ns / 1ps

module tb_APB_PWM;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns

  // Signals for APB interface
  logic         PCLK;
  logic         PRESETn;
  logic [31:0]  PADDR;
  logic         PSEL;
  logic         PENABLE;
  logic         PWRITE;
  logic [31:0]  PWDATA;

  logic         PREADY;
  logic [31:0]  PRDATA;
  logic         PSLAVEERR;

  // PWM output
  logic         PWM;
  
  logic [31:0] read_data;

  // Instantiate the DUT (Device Under Test)
  APB_PWM dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PSLAVEERR(PSLAVEERR),
    .PWM(PWM)
  );

  // Clock generation
  initial begin
    PCLK = 1'b0;
    forever #(CLK_PERIOD/2) PCLK = ~PCLK;
  end

  // Task to write to a register
  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge PCLK);
      PSEL <= 1'b1;
      PADDR <= addr;
      PWDATA <= data;
      PWRITE <= 1'b1;
      PENABLE <= 1'b0;
      @(posedge PCLK);
      PENABLE <= 1'b1;
      @(posedge PCLK);
      while (!PREADY) @(posedge PCLK);
      PSEL <= 1'b0;
      PENABLE <= 1'b0;
      PWRITE <= 1'b0;
    end
  endtask

  // Task to read from a register
  task apb_read(input [31:0] addr, output [31:0] data);
    begin
      @(posedge PCLK);
      PSEL <= 1'b1;
      PADDR <= addr;
      PWRITE <= 1'b0;
      PENABLE <= 1'b0;
      @(posedge PCLK);
      PENABLE <= 1'b1;
      @(posedge PCLK);
      while (!PREADY) @(posedge PCLK);
      data <= PRDATA;
      PSEL <= 1'b0;
      PENABLE <= 1'b0;
    end
  endtask

  // Initial block to apply test stimulus
  initial begin
    // Initialize signals
    PRESETn = 1'b0;
    PSEL = 1'b0;
    PENABLE = 1'b0;
    PWRITE = 1'b0;
    PADDR = 32'd0;
    PWDATA = 32'd0;

    // Apply reset
    @(negedge PCLK);
    PRESETn = 1'b1;
    @(negedge PCLK);
    PRESETn = 1'b0;
    repeat (2) @(posedge PCLK);
    PRESETn = 1'b1;

    // Write to registers
    apb_write(32'h0000, 32'd100);   // Write to period register
    apb_write(32'h0004, 32'd40);    // Write to pulse register
    apb_write(32'h000C, 32'd1);     // Write to enable register

    // Read back registers
    apb_read(32'h0000, read_data);
    $display("Period register: %d", read_data);
    apb_read(32'h0004, read_data);
    $display("Pulse register: %d", read_data);
    apb_read(32'h000C, read_data);
    $display("Enable register: %d", read_data);

    // Observe PWM output
    $display("Observing PWM output...");
    repeat (200) @(posedge PCLK);
    $stop;
  end

endmodule
