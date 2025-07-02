module Cfu (
    input cmd_valid,
    output cmd_ready,
    input [9:0] cmd_payload_function_id,
    input [31:0] cmd_payload_inputs_0,
    input [31:0] cmd_payload_inputs_1,
    output reg rsp_valid,
    input rsp_ready,
    output reg [31:0] rsp_payload_outputs_0,
    input reset,
    input clk
);

wire signed [15:0] prod_0, prod_1, prod_2, prod_3;
assign prod_0 = $signed({1'b0, cmd_payload_inputs_0[7:0]}) * $signed({1'b0, cmd_payload_inputs_1[7:0]});
assign prod_1 = $signed({1'b0, cmd_payload_inputs_0[15:8]}) * $signed({1'b0, cmd_payload_inputs_1[15:8]});
assign prod_2 = $signed({1'b0, cmd_payload_inputs_0[23:16]}) * $signed({1'b0, cmd_payload_inputs_1[23:16]});
assign prod_3 = $signed({1'b0, cmd_payload_inputs_0[31:24]}) * $signed({1'b0, cmd_payload_inputs_1[31:24]});

wire signed [31:0] sum_prods = prod_0 + prod_1 + prod_2 + prod_3;

assign cmd_ready = ~rsp_valid;

always @(posedge clk) begin
    if (reset) begin
        rsp_valid <= 1'b0;
        rsp_payload_outputs_0 <= 32'b0;
    end else if (rsp_valid) begin
        rsp_valid <= ~rsp_ready;
    end else if (cmd_valid) begin
        rsp_valid <= 1'b1;
        rsp_payload_outputs_0 <= sum_prods;
    end
end

endmodule
