module blast8_rom (
	input logic clock,
	input logic [10:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:1295] /* synthesis ram_init_file = "./blast8/blast8.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
