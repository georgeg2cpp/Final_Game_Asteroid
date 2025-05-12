
module top_vga(
			   input wire	     clk, // 100 MHz board clock on Nexys A7
			   input wire	     rst, // Active-high reset      
			   input wire move_up,
			   input wire move_down,
			   input wire move_left,
			   input wire move_right,
			   // VGA outputs
			   output wire [3:0] vgaRed,
			   output wire [3:0] vgaGreen,
			   output wire [3:0] vgaBlue,
			   output wire	     hsync,
			   output wire	     vsync
			   );
   reg [1:0] next_state = 0; // three state "0" = menu screen, "1" = game screen, "2" = game_over
   wire [9:0] hcount;
   wire [9:0] vcount;
   wire	      hblank;
   wire	      vblank;
   wire	      pixpulse;
   wire	      is_a_wall;//, is_a_wall2, bottom_border;
   wire       empty, draw_ball;
   wire       draw_ball2,draw_ball3;
   wire [2:0] draw_balls;
   wire       draw_paddle;
   wire       draw_score;
   wire [23:0] draw_b;
   //wire [23:0] broken_b;
   reg [7:0] sc = 8'b00000000;
   wire [5:0] scored;
   wire	      move;
	reg [1:0]lives = 2'b11;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire empty_cond;
wire life_det;
	
    reg [1:0] FSM;     // initial state is 0
    wire [2:0] collision; // used to detect if the ball has collided with the ship
    wire next_collison = 0; // used to
    // values for bullet
//    reg [1:0] other_b = 1'b0;
//    wire [1:0] draw_B; 
//    wire [1:0] bullet_sc;
//    wire [9:0] ship_x;
//    wire [9:0] ship_y;
 // FSM
   localparam TITLE_SCREEN = 2'b00;     // State 0 starting screen
   localparam PLAY_GAME = 2'b01;        // state 1 game play
   localparam GAME_OVER = 2'b10;        // stae 2 game over
   // check if we collided 3 times
   localparam CRASH = 2'b11;
    
   localparam PADDLE_COLOR = 12'hf7b;
   localparam SCORE_COLOR = 12'hfff;
   localparam BLOCK_COLOR = 12'hf0a;
   localparam WALL_COLOR = 12'h00f;
   localparam BALL_COLOR = 12'h0f0;
   localparam EMPTY_COLOR = 12'h000;
   localparam BORDER_COLOR = 12'hf00;
   
   localparam BULLET_COLOR = 12'h850;
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

   ball #(325,10,0,1,10,10,3) u_ball_1 ( 
		  // Outputs
		  .draw_ball		(draw_ball),
		  .score_increment    (scored[0]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[0]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		((empty & ~draw_ball2 & ~draw_ball3)),
		  .move			(move),
		  .ship       (draw_paddle));
		  // working asteroid
 ball #(250,10,0,1,10,10,1) u_ball_2 ( 
		  // Outputs
		  .draw_ball		(draw_ball2),
		  .score_increment    (scored[1]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[1]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~ draw_ball3),
		  .move			(move),
		  .ship       (draw_paddle));		
		  
ball #(375,10,0,1,10,10,2) u_ball_3 ( 
		  // Outputs
		  .draw_ball		(draw_ball3),
		  .score_increment    (scored[2]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[2]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~draw_ball2),
		  .move			(move),
		  .ship       (draw_paddle));	  
		  	
		  	//end of original working asteroid		 
		// new asteroid
//   ball #() u_ball_1 ( 
//		  // Outputs
//		  .draw_ball		(draw_ball),
//		  .inc_score   (scored[0]),
//		  .dec_lives      (collision[0]),
//		  .xloc			(),
//		  .yloc			(),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		((empty & ~draw_ball2 & ~draw_ball3)),
//		  .move			(move));
//		  // working asteroid
// ball #() u_ball_2 ( 
//		  // Outputs
//		  .draw_ball		(draw_ball2),
//		  .inc_score   (scored[1]),
//		  .dec_lives      (collision[1]),
//		  .xloc			(),
//		  .yloc			(),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		(empty & ~draw_ball & ~ draw_ball3),
//		  .move			(move));	
		  
//ball #() u_ball_3 ( 
//		  // Outputs
//		  .draw_ball		(draw_ball3),
//		  .inc_score   (scored[2]),
//		  .dec_lives      (collision[3]),
//		  .xloc			(),
//		  .yloc			(),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		(empty & ~draw_ball & ~draw_ball2),
//		  .move			(move));
		//end of new asteroid  	
		  	 
paddle #(320,400,0,0) u_pad(
        //Outputs
        .draw_paddle    (draw_paddle),
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
		  .empty		(empty & ship_border),
	.dec_lives (life_det),
		  .move			(move));

	
