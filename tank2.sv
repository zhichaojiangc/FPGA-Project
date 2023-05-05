module  ball2 ( input Reset, frame_clk, Bullet1_Tank2_intersect,bullet_background2,
					input [7:0] keycode,
					input top_is_background_color,bottom_is_background_color,left_is_background_color,right_is_background_color,
               output [9:0]  TankX, TankY, TankS,
					output [9:0] BulletX, BulletY, BulletS,
					output reg [1:0] TankDirection
					);
    
    logic [9:0] Tank_X_Pos, Tank_X_Motion, Tank_Y_Pos, Tank_Y_Motion, Tank_Size;
	 logic [9:0] Bullet_X_Pos, Bullet_Y_Pos, Bullet_Size;
	 logic q_pressed;
	 logic [1:0] BulletDirection;
	 int counter = 0;

    parameter [9:0] Tank_X_Center=54;  // Center position on the X axis
    parameter [9:0] Tank_Y_Center=54;  // Center position on the Y axis
    parameter [9:0] Tank_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Tank_X_Max=467;     // Rightmost point on the X axis
    parameter [9:0] Tank_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Tank_Y_Max=467;     // Bottommost point on the Y axis
    parameter [9:0] Tank_X_Step=4;      // Step size on the X axis
    parameter [9:0] Tank_Y_Step=4;      // Step size on the Y axis
    parameter [9:0] Bullet_Step=4;      // Step size on the
	 
    assign Tank_Size = 18;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
    assign Bullet_Size = 4; // Half of the current ball size
	 
	 
    // Add direction states
    localparam DIR_UP = 2'b00;
    localparam DIR_LEFT = 2'b01;
    localparam DIR_DOWN = 2'b10;
    localparam DIR_RIGHT = 2'b11;
	 
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Tank_Y_Motion <= 10'd0; //Tank_Y_Step;
				Tank_X_Motion <= 10'd0; //Tank_X_Step;
				Tank_Y_Pos <= Tank_Y_Center;
				Tank_X_Pos <= Tank_X_Center;
				Bullet_Y_Pos <= Tank_Y_Pos - Tank_Size - Bullet_Size;
            Bullet_X_Pos <= Tank_X_Pos;
				q_pressed <= 1'b0; // Reset q_pressed signal
				counter<=0;

        end
		  
		  else if (Bullet1_Tank2_intersect==1'b1)
		  begin
				counter<=counter+1;
				
			if(counter == 8)begin	  
            Tank_Y_Motion <= 10'd0; //Tank_Y_Step;
				Tank_X_Motion <= 10'd0; //Tank_X_Step;
				Tank_Y_Pos <= Tank_Y_Center;
				Tank_X_Pos <= Tank_X_Center;
				Bullet_Y_Pos <= Tank_Y_Pos - Tank_Size - Bullet_Size;
            Bullet_X_Pos <= Tank_X_Pos;
				q_pressed <= 1'b0; // Reset q_pressed signal	
				counter<=0;	
			end	
		  end
		  
           
        else 
        begin 
				 
				 case (keycode)
					8'h0D : begin
								TankDirection <= DIR_LEFT;
								
								if ( (Tank_X_Pos - Tank_Size) <= Tank_X_Min ||left_is_background_color!=1'b1)
								begin
								Tank_X_Motion <= 0;
								Tank_Y_Motion <= 0;
								end
							   else 
								begin
								Tank_X_Motion <= -1;//j
								Tank_Y_Motion<= 0;
								end
							  end
					        
					8'h0F : begin
								TankDirection <= DIR_RIGHT;
								
								if ((Tank_X_Pos + Tank_Size) >= Tank_X_Max || right_is_background_color!=1'b1)
								begin
								Tank_X_Motion <= 0;
								Tank_Y_Motion <= 0;
								end		
								else
								begin 
					        Tank_X_Motion <= 1;//l
							  Tank_Y_Motion <= 0;
							  end
							 end

							  
					8'h0E : begin
					        TankDirection <= DIR_DOWN;
							  
								if ( (Tank_Y_Pos + Tank_Size) >= Tank_Y_Max ||bottom_is_background_color!=1'b1)
								begin
								Tank_X_Motion <= 0;
								Tank_Y_Motion <= 0;
								end
							else
								begin
					        Tank_Y_Motion <= 1;//k
							  Tank_X_Motion <= 0;
							  end
							 end
							  
					8'h0C : begin
								TankDirection <= DIR_UP;
								
								if ((Tank_Y_Pos - Tank_Size)<=Tank_Y_Min ||top_is_background_color!=1'b1)
								begin
									Tank_Y_Motion <= 0;
									Tank_X_Motion <= 0;
								end 
								else
								begin
					        Tank_Y_Motion <= -1;//I
							  Tank_X_Motion <= 0;
							  end
							 end	
				    
					8'h10 : q_pressed <= 1'b1; //M
		
					default: ;
			   endcase

				  

		if (q_pressed)
		begin
		
			if (Bullet_Y_Pos < Tank_Y_Min || Bullet_Y_Pos > Tank_Y_Max || Bullet_X_Pos < Tank_X_Min || Bullet_X_Pos > Tank_X_Max || bullet_background2==1'b1) begin // If the smaller ball has reached the edge
				Bullet_Y_Pos <= Tank_Y_Pos; // Reset the small ball Y position to the top of the larger ball
				Bullet_X_Pos <= Tank_X_Pos;
				q_pressed <= 1'b0;
			end
			
			else
            case (BulletDirection)
                DIR_UP: begin

										Bullet_Y_Pos <= Bullet_Y_Pos - Bullet_Step;
										
                        end
                DIR_LEFT: begin

										Bullet_X_Pos <= Bullet_X_Pos - Bullet_Step;
                        end
                DIR_DOWN: begin

										Bullet_Y_Pos <= Bullet_Y_Pos + Bullet_Step;
                        end
                DIR_RIGHT: begin

										Bullet_X_Pos <= Bullet_X_Pos + Bullet_Step;
                        end
            endcase
				
		end
		
		else
		begin
			// Update the smaller ball position based on the current ball
			Bullet_Y_Pos <= Tank_Y_Pos;
			Bullet_X_Pos <= Tank_X_Pos;
			BulletDirection <= TankDirection;
		end


				 Tank_Y_Pos <= (Tank_Y_Pos + Tank_Y_Motion);  // Update ball position
				 Tank_X_Pos <= (Tank_X_Pos + Tank_X_Motion);
			
			
      		if(Tank_X_Motion != 0 ||Tank_Y_Motion != 0) begin
					Tank_X_Motion <= 0;
					Tank_Y_Motion <= 0;
				end;
			
		end  //end for reset else
    end    //end for always_comb logic
       
    assign TankX = Tank_X_Pos;
    assign TankY = Tank_Y_Pos;
    assign TankS = Tank_Size;
    
	 assign BulletX = Bullet_X_Pos;
    assign BulletY = Bullet_Y_Pos;
    assign BulletS = Bullet_Size;
	 
	  // Add TankDirection output
    assign TankDirection = TankDirection;
endmodule


