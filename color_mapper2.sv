module color_mapper2 (
    input [9:0] Tank1X, Tank1Y, Tank2X, Tank2Y, DrawX, DrawY, 
    input [9:0] Tank_size, Bullet1X, Bullet1Y, Bullet2X, Bullet2Y, Bullet_size,
    input [1:0] Tank1Direction, Tank2Direction, // Add Tank2Direction input
    input logic vga_clk, blank,
	 input [7:0] keycode,
    output logic [7:0] Red, Green, Blue,
    output logic top_is_background_color,bottom_is_background_color,left_is_background_color,right_is_background_color,
    output logic top_is_background_color_2,bottom_is_background_color_2,left_is_background_color_2,right_is_background_color_2,
	output logic Bullet2_Tank1_intersect, Bullet1_Tank2_intersect,
	output logic bullet_background, bullet_background2

);

//state machine logic
localparam IDLE = 2'b00;
localparam RUNNING = 2'b01;
localparam RESET = 2'b10;
logic [1:0] currentState;
logic EnterKeyPressed;

always_ff @(posedge vga_clk) begin
	case (keycode)
	8'h28 : EnterKeyPressed<=1'b1;
	endcase
		
    case (currentState)
        IDLE: begin
            if (EnterKeyPressed) begin
                currentState <= RUNNING;
            end
        end
        RUNNING: begin
            if (bullet1_star_intersect || bullet2_star_intersect) begin
                currentState <= RESET;
            end
        end
        RESET: begin
            if (EnterKeyPressed) begin
                currentState <= RUNNING;
            end
            else begin
                currentState <= IDLE;
            end
        end
    endcase
