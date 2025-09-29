`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2025 08:42:03 PM
// Design Name: 
// Module Name: top_conv
// Project Name: 
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

// File: top_conv.v
// Minimal synthesizable wrapper around conv2d_3x3_lb + 3 scratchpads.
// - Exposes a simple control/handshake: clk, reset, start, tile size, bases, busy/done.
// - Scratchpads are *internal* for now (no external memory bus).
// - Later you can replace/bridge A/B/C to AXI or a CSR bus.

module top_conv (
    input         clk,
    input         reset,       // active-high
    input         start,       // pulse to begin a run

    // Control (software/CFU can eventually drive these)
    input  [7:0]  base_a,      // base addr in A for input tile
    input  [7:0]  base_b,      // base addr in B for 3x3 kernel (9 words)
    input  [7:0]  base_c,      // base addr in C for output tile
    input  [4:0]  tile_w,      // <=16
    input  [4:0]  tile_h,      // <=16

    output        busy,
    output        done

    // (optional) debug ports could be added here
);

    // --------------------------
    // Scratchpad A (input)
    // --------------------------
    wire        a_en;
    wire        a_we;
    wire [7:0]  a_addr;
    wire [31:0] a_di;
    wire [31:0] a_dout;

    rams_sp_nc spm_a (
        .clk (clk),
        .we  (a_we),     // driven 0 by conv engine
        .en  (a_en),
        .addr(a_addr),
        .di  (a_di),     // 0
        .dout(a_dout)
    );

    // --------------------------
    // Scratchpad B (kernel, 9 words)
    // --------------------------
    wire        b_en;
    wire        b_we;
    wire [7:0]  b_addr;
    wire [31:0] b_di;
    wire [31:0] b_dout;

    rams_sp_nc spm_b (
        .clk (clk),
        .we  (b_we),     // driven 0 by conv engine
        .en  (b_en),
        .addr(b_addr),
        .di  (b_di),     // 0
        .dout(b_dout)
    );

    // --------------------------
    // Scratchpad C (output)
    // --------------------------
    wire        c_en;
    wire        c_we;
    wire [7:0]  c_addr;
    wire [31:0] c_di;
    wire [31:0] c_dout;

    rams_sp_nc spm_c (
        .clk (clk),
        .we  (c_we),     // writes from conv engine
        .en  (c_en),
        .addr(c_addr),
        .di  (c_di),
        .dout(c_dout)    // unused here
    );

    // --------------------------
    // Convolution engine
    // --------------------------
    conv2d_3x3_lb #(.MAX_W(16)) u_conv (
        .clk    (clk),
        .reset  (reset),

        .start  (start),
        .base_a (base_a),
        .base_b (base_b),
        .base_c (base_c),
        .tile_w (tile_w),
        .tile_h (tile_h),
        .busy   (busy),
        .done   (done),

        // A
        .a_en   (a_en),
        .a_we   (a_we),
        .a_addr (a_addr),
        .a_di   (a_di),
        .a_dout (a_dout),

        // B
        .b_en   (b_en),
        .b_we   (b_we),
        .b_addr (b_addr),
        .b_di   (b_di),
        .b_dout (b_dout),

        // C
        .c_en   (c_en),
        .c_we   (c_we),
        .c_addr (c_addr),
        .c_di   (c_di),
        .c_dout (c_dout)
    );

endmodule
