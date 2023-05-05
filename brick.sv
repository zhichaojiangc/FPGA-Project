module brick_block (
	 input logic vga_clk,
    input [9:0] wall_x, wall_y, wall_size, DrawX, DrawY, 
    output logic [7:0] Red_b, Green_b, Blue_b,
	 output logic brick_on
);


// logic for one brick
logic [3:0] rom_q_brick;
//    parameter [9:0] wall_x=18; // Wall x-coordinates
//    parameter [9:0] wall_y=18; // Wall y-coordinates
	 
assign rom_address_brick = (((DrawX - (wall_x - wall_size)) * 36) / (2 * wall_size)) + ((((DrawY - (wall_y - wall_size)) * 36) / (2 * wall_size)) * 36);

always_comb
    begin:brick_on_proc
        if ((DrawX >= wall_x - wall_size) &&
            (DrawX <= wall_x + wall_size) &&
            (DrawY >= wall_y - wall_size) &&
            (DrawY <= wall_y + wall_size))
            brick_on = 1'b1;
        else 
            brick_on = 1'b0;
     end


//Instantiate bricks map
Battle_City_bricks_rom brick_r(
    .clock   (vga_clk),
    .address (rom_address_brick),
    .q       (rom_q_brick)
);

Battle_City_bricks_palette brick_p (
    .index (rom_q_brick),
    .red   (Red_b),
    .green (Green_b),
    .blue  (Blue_b)
);
endmodule 