end


	logic [7:0] red_brick1;
	logic [7:0] green_brick1;
	logic [7:0] blue_brick1;

	//collision check

	always_comb
	begin:Bullet2_Tank1_intersect_proc
    if  (((Bullet2X + Bullet_size) > (Tank1X-Tank_size )) &&
        ((Bullet2X - Bullet_size) < (Tank_size + Tank1X))&&
		  ((Bullet2Y + Bullet_size) > (Tank1Y-Tank_size))&&
		  ((Bullet2Y - Bullet_size) < (Tank_size + Tank1Y))) begin
        Bullet2_Tank1_intersect = 1'b1;
   end else
        Bullet2_Tank1_intersect = 1'b0;
	end
	
	always_comb
	begin:Bullet1_Tank2_intersect_proc
    if (((Bullet1X + Bullet_size) > (Tank2X-Tank_size )) &&
        ((Bullet1X - Bullet_size) < (Tank_size + Tank2X))&&
		  ((Bullet1Y + Bullet_size) > (Tank2Y-Tank_size))&&
		  ((Bullet1Y - Bullet_size) < (Tank_size + Tank2Y)))
        Bullet1_Tank2_intersect = 1'b1;
    else
        Bullet1_Tank2_intersect = 1'b0;
	end


    // Add new wires for Tank2 and Bullet2
    logic Tank1_on, Tank2_on, Bullet1_on, Bullet2_on;
    
    // Your existing code for DistX, DistY, Size, and Bullet_on_proc
	 int DistX, DistY, Size;
	 assign DistX = DrawX - Bullet1X;
    assign DistY = DrawY - Bullet1Y;
    assign Size = Bullet_size;
	 
	 always_comb
    begin:Bullet_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            Bullet1_on = 1'b1;
        else 
            Bullet1_on = 1'b0;
     end
    // Add Bullet2_on_proc with new DistX and DistY
    int DistX2, DistY2;
    assign DistX2 = DrawX - Bullet2X;
    assign DistY2 = DrawY - Bullet2Y;

    always_comb
    begin:Bullet2_on_proc
        if ( (DistX2*DistX2 + DistY2*DistY2) <= (Size * Size) ) 
            Bullet2_on = 1'b1;
        else 
            Bullet2_on = 1'b0;
    end


	 //logic for map 1
	 logic [17:0] rom_address_m;
	 logic [3:0] rom_q_m;
	 logic [3:0] palette_red_m, palette_green_m, palette_blue_m;
	 assign rom_address_m = ((DrawX * 468) / 640) + (((DrawY * 468) / 480) * 468);
	 
	 //logic for tank 1
	 logic [10:0] rom_address_t;
	 logic [3:0] rom_q_t;
	 logic [3:0] palette_red_t, palette_green_t, palette_blue_t;
	 
	 // Add new logic for Tank2 and Bullet2
	logic [3:0] rom_q_t2;
	logic [10:0] rom_address_t2;
	logic [3:0] palette_red_t2, palette_green_t2, palette_blue_t2;
	 
	 //logic for brick image
	 logic [10:0] rom_address_brick;
	 logic [3:0] rom_q_brick;
	 logic [3:0] palette_red_brick, palette_green_brick, palette_blue_brick;

	 
	 //logic for wall
	 logic [10:0] rom_address_wall;
	 logic [3:0] rom_q_wall;
	 logic [3:0] palette_red_wall, palette_green_wall, palette_blue_wall;	

	 //logic for star
	 logic [10:0] rom_address_star;
	 logic [3:0] rom_q_star;
	 logic [3:0] palette_red_star, palette_green_star, palette_blue_star;	 

	 //logci for river
	 logic [10:0] rom_address_river;
	 logic [3:0] rom_q_river;
	 logic [3:0] palette_red_river, palette_green_river, palette_blue_river;

	//logic for the game over image
	 logic [17:0] rom_address_over;
	 logic  rom_q_over;
	 logic [3:0] palette_red_over, palette_green_over, palette_blue_over;
	 
	//logic for the blast image
	 logic [10:0] rom_address_blast;
	 logic  rom_q_blast;
	 logic [3:0] palette_red_blast, palette_green_blast, palette_blue_blast;
	 


    // Modify rom_address_t assignment based on TankDirection
	     // Add direction states
    localparam DIR_UP = 2'b00;
    localparam DIR_LEFT = 2'b01;
    localparam DIR_DOWN = 2'b10;
    localparam DIR_RIGHT = 2'b11;
    assign rom_address_t = 
        (Tank1Direction == DIR_UP) ? 
            (((DrawX - (Tank1X - Tank_size)) * 36) / (2 * Tank_size)) + ((((DrawY - (Tank1Y - Tank_size)) * 36) / (2 * Tank_size)) * 36) :
        (Tank1Direction == DIR_LEFT) ? 
            (((DrawY - (Tank1Y - Tank_size)) * 36) / (2 * Tank_size)) + ((((DrawX - (Tank1X - Tank_size)) * 36) / (2 * Tank_size)) * 36) :
        (Tank1Direction == DIR_DOWN) ? 
            (((DrawX - (Tank1X - Tank_size)) * 36) / (2 * Tank_size)) + (((((Tank_size * 2) - (DrawY - (Tank1Y - Tank_size))) * 36) / (2 * Tank_size)) * 36) :
            (((DrawY - (Tank1Y - Tank_size)) * 36) / (2 * Tank_size)) + (((((Tank_size * 2) - (DrawX - (Tank1X - Tank_size))) * 36) / (2 * Tank_size)) * 36);
	 assign rom_address_blast = (((DrawX - (Tank1X - Tank_size)) * 36) / (2 * Tank_size)) + ((((DrawY - (Tank1Y - Tank_size)) * 36) / (2 * Tank_size)) * 36);



    // Modify rom_address_t2 assignment based on Tank2Direction
    assign rom_address_t2 = 
        (Tank2Direction == DIR_UP) ? 
            (((DrawX - (Tank2X - Tank_size)) * 36) / (2 * Tank_size)) + ((((DrawY - (Tank2Y - Tank_size)) * 36) / (2 * Tank_size)) * 36) :
        (Tank2Direction == DIR_LEFT) ? 
            (((DrawY - (Tank2Y - Tank_size)) * 36) / (2 * Tank_size)) + ((((DrawX - (Tank2X - Tank_size)) * 36) / (2 * Tank_size)) * 36) :
        (Tank2Direction == DIR_DOWN) ? 
            (((DrawX - (Tank2X - Tank_size)) * 36) / (2 * Tank_size)) + (((((Tank_size * 2) - (DrawY - (Tank2Y - Tank_size))) * 36) / (2 * Tank_size)) * 36) :
            (((DrawY - (Tank2Y - Tank_size)) * 36) / (2 * Tank_size)) + (((((Tank_size * 2) - (DrawX - (Tank2X - Tank_size))) * 36) / (2 * Tank_size)) * 36);

    // Your existing code for Tank_on_proc
    always_comb
    begin:Tank1_on_proc
        if (
				(DrawX > Tank1X - Tank_size+2) &&
            (DrawX <= Tank1X + Tank_size-2) &&
            (DrawY > Tank1Y - Tank_size+2) &&
            (DrawY <= Tank1Y + Tank_size-2))
            Tank1_on = 1'b1;
        else 
            Tank1_on = 1'b0;
     end
	  
    // Add new Tank2_on_proc
    always_comb
    begin:Tank2_on_proc
        if (
				(DrawX > Tank2X - Tank_size+2) &&
            (DrawX <= Tank2X + Tank_size-2) &&
            (DrawY > Tank2Y - Tank_size+2) &&
				(DrawY <= Tank2Y + Tank_size-2))
					Tank2_on = 1'b1;
			else
				Tank2_on = 1'b0;
	end
	
logic over_on;
    always_comb
    begin:over_on_proc
        if (
				(DrawX <= 467) &&
            (DrawX >= 0) &&
            (DrawY <= 467) &&
				(DrawY >= 0))
					over_on = 1'b1;
			else
				over_on = 1'b0;
	end


