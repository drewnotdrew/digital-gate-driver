/*
  A pulse width modulation module 
*/

module pwm(clk, rst, ena, step, duty, out);

parameter N = 8;

input wire clk, rst;
input wire ena; // Enables the output.
input wire step; // Enables the internal counter. You should only increment when this signal is high (this is how we slow down the PWM to reasonable speeds).
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
  counter <= counter + 1;
end else if (counter > duty & duty != duty[N-1])  begin
  out <= 0;
  counter <= counter + 1;
end else if (duty != totalDuty) begin
  out <= 0;
  counter <= counter + 1;

end
end
end
endmodule

/*
  Main module
*/
module main (
    input logic clk,
    input logic rst_n,
    input logic rx,
    output logic pwm_out
);

// Signals connecting the modules
logic [7:0] uart_read_data;
logic uart_read_valid;
logic uart_read_ready;
logic [7:0] pwm_duty_cycle;

// UART instance
uart uart_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .read_data(uart_read_data),
    .read_ready(uart_read_ready),
    .read_valid(uart_read_valid),
    .tx(),             // TX output unused for now so I'm going to tie it off
    .write_data('0),   // Tie-off unused write interface
    .write_valid(1'b0),
    .write_ready()
);

// PWM instance
pwm #(.N(8)) pwm_inst (
    .clk(clk),
    .rst(~rst_n),       // I think the pwm and flip_flop expect active-high reset; rst_n is active-low, so I inverted it (~rst_n)
    .ena(1'b1),
    .step(1'b1),
    .duty(pwm_duty_cycle),
    .out(pwm_out)
);

// Update PWM duty cycle when new UART data is available
always_ff @(posedge clk) begin
    if (!rst_n)
        pwm_duty_cycle <= 8'b0;   // I changed this it was '0l' and I think it should be '0'
    else if (uart_read_valid && uart_read_ready)
        pwm_duty_cycle <= uart_read_data;
end

// Always accepts UART read
assign uart_read_ready = 1'b1;

endmodule