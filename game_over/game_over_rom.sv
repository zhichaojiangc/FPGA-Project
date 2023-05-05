module game_over_rom (
	input logic clock,
	input logic [17:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:219023] /* synthesis ram_init_file = "./game_over/game_over.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
