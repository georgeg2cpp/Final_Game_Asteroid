// 3x3 ball drawing and movement control 

module ball #(parameter xloc_start=320,
	      parameter yloc_start=240,
	      parameter xdir_start=0,
	      parameter ydir_start=0,
	      parameter xsize = 10,
	      parameter ysize = 10,
	      parameter [3:0] down = 1)
   (
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    input        ship,
    output	     draw_ball, // is the ball being drawn here?
    output collision,
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc, // y-location of the ball
    output reg score_increment
    );

   reg [ysize*2:0]			 occupied_lft;
   reg [ysize*2:0]			 occupied_rgt;
   reg [xsize*2:0]			 occupied_bot;
   reg [xsize*2:0]			 occupied_top;
   
   reg [2:0] speed = down; //Kind of vertical speed
   reg [2:0] shot_clk = 1;//Keeps track of how many times the asteroid has reset vertical position
   
   reg				 xdir, ydir;
   reg				 update_neighbors;
   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
   assign draw_ball = (hcount <= xloc+xsize) & (hcount >= xloc-xsize) & (vcount <= yloc+ysize) & (vcount >= yloc-ysize) ?  1 : 0;
   assign collision = (ship)? 1:0;
   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 5'b0;//ysize_div_2*2 bits
	   occupied_rgt <= 5'b0;
	   occupied_bot <= 5'b0;
	   occupied_top <= 5'b0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (update_neighbors) begin
	      occupied_lft <= 5'b0;
	      occupied_rgt <= 5'b0;
	      occupied_bot <= 5'b0;
	      occupied_top <= 5'b0;
	   end else if (~empty) begin
	      if (vcount >= yloc-(ysize+1) && vcount <= yloc+(ysize+1)) 
		if (hcount == xloc+(xsize+1))
		  occupied_rgt[(yloc-vcount+(ysize+1))] <= 1'b1;  // LSB is at bottom
		else if (hcount == xloc-(xsize+1))
		  occupied_lft[(yloc-vcount+(ysize+1))] <= 1'b1;
	      
	      if (hcount >= xloc-(xsize+1) && hcount <= xloc+(xsize+1)) 
		if (vcount == yloc+(ysize+1))
		  occupied_bot[(xloc-hcount+(ysize+1))] <= 1'b1;  // LSB is at right
		else if (vcount == yloc-(ysize+1))
		  occupied_top[(xloc-hcount+(xsize+1))] <= 1'b1;
	   end
	end
     end	      


   assign blk_lft_up = |occupied_lft[ysize*2:ysize*2-1];  // upper left pixels are blocked
   assign blk_lft_dn = |occupied_lft[2:1];  // lower left pixels are blocked
   assign blk_rgt_up = |occupied_rgt[ysize*2:ysize*2-1];  // upper right pixels are blocked
   assign blk_rgt_dn = |occupied_rgt[2:1];  // lower right pixels are blocked

   assign blk_up_lft = |occupied_top[ysize*2:ysize*2-1];  // left-side top pixels are blocked
   assign blk_up_rgt = |occupied_top[2:1];  // right-side top pixels are blocked
   assign blk_dn_lft = |occupied_bot[ysize*2:ysize*2-1];  // left-side bottom pixels are blocked
   assign blk_dn_rgt = |occupied_bot[2:1];  // right-side bottom pixels are blocked

   assign corner_lft_up = occupied_lft[ysize*2] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
   assign corner_rgt_up = occupied_rgt[ysize*2] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
   assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
   assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   xloc <= xloc_start;
	   yloc <= yloc_start;
	   xdir <= xdir_start;
	   ydir <= ydir_start;
	   speed <= down;
	   update_neighbors <= 0;
	end else if (pixpulse) begin
	   score_increment <= 0;
	   update_neighbors <= 0; // default
	   if (move) begin
	       if(speed == 0)
	           speed = 1;
	       case ({xdir,ydir})
		2'b00: begin  // heading to the left and up
		   if (blk_lft_up | corner_lft_up) 
		      begin
		      xloc <= xloc + 1;
		      xdir <= ~xdir;
		      end 
		   else 
		      begin
		      xloc <= xloc - 1;
		      end
		   if (blk_up_lft | corner_lft_up)
		       begin
		      yloc <= yloc + speed;
//		      ydir <= ~ydir;
		       end 
//		       else 
//		          begin
//		          yloc <= yloc - 1;
//		          end
		end
		2'b01: begin  // heading to the left and down
		   // complete this code
		   if(blk_lft_dn | corner_lft_dn) begin
		   xloc<=xloc+1;
		   xdir <= ~xdir;
		   end
		   else begin
		   xloc<=xloc-1;
		   end
		   if(blk_dn_lft | corner_lft_dn) begin
