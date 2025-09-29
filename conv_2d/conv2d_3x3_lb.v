`timescale 1ns/1ps

module conv2d_3x3_lb #(
    parameter MAX_W = 16
)(
    input         clk,
    input         reset,

    // Control
    input         start,
    input  [7:0]  base_a,
    input  [7:0]  base_b,
    input  [7:0]  base_c,
    input  [4:0]  tile_w,   // <=16
    input  [4:0]  tile_h,   // <=16
    output reg    busy,
    output reg    done,

    // Scratchpad A (input, read-only)
    output reg        a_en,
    output            a_we,         // tied off
    output reg  [7:0] a_addr,
    output      [31:0] a_di,        // tied off
    input       [31:0] a_dout,

    // Scratchpad B (kernel, read-only)
    output reg        b_en,
    output            b_we,         // tied off
    output reg  [7:0] b_addr,
    output      [31:0] b_di,        // tied off
    input       [31:0] b_dout,

    // Scratchpad C (output, write-only during compute)
    output reg        c_en,
    output reg        c_we,
    output reg  [7:0] c_addr,
    output reg [31:0] c_di,
    input       [31:0] c_dout       // unused
);

    // Tie-offs (A/B write ports unused)
    assign a_we = 1'b0;
    assign b_we = 1'b0;
    assign a_di = 32'd0;
    assign b_di = 32'd0;

    // FSM
    localparam S_IDLE    = 0,
               S_LOADK_A = 1,
               S_LOADK_C = 2,
               S_STREAM  = 3,
               S_DONE    = 4;

    reg [2:0] state;

    // Kernel regs
    reg signed [31:0] k00, k01, k02,
                      k10, k11, k12,
                      k20, k21, k22;
    reg [3:0] k_idx; // 0..8

    // Line buffers (two previous rows)
    reg signed [31:0] LB0 [0:MAX_W-1];  // row y-2
    reg signed [31:0] LB1 [0:MAX_W-1];  // row y-1

    // Sliding window regs (current window)
    reg signed [31:0] w0_0, w0_1, w0_2;
    reg signed [31:0] w1_0, w1_1, w1_2;
    reg signed [31:0] w2_0, w2_1, w2_2;

    // Raster coords
    reg [4:0] x, y;      // issue coordinates
    reg [4:0] x_d, y_d;  // arrival coordinates (1-cycle behind a_en)

    // Output dims
    wire [4:0] out_w = (tile_w >= 3) ? (tile_w - 2) : 5'd0;
    wire [4:0] out_h = (tile_h >= 3) ? (tile_h - 2) : 5'd0;

    // Address math
    wire [7:0] addr_a_calc = base_a + (y * tile_w + x);
    wire [7:0] addr_c_calc = base_c + ((y_d - 2) * out_w + (x_d - 2));

    // Streaming control
    reg a_en_q;             // last a_en
    reg a_valid;            // a_dout valid (=a_en_q)
    reg issued_last;        // last input issued
    reg last_arrived;       // last input arrived

    // One-entry *data+addr* queue (computed from NEXT window)
    reg        emit_pending;
    reg [7:0]  emit_addr_hold;
    reg [31:0] emit_val_hold;

    integer i;

    // ------------- sequential -------------
    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            busy  <= 1'b0;
            done  <= 1'b0;

            a_en <= 1'b0; a_addr <= 8'd0;
            b_en <= 1'b0; b_addr <= 8'd0;
            c_en <= 1'b0; c_we   <= 1'b0; c_addr <= 8'd0; c_di <= 32'd0;

            x <= 0; y <= 0; x_d <= 0; y_d <= 0;
            k_idx <= 0;

            w0_0 <= 0; w0_1 <= 0; w0_2 <= 0;
            w1_0 <= 0; w1_1 <= 0; w1_2 <= 0;
            w2_0 <= 0; w2_1 <= 0; w2_2 <= 0;

            a_en_q <= 1'b0;
            a_valid <= 1'b0;
            issued_last <= 1'b0;
            last_arrived <= 1'b0;

            emit_pending <= 1'b0;
            emit_addr_hold <= 8'd0;
            emit_val_hold  <= 32'd0;

            for (i=0; i<MAX_W; i=i+1) begin
                LB0[i] <= 32'd0;
                LB1[i] <= 32'd0;
            end
        end else begin
            // defaults
            a_en <= 1'b0;
            b_en <= 1'b0;
            c_en <= 1'b0;
            c_we <= 1'b0;

            case (state)
            // --------------------------
            S_IDLE: begin
                done <= 1'b0;
                if (start) begin
                    busy   <= 1'b1;
                    // start kernel load
                    k_idx  <= 4'd0;
                    b_en   <= 1'b1;
                    b_addr <= base_b;
                    state  <= S_LOADK_A;

                    // clear stream book-keeping
                    x <= 0; y <= 0; x_d <= 0; y_d <= 0;
                    a_en_q <= 1'b0; a_valid <= 1'b0;
                    issued_last <= 1'b0; last_arrived <= 1'b0;
                    emit_pending <= 1'b0;
                end
            end

            // --------------------------
            S_LOADK_A: begin
                b_en  <= 1'b1;
                state <= S_LOADK_C;   // capture next cycle
            end

            // --------------------------
            S_LOADK_C: begin
                b_en <= 1'b1;
                case (k_idx)
                    4'd0: k00 <= b_dout; 4'd1: k01 <= b_dout; 4'd2: k02 <= b_dout;
                    4'd3: k10 <= b_dout; 4'd4: k11 <= b_dout; 4'd5: k12 <= b_dout;
                    4'd6: k20 <= b_dout; 4'd7: k21 <= b_dout; 4'd8: k22 <= b_dout;
                endcase
                if (k_idx == 4'd8) begin
                    state <= S_STREAM;
                end else begin
                    k_idx  <= k_idx + 1'b1;
                    b_en   <= 1'b1;
                    b_addr <= base_b + (k_idx + 1'b1);
                    state  <= S_LOADK_A;
                end
            end

            // --------------------------
            S_STREAM: begin
                // (A) Flush any queued write from the window computed last cycle
                if (emit_pending) begin
                    c_en   <= 1'b1;
                    c_we   <= 1'b1;
                    c_addr <= emit_addr_hold;
                    c_di   <= emit_val_hold;
                    emit_pending <= 1'b0;
                end

                // (B) Issue next input pixel (unless already issued the last)
                if (!issued_last) begin
                    a_en   <= 1'b1;
                    a_addr <= addr_a_calc;
                    if ((x == tile_w-1) && (y == tile_h-1))
                        issued_last <= 1'b1; // last issue
                end

                // advance issue coords
                if (x + 1 < tile_w) begin
                    x <= x + 1'b1;
                end else begin
                    x <= 0;
                    if (y + 1 < tile_h) y <= y + 1'b1;
                end

                // (C) Track arrival validity
                a_valid <= a_en_q;
                a_en_q  <= a_en;

                // (D) On arrival: compute NEXT window and its dot product, then register window
                if (a_valid) begin
                    // hold current arrival coords for logic below
                    // (RHS uses pre-update values thanks to non-blocking semantics)

                    // advance arrival coords for next cycle
                    if (x_d + 1 < tile_w) begin
                        x_d <= x_d + 1'b1;
                    end else begin
                        x_d <= 0;
                        if (y_d + 1 < tile_h) y_d <= y_d + 1'b1;
                    end

                    if (y_d == 0) begin
                        // first row
                        LB1[x_d] <= a_dout;
                    end else if (y_d == 1) begin
                        // second row
                        LB0[x_d] <= LB1[x_d];
                        LB1[x_d] <= a_dout;
                    end else begin
                        // y_d >= 2 ---- compute NEXT window from current regs + new column
                        // Right column that will enter next window:
                        //   top = LB0[x_d], mid = LB1[x_d], bot = a_dout
                        // Build next-window values (combinationally)
                        // top row
                        //   n_w0_0 = w0_1; n_w0_1 = w0_2; n_w0_2 = LB0[x_d];
                        // mid row
                        //   n_w1_0 = w1_1; n_w1_1 = w1_2; n_w1_2 = LB1[x_d];
                        // bot row
                        //   n_w2_0 = w2_1; n_w2_1 = w2_2; n_w2_2 = a_dout;

                        // Compute the dot-product for that next window (acc_next)
                        // Note: use signed math like main datapath
                        // Top partial
                        begin : BUILD_AND_QUEUE
                            reg signed [31:0] n_w0_0, n_w0_1, n_w0_2;
                            reg signed [31:0] n_w1_0, n_w1_1, n_w1_2;
                            reg signed [31:0] n_w2_0, n_w2_1, n_w2_2;
                            reg signed [63:0] s0, s1, s2, acc_next;

                            n_w0_0 = w0_1;  n_w0_1 = w0_2;  n_w0_2 = LB0[x_d];
                            n_w1_0 = w1_1;  n_w1_1 = w1_2;  n_w1_2 = LB1[x_d];
                            n_w2_0 = w2_1;  n_w2_1 = w2_2;  n_w2_2 = a_dout;

                            s0 = $signed(w0_0)*$signed(k00) +
                                 $signed(w0_1)*$signed(k01) +
                                 $signed(w0_2)*$signed(k02);
                            s1 = $signed(w1_0)*$signed(k10) +
                                 $signed(w1_1)*$signed(k11) +
                                 $signed(w1_2)*$signed(k12);
                            s2 = $signed(w2_0)*$signed(k20) +
                                 $signed(w2_1)*$signed(k21) +
                                 $signed(w2_2)*$signed(k22);
                            acc_next = s0 + s1 + s2;

                            // Queue write for NEXT cycle once horizontally valid
                            if ((x_d >= 5'd2) && (y_d >= 5'd2)) begin
                                emit_pending   <= 1'b1;
                                emit_addr_hold <= addr_c_calc; // (oy=y_d-2, ox=x_d-2)
                                emit_val_hold  <= acc_next[31:0]; // truncation
                                $display("[%0t] QUEUE C  ox=%0d oy=%0d  addr=%0d  val=%0d",
                                $time, x_d-2, y_d-2, addr_c_calc, acc_next[31:0]);
                            end

                            // advance to next window
                            w0_0 <= n_w0_0;  w0_1 <= n_w0_1;  w0_2 <= n_w0_2;
                            w1_0 <= n_w1_0;  w1_1 <= n_w1_1;  w1_2 <= n_w1_2;
                            w2_0 <= n_w2_0;  w2_1 <= n_w2_1;  w2_2 <= n_w2_2;
                        end

                        // Update line buffers for future rows
                        LB0[x_d] <= LB1[x_d];
                        LB1[x_d] <= a_dout;
                    end

                    // mark last arrival
                    if ((x_d == tile_w-1) && (y_d == tile_h-1))
                        last_arrived <= 1'b1;
                end

                // Exit when the last pixel has arrived AND we've flushed the last queued write
                if (last_arrived && !emit_pending) begin
                    state <= S_DONE;
                end
            end

            // --------------------------
            S_DONE: begin
                busy <= 1'b0;
                done <= 1'b1;
                if (!start) state <= S_IDLE;
            end

            default: state <= S_IDLE;
            endcase
        end
    end

endmodule
