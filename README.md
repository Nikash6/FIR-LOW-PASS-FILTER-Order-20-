# FIR-LOW-PASS-FILTER-Order-20-
Fir low pass filter of order 20 in verilog 
20-Tap Digital FIR Filter in Verilog
A high-precision, 20-tap Finite Impulse Response (FIR) filter designed in Verilog for FPGA implementation. This project demonstrates fixed-point arithmetic, AXI-Stream interface compliance, and hardware-efficient signal processing.

## Project Overview
This repository contains the RTL design and testbench for a low-pass FIR filter. The design focuses on maintaining signal integrity by managing bit growth during the Multiply-Accumulate (MAC) stages to avoid truncation errors.

### Key Features
Order-20 Filter: 20 symmetric tap coefficients for efficient frequency response.

High Precision: Uses 32-bit signed input data and 64-bit internal accumulators to prevent overflow.

AXI-Stream Interface: Standard s_axis and m_axis handshaking for easy integration with Xilinx IP blocks or Zynq systems.

Fixed-Point Scaling: Implements arithmetic right-shifting to normalize the filtered output.

## Technical Specifications
Parameter	Specification
Language	Verilog HDL
Input Data Width	32-bit Signed
Output Data Width	32-bit Signed
Internal Precision	64-bit Accumulators
Interface	AXI4-Stream
Clock Frequency	100 MHz
## Design Architecture
The filter is implemented using a Transpose Direct Form structure.

Shift Buffer: A 20-stage deep register chain to store incoming 32-bit samples.

MAC Stage: Parallel multiplication of samples with 32-bit coefficients into 64-bit registers.

Summation & Scaling: The 64-bit sum is arithmetically right-shifted (by 28 bits) to map the result back to a 32-bit range, ensuring a smooth analog waveform output.

## Simulation Results
The design was verified using Vivado Simulator (XSIM). The testbench generates a sinusoidal signal to demonstrate the filter's behavior.

### Waveform Verification
Input: 32-bit signed sinusoid.

Output: Filtered 32-bit signed sinusoid.

****Note: To view the output properly in Vivado, set the m_axis_fir_tdata waveform style to Analog and the Radix to Signed Decimal.