//		   yloc <=yloc-1;
//		   ydir <= ~ydir;
		   end
		   else begin
		   yloc <= yloc+speed; end
		   end
		   
		
		2'b10: begin  // heading to the right and up
		   // complete this code
		   if(blk_rgt_up | corner_rgt_up) begin
		   xloc<=xloc - 1;
		   xdir <= ~xdir; end
		   else begin
		   xloc<=xloc+1; end
		   if(blk_up_rgt | corner_rgt_up) begin
		   yloc <= yloc+speed;
		   //ydir<= ~ydir;
		   end
//		   else begin
//		   yloc <= yloc - 1; end
		   
		end
		2'b11: begin  // heading to the right and down
		   // complete this code
		   if(blk_rgt_dn | corner_rgt_dn) begin
		   xloc<=xloc - 1;
		   xdir <= ~xdir;
		   end
		   else begin
		   xloc <= xloc+1;
		   end
		   if(blk_dn_rgt | corner_rgt_dn) begin
		   //yloc<=yloc-1;
		   //ydir=~ydir; 
		   end
		   else begin
		   yloc <= yloc + speed; end
		end
	      endcase 
	      if(yloc >= 480) begin
	            shot_clk = shot_clk + 1;
                yloc <= 0;
                score_increment <= 1;                
                if ((xloc <= 132) | (xloc >=413)) begin
                    xloc <= 200;                    
                end
                if(shot_clk == 0)begin
                    shot_clk = 1;
                    if(speed >= 5)
                        speed = 2;
                    else
                        speed = speed + 1;
                end
              
             end  
             if(collision) begin
                yloc <= 0;
                speed = 1;
                end 
	      update_neighbors <= 1;
	   end 
	end 
     end
   
endmodule // ball

//`timescale 1ns / 1ps


//// 3x3 ball drawing and movement control 

//module ball #(parameter xloc_start=320,
//	      parameter yloc_start=240,
//	      parameter xsize_div_2 = 10,
//	      parameter ysize_div_2 = 10,
//	      parameter xdir_start=0,
//	      parameter ydir_start=1,
//        parameter [0:0] left = 0,
//        parameter step_size = 31)
//   (
//    input	     clk, // 100 MHz system clock
//    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
//    input	     rst,
//    input [9:0]	     hcount, // x-location where we are drawing
//    input [9:0]	     vcount, // y-location where we are drawing
//    input	     empty, // is this pixel empty
//    input	     move, // signal to update the location of the ball
//    output	     draw_ball, // is the ball being drawn here?
//    output reg [9:0] xloc, // x-location of the ball
//     output reg [9:0] yloc, // y-location of the ball
//     output reg inc_score,
//     output reg dec_lives
//    );

//   reg [ysize_div_2*2:0]			 occupied_lft;
//   reg [ysize_div_2*2:0]			 occupied_rgt;
//   reg [xsize_div_2*2:0]			 occupied_bot;
//   reg [xsize_div_2*2:0]			 occupied_top;
//   reg				 xdir, ydir;
//   reg				 update_neighbors;

  
//  reg [3:0] vert_move = 1; //Kind of vertical speed
//  reg [4:0] shot_clk = 1;//Keeps track of how many times the asteroid has reset vertical position
//  reg [4:0] count = 0; //Timer to judge how long until asteroid moves to left or right (which is based on parameter above 'left')
//  reg [1:0] horz_move;//Used for case statement to determine which horrizontal direction asteroid moves
//  reg [1:0] horz_move_adj;//Actually used for what's mentioned above, depends on above line as well as if asteroids have had to change course
//  reg change_dir = 0;//Used for the two above instantiations
//  reg [8:0] rand = 9'b000000001;//the $random thing you saw online only works in simulations, so I had to simulation RNG with a LFSR or johnson counter of sorts.
  
//   wire right_side, left_side, bottom_side;
//   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
//   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
//   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
//   // are we pointing at a pixel in the ball?
//   // this will make a square ball...
// assign draw_ball = (hcount <= xloc+xsize_div_2) & (hcount >= xloc-xsize_div_2) & 
//			(vcount <= yloc+ysize_div_2) & (vcount >= yloc-ysize_div_2) ?  1 : 0;
//   // hcount goes from 0=left to 640=right
//   // vcount goes from 0=top to 480=bottom
   
//   // keep track of the neighboring pixels to detect a collision
//   always @(posedge clk or posedge rst)
//     begin
//	if (rst) begin
//	   occupied_lft <= 0;
//	   occupied_rgt <= 0;
//	   occupied_bot <= 0;
//	   occupied_top <= 0;
//	end else if (pixpulse) begin  // only make changes when pixpulse is high
//	   if (update_neighbors) begin
//	      occupied_lft <= 0;
//	      occupied_rgt <=0;
//	      occupied_bot <= 0;
//	      occupied_top <= 0;
//	   end 
//	    if (vcount >= yloc-(ysize_div_2+1) && vcount <= yloc+(ysize_div_2+1)) 
//	     if (hcount == xloc+(xsize_div_2+1))
//	       occupied_rgt[(yloc-vcount+(ysize_div_2+1))] <= ~empty;  // LSB is at bottom
//	     else if (hcount == xloc-(xsize_div_2+1))
//	       occupied_lft[(yloc-vcount+(ysize_div_2+1))] <= ~empty;
	      
