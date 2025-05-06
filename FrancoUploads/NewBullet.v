`timescale 1ns / 1ps


// 3x3 ball drawing and movement control 

module bullet #(parameter xloc_start=450,
	      parameter yloc_start=240,
	      parameter xsize_div_2 = 4,
	      parameter ysize_div_2 = 9)
   (
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    input press,
    input other,
    input [9:0] ship_x,
    input [9:0] ship_y,
    output	     draw_bullet, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
     output reg [9:0] yloc, // y-location of the ball
     output reg inc_score
    
    );

   reg [ysize_div_2*2:0]			 occupied_lft;
   reg [ysize_div_2*2:0]			 occupied_rgt;
   reg [xsize_div_2*2:0]			 occupied_bot;
   reg [xsize_div_2*2:0]			 occupied_top;
   reg				 xdir, ydir;
   reg				 update_neighbors;

  //reg [4:0] horiz_move = 5'd31;
 
  
  
   wire right_side, left_side, bottom_side,top_side;
   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   
 reg undrawed;
 assign draw_bullet = ((hcount <= xloc+xsize_div_2) & (hcount >= xloc-xsize_div_2) & 
			(vcount <= yloc+ysize_div_2) & (vcount >= yloc-ysize_div_2)) ?  ~undrawed : 0;
   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 0;
	   occupied_rgt <= 0;
	   occupied_bot <= 0;
	   occupied_top <= 0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (update_neighbors) begin
	      occupied_lft <= 0;
	      occupied_rgt <=0;
	      occupied_bot <= 0;
	      occupied_top <= 0;
	   end 
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
   
   assign right_side = |occupied_rgt[((ysize_div_2*2)-1):1];
   assign left_side = |occupied_rgt[((ysize_div_2*2)-1):1];
   assign bottom_side = |occupied_bot[((xsize_div_2*2)-1):1];
   assign top_side = |occupied_top[((xsize_div_2*2)-1):1];

   
   
   
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   xloc <= xloc_start;
	   yloc <= yloc_start;
	  
	   update_neighbors <= 0;
	   inc_score <= 0;
       
	end else if (pixpulse) begin
	   update_neighbors <= 0; // default
        inc_score <= 0;
        undrawed <= (xloc == xloc_start);
	   if (move) begin
	   
	       if (press & undrawed & other) begin//& other bullet
	           xloc <= ship_x;
	           yloc <= ship_y - 35;       
	           
	       end
	       else if(~undrawed) begin
	           yloc <= yloc - 2;
	       end
	       
	       
	       
	       
//            if(yloc <= (ysize_div_2 + 10)) begin
//            inc_score <= 1;
//            yloc <= yloc + 3;
//       end
           

         // case (horz_move_adj)
           // 2'b10: xloc <= xloc - 1;
            //2'b01: xloc <= xloc + 1;
            //default: xloc <= xloc;
          //endcase
     
          
	  

	      update_neighbors <= 1;
         // undrawed = (xloc == xloc_start);
       if(yloc < 20)begin
                xloc <= xloc_start;
               yloc <= yloc_start;
                
        end
          else if(top_side | right_side | left_side) begin
                  xloc <= xloc_start;
               yloc <= yloc_start;
               inc_score <= 1;
                
          end
	   end 
	end 
     end
   
endmodule
