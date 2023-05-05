//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode,keycode2;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[3:0];
	assign VGA_B = Blue[3:0];
	assign VGA_G = Green[3:0];
	
	
	shuai_lab62soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		.keycode2_export(keycode2)
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.

vga_controller vga1(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), 
						.blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));

//
//logic [9:0] smallballxsig, smallballysig,smallballsizesig;
//logic [1:0] TankDirection;
//
//ball ball1( .Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), 
//				.TankX(ballxsig), .TankY(ballysig), .TankS(ballsizesig), .TankDirection(TankDirection),
//				.BulletX(smallballxsig), .BulletY(smallballysig), .BulletS(smallballsizesig));
//
//color_mapper color1(
//							.vga_clk(VGA_Clk), .blank(blank),.TankX(ballxsig), .TankDirection(TankDirection),
//							.TankY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), 
//							.Tank_size(ballsizesig),.Red(Red), .Green(Green), .Blue(Blue),
//							.BulletX(smallballxsig), .BulletY(smallballysig),.Bullet_size(smallballsizesig));



logic [9:0] Bullet1X, Bullet1Y, Bullet1S,Bullet2X, Bullet2Y, Bullet2S;
logic [9:0] Tank1X, Tank1Y, Tank1S,Tank2X, Tank2Y, Tank2S;
logic [1:0] Tank1Direction, Tank2Direction;
logic top_is_background_color,bottom_is_background_color,left_is_background_color,right_is_background_color,
		top_is_background_color2,bottom_is_background_color2,left_is_background_color2,right_is_background_color2;
logic Bullet1_Tank2_intersect,Bullet2_Tank1_intersect;
logic bullet_background,bullet_background2;

ball_game ball1( .Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode),.keycode2(keycode2), 
				.Tank1X(Tank1X), .Tank1Y(Tank1Y), .Tank1S(Tank1S), .Tank1Direction(Tank1Direction),
				.Tank2X(Tank2X), .Tank2Y(Tank2Y), .Tank2S(Tank2S), .Tank2Direction(Tank2Direction),
				.Bullet1X(Bullet1X), .Bullet1Y(Bullet1Y), .Bullet1S(Bullet1S),
				.Bullet2X(Bullet2X), .Bullet2Y(Bullet2Y), .Bullet2S(Bullet2S),
				.top_is_background_color(top_is_background_color),
				.bottom_is_background_color(bottom_is_background_color),
				.left_is_background_color(left_is_background_color),
				.right_is_background_color(right_is_background_color),
				.top_is_background_color_2(top_is_background_color2),
				.bottom_is_background_color_2(bottom_is_background_color2),
				.left_is_background_color_2(left_is_background_color2),
				.right_is_background_color_2(right_is_background_color2),
				.Bullet2_Tank1_intersect(Bullet2_Tank1_intersect),
				.Bullet1_Tank2_intersect(Bullet1_Tank2_intersect),
				.bullet_background(bullet_background),
				.bullet_background2(bullet_background2));
				
				

color_mapper2 color1(.keycode(keycode),
				.vga_clk(VGA_Clk), .blank(blank),.Red(Red), .Green(Green), .Blue(Blue),.DrawX(drawxsig), .DrawY(drawysig), 
				.Tank1X(Tank1X), .Tank1Y(Tank1Y), .Tank_size(Tank1S), .Tank1Direction(Tank1Direction),
				.Tank2X(Tank2X), .Tank2Y(Tank2Y), .Tank2Direction(Tank2Direction),
				.Bullet1X(Bullet1X), .Bullet1Y(Bullet1Y), .Bullet_size(Bullet1S),
				.Bullet2X(Bullet2X), .Bullet2Y(Bullet2Y),
				.top_is_background_color(top_is_background_color),
				.bottom_is_background_color(bottom_is_background_color),
				.left_is_background_color(left_is_background_color),
				.right_is_background_color(right_is_background_color),
				.top_is_background_color_2(top_is_background_color2),
				.bottom_is_background_color_2(bottom_is_background_color2),
				.left_is_background_color_2(left_is_background_color2),
				.right_is_background_color_2(right_is_background_color2),
				.Bullet2_Tank1_intersect(Bullet2_Tank1_intersect),
				.Bullet1_Tank2_intersect(Bullet1_Tank2_intersect),
				.bullet_background(bullet_background),
				.bullet_background2(bullet_background2));
endmodule












////-------------------------------------------------------------------------
////                                                                       --
////                                                                       --
////      For use with ECE 385 Lab 62                                       --
////      UIUC ECE Department                                              --
////-------------------------------------------------------------------------
//
//
//module lab62 (
//
//      ///////// Clocks /////////
//      input     MAX10_CLK1_50, 
//
//      ///////// KEY /////////
//      input    [ 1: 0]   KEY,
//
//      ///////// SW /////////
//      input    [ 9: 0]   SW,
//
//      ///////// LEDR /////////
//      output   [ 9: 0]   LEDR,
//
//      ///////// HEX /////////
//      output   [ 7: 0]   HEX0,
//      output   [ 7: 0]   HEX1,
//      output   [ 7: 0]   HEX2,
//      output   [ 7: 0]   HEX3,
//      output   [ 7: 0]   HEX4,
//      output   [ 7: 0]   HEX5,
//
//      ///////// SDRAM /////////
//      output             DRAM_CLK,
//      output             DRAM_CKE,
//      output   [12: 0]   DRAM_ADDR,
//      output   [ 1: 0]   DRAM_BA,
//      inout    [15: 0]   DRAM_DQ,
//      output             DRAM_LDQM,
//      output             DRAM_UDQM,
//      output             DRAM_CS_N,
//      output             DRAM_WE_N,
//      output             DRAM_CAS_N,
//      output             DRAM_RAS_N,
//
//      ///////// VGA /////////
//      output             VGA_HS,
//      output             VGA_VS,
//      output   [ 3: 0]   VGA_R,
//      output   [ 3: 0]   VGA_G,
//      output   [ 3: 0]   VGA_B,
//
//
//      ///////// ARDUINO /////////
//      inout    [15: 0]   ARDUINO_IO,
//      inout              ARDUINO_RESET_N 
//
//);
//
//
//
//
//logic Reset_h, vssig, blank, sync, VGA_Clk;
//
//
////=======================================================
////  REG/WIRE declarations
////=======================================================
//	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
//	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
//	logic [1:0] signs;
//	logic [1:0] hundreds;
//	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
//	logic [7:0] Red, Blue, Green;
//	logic [7:0] keycode;
//
////=======================================================
////  Structural coding
////=======================================================
//	assign ARDUINO_IO[10] = SPI0_CS_N;
//	assign ARDUINO_IO[13] = SPI0_SCLK;
//	assign ARDUINO_IO[11] = SPI0_MOSI;
//	assign ARDUINO_IO[12] = 1'bZ;
//	assign SPI0_MISO = ARDUINO_IO[12];
//	
//	assign ARDUINO_IO[9] = 1'bZ; 
//	assign USB_IRQ = ARDUINO_IO[9];
//		
//	//Assignments specific to Circuits At Home UHS_20
//	assign ARDUINO_RESET_N = USB_RST;
//	assign ARDUINO_IO[7] = USB_RST;//USB reset 
//	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
//	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
//	
//	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
//	assign ARDUINO_IO[6] = 1'b1;
//	
//	//HEX drivers to convert numbers to HEX output
//	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
//	assign HEX4[7] = 1'b1;
//	
//	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
//	assign HEX3[7] = 1'b1;
//	
//	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
//	assign HEX1[7] = 1'b1;
//	
//	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
//	assign HEX0[7] = 1'b1;
//	
//	//fill in the hundreds digit as well as the negative sign
//	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
//	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
//	
//	
//	//Assign one button to reset
//	assign {Reset_h}=~ (KEY[0]);
//
//	//Our A/D converter is only 12 bit
//	assign VGA_R = Red[7:4];
//	assign VGA_B = Blue[7:4];
//	assign VGA_G = Green[7:4];
//	
//	
//	shuai_lab62soc u0 (
//		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
//		.reset_reset_n                     (1'b1),           //reset.reset_n
//		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
//		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
//		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
//		.key_external_connection_export    (KEY),            //key_external_connection.export
//
//		//SDRAM
//		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
//		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
//		.sdram_wire_ba(DRAM_BA),                             //.ba
//		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
//		.sdram_wire_cke(DRAM_CKE),                           //.cke
//		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
//		.sdram_wire_dq(DRAM_DQ),                             //.dq
//		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
//		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
//		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n
//
//		//USB SPI	
//		.spi0_SS_n(SPI0_CS_N),
//		.spi0_MOSI(SPI0_MOSI),
//		.spi0_MISO(SPI0_MISO),
//		.spi0_SCLK(SPI0_SCLK),
//		
//		//USB GPIO
//		.usb_rst_export(USB_RST),
//		.usb_irq_export(USB_IRQ),
//		.usb_gpx_export(USB_GPX),
//		
//		//LEDs and HEX
//		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
//		.leds_export({hundreds, signs, LEDR}),
//		.keycode_export(keycode)
//		
//	 );
//
//
////instantiate a vga_controller, ball, and color_mapper here with the ports.
//ball ball1( .Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode),
//				.BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig));
//
//vga_controller vga1(.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(), 
//						.blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));
//
//color_mapper color1(.BallX(ballxsig), .BallY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), 
//							.Ball_size(ballsizesig),.Red(Red), .Green(Green), .Blue(Blue));
//endmodule
