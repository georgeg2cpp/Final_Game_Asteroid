
module top_vga(
			   input wire	     clk, // 100 MHz board clock on Nexys A7
			   input wire	     rst, // Active-high reset
			   input wire move_up,
			   input wire move_down,
			   input wire move_left,
			   input wire move_right,
			   input wire shoot,
			   // VGA outputs
			   output wire [3:0] vgaRed,
			   output wire [3:0] vgaGreen,
			   output wire [3:0] vgaBlue,
			   output wire	     hsync,
			   output wire	     vsync
			   );

   wire [9:0] hcount;
   wire [9:0] vcount;
   wire	      hblank;
   wire	      vblank;
   wire	      pixpulse;
   wire	      is_a_wall, empty, draw_ball;
   wire	      draw_bigball;
   wire       draw_ball2,draw_ball3;
   wire       draw_paddle;
   wire       draw_score;
   wire [23:0] draw_b;
    wire [23:0] broken_b;
   reg [7:0] sc = 8'b00000000;
   wire	      move;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire all_broken;
   wire bullet_broken;
   wire unbreak_bullet;
   wire draw_bullet;
   wire empty_cond;
   
   wire [4:0] ast_tracker;
   wire [1:0] lives;
 
 //  wire move_up,move_down,move_left,move_right;

   localparam PADDLE_COLOR = 12'hfd0;
   localparam SCORE_COLOR = 12'hfff;
   localparam BLOCK_COLOR = 12'hf0a;
   localparam WALL_COLOR = 12'hf00;
   localparam BALL_COLOR = 12'h850;
   localparam EMPTY_COLOR = 12'h000;//Background
   
   //---------------------------------------------
   // VGA Timing Generator
   //---------------------------------------------
   vga_timing vga_gen (
		       .clk    (clk),
		       .pixpulse (pixpulse),
		       .rst    (rst),  //active high
		       .hcount (hcount[9:0]),
		       .vcount (vcount[9:0]),
		       .hsync  (hsync),
		       .vsync  (vsync),
		       .hblank (hblank),
		       .vblank (vblank)
		       );

   ball #(320,30,10,10,1,1,0,31) u_ball_1 ( 
		  // Outputs
		  .draw_ball		(draw_ball),
		  .xloc			(),
		  .yloc			(),
		  .inc_score (),
		  .dec_lives (),
		//  .inc_score(),
		//  .broken(),
		  // Inputs
		//  .unbreak(1'b1),
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		((empty) & ~draw_paddle & ~draw_ball2 & ~draw_ball3),
		  .move			(move));
 ball #(250,30,10,10,1,1,1,20) u_ball_2 ( 
		  // Outputs
		  .draw_ball		(draw_ball2),
		  .xloc			(),
		  .yloc			(),
		   .inc_score (),
		  .dec_lives (),
		//  .inc_score(),
		//  .broken(),
		  // Inputs
		 // .unbreak(1'b1),
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_paddle & ~draw_ball & ~draw_ball3),
		  .move			(move));	
ball #(380,30,10,10,1,1,0,10) u_ball_3 ( 
		  // Outputs
		  .draw_ball		(draw_ball3),
		  .xloc			(),
		  .yloc			(),
		   .inc_score (),
		  .dec_lives (),
		  // Inputs
		 // .inc_score(),
		 // .broken(),
		  // Inputs
		 // .unbreak(1'b1),
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_paddle & ~draw_ball2 & ~draw_ball),
		  .move			(move));	  
		  
 /*bigball #(200,90,0,0) u_bigball ( 
		  // Outputs
		  .draw_ball		(draw_bigball),
		  .xloc			(),
		  .yloc			(),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~draw_paddle & ~draw_ball2 & ~draw_ball3),
		  .move			(move));
*/		  
paddle #(320,400) u_pad(
        //Outputs
        .draw_ship    (draw_paddle),
        .xloc           (ship_x),
        .yloc           (ship_y),
        //Inputs
        .clk			(clk),
        .mU             (move_up),
        .mD             (move_down),
        .mL             (move_left),
        .mR             (move_right),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~draw_bigball & ~draw_ball2 & ~draw_ball3),
		  .move			(move));