//	   if (hcount >= xloc-(xsize_div_2+1) && hcount <= xloc+(xsize_div_2+1)) 
//	     if (vcount == yloc+(ysize_div_2+1))
//	       occupied_bot[(xloc-hcount+(xsize_div_2+1))] <= ~empty;  // LSB is at right
//	     else if (vcount == yloc-(ysize_div_2+1))
//	       occupied_top[(xloc-hcount+(xsize_div_2+1))] <= ~empty;
	   
	    
//	end
//     end	      


//   assign blk_lft_up = |occupied_lft[3:2];  // upper left pixels are blocked
//   assign blk_lft_dn = |occupied_lft[2:1];  // lower left pixels are blocked
//   assign blk_rgt_up = |occupied_rgt[3:2];  // upper right pixels are blocked
//   assign blk_rgt_dn = |occupied_rgt[2:1];  // lower right pixels are blocked

//   assign blk_up_lft = |occupied_top[3:2];  // left-side top pixels are blocked
//   assign blk_up_rgt = |occupied_top[2:1];  // right-side top pixels are blocked
//   assign blk_dn_lft = |occupied_bot[3:2];  // left-side bottom pixels are blocked
//   assign blk_dn_rgt = |occupied_bot[2:1];  // right-side bottom pixels are blocked

//   assign corner_lft_up = occupied_lft[4] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
//   assign corner_rgt_up = occupied_rgt[4] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
//   assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
//   assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   
//   assign right_side = |occupied_rgt[((ysize_div_2*2)-1):1];
//   assign left_side = |occupied_rgt[((ysize_div_2*2)-1):1];
//   assign bottom_side = |occupied_bot[((xsize_div_2*2)-1):1];
   
//   always @(posedge clk or posedge rst)
//     begin
//	if (rst) begin
//	   xloc <= xloc_start;
//	   yloc <= yloc_start;
//	   xdir <= xdir_start;
//	   ydir <= ydir_start;
//	   update_neighbors <= 0;
//       inc_score <= 0;
//       dec_lives <= 0;
//       shot_clk <= 1;
//       count <= 0;
//       horz_move <= 0;
//    horz_move_adj <= 0;
//       rand = 9'b000000001;
//       vert_move <= 1;
//	end else if (pixpulse) begin
//	   update_neighbors <= 0; // default
//    inc_score <= 0;
//    dec_lives <= 0;
//    horz_move <= 0;
//    horz_move_adj <= 0;
//    rand <= {rand[7:0],(rand[8]^rand[4])};//Used for pseudo RNG
//    if (shot_clk[2:0] == 0) vert_move <= vert_move + 1; //Every 8 times the ball reaches the bottom it should speed up. In practice every 5-8 times the asteroids get stuck at the top of the screen.
//                                                        //Hitting them with the ship resets it, but its pretty weird, could you try looking into this please?
//    if(count == step_size) horz_move <= {left,~left};//'X' is the step size. Every 'X' clock cycles the asteroid is going to move 1 pixel left/right (depends on parameter).
//    if (left_side | right_side) change_dir <= ~change_dir;//If an asteroid was supposed to go left it will change direction. Could improve by hard coding for each side of a collision. Ex: Blocked on right side-> {1,0} and vice versa
//    horz_move_adj <= horz_move ^ {2{change_dir}};
//	   if (move) begin
//       if(yloc <= (ysize_div_2 + 10)) begin//If the asteroid has just relocated to top of screen.
//         inc_score <= 1;                  //Toggle score to change (used in top module)
//         shot_clk <= (shot_clk+1);
//         yloc <= yloc + 3;                //An attempt to fix an issue that I mentioned above, but didn't work.
//       end
//      yloc <= yloc + vert_move;        //Adjusts y location by the speed.

//       case (horz_move_adj)          //Forgot why it had to be two bits, probably works better with 1. If the asteroid is called to move left, it will do so and vice versa.
//            2'b10: xloc <= xloc - 1;
//            2'b01: xloc <= xloc + 1;
//            default: xloc <= xloc;
//          endcase
//      yloc <= yloc + vert_move;
          
	 
//	      update_neighbors <= 1;
//          count <= count + 1;
//       if(yloc > 475 - (ysize_div_2))begin //If bottom of screen is reached, reset y location, x remains unchanged.
//        yloc <= (ysize_div_2 + 10);
//        end
//       else if(bottom_side) begin //If collision with ship...
//         yloc <= (ysize_div_2+10);//" " " "
//            dec_lives <= 1;    //Toggle to decrease life count in top module. See line about scores
//         xloc <= (140) + (rand % 256);  //Pseudo RNG, works like a charm.
//          end
//	   end 
//	end 
//     end
   
//endmodule
