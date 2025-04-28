module top_vga(
			   input wire	     clk, // 100 MHz board clock on Nexys A7
			   input wire	     rst, // Active-high reset
			   input wire move_up,
			   input wire move_down,
			   input wire move_left,
			   input wire move_right,
			   input wire btnC,
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
   wire	      is_a_wall, empty, draw_asteroid;
//   wire	      draw_bigball;
//   wire       draw_ball2,draw_ball3;
   wire       draw_ship;
   wire       draw_score;
   wire [23:0] draw_b;
   wire [23:0] broken_b;
   reg [7:0] sc = 8'b00000000;
   wire	      move;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire all_broken;
   wire empty_cond;
 //  wire move_up,move_down,move_left,move_right;

   localparam SHIP_COLOR = 12'hf7b;     // pink color
   localparam SCORE_COLOR = 12'hfff;    // white color
   localparam BLOCK_COLOR = 12'hf0a;    // pink
   localparam WALL_COLOR = 12'h00f;     // blue
   localparam BALL_COLOR = 12'h0f0;     // Greem
   localparam EMPTY_COLOR = 12'h000;    // black color
   
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
   //---------------------------------------------
   // Asteroid generation
   //---------------------------------------------    
    asteroid_small #(320, 240, 0, 0) asteroid1(
        // outputs
        .draw_asteroid(draw_asteroid),
        .xloc(),
        .yloc(),
        // inputs
        .clk(clk),
        .pixpulse(pixpulse),
        .rst(rst),
        .hcount(hcount[9:0]),
        .vcount(vcount[9:0]),
		.empty((empty & ~draw_ship)),
		.move(move)
        );
    
//   asteroid_small #(100,30,0,0) u_ball_1 ( 
//		  // Outputs
//		  .draw_ball		(draw_ball),
//		  .xloc			(),
//		  .yloc			(),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		((empty & ~draw_bigball & ~draw_ship & ~draw_ball2 & ~draw_ball3)),
//		  .move			(move));
	  
// asteroid_big #(200,90,0,0) u_bigball ( 
//		  // Outputs
//		  .draw_ball		(draw_bigball),
//		  .xloc			(),
//		  .yloc			(),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		(empty & ~draw_ball & ~draw_ship & ~draw_ball2 & ~draw_ball3),
//		  .move			(move));

   //---------------------------------------------
   // Spaceship handling
   //---------------------------------------------		  s
spaceship #(375,440,0,0) u_ship(
        //Outputs
        .draw_ship    (draw_ship),
        .xloc           (),
        .yloc           (),
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
   //---------------------------------------------
   // Score counter
   //---------------------------------------------		  
score #(80,420) s1(
   
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst (rst),
   	.hcount(hcount[9:0]), // x-location where we are drawing
    .vcount (vcount[9:0]), // y-location where we are drawing
    .score (sc[7:0]),
    .draw_score (draw_score)
    );

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
//    genvar i;
//    generate
//    for (i = 0; i < 24; i = i + 1) begin : gen_blocks
//            block #(
//                .xloc(50 + (i % 12) * 45),
//                .yloc(50 + (i / 12) * 30)
//            ) u_block (
//                .clk(clk),
//                .pixpulse(pixpulse),
//                .rst(rst),
//                .hcount(hcount),
//                .vcount(vcount),
//                .empty(empty_cond),
//                .move(move),
//                .unbreak(all_broken),
//                .draw_block(draw_b[i]),
//                .broken(broken_b[i])
//            );
//        end
//    endgenerate
   //---------------------------------------------
   // Generate border, screen size is 640 x 480
   // border is going to be horizontal: 160-480 ;   verticle: 10-470;
   //---------------------------------------------
   assign is_a_wall = ((hcount < 160) | (hcount > 480) | (vcount < 10) | (vcount > 460));
//assign is_a_wall2 = (((hcount<330)&(hcount>310) & (vcount<280)&(vcount>200)));//Island
   
    
   assign empty = ~(is_a_wall | (|draw_b[23:0]));
   assign empty_cond = empty & ~draw_ball & ~draw_ship;
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
        current_pixel <= (is_a_wall) ? 
        WALL_COLOR : 
         (draw_ball) ? BALL_COLOR :
         (draw_ship) ? SHIP_COLOR: 
        (|draw_b[23:0])? BLOCK_COLOR: 
        (draw_score)? SCORE_COLOR:EMPTY_COLOR;
   end
   

   // Map 12-bit to 4:4:4
   assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   