score #(80,40) s1(
   
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst (rst),
   	.hcount(hcount[9:0]), // x-location where we are drawing
    .vcount (vcount[9:0]), // y-location where we are drawing
    .score (sc[7:0]),
    .draw_score (draw_score)
    );
//module bullet #(parameter xloc_start=320,
//	      parameter yloc_start=240,
//	      parameter ydir_start=1)(
//input	     clk,
//    input	     pixpulse, 
//    input	     rst,
//   // input      [1:0] bullet_count, //If # of bullets is 2'b11, do not draw bullet
//    input unbreak,
//    input [9:0]	     hcount, 
//    input [9:0]	     vcount,
//    input button_pressed, //Needs to be incorporated into code, if statement or case statement
//    input	     empty, 
//    input	     move, // signal to update the location of the ball
//    output	     draw_bullet, //
//    output reg [9:0] xloc,
//    output reg [9:0] yloc,
//   // output reg [1:0] new_bullet_count,
//    output reg broken 
//    );



/*  block #(120,100,20,10) b1
   (
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount[9:0]), // x-location where we are drawing
    .vcount(vcount[9:0]), // y-location where we are drawing
    .empty (1'b1) , // is this pixel empty
    .move(move), // signal to update the status of the block
    .unbreak(all_broken),  // reset the block
    .draw_block(draw_b[0]), // is the block being drawn here?
    .broken(broken_b[0]) // is this block broken
    );
    block #(150,100,20,10) b2
   (
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount[9:0]), // x-location where we are drawing
    .vcount(vcount[9:0]), // y-location where we are drawing
    .empty (1'b1) , // is this pixel empty
    .move(move), // signal to update the status of the block
    .unbreak(all_broken),  // reset the block
    .draw_block(draw_b[0]), // is the block being drawn here?
    .broken(broken_b[0]) // is this block broken
    );*/
  /*  genvar i;
    generate
    for (i = 0; i < 24; i = i + 1) begin : gen_blocks
            block #(
                .xloc(50 + (i % 12) * 45),
                .yloc(50 + (i / 12) * 30)
            ) u_block (
                .clk(clk),
                .pixpulse(pixpulse),
                .rst(rst),
                .hcount(hcount),
                .vcount(vcount),
                .empty(empty_cond),
                .move(move),
                .unbreak(all_broken),
                .draw_block(draw_b[i]),
                .broken(broken_b[i])
            );
        end
    endgenerate
    */
   assign is_a_wall = (((hcount < 137) & (hcount > 132)) | ((hcount < 418) & (hcount > 413)));//Borders
  assign is_a_wall2 = ((vcount>475) & (hcount > 132) & (hcount < 418));//Island
     wire [9:0] ship_x;
   wire [9:0] ship_y ;
    
   assign empty = ~(is_a_wall)| is_a_wall2;
   assign empty_cond = empty & ~draw_ball & ~draw_bigball & ~draw_ball2 & ~draw_ball3 & ~draw_paddle;
assign all_broken = &broken_b;
   assign move = (vblank & ~vblank_d1);  // move balls at start of vertical blanking
reg [23:0] blk_next;
   always @(posedge clk or posedge rst) begin
      if (rst) begin
	 vblank_d1 <= 0;
	 sc = 0;
      end else if (pixpulse) begin
      if(blk_next ^ broken_b) begin
      sc = sc+1;
      end
      
         vblank_d1 <= vblank;
         blk_next = broken_b;
      end
   end
   
   // Register the current pixel
   always @(posedge clk) begin
      if (pixpulse)
        current_pixel <= (is_a_wall|is_a_wall2) ? 
        WALL_COLOR : 
         (draw_ball  | draw_ball2 | draw_ball3) ? BALL_COLOR :
         (draw_paddle) ? PADDLE_COLOR: 
        (draw_bullet)? BLOCK_COLOR: 
        (draw_score)? SCORE_COLOR:EMPTY_COLOR;
   end
   

   // Map 12-bit to 4:4:4
   assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   
