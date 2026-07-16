
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S Nikash kalyan kumar
// 
// Create Date: 10.05.2026 21:36:05
// Design Name: RTL code
// Module Name: firflt20tap
// Project Name: filrfilter  order 20
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module FIR(
    input clk,
    input reset,
    input signed [31:0] s_axis_fir_tdata, 
    input [3:0] s_axis_fir_tkeep,
    input s_axis_fir_tlast,
    input s_axis_fir_tvalid,
    input m_axis_fir_tready,
    output reg m_axis_fir_tvalid,
    output reg s_axis_fir_tready,
    output reg m_axis_fir_tlast,
    output reg [3:0] m_axis_fir_tkeep,
    output reg signed [31:0] m_axis_fir_tdata 
    );

    // Internal Control Signals
    reg enable_fir, enable_buff;
    reg [4:0] buff_cnt; 
    reg signed [31:0] in_sample; 
    
    // 20-tap Buffer
    reg signed [31:0] buff0, buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8, buff9, 
                      buff10, buff11, buff12, buff13, buff14, buff15, buff16, buff17, buff18, buff19; 
    
    // Taps (Constants)
    wire signed [31:0] tap0, tap1, tap2, tap3, tap4, tap5, tap6, tap7, tap8, tap9, 
                       tap10, tap11, tap12, tap13, tap14, tap15, tap16, tap17, tap18, tap19; 
    
    // CRITICAL FIX: Multiplication Accumulators expanded to 64 bits
    reg signed [63:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, 
                      acc10, acc11, acc12, acc13, acc14, acc15, acc16, acc17, acc18, acc19; 

    // Tap Coefficients (Fixed Point)
    assign tap0 = 32'h0000F973; assign tap1 = 32'h0000F0D9; assign tap2 = 32'h00000068;
    assign tap3 = 32'h0000374B; assign tap4 = 32'h00003A29; assign tap5 = 32'h00009BA6;
    assign tap6 = 32'hFFFEFF98; assign tap7 = 32'h00000346; assign tap8 = 32'h00031062;
    assign tap9 = 32'h0005F4F0; assign tap10 = 32'h0005F4F0; assign tap11 = 32'h00031062;
    assign tap12 = 32'h00000346; assign tap13 = 32'hFFFEFF98; assign tap14 = 32'h00009BA6;
    assign tap15 = 32'h00003A29; assign tap16 = 32'h0000374B; assign tap17 = 32'h00000068;
    assign tap18 = 32'h0000F0D9; assign tap19 = 32'h0000F973;

    // AXI Control Path
    always @ (posedge clk) begin
        if (reset == 1'b0) begin
            m_axis_fir_tkeep <= 4'h0;
            m_axis_fir_tlast <= 1'b0;
            s_axis_fir_tready <= 1'b0;
            m_axis_fir_tvalid <= 1'b0;
            enable_buff <= 1'b0;
        end else begin
            m_axis_fir_tkeep <= 4'hf;
            m_axis_fir_tlast <= s_axis_fir_tlast;
            s_axis_fir_tready <= m_axis_fir_tready;
            m_axis_fir_tvalid <= s_axis_fir_tvalid;
            enable_buff <= s_axis_fir_tvalid && m_axis_fir_tready;
        end
    end

    // Buffer Counter and Data Capture
    always @ (posedge clk) begin
        if (reset == 1'b0) begin
            buff_cnt <= 5'd0;
            enable_fir <= 1'b0;
            in_sample <= 32'd0;
        end else if (s_axis_fir_tvalid && m_axis_fir_tready) begin
            in_sample <= s_axis_fir_tdata;
            if (buff_cnt == 5'd19) begin 
                enable_fir <= 1'b1;
            end else begin
                buff_cnt <= buff_cnt + 1;
            end
        end
    end   

    // Shift Buffer Logic
    always @ (posedge clk) begin
        if (reset == 1'b0) begin
            {buff0, buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8, buff9, 
             buff10, buff11, buff12, buff13, buff14, buff15, buff16, buff17, buff18, buff19} <= 0;
        end else if (enable_buff) begin
            buff0  <= in_sample;
            buff1  <= buff0;  buff2  <= buff1;  buff3  <= buff2;
            buff4  <= buff3;  buff5  <= buff4;  buff6  <= buff5;
            buff7  <= buff6;  buff8  <= buff7;  buff9  <= buff8;
            buff10 <= buff9;  buff11 <= buff10; buff12 <= buff11;
            buff13 <= buff12; buff14 <= buff13; buff15 <= buff14;
            buff16 <= buff15; buff17 <= buff16; buff18 <= buff17;
            buff19 <= buff18; 
        end
    end
        
    // Multiply & Accumulate Stage
    always @ (posedge clk) begin
        if (reset == 1'b0) begin
            m_axis_fir_tdata <= 32'd0;
        end else if (enable_fir) begin
            // Math performed at 64-bit precision to prevent clipping
            acc0 <= tap0 * buff0;   acc1 <= tap1 * buff1;   acc2 <= tap2 * buff2;
            acc3 <= tap3 * buff3;   acc4 <= tap4 * buff4;   acc5 <= tap5 * buff5;
            acc6 <= tap6 * buff6;   acc7 <= tap7 * buff7;   acc8 <= tap8 * buff8;
            acc9 <= tap9 * buff9;   acc10 <= tap10 * buff10; acc11 <= tap11 * buff11;
            acc12 <= tap12 * buff12; acc13 <= tap13 * buff13; acc14 <= tap14 * buff14;
            acc15 <= tap15 * buff15; acc16 <= tap16 * buff16; acc17 <= tap17 * buff17;
            acc18 <= tap18 * buff18; acc19 <= tap19 * buff19;

            // Shift down by 16 bits to bring the 64-bit result into 32-bit viewing range
            m_axis_fir_tdata <= (acc0 + acc1 + acc2 + acc3 + acc4 + acc5 + acc6 + acc7 + acc8 + acc9 + 
                     acc10 + acc11 + acc12 + acc13 + acc14 + acc15 + acc16 + acc17 + acc18 + acc19) >>> 28;
        end
    end    
endmodule
