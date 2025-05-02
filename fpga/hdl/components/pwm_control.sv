module pwm_control;


  reg clk;
  reg rst;
  reg ena;
  reg [7:0] duty;
  wire out;

  pwm #(.N(8)) pwm_inst (
    .clk(clk),
    .rst(rst),
    .ena(ena),
    .duty(duty),
    .out(out)
  );


  always begin
    #5 clk = ~clk;
  end

  // FSM states
  typedef enum logic [2:0] {
    IDLE,
    RESET,
    DUTY_50,
    DUTY_75,
    DUTY_25,
    DUTY_0,
    DUTY_100,
    DONE
  } state_t;

  state_t state, next_state;
  integer count;


  always @(posedge clk) begin
    state <= next_state;
  end


  always @(posedge clk) begin
    case (state)
      IDLE: begin
        clk <= 0;
        rst <= 0;
        ena <= 1;
        duty <= 8'd0;
        count <= 0;
      end

      RESET: begin
        rst <= 1;
        count <= count + 1;
      end

      default: begin
        rst <= 0;
        count <= count + 1;
      end
    endcase
  end

  // FSM next state logic
  always @(*) begin
    next_state = state;
    case (state)
      IDLE:      next_state = RESET;

      RESET:     if (count >= 5)      next_state = DUTY_50;

      DUTY_50:   if (count >= 205)    next_state = DUTY_75;

      DUTY_75:   if (count >= 405)    next_state = DUTY_25;

      DUTY_25:   if (count >= 605)    next_state = DUTY_0;

      DUTY_0:    if (count >= 805)    next_state = DUTY_100;

      DUTY_100:  if (count >= 1005)   next_state = DONE;

      DONE:      next_state = DONE;
    endcase
  end

 
  always @(posedge clk) begin
    case (state)
      DUTY_50:   duty <= 8'd128; // 50%
      DUTY_75:   duty <= 8'd192; // 75%
      DUTY_25:   duty <= 8'd64;  // 25%
      DUTY_0:    duty <= 8'd0;   // 0%
      DUTY_100:  duty <= 8'd255; // 100%
    endcase

    if (state == DONE) begin
      $display("Test complete.");
      $finish;
    end
  end

endmodule