//Draw brick in the map

reg [9:0] coords_x_brick [0:31] = '{0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
											  432, 432, 432, 432, 432, 432, 432, 432, 432,
											  72 , 108, /*180,*/ 180, 252, /*252,*/ /*216,*/ 324, 360,
											  72 , 108, /*180,*/ 180, 252, /*252,*/ 324, 360, /*216,*/
											  36 , 396
											  
											};
reg [9:0] coords_y_brick [0:31] = '{72 , 108, 144, 180, 216, 252, 288, 324, 360,
											  72  , 108, 144, 180, 216, 252, 288, 324, 360,
											  0   , 0  , /*36 ,*/ 0  , 0  , /*36  ,*/ /*36 ,*/ 0  , 0  ,
											  432 , 432, /*396,*/ 432, 432, /*396,*/ 432, 432, /*396,*/
											  396 , 36
											  
											};
reg [31:0] index_brick;
reg [0:31] brick_on;
reg [0:31] brick_hit=32'b0;

always_comb begin
    for (index_brick = 0; index_brick < 32; index_brick++) begin
        if (brick_destroyed[index_brick] == 1'b0 &&
				(DrawX >= coords_x_brick[index_brick]) &&
            (DrawX <= coords_x_brick[index_brick] + 35) &&
            (DrawY >= coords_y_brick[index_brick]) &&
            (DrawY <= coords_y_brick[index_brick] + 35))
            brick_on[index_brick] = 1'b1;
        else
            brick_on[index_brick] = 1'b0;
    end
end


//Draw wall in the map
reg [9:0] coords_x_wall [0:33] = '{0 , 36 , 396, 432,
											 0  , 432,
											 0  , 36 , 396, 432,
											 0  , 432,
											 144, 144, 288, 288,
											 72 , 72 , 108, 108, 108,
											 180, 180, 180,
											 216, 216, 252, 252, 252,
											 324, 324, 324, 
											 360, 360
											 
											};
											
reg [9:0] coords_y_wall [0:33] = '{0 , 0  , 0  , 0  , 
											 36 , 36 ,
											 432, 432, 432, 432,
											 396, 396,
											 0  , 432, 0  , 432,
											 144, 285, 36 , 216, 396,
											 72 , 216, 360,
											 72 , 360, 72 , 216, 360,
											 36 , 216, 396,
											 144, 285
											 
											};
reg [33:0] index_wall;
reg [0:33] wall_on;

always_comb begin
    for (index_wall = 0; index_wall < 34; index_wall++) begin
        if ((DrawX >= coords_x_wall[index_wall]) &&
            (DrawX <= coords_x_wall[index_wall] + 35) &&
            (DrawY >= coords_y_wall[index_wall]) &&
            (DrawY <= coords_y_wall[index_wall] + 35))
            wall_on[index_wall] = 1'b1;
        else 
            wall_on[index_wall] = 1'b0;
    end
end



//Draw star in the map
reg [9:0] coords_x_star [0:1] = '{216, 216};
reg [9:0] coords_y_star [0:1] = '{0  , 432};
reg [1:0] index_star;
reg [0:1] star_on;

always_comb begin
    for (index_star = 0; index_star < 2; index_star++) begin
        if (!star_destroyed[index_star] &&
            (DrawX >= coords_x_star[index_star]) &&
            (DrawX <= coords_x_star[index_star] + 35) &&
            (DrawY >= coords_y_star[index_star]) &&
            (DrawY <= coords_y_star[index_star] + 35))
            star_on[index_star] = 1'b1;
        else 
            star_on[index_star] = 1'b0;
    end
end


//Draw river on the map
reg [9:0] coords_x_river [0:5] = '{36, 144, 180, 252, 288, 396};
reg [9:0] coords_y_river [0:5] = '{216, 288, 288, 144, 144, 216};
reg [5:0] index_river;
reg [0:5] river_on;
always_comb begin
    for (index_river = 0; index_river < 6; index_river++) begin
        if (
            (DrawX >= coords_x_river[index_river]) &&
            (DrawX <= coords_x_river[index_river] + 35) &&
            (DrawY >= coords_y_river[index_river]) &&
            (DrawY <= coords_y_river[index_river] + 35))
            river_on[index_river] = 1'b1;
        else 
            river_on[index_river] = 1'b0;
    end
end


