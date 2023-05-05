module ball_game ( input Reset, frame_clk, top_is_background_color,bottom_is_background_color,left_is_background_color,right_is_background_color,
						 top_is_background_color_2,bottom_is_background_color_2,left_is_background_color_2,right_is_background_color_2,
                   input Bullet1_Tank2_intersect, Bullet2_Tank1_intersect,
						 input bullet_background,bullet_background2,
						 input [7:0] keycode,keycode2,
                   output [9:0] Tank1X, Tank1Y, Tank1S,
                   output [9:0] Bullet1X, Bullet1Y, Bullet1S,
                   output reg [1:0] Tank1Direction,
                   output [9:0] Tank2X, Tank2Y, Tank2S,
                   output [9:0] Bullet2X, Bullet2Y, Bullet2S,
                   output reg [1:0] Tank2Direction
                 );

    // Instantiate the first ball module
    ball tank1 ( .Reset(Reset), .frame_clk(frame_clk), .keycode(keycode),
						.top_is_background_color(top_is_background_color),
						.bottom_is_background_color(bottom_is_background_color),
						.left_is_background_color(left_is_background_color),
						.right_is_background_color(right_is_background_color),
                 .TankX(Tank1X), .TankY(Tank1Y), .TankS(Tank1S),
                 .BulletX(Bullet1X), .BulletY(Bullet1Y), .BulletS(Bullet1S),
                 .TankDirection(Tank1Direction), .Bullet2_Tank1_intersect(Bullet2_Tank1_intersect),
					  .bullet_background(bullet_background)
               );

    // Instantiate the second ball module
    ball2 tank2 ( .Reset(Reset), .frame_clk(frame_clk), .keycode(keycode2),
						.top_is_background_color(top_is_background_color_2),
						.bottom_is_background_color(bottom_is_background_color_2),
						.left_is_background_color(left_is_background_color_2),
						.right_is_background_color(right_is_background_color_2),
                 .TankX(Tank2X), .TankY(Tank2Y), .TankS(Tank2S),
                 .BulletX(Bullet2X), .BulletY(Bullet2Y), .BulletS(Bullet2S),
                 .TankDirection(Tank2Direction), .Bullet1_Tank2_intersect(Bullet1_Tank2_intersect),
					  .bullet_background2(bullet_background2)
               );



endmodule
