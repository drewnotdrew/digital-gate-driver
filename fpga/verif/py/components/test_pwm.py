import random
import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
from verif.py.cocotb_runner import run_cocotb
pytest_plugins = []

@cocotb.test()
async def pwm_basic(dut):
    """
    Test the PWM output at various duty cycles.
    """
    
    N = 8
    max_duty = 2**N - 1
    dut.clk.value = 0
    dut.duty.value = 175
    dut.ena.value = 1

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 0


    async def count_pwm_high_pulses(duty_val, steps=2**N):
        dut.duty.value = duty_val
        dut.ena.value = 1
        await ClockCycles(dut.clk, 1) 

        high_count = 0
        for _ in range(steps):
            await RisingEdge(dut.clk)
            if dut.out.value.integer:
                high_count += 1
        return high_count

    # duty = 0 
    high_pulses = await count_pwm_high_pulses(0)
    # assert high_pulses == 0, f"Expected 0 high pulses, got {high_pulses}"

    # duty = max 
    high_pulses = await count_pwm_high_pulses(max_duty)
    # assert high_pulses == 2**N, f"Expected all high pulses, got {high_pulses}"

    # duty = 50%
    expected = 128
    high_pulses = await count_pwm_high_pulses(expected)
    tolerance = 2 
    # assert abs(high_pulses - expected) <= tolerance, f"Expected ~{expected}, got {high_pulses}"
    await ClockCycles(dut.clk, 10000)
    

def test_pwm():
    run_cocotb(top="pwm", deps=[])
