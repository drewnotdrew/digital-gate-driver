/*
  Main modlue
*/

logic [7:0] uart_read_data;
logic uart_read_valid
logic uart_read_ready
logic [7:0] pwm_duty_cycle
logic pwm_out

uart uart_inst (
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .read_data(uart_read_data),
    .read_ready(uart_read_ready),
    .read_valid(uart_read_valid)
);

pwm #( .N(8) ) pwm_inst (
    .clk(clk),
    .rst(~rst_n),
    .ena(1'b1),
    .step(1'b1),
    .duty(pwm_duty_cycle),
    .out(pwm_out)
);

always_ff @ (posedge clk) begin
    if (!rst_n)
        pwm_duty_cycle <= 8'b0l
    else if (uart_read_valid && uart_read_ready)
        pwm_duty_cycle <= uart_read_data;
end

assign uart_read_ready = 1'b1;