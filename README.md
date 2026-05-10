# FIR-LOW-PASS-FILTER-Order-20-
Fir low pass filter of order 20 in verilog 
20-Tap Digital FIR Filter in Verilog
A high-precision, 20-tap Finite Impulse Response (FIR) filter designed in Verilog for FPGA implementation. This project demonstrates fixed-point arithmetic, AXI-Stream interface compliance, and hardware-efficient signal processing.

## Project Overview
This repository contains the RTL design and testbench for a low-pass FIR filter. The design focuses on maintaining signal integrity by managing bit growth during the Multiply-Accumulate (MAC) stages to avoid truncation errors.

PASS Band frequency (Fp) = 200 Hz and Sampling Frequency (f) = 1000 hz
## Mathematical Foundation### Transfer FunctionThe filter coefficients are derived from the following Z-domain transfer function
The specific fractional coefficients (e.g., $b_{10} = 0.3723$, $b_{11} = 0.1915$) were generated using the Hamming Window method to minimize sidelobe levels.### Fixed-Point QuantizationTo implement these on hardware, the fractional coefficients were scaled to 32-bit integers using a quantization factor of This ensures that the hardware can perform high-speed integer multiplications while maintaining the precision of the original filter response.
Usually, you have to decide how many bits in the register you want to dedicate to the integer part of the number vs the fractional part of the number. Therefore the math to convert the fractional value taps is:(fractional coefficient value)*(2^(20))
Where any decimal value of this product is rounded off and the two's compliment of the value is calculated if the coefficient is negative:
tap0 = twos(-0.0016 * 1048576) = 0x0000F973
tap1 = twos(-0.0037 * 2^20) = 0x0000F0D9
tap2 = (0.0135 * 2^20) = 0x00000068
.
.
.
.
.
.
.
tap19=......
Transfer function 'ha' from input 'u1' to output ...

 y1:  -0.001643 z^19 - 0.003716 z^18 + 0.0001734 z^17 + 0.01356 z^16 + 0.01423 z^15 - 0.02456 z^14 - 0.06267 z^13 + 0.0008343 z^12 + 0.1915 z^11 + 0.3723 z^10
 + 0.3723 z^9 + 0.1915 z^8 + 0.0008343 z^7 - 0.06267 z^6 - 0.02456 z^5 + 0.01423 z^4 + 0.01356 z^3 + 0.0001734 z^2 - 0.003716 z - 0.001643



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
Right-click m_axis_fir_tdata -->rightarrow Radix -->rightarrow Signed Decimal.

Right-click m_axis_fir_tdata -->rightarrow Waveform Style -->rightarrow$ Analog.

Right-click --> rightarrow--> Analog Settings -->rightarrow Ensure Auto-scale is selected.

### Waveform Verification
Input: 32-bit signed sinusoid.

Output: Filtered 32-bit signed sinusoid.

****Note: To view the output properly in Vivado, set the m_axis_fir_tdata waveform style to Analog and the Radix to Signed Decimal.
