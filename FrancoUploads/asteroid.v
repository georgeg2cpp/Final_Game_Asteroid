`timescale 1ns / 1ps


module asteroid # (parameter xloc_start = 320, //Adjust in top module with pseudo-RNG
                   parameter yloc_start = 0,
                   parameter xsize_div_2 = 10,//No need for separate module for large asteroid...
                   parameter ysize_div_2 = 10,//This parameter gives half of the specified dimension on the asteroid
                   parameter xdir_start = 0, //Can adjust parameter in top module to make it go diagonally
                   parameter ydir_start = 1,
                   parameter start_speed = 1)(//Can adjust in top module to increase speed
    input	     clk, 
    input	     pixpulse, 
    input	     rst,
    input [9:0]	     hcount, 
    input [9:0]	     vcount,
    input unbreak,                //Adapted from 'block' module. Uncertain whether this will be used
    //input [1:0] break_conditions,//What did the asteroid collide with? 
    //input [7:0] pre_score, //Have the score be carried into asteroid module and have it be-
    input	     empty,       //-incremented by the module depending on what the asteroid hit.
   // input [1:0] pre_lives,  //See above comment, except for 'lives' of the ship
    input	     move,      //Note: Need to have bus in top module for lives_next-
    
   
    output	     draw_ast, //-and other buses as to properly change value in following clk cycle
    output reg [9:0] xloc, //Note: If we are including life tracking capabilities, I am not-
    output reg [9:0] yloc,//-sure if checking for 0 lives happens here or in top module (probs latter)
    output reg broken,
    //output reg [7:0] post_score,
   // output reg [1:0] post_lives,
    output reg inc_score
    );
    reg [5:0]			 occupied_lft;
    reg [5:0]			 occupied_rgt;
    reg [5:0]			 occupied_bot;
    reg [5:0]			 occupied_top;
    reg				 xdir, ydir;
    reg				 update_neighbors;
    
    wire blk_lft = |occupied_lft;
    wire blk_rgt = |occupied_rgt;
    wire blk_bot = |occupied_bot;
    
    reg [2:0] speed = start_speed;
    localparam END_SCREEN = 2'b00;
    localparam HIT_BULLET = 2'b01;
    localparam HIT_SHIP = 2'b10;
    assign draw_ast = (hcount <= xloc+xsize_div_2) & (hcount >= xloc-xsize_div_2) & 
			(vcount <= yloc+ysize_div_2) & (vcount >= yloc-ysize_div_2) ?  ~broken : 0;
	always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 0;
	   occupied_rgt <= 0;
	   occupied_bot <= 0;
	   occupied_top <= 0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (vcount >= yloc-(ysize_div_2+1) && vcount <= yloc+(ysize_div_2+1)) 
	     if (hcount == xloc+(xsize_div_2+1))
	       occupied_rgt[(yloc-vcount+(ysize_div_2+1))] <= ~empty;  // LSB is at bottom
	     else if (hcount == xloc-(xsize_div_2+1))
	       occupied_lft[(yloc-vcount+(ysize_div_2+1))] <= ~empty;
	      
	   if (hcount >= xloc-(xsize_div_2+1) && hcount <= xloc+(xsize_div_2+1)) 
	     if (vcount == yloc+(ysize_div_2+1))
	       occupied_bot[(xloc-hcount+(xsize_div_2+1))] <= ~empty;  // LSB is at right
	     else if (vcount == yloc-(ysize_div_2+1))
	       occupied_top[(xloc-hcount+(xsize_div_2+1))] <= ~empty;
	end
     end	      
     always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   broken <= 0;
	   inc_score <= 0;
	   speed = start_speed;
	end else if (pixpulse) begin
	
	
	   if (unbreak) begin
	      broken <= 0;//Possibly put asteroid limit for how many can be on screen at a time
	   end            //Could increase as time goes on...
	   if (move) begin
	      // inc_score <= 0;
	           if((yloc+ysize_div_2+1) <= 10) begin
		          yloc <= 60;//(ysize_div_2)+(ysize_div_2)+5;//Moves asteroid to top of screen
		          speed <= speed + 1;
		        //To-Do: Put code to increase the speed
		        end
	      if (blk_lft | blk_bot | blk_rgt) begin
		      broken <= 1;//Could assign as broken, or set position to top of screen for asteroid
		                  //to keep falling down until it collides with something else
		                  //These comments also apply to 'END_SCREEN' case statement below
		      //inc_score <= 1;  
		        
		        
		        /*  case (break_conditions)
		              END_SCREEN: begin
		                  
		 
		 
		                          end
		              HIT_BULLET: begin
		              post_score = pre_score + 1;
		              
		              
		                          end
		              HIT_SHIP:begin
		              post_lives = pre_lives - 1;
		              
		                      end
		              
		          endcase*/
		          
	      end
	      else begin
	           yloc <= yloc + speed;
	      end
	      if(broken) begin
	           broken <= 0;
	           inc_score <= 1;
	           //xloc = random between a and b 
	           //yloc = 60
	           //speed = speed + 1 if(score high enough) or enough time passes
	
	end
	   end 
	end 
     end		
			
		
endmodule
