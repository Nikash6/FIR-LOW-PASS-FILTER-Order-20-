
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S Nikash Kalyan Kumar
// 
// Create Date: 10.05.2026 21:37:35
// Design Name: Testbench
// Module Name: test20tap
// Project Name: Firfilter order-20 
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

module tb_FIR;

    reg clk, reset, s_axis_fir_tvalid, m_axis_fir_tready;
    reg signed [31:0] s_axis_fir_tdata; // Explicit 32-bit width
    wire m_axis_fir_tvalid;
    wire [3:0] m_axis_fir_tkeep;
    wire signed [31:0] m_axis_fir_tdata;
    
    // Clock Generation
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end
    
    // Reset Sequence
    initial begin
        reset = 0; #50;
        reset = 1; 
    end
    
    // Handshake Control
    initial begin
        s_axis_fir_tvalid = 1;
        m_axis_fir_tready = 1;
    end

    // Instantiate FIR module
    FIR FIR_i(
        .clk(clk),
        .reset(reset),
        .s_axis_fir_tdata(s_axis_fir_tdata),   
        .s_axis_fir_tvalid(s_axis_fir_tvalid), 
        .m_axis_fir_tready(m_axis_fir_tready),
        .m_axis_fir_tvalid(m_axis_fir_tvalid), 
        .m_axis_fir_tkeep(m_axis_fir_tkeep),   
        .m_axis_fir_tdata(m_axis_fir_tdata)
    );
        
    reg [2:0] state_reg;
    reg [3:0] cntr;
    parameter wvfm_period = 4'd4;
    
    // State machine generating a full 32-bit range Sinusoid
    always @ (posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            cntr <= 4'd0;
            s_axis_fir_tdata <= 32'd0;
            state_reg <= 3'd0;
        end else begin
            case (state_reg)
                0: begin // 0 degrees
                    s_axis_fir_tdata <= 32'h00000000;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 1; end
                    else cntr <= cntr + 1;
                end
                1: begin // 45 degrees
                    s_axis_fir_tdata <= 32'h5A827999; 
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 2; end
                    else cntr <= cntr + 1;
                end
                2: begin // 90 degrees
                    s_axis_fir_tdata <= 32'h7FFFFFFF;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 3; end
                    else cntr <= cntr + 1;
                end
                3: begin // 135 degrees
                    s_axis_fir_tdata <= 32'h5A827999;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 4; end
                    else cntr <= cntr + 1;
                end
                4: begin // 180 degrees
                    s_axis_fir_tdata <= 32'h00000000;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 5; end
                    else cntr <= cntr + 1;
                end
                5: begin // 225 degrees
                    s_axis_fir_tdata <= 32'hA57D8666;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 6; end
                    else cntr <= cntr + 1;
                end
                6: begin // 270 degrees
                    s_axis_fir_tdata <= 32'h80000001;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 7; end
                    else cntr <= cntr + 1;
                end
                7: begin // 315 degrees
                    s_axis_fir_tdata <= 32'hA57D8666;
                    if (cntr == wvfm_period) begin cntr <= 0; state_reg <= 0; end
                    else cntr <= cntr + 1;
                end
            endcase
        end
    end
endmodule
