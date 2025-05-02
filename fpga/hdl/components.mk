# Flip flop for testing
flip_flop_TOP=hdl/components/flip_flop.sv
flip_flop_XDC=xdc/components/flip_flop_cmod-a7.xdc
# flip_flop_XDC=xdc/components/flip_flop_zybo.xdc
flip_flop_SRCS=hdl/components/flip_flop.sv
# flip_flop_DEPS=""

# LED for testing
led_TOP=hdl/components/led.sv
led_XDC=xdc/components/led.xdc
led_SRCS=hdl/components/led.sv

# PWM Output
pwm_TOP=hdl/components/pwm.sv
pwm_XDC=xdc/components/pwm.xdc
pwm_SRCS=hdl/components/pwm.sv

# PWM Test
pwm_tb_TOP=hdl/components/pwm_tb.sv
pwm_tb_XDC=xdc/components/pwm_tb.xdc
pwm_tb_SRCS=hdl/components/pwm_tb.sv hdl/components/pwm_control.sv hdl/components/pwm.sv
# pwm_led_DEPS=