// 3x3 ball drawing and movement control 

module ball #(parameter xloc_start=320,
	      parameter yloc_start=240,
	      parameter xdir_start=0,
	      parameter ydir_start=0,
	      parameter xsize = 10,
	      parameter ysize = 10,
	      parameter [2:0] down = 2,
	      parameter [2:0] horizontal = 1)
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
    output reg collision,
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc, // y-location of the ball
    output reg score_increment
    );

   reg [ysize*2:0]			 occupied_lft;
   reg [ysize*2:0]			 occupied_rgt;
   reg [xsize*2:0]			 occupied_bot;
   reg [xsize*2:0]			 occupied_top;
   
   reg [2:0] Verticle = down; //Kind of vertical speed
   reg [2:0] LF = horizontal; //Kind of vertical speed
   reg [2:0] shot_clk = 1;//Keeps track of how many times the asteroid has reset vertical position
   reg [2:0] score_x, score_y;
   reg				 xdir, ydir;
   reg				 update_neighbors;
   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
   assign draw_ball = (hcount <= xloc+xsize) & (hcount >= xloc-xsize) & (vcount <= yloc+ysize) & (vcount >= yloc-ysize) ?  1 : 0;
   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 5'b0;
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
	   Verticle <= down;
	   update_neighbors <= 0;
	   score_x <= 0;
	   score_y <= 0;
	end else if (pixpulse) begin
	   score_increment <= 0;
	   update_neighbors <= 0; // default
	   collision <= 0;
	   score_x <= 0;
	   score_y <= 0;
	   if (move) begin
	       if(Verticle == 0) Verticle = 1;
	       if (|occupied_lft | |occupied_rgt | |occupied_bot) begin
	           collision <= 1;
	            xloc <= xloc + LF;
                yloc <= 12;
                if(xloc < 10 | xloc > 610 ) xloc <= 100;
	       end else begin
	       xloc <= xloc + LF;
           yloc <= yloc + Verticle;
           if(yloc >= 500) begin
                score_increment <= 1;
                yloc <= 10;
                if(xloc < 10 | xloc > 610 ) xloc <= 100;
           end 
           end

     end
     end
     end
   
endmodule // ball