//main palette logic
always_ff @ (posedge vga_clk) begin

		Red <= 8'h00;
		Green <= 8'h00;
		Blue <= 8'h00;
	

		if (blank&&currentState == RUNNING) begin
		
		if (game_over==1'b1 && over_on == 1)begin
					Red <= palette_red_over;
					Green <= palette_green_over;
					Blue <= palette_blue_over;
		  end
		 else begin
			for(index_brick = 0; index_brick < 32; index_brick++) begin

				 if (brick_on[index_brick]/*&& brick_destroyed[index_brick] != 1'b1*/) begin
//						rom_address_brick <= (((DrawX - coords_x_brick[index_brick]) * 36) / 36) + ((((DrawY - coords_y_brick[index_brick]) * 36) / 36) * 36);
						rom_address_brick <= ((DrawX - coords_x_brick[index_brick]) % 36) + (((DrawY - coords_y_brick[index_brick]) % 36) * 36);
						Red <= palette_red_brick;
						Green <= palette_green_brick;
						Blue <= palette_blue_brick;
						break;
				end
			end
			
			for(index_wall = 0; index_wall < 34; index_wall++) begin
				if (wall_on[index_wall]) begin
//						rom_address_wall <= (((DrawX - coords_x_wall[index_wall]) * 36) / 36) + ((((DrawY - coords_y_wall[index_wall]) * 36) / 36) * 36);
						rom_address_wall <= ((DrawX - coords_x_wall[index_wall]) % 36) + (((DrawY - coords_y_wall[index_wall]) % 36) * 36);

						Red <= palette_red_wall;
						Green <= palette_green_wall;
						Blue <= palette_blue_wall;
						break;
				end
			end
			for(index_star = 0; index_star < 2; index_star++) begin
				if (star_on[index_star]) begin
						rom_address_star <= ((DrawX - coords_x_star[index_star]) % 36) + (((DrawY - coords_y_star[index_star]) % 36) * 36);

						Red <= palette_red_star;
						Green <= palette_green_star;
						Blue <= palette_blue_star;
						break;
				end
			end
			
			for(index_river = 0; index_river < 6; index_river++) begin
				if (river_on[index_river]) begin
						rom_address_river <= ((DrawX - coords_x_river[index_river]) % 36) + (((DrawY - coords_y_river[index_river]) % 36) * 36);

						Red <= palette_red_river;
						Green <= palette_green_river;
						Blue <= palette_blue_river;
						break;
				end
		 end if (Tank1_on == 1'b1) begin
            if (Bullet2_Tank1_intersect == 1'b1) begin 					
                Red <= palette_red_blast;
                Green <= palette_green_blast;
                Blue <= palette_blue_blast;
            end else begin
                Red <= palette_red_t;
                Green <= palette_green_t;
                Blue <= palette_blue_t;
            end
        end else if (Tank2_on == 1'b1) begin
            if (Bullet1_Tank2_intersect == 1'b1) begin 					
                Red <= palette_red_blast;
                Green <= palette_green_blast;
                Blue <= palette_blue_blast;
            end else begin
                Red <= palette_red_t2;
                Green <= palette_green_t2;
                Blue <= palette_blue_t2;
            end
        end else if (Bullet1_on == 1'b1) begin
            Red <= 8'hff;
            Green <= 8'h55;
            Blue <= 8'h00;
        end else if (Bullet2_on == 1'b1) begin
            Red <= 8'h00;
            Green <= 8'hff;
            Blue <= 8'h00;

        end else if (star_on == 1'b1) begin
            Red <= palette_red_star;
            Green <= palette_green_star;
            Blue <= palette_blue_star;
		  end 
		  
		end
   end
	
end



// check for the bullet-brick intersection
reg [0:31] bullet1_brick_intersect;
reg [0:31] bullet2_brick_intersect;
reg [0:31] brick_destroyed=32'b0;

always @(posedge vga_clk) begin
    for (index_brick = 0; index_brick < 32; index_brick++) begin
        if (bullet1_brick_intersect[index_brick] || bullet2_brick_intersect[index_brick]) begin
            brick_destroyed[index_brick] <= 1'b1;
        end
    end
end

// In the first always_comb block
reg bullet_background_acc;
always_comb begin
    bullet_background_acc = 1'b0;
    for (index_brick = 0; index_brick < 32; index_brick++) begin
        if (((Bullet1X + Bullet_size) > coords_x_brick[index_brick]) &&
            ((Bullet1X - Bullet_size) < (coords_x_brick[index_brick] + 35)) &&
            ((Bullet1Y + Bullet_size) > coords_y_brick[index_brick]) &&
            ((Bullet1Y - Bullet_size) < (coords_y_brick[index_brick] + 35))) 
				begin
            bullet1_brick_intersect[index_brick] = 1'b1;
//				if (brick_on[index_brick] == 1'b1)
					bullet_background_acc = 1'b1;
			end
			
        else
				begin
            bullet1_brick_intersect[index_brick] = 1'b0;
				end
    end
end

assign  bullet_background = bullet_background_acc||bullet_background_acc_wall;

// In the second always_comb block
reg bullet_background2_acc;
always_comb begin
    bullet_background2_acc = 1'b0;
    for (index_brick = 0; index_brick < 32; index_brick++) begin
        if (((Bullet2X + Bullet_size) > coords_x_brick[index_brick]) &&
            ((Bullet2X - Bullet_size) < (coords_x_brick[index_brick] + 35)) &&
            ((Bullet2Y + Bullet_size) > coords_y_brick[index_brick]) &&
            ((Bullet2Y - Bullet_size) < (coords_y_brick[index_brick] + 35))) 
				begin
            bullet2_brick_intersect[index_brick] = 1'b1;
				bullet_background2_acc = 1'b1;
				end
        else
				begin
            bullet2_brick_intersect[index_brick] = 1'b0;
				end
    end
end

assign  bullet_background2 = bullet_background2_acc||bullet_background2_acc_wall;


//bullet_wall_intersect
reg bullet_background_acc_wall;
always_comb begin
	bullet_background_acc_wall=1'b0;
    for (index_wall = 0; index_wall < 34; index_wall++) begin
        if (((Bullet1X + Bullet_size) >= coords_x_wall[index_wall]) &&
            ((Bullet1X - Bullet_size) <= coords_x_wall[index_wall] + 35) &&
            ((Bullet1Y + Bullet_size) >= coords_y_wall[index_wall]) &&
            ((Bullet1Y - Bullet_size) <= coords_y_wall[index_wall] + 35))
				bullet_background_acc_wall=1'b1;

    end
end

reg bullet_background2_acc_wall;
always_comb begin
	bullet_background2_acc_wall=1'b0;
    for (index_wall = 0; index_wall < 34; index_wall++) begin
        if (((Bullet2X + Bullet_size) >= coords_x_wall[index_wall]) &&
            ((Bullet2X - Bullet_size) <= coords_x_wall[index_wall] + 35) &&
            ((Bullet2Y + Bullet_size) >= coords_y_wall[index_wall]) &&
            ((Bullet2Y - Bullet_size) <= coords_y_wall[index_wall] + 35))
				bullet_background2_acc_wall=1'b1;

    end
end


//bullet_star_intersect
logic [1:0] bullet1_star_intersect;
logic [1:0] bullet2_star_intersect;
logic [1:0] star_intersect;

always_comb
begin:Bullet1_star_intersect_proc

	for (index_star = 0; index_star < 2; index_star++) begin
    if  (((Bullet1X + Bullet_size) > (coords_x_star[index_star])) &&
        ((Bullet1X - Bullet_size) < (coords_x_star[index_star] + 35)) &&
        ((Bullet1Y + Bullet_size) > (coords_y_star[index_star])) &&
        ((Bullet1Y - Bullet_size) < (coords_y_star[index_star] + 35)))
		  bullet1_star_intersect[index_star]=1'b1; 
    else 
		  bullet1_star_intersect[index_star]=1'b0; 
	end
end

always_comb
begin:Bullet2_star_intersect_proc

	for (index_star = 0; index_star < 2; index_star++) begin
    if  (((Bullet2X + Bullet_size) > (coords_x_star[index_star])) &&
        ((Bullet2X - Bullet_size) < (coords_x_star[index_star] + 35)) &&
        ((Bullet2Y + Bullet_size) > (coords_y_star[index_star])) &&
        ((Bullet2Y - Bullet_size) < (coords_y_star[index_star] + 35)))
		  bullet2_star_intersect[index_star]=1'b1; 
    else 
		  bullet2_star_intersect[index_star]=1'b0; 
	end
end



reg [1:0] star_destroyed=2'b0;
logic game_over=1'b0;
always_ff @(posedge vga_clk) begin
    for ( index_star = 0; index_star < 2; index_star++) begin
        if (bullet1_star_intersect[index_star] || bullet2_star_intersect[index_star]) begin
            star_destroyed[index_star]<=1'b1;
				game_over=1'b1;
        end
    end
end





//background check for tank 1

//check for the top of the tank collision
always_comb begin: check_background_top
        if (SpecifiedPixel_Red_TopL == 8'h00 && SpecifiedPixel_Green_TopL == 8'h00 && SpecifiedPixel_Blue_TopL == 8'h00 &&
		  SpecifiedPixel_Red_TopR == 8'h00 && SpecifiedPixel_Green_TopR == 8'h00 && SpecifiedPixel_Blue_TopR == 8'h00) 
				top_is_background_color=1'b1;		
			else
				top_is_background_color=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_TopL, SpecifiedPixel_Green_TopL, SpecifiedPixel_Blue_TopL;
 logic [7:0] SpecifiedPixel_Red_TopR, SpecifiedPixel_Green_TopR, SpecifiedPixel_Blue_TopR;
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank1X-Tank_size+3 && DrawY == Tank1Y-Tank_size+2) begin
        SpecifiedPixel_Red_TopL <= Red;
        SpecifiedPixel_Green_TopL <= Green;
        SpecifiedPixel_Blue_TopL <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank1X+Tank_size-2 && DrawY == Tank1Y-Tank_size+2) begin
        SpecifiedPixel_Red_TopR <= Red;
        SpecifiedPixel_Green_TopR <= Green;
        SpecifiedPixel_Blue_TopR <= Blue;
    end
  end
  
//check for the bottom of the tank collision
always_comb begin: check_background_bottom
        if (SpecifiedPixel_Red_BotL == 8'h00 && SpecifiedPixel_Green_BotL == 8'h00 && SpecifiedPixel_Blue_BotL == 8'h00 &&
		  SpecifiedPixel_Red_BotR == 8'h00 && SpecifiedPixel_Green_BotR == 8'h00 && SpecifiedPixel_Blue_BotR == 8'h00) 
				bottom_is_background_color=1'b1;		
			else
				bottom_is_background_color=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_BotL, SpecifiedPixel_Green_BotL, SpecifiedPixel_Blue_BotL;
 logic [7:0] SpecifiedPixel_Red_BotR, SpecifiedPixel_Green_BotR, SpecifiedPixel_Blue_BotR;
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank1X-Tank_size+3 && DrawY == Tank1Y+Tank_size-1) begin
        SpecifiedPixel_Red_BotL <= Red;
        SpecifiedPixel_Green_BotL <= Green;
        SpecifiedPixel_Blue_BotL <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size && DrawY == Tank1Y+Tank_size+1) begin
    if (DrawX == Tank1X+Tank_size-2 && DrawY == Tank1Y+Tank_size-1) begin

        SpecifiedPixel_Red_BotR <= Red;
        SpecifiedPixel_Green_BotR <= Green;
        SpecifiedPixel_Blue_BotR <= Blue;
    end
  end

//check for the left of the tank collision
always_comb begin: check_background_left
        if (SpecifiedPixel_Red_LeftU == 8'h00 && SpecifiedPixel_Green_LeftU == 8'h00 && SpecifiedPixel_Blue_LeftU == 8'h00 &&
		  SpecifiedPixel_Red_LeftD == 8'h00 && SpecifiedPixel_Green_LeftD == 8'h00 && SpecifiedPixel_Blue_LeftD == 8'h00) 
				left_is_background_color=1'b1;		
			else
				left_is_background_color=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_LeftU, SpecifiedPixel_Green_LeftU, SpecifiedPixel_Blue_LeftU;
 logic [7:0] SpecifiedPixel_Red_LeftD, SpecifiedPixel_Green_LeftD, SpecifiedPixel_Blue_LeftD;
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X-Tank_size-1 && DrawY == Tank1Y+Tank_size) begin
    if (DrawX == Tank1X-Tank_size+2 && DrawY == Tank1Y+Tank_size-2) begin

        SpecifiedPixel_Red_LeftU <= Red;
        SpecifiedPixel_Green_LeftU <= Green;
        SpecifiedPixel_Blue_LeftU <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X-Tank_size-1 && DrawY == Tank1Y-Tank_size) begin
    if (DrawX == Tank1X-Tank_size+2 && DrawY == Tank1Y-Tank_size+3) begin

        SpecifiedPixel_Red_LeftD <= Red;
        SpecifiedPixel_Green_LeftD <= Green;
        SpecifiedPixel_Blue_LeftD <= Blue;
    end
  end

  
//check for the right of the tank collision
always_comb begin: check_background_right
    if (SpecifiedPixel_Red_RightU == 8'h00 && SpecifiedPixel_Green_RightU == 8'h00 && SpecifiedPixel_Blue_RightU == 8'h00 &&
        SpecifiedPixel_Red_RightD == 8'h00 && SpecifiedPixel_Green_RightD == 8'h00 && SpecifiedPixel_Blue_RightD == 8'h00) 
        right_is_background_color = 1'b1;        
    else
        right_is_background_color = 1'b0;
end

 logic [7:0] SpecifiedPixel_Red_RightU, SpecifiedPixel_Green_RightU, SpecifiedPixel_Blue_RightU;
 logic [7:0] SpecifiedPixel_Red_RightD, SpecifiedPixel_Green_RightD, SpecifiedPixel_Blue_RightD;
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size+1 && DrawY == Tank1Y+Tank_size) begin
    if (DrawX == Tank1X+Tank_size+2 && DrawY == Tank1Y+Tank_size-2) begin

        SpecifiedPixel_Red_RightU <= Red;
        SpecifiedPixel_Green_RightU <= Green;
        SpecifiedPixel_Blue_RightU <= Blue;
    end
  end
  

 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size+1 && DrawY == Tank1Y-Tank_size) begin
    if (DrawX == Tank1X+Tank_size+2 && DrawY == Tank1Y-Tank_size+3) begin


        SpecifiedPixel_Red_RightD <= Red;
        SpecifiedPixel_Green_RightD <= Green;
        SpecifiedPixel_Blue_RightD <= Blue;
    end
  end
  
  
  
//background check for tank 2

//check for the top of the tank collision
always_comb begin: check_background_top_2
        if (SpecifiedPixel_Red_TopL_2 == 8'h00 && SpecifiedPixel_Green_TopL_2 == 8'h00 && SpecifiedPixel_Blue_TopL_2 == 8'h00 &&
		  SpecifiedPixel_Red_TopR_2 == 8'h00 && SpecifiedPixel_Green_TopR_2 == 8'h00 && SpecifiedPixel_Blue_TopR_2 == 8'h00) 
				top_is_background_color_2=1'b1;		
			else
				top_is_background_color_2=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_TopL_2, SpecifiedPixel_Green_TopL_2, SpecifiedPixel_Blue_TopL_2;
 logic [7:0] SpecifiedPixel_Red_TopR_2, SpecifiedPixel_Green_TopR_2, SpecifiedPixel_Blue_TopR_2;
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank2X-Tank_size+3 && DrawY == Tank2Y-Tank_size+2) begin
        SpecifiedPixel_Red_TopL_2 <= Red;
        SpecifiedPixel_Green_TopL_2 <= Green;
        SpecifiedPixel_Blue_TopL_2 <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank2X+Tank_size-2 && DrawY == Tank2Y-Tank_size+2) begin
        SpecifiedPixel_Red_TopR_2 <= Red;
        SpecifiedPixel_Green_TopR_2 <= Green;
        SpecifiedPixel_Blue_TopR_2 <= Blue;
    end
  end
  
//check for the bottom of the tank collision
always_comb begin: check_background_bottom_2
        if (SpecifiedPixel_Red_BotL_2 == 8'h00 && SpecifiedPixel_Green_BotL_2 == 8'h00 && SpecifiedPixel_Blue_BotL_2 == 8'h00 &&
		  SpecifiedPixel_Red_BotR_2 == 8'h00 && SpecifiedPixel_Green_BotR_2 == 8'h00 && SpecifiedPixel_Blue_BotR_2 == 8'h00) 
				bottom_is_background_color_2=1'b1;		
			else
				bottom_is_background_color_2=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_BotL_2, SpecifiedPixel_Green_BotL_2, SpecifiedPixel_Blue_BotL_2;
 logic [7:0] SpecifiedPixel_Red_BotR_2, SpecifiedPixel_Green_BotR_2, SpecifiedPixel_Blue_BotR_2;
 always_ff @ (posedge vga_clk) begin
    if (DrawX == Tank2X-Tank_size+3 && DrawY == Tank2Y+Tank_size-1) begin
        SpecifiedPixel_Red_BotL_2 <= Red;
        SpecifiedPixel_Green_BotL_2 <= Green;
        SpecifiedPixel_Blue_BotL_2 <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size && DrawY == Tank1Y+Tank_size+1) begin
    if (DrawX == Tank2X+Tank_size-2 && DrawY == Tank2Y+Tank_size-1) begin

        SpecifiedPixel_Red_BotR_2 <= Red;
        SpecifiedPixel_Green_BotR_2 <= Green;
        SpecifiedPixel_Blue_BotR_2 <= Blue;
    end
  end

//check for the left of the tank collision
always_comb begin: check_background_left_2
        if (SpecifiedPixel_Red_LeftU_2 == 8'h00 && SpecifiedPixel_Green_LeftU_2 == 8'h00 && SpecifiedPixel_Blue_LeftU_2 == 8'h00 &&
		  SpecifiedPixel_Red_LeftD_2 == 8'h00 && SpecifiedPixel_Green_LeftD_2 == 8'h00 && SpecifiedPixel_Blue_LeftD_2 == 8'h00) 
				left_is_background_color_2=1'b1;		
			else
				left_is_background_color_2=1'b0;
	end

 logic [7:0] SpecifiedPixel_Red_LeftU_2, SpecifiedPixel_Green_LeftU_2, SpecifiedPixel_Blue_LeftU_2;
 logic [7:0] SpecifiedPixel_Red_LeftD_2, SpecifiedPixel_Green_LeftD_2, SpecifiedPixel_Blue_LeftD_2;
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X-Tank_size-1 && DrawY == Tank1Y+Tank_size) begin
    if (DrawX == Tank2X-Tank_size+2 && DrawY == Tank2Y+Tank_size-2) begin

        SpecifiedPixel_Red_LeftU_2 <= Red;
        SpecifiedPixel_Green_LeftU_2 <= Green;
        SpecifiedPixel_Blue_LeftU_2 <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X-Tank_size-1 && DrawY == Tank1Y-Tank_size) begin
    if (DrawX == Tank2X-Tank_size+2 && DrawY == Tank2Y-Tank_size+3) begin

        SpecifiedPixel_Red_LeftD_2 <= Red;
        SpecifiedPixel_Green_LeftD_2 <= Green;
        SpecifiedPixel_Blue_LeftD_2 <= Blue;
    end
  end

  
//check for the right of the tank collision
always_comb begin: check_background_right_2
    if (SpecifiedPixel_Red_RightU_2 == 8'h00 && SpecifiedPixel_Green_RightU_2 == 8'h00 && SpecifiedPixel_Blue_RightU_2 == 8'h00 &&
        SpecifiedPixel_Red_RightD_2 == 8'h00 && SpecifiedPixel_Green_RightD_2 == 8'h00 && SpecifiedPixel_Blue_RightD_2 == 8'h00) 
        right_is_background_color_2 = 1'b1;        
    else
        right_is_background_color_2 = 1'b0;
end

 logic [7:0] SpecifiedPixel_Red_RightU_2, SpecifiedPixel_Green_RightU_2, SpecifiedPixel_Blue_RightU_2;
 logic [7:0] SpecifiedPixel_Red_RightD_2, SpecifiedPixel_Green_RightD_2, SpecifiedPixel_Blue_RightD_2;
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size+1 && DrawY == Tank1Y+Tank_size) begin
    if (DrawX == Tank2X+Tank_size+2 && DrawY == Tank2Y+Tank_size-2) begin

        SpecifiedPixel_Red_RightU_2 <= Red;
        SpecifiedPixel_Green_RightU_2 <= Green;
        SpecifiedPixel_Blue_RightU_2 <= Blue;
    end
  end
 always_ff @ (posedge vga_clk) begin
//    if (DrawX == Tank1X+Tank_size+1 && DrawY == Tank1Y-Tank_size) begin
    if (DrawX == Tank2X+Tank_size+2 && DrawY == Tank2Y-Tank_size+3) begin


        SpecifiedPixel_Red_RightD_2 <= Red;
        SpecifiedPixel_Green_RightD_2 <= Green;
        SpecifiedPixel_Blue_RightD_2 <= Blue;
    end
  end
  
  


  
  
  
//instantiate tank modules
tank1_rom tank1_rom (
	.clock   (vga_clk),
	.address (rom_address_t),
	.q       (rom_q_t)
);

tank1_palette tank1_palette (
	.index (rom_q_t),
	.red   (palette_red_t),
	.green (palette_green_t),
	.blue  (palette_blue_t)
);

// Instantiate tank2_rom and tank2_palette
tank2_rom tank2_rom (
    .clock   (vga_clk),
    .address (rom_address_t2),
    .q       (rom_q_t2)
);

tank2_palette tank2_palette (
    .index (rom_q_t2),
    .red   (palette_red_t2),
    .green (palette_green_t2),
    .blue  (palette_blue_t2)
);

//Instantiate bricks map
Battle_City_bricks_rom brick_r(
    .clock   (vga_clk),
    .address (rom_address_brick),
    .q       (rom_q_brick)
);

Battle_City_bricks_palette brick_p (
    .index (rom_q_brick),
    .red   (palette_red_brick),
    .green (palette_green_brick),
    .blue  (palette_blue_brick)
);

//Instantiate wall
wall_rom wall_rom (
	.clock   (vga_clk),
	.address (rom_address_wall),
	.q       (rom_q_wall)
);

wall_palette wall_palette (
	.index (rom_q_wall),
	.red   (palette_red_wall),
	.green (palette_green_wall),
	.blue  (palette_blue_wall)
);

//star
star_rom star_rom (
	.clock   (vga_clk),
	.address (rom_address_star),
	.q       (rom_q_star)
);

star_palette star_palette (
	.index (rom_q_star),
	.red   (palette_red_star),
	.green (palette_green_star),
	.blue  (palette_blue_star)
);

//river
river_rom river_rom(
	.clock   (vga_clk),
	.address (rom_address_river),
	.q       (rom_q_river)
);
river_palette river_palette(
	.index (rom_q_river),
	.red   (palette_red_river),
	.green (palette_green_river),
	.blue  (palette_blue_river)
);

//game over

game_over_rom game_over_rom (
	.clock   (vga_clk),
	.address (rom_address_over),
	.q       (rom_q_over)
);

game_over_palette game_over_palette (
	.index (rom_q_over),
	.red   (palette_red_over),
	.green (palette_green_over),
	.blue  (palette_blue_over)
);
assign rom_address_over = ((DrawX * 468) / 468) + (((DrawY * 468) / 468) * 468);

blast8_rom blast8_rom (
	.clock   (vga_clk),
	.address (rom_address_blast),
	.q       (rom_q_blast)
);

blast8_palette blast8_palette (
	.index (rom_q_blast),
	.red   (palette_red_blast),
	.green (palette_green_blast),
	.blue  (palette_blue_blast)
);


endmodule 