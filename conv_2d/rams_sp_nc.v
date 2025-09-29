module rams_sp_nc (
    input         clk,
    input         we,
    input         en,
    input  [7:0]  addr,
    input  [31:0] di,
    output reg [31:0] dout
);

reg [31:0] RAM [255:0];

// reg [31:0] dout;			had to remove this. 

always @(posedge clk)
begin
	if (en)
	begin
		if (we)
			RAM[addr] <= di;
		else
			dout <= RAM [addr];
	end
end
endmodule