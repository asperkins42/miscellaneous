`timescale 1ns / 1ps

module tb_conv2d;
  reg clk=0; always #5 clk = ~clk; // 100 MHz
  reg reset=1;
  reg start=0;

  // Scratchpad wires
  wire [31:0] a_dout, b_dout, c_dout;
  wire        a_en, b_en, c_en;
  wire        a_we, b_we, c_we;
  wire [7:0]  a_addr, b_addr, c_addr;
  wire [31:0] a_di, b_di, c_di;

  // Control
  reg  [7:0] base_a=0, base_b=0, base_c=0;
  reg  [4:0] tile_w=5, tile_h=5; // 5x5 input
  wire busy, done;

  // Scratchpads
  rams_sp_nc A(.clk(clk), .we(a_we), .en(a_en), .addr(a_addr), .di(a_di), .dout(a_dout));
  rams_sp_nc B(.clk(clk), .we(b_we), .en(b_en), .addr(b_addr), .di(b_di), .dout(b_dout));
  rams_sp_nc C(.clk(clk), .we(c_we), .en(c_en), .addr(c_addr), .di(c_di), .dout(c_dout));

  // DUT
  conv2d_3x3_lb dut (
    .clk(clk), .reset(reset),
    .start(start), .base_a(base_a), .base_b(base_b), .base_c(base_c),
    .tile_w(tile_w), .tile_h(tile_h),
    .busy(busy), .done(done),
    .a_en(a_en), .a_we(a_we), .a_addr(a_addr), .a_di(a_di), .a_dout(a_dout),
    .b_en(b_en), .b_we(b_we), .b_addr(b_addr), .b_di(b_di), .b_dout(b_dout),
    .c_en(c_en), .c_we(c_we), .c_addr(c_addr), .c_di(c_di), .c_dout(c_dout)
  );

  // Optional: nicer timestamps
  initial $timeformat(-9,0," ns",10);

  // Monitor every write into C during the run
  always @(posedge clk) begin
    if (c_en && c_we)
      $display("[%0t] C WRITE  addr=%0d  idx=%0d  val=%0d",
               $time, c_addr, (c_addr - base_c), c_di);
  end

  // ---- Init & run (pure Verilog, no fork/join_any) ----
  integer i;
  integer cycles;

  initial begin
    // Preload A with 0..24 (row-major 5x5)
    for (i=0; i<25; i=i+1) A.RAM[i] = i[31:0];

    // Preload B with all 1s (3x3 kernel)
    for (i=0; i<9; i=i+1)  B.RAM[i] = 32'd0;
    B.RAM[0] = 32'd1;

    // Hold reset a few cycles
    repeat (5) @(posedge clk);
    reset <= 0;

    // Kick it
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;

    // Wait for done with a simple cycle timeout
    cycles = 0;
    while (!done && cycles < 2000) begin
      @(posedge clk);
      cycles = cycles + 1;
    end

    if (!done) begin
      $display("** TIMEOUT @ %0t ** dumping C anyway", $time);
      dump_c_matrix();
    end else begin
      $display("Convolution complete @ %0t", $time);
      dump_c_matrix();
    end

    $finish;
  end

  // ---- Helpers ----
  task dump_c_matrix;
    integer OW, OH, oy, ox;
    begin
      OW = (tile_w >= 3) ? (tile_w - 2) : 0;
      OH = (tile_h >= 3) ? (tile_h - 2) : 0;

      $display("C matrix (%0dx%0d) at base_c=%0d:", OH, OW, base_c);
      for (oy = 0; oy < OH; oy = oy + 1) begin
        $write("row %0d : ", oy);
        for (ox = 0; ox < OW; ox = ox + 1) begin
          $write("%0d ", C.RAM[base_c + oy*OW + ox]);
        end
        $write("\n");
      end
      $writememh("C_dump.hex", C.RAM);
      $display("C written to C_dump.hex");
    end
  endtask

endmodule