//	 bullet #(450, 240,4,9) bullet1
//   (
//   //input
//    .clk        (clk), // 100 MHz system clock
//    .pixpulse       (pixpulse), // every 4 clocks for 25MHz pixel rate
//    .rst        (rst),
//    .hcount     (hcount), // x-location where we are drawing
//    .vcount     (vcount), // y-location where we are drawing
//    .empty      (empty & ~draw_ball & ~draw_ball2 & ~draw_ball3), // is this pixel empty
//    .move       (move), // signal to update the location of the ball
//    .press      (shoot),
//    .other      (1'b1),
//    .ship_x     (ship_x),
//    .ship_y     (ship_y),
//    //output
//     .draw_bullet(draw_b[1]), // is the ball being drawn here?
//     .xloc(), // x-location of the ball
//     .yloc(), // y-location of the ball
//     .inc_score (bullet_sc[0])
//    );	  
    
//    bullet #(100, 240,4,9) bullet2
//   (
//   //input
//    .clk        (clk), // 100 MHz system clock
//    .pixpulse       (pixpulse), // every 4 clocks for 25MHz pixel rate
//    .rst        (rst),
//    .hcount     (hcount), // x-location where we are drawing
//    .vcount     (vcount), // y-location where we are drawing
//    .empty      (sc), // is this pixel empty
//    .move       (move), // signal to update the location of the ball
//    .press      (shoot),
//    .other      (draw_b[1]),
//    .ship_x     (ship_x),
//    .ship_y     (ship_y),
//    //output
//     .draw_bullet(draw_b[0]), // is the ball being drawn here?
//     .xloc(), // x-location of the ball
//     .yloc(), // y-location of the ball
//     .inc_score (bullet_sc[1])
//    );
score #(80,420) s1(
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst (rst),
   	.hcount(hcount[9:0]), // x-location where we are drawing
    .vcount (vcount[9:0]), // y-location where we are drawing
    .score (sc[7:0]),
    .draw_score (draw_score)
    );
    
    
   assign is_a_wall = (((hcount < 152) & (hcount > 132)) | ((hcount < 433) & (hcount > 413)));
   
   assign is_a_wall2 = ((vcount < 1) | (vcount > 474)) & ((hcount > 137) | (hcount < 413));
   
       
   assign empty = ~(is_a_wall);
   assign ship_border = ~(is_a_wall2);
   assign empty_cond = empty & ~draw_ball & ~draw_ball2 & ~draw_ball3 & ~draw_paddle;
   assign move = (vblank & ~vblank_d1);  // move balls at start of vertical blanking
   assign asteroid_collide = (draw_ball | draw_ball2 | draw_ball3);
   
   always @(posedge clk or posedge rst) begin
      if (rst) begin
	 vblank_d1 <= 0;
	 sc <= 0;
	 FSM <= TITLE_SCREEN;
      end else if (pixpulse) begin
         vblank_d1 <= vblank;
         sc = sc + scored[0] + scored[1] + scored[2] + scored[3] + scored[4] + scored[5]; 
         FSM <= next_state;         
      end
   end

      always @(*) begin
      next_state <= FSM;
      case (FSM)
        TITLE_SCREEN: begin
            if(move_up | move_down | move_left | move_right)begin 
            next_state <= PLAY_GAME;
            end
        end
        PLAY_GAME: begin
//            if(lives == CRASH) next_state <= GAME_OVER;
//            else if(|collision) lives <= lives - 1;
		if(life_det) lives <= lives - 1;
               if((lives == CRASH)) next_state <= GAME_OVER;
        end
        GAME_OVER: begin
            if(move_up & move_down & move_left & move_right) begin
                next_state <= PLAY_GAME;
                lives <= CRASH;
                //sc <= 0;
                end
            end
       endcase   
   end

   always @(posedge clk) begin
      if (pixpulse)
        case (FSM)
        TITLE_SCREEN: begin
          current_pixel <= PADDLE_COLOR;
        end
        PLAY_GAME: begin
          current_pixel <= (is_a_wall) ? WALL_COLOR : 
         (draw_ball| draw_ball2 | draw_ball3) ? BALL_COLOR :
         (draw_paddle) ? PADDLE_COLOR:  
        (draw_score)? SCORE_COLOR:EMPTY_COLOR;
       end
       GAME_OVER:
            current_pixel <= (draw_score)? SCORE_COLOR:EMPTY_COLOR; // draw on the screen
endcase
end   
//    original working 
//   always @(posedge clk) begin
//      if (pixpulse)
//        current_pixel <= (is_a_wall) ? WALL_COLOR : 
//         (draw_ball| draw_ball2 | draw_ball3 | (|draw_balls)) ? BALL_COLOR :
//         (draw_paddle) ? PADDLE_COLOR:  
//        (draw_score)? SCORE_COLOR:EMPTY_COLOR;
//   end
   
      // Map 12-bit to 4:4:4
   assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   
