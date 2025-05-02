/*
  A pulse width modulation module 
*/

module pwm(clk, rst, ena, duty, out);

parameter N = 8;

input wire clk, rst;
input wire ena; // Enables the output.
// input wire step; // Enables the internal counter. You should only increment when this signal is high (this is how we slow down the PWM to reasonable speeds).
input wire [N-1:0] duty; // The "duty cycle" input.
output logic out;
int totalDuty = 2**N-1;
logic [N-1:0] counter;

initial out = 0;
initial counter = 0;

// Create combinational (always_comb) and sequential (always_ff @(posedge clk)) 
// logic that drives the out signal.
// out should be off if ena is low.
// out should be fully zero (no pulses) if duty is 0.
// out should have its highest duty cycle if duty is 2^N-1;
// bonus: out should be fully zero at duty = 0, and fully 1 (always on) at duty = 2^N-1;
// You can use behavioural combinational logic, but try to keep your sequential
//   and combinational blocks as separate as possible.
always_ff @(posedge clk) begin: PWM
  counter <= counter + 1;
  if (rst) begin
    out <= 0;
    counter <= 0;
  end else if (ena) begin
    if (counter < duty) begin
      out <= 1;
      // counter <= counter + 1;
    end else if (counter > duty & duty != duty[N-1])  begin
      out <= 0;
      counter <= counter + 1;
    end else if (duty != totalDuty) begin
      out <= 0;
      // counter <= counter + 1;
    end
  end
end

endmodule
