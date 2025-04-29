`timescale 1ns / 1ps
module bullet #(parameter xloc_start=320,
	      parameter yloc_start=240,
	      parameter ydir_start= -1)(
    input	     clk,
    input	     pixpulse, 
    input	     rst,
    input      [1:0] bullet_count, //If # of bullets is 2'b11, do not draw bullet /// might omit, main_VGA will track bullet amount
    input [9:0]	     hcount, 
    input [9:0]	     vcount,
    input fire, // check if we can fire this bullet max 3 bullet
    input firePosX,    // x-location of ship firing the bullet
    input firePosY,    // y-location of ship firing the bullet
    input button_pressed, //Needs to be incorporated into code, if statement or case statement
    input	     empty, 
    input	     move, // signal to update the location of the ball
    output	     draw_bullet, //
    output reg [9:0] xloc,
    output reg [9:0] yloc,
    output reg [1:0] new_bullet_count,
    output reg broken 
    );
    
   reg [4:0]			 occupied_lft;
   reg [4:0]			 occupied_rgt;
   reg [4:0]			 occupied_bot;
   reg [4:0]			 occupied_top;
   reg				 xdir, ydir;
   reg				 update_neighbors;
   wire                  drawable;
   wire				 blk_lft, blk_rgt;
   wire				 blk_up, blk_dn;
       assign drawable = ~(&bullet_count);
       assign draw_bullet = (drawable & (hcount <= xloc+4) & (hcount >= xloc-4) & (vcount <= yloc+9) & (vcount >= yloc-9)) ?  ~broken : 0;
 always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 5'b0;
	   occupied_rgt <= 5'b0;
	   occupied_bot <= 5'b0;
	   occupied_top <= 5'b0;
	end else if (pixpulse) begin  
	   if (update_neighbors) begin
	      occupied_lft <= 5'b0;
	      occupied_rgt <= 5'b0;
	      occupied_bot <= 5'b0;
	      occupied_top <= 5'b0;
	   end else if (~empty) begin
	      if (vcount >= yloc-10 && vcount <= yloc+10) 
		if (hcount == xloc+5)
		  occupied_rgt[(yloc-vcount+10)] <= 1'b1;  
		else if (hcount == xloc-5)
		  occupied_lft[(yloc-vcount+10)] <= 1'b1;
	      
	      if (hcount >= xloc-5 && hcount <= xloc+5) 
		if (vcount == yloc+10)
		  occupied_bot[(xloc-hcount+5)] <= 1'b1;  
		else if (vcount == yloc-10)
		  occupied_top[(xloc-hcount+5)] <= 1'b1;
	   end
	end
     end	      
     assign blk_lft = |occupied_lft; 
   assign blk_rgt = |occupied_rgt;  

   assign blk_up = |occupied_top; 
   assign blk_dn = |occupied_bot;
     
     
    always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   xloc <= xloc_start;
	   yloc <= yloc_start;
	   //xdir <= xdir_start;
	   ydir <= ydir_start;
	   new_bullet_count <= 2'b00;
	   broken <= 0;
	   update_neighbors <= 0;
	end else if (pixpulse) begin
	   update_neighbors <= 0; // we might not need to use update neighbor
	   if(fire) broken <= 0;
	   if (move) begin
            if((blk_up) | (blk_lft) | (|blk_rgt)) begin
                new_bullet_count = bullet_count - 1;
                broken <= 1;
                end
            else begin
            yloc <= yloc - 2;
            end
            
//PUT IN CODE TO ACCOUNT FOR BUTTON PRESS
	      update_neighbors <= 1;
	   end 
	end 
     end
endmodule
