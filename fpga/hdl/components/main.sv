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