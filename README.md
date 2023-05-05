#**ECE 385 Final Project: *Battle City***

##Introduction:
For our final project, we implemented a revised version of the *Battle City* video game on the MAX10 FPGA. In this project, we utilized the C programming language to create a NIOS II CPU to control the system and handle low-performance tasks such as I/O and user interfaces. We also used System Verilog to design the peripherals and components and manipulate high-performance tasks such as tank movement and color palettes. The USB interface was used with the SPI protocol to connect to the board and initialize VGA signals to display the video on the VGA display. Additionally, the USB interface provided power to the keyboard, which was used to control the motion of the tanks and transfer data.

##Instructions for Compiling the Game:
To compile the Battle City video game on the FPGA board, please follow these steps:
1. Connect the FPGA board to the computer, VGA screen, and keyboard before compilation.
2. Start a new Quartus project.
3. Add all the .sv files and the .qip files.
4. Open the Platform Designer, load the soc.qsys file, and generate HDL.
5. Set lab62.sv as the top-level hierarchy and compile the file.
6. Program the project onto the FPGA board.
7. Open Eclipse and create a new project.
8. Add usb_kb and usb_kb_bsp to the project.
9. Select NIOS-II -> Generate BSP, and build.
10. Run the configuration.

**Battle City (Modified Edition):**
In our modified version of Battle City, we preserved the basic logic of the tanks, bullets, and map but modified it to be more entertaining. Two tanks are on the screen, each controlled by a player using the keyboard. The player can control a tank and shoot missiles (bullets) in multiple directions to destroy enemy tanks and specific blocks on the map. Each time a missile hits a tank, the tank goes back to its original position. There are two bases on the opposite sides of the screen, one for each player. If a player's base is destroyed, the game is over, and that player loses the game. Further details regarding the game mechanism and image display will be discussed in the Game Mechanism and Image Display section of the final lab report.
