module pwm_top (
  input wire clk,
  input wire rst,
  output wire pwm_out
);
timeunit 1ns; timeprecision 100ps;
  reg [7:0] duty;
  logic ena;

  pwm #(.N(8)) pwm_inst (
    .clk(clk),
    .rst(rst),
    .ena(ena),
    .duty(duty),
    .out(pwm_out)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      ena <= 0;
      duty <= 8'd0;
    end else begin
      ena <= 1;
      duty <= 8'b1010100; 
    end
  end

endmodule
