
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
   wire	      is_a_wall;
   wire       empty; 
   wire [4:0] draw_ball;
   wire       draw_text;
   wire [3:0] draw_balls;
   wire       draw_paddle;
   wire       draw_score;
   wire [23:0] draw_b;
   //wire [23:0] broken_b;
   reg [8:0] sc = 8'b00000000;
   reg [8:0] temp_sc = 8'b00000000;
   wire [5:0] scored, scoreds;
   wire	      move;
   reg [1:0] lives = 2'b11;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire empty_cond;
   wire life_det = 0;
    reg [1:0] FSM;     // initial state is 0
    wire [4:0] collision, collisions; // used to detect if the ball has collided with the ship
    wire next_collison = 0; // used to

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
   localparam TEXT_COLOR = SCORE_COLOR;
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
    text_render #(300,232) r1
(
    .clk (clk),
    .vcount(vcount),
    .hcount(hcount),
    .state_set(FSM),
    .char_on (draw_text),
    .char_pixel()

);
//genvar i;
//    generate
//    for (i = 0; i < 5; i = i + 1) begin : gen_asteroid
//               ball #(100 + i * 75,10,1,1,10,10,3)
//                u_ball ( 
//		  // Outputs
//		  .draw_ball		(draw_ball[i]),
//		  .score_increment    (scored[i]),
//		  .xloc			(),
//		  .yloc			(),
//		  //.collision      (collision[i]),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst | FSM == GAME_OVER),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		(~draw_paddle),
//		  .move			(move & FSM),
//		  .ship       (draw_paddle));
//        end
//    endgenerate
    
//genvar j;
//    generate
//    for (j = 0; j < 5; j = j + 1) begin : gen_asteroid2
//               ball #(600 - j * 75,10,1,1,10,10,3)
//                u_ball ( 
//		  // Outputs
//		  .draw_ball		(draw_balls[j]),
//		  .score_increment    (scoreds[j]),
//		  .xloc			(),
//		  .yloc			(),
//		  //.collision      (collisions[j]),
//		  // Inputs
//		  .clk			(clk),
//		  .pixpulse             (pixpulse),
//		  .rst			(rst | FSM == GAME_OVER),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .empty		(~draw_paddle),
//		  .move			(move & FSM),
//		  .ship       (draw_paddle));
//        end
//    endgenerate    
   ball #(325,10,0,1,10,10,3) u_ball_1 ( 
		  // Outputs
		  .draw_ball		(draw_ball[0]),
		  .score_increment    (scored[0]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[0]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(~draw_paddle),
		  .move			(move & FSM),
		  .ship       (draw_paddle));
		  // working asteroid
 ball #(450,10,0,1,10,10,1) u_ball_2 ( 
		  // Outputs
		  .draw_ball		(draw_ball[1]),
		  .score_increment    (scored[1]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[1]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(~draw_paddle),
		  .move			(move & FSM),
		  .ship       (draw_paddle));		
		  
ball #(500,10,0,1,10,10,2, -1) u_ball_3 ( 
		  // Outputs
		  .draw_ball		(draw_ball[2]),
		  .score_increment    (scored[2]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[2]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(~draw_paddle),
		  .move			(move & FSM),
		  .ship       (draw_paddle));	  
		  	
ball #(75,10,2,1,5,5,1) u_ball_4 ( 
		  // Outputs
		  .draw_ball		(draw_ball[3]),
		  .score_increment    (scored[3]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[3]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(~draw_paddle),
		  .move			(move & FSM),
		  .ship       (draw_paddle));	
		  
ball #(675,10,2,1,5,5,1, -2) u_ball_5 ( 
		  // Outputs
		  .draw_ball		(draw_ball[4]),
		  .score_increment    (scored[4]),
		  .xloc			(),
		  .yloc			(),
		  .collision      (collision[4]),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(~draw_paddle),
		  .move			(move & FSM),
		  .ship       (draw_paddle));			  
		  	//end of original working asteroid		 
 	
		  	 
paddle #(320,400,0,0) u_pad(
        //Outputs
        .draw_paddle    (draw_paddle),
        .xloc           (),
        .yloc           (),
        .dec_lives      (life_det),
        //Inputs
        .clk			(clk),
        .mU             (move_up),
        .mD             (move_down),
        .mL             (move_left),
        .mR             (move_right),
		  .pixpulse             (pixpulse),
		  .rst			(rst | FSM == GAME_OVER),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty | (|draw_ball)),
		  .move			(move & FSM));

score #(80,420) s1(
    .clk (clk), // 100 MHz system clock
    .pixpulse (pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst (rst | FSM == TITLE_SCREEN),
   	.hcount(hcount[9:0]), // x-location where we are drawing
    .vcount (vcount[9:0]), // y-location where we are drawing
    .score (sc),
    .state_set(FSM),
    .draw_score (draw_score)
    );
    
   
   assign is_a_wall = ((vcount < 1) | (vcount > 474)) | ((hcount < 3) | (hcount > 635));
   
       
   assign empty = ~(is_a_wall);
   //assign empty_cond = empty & ~draw_ball & ~draw_ball2 & ~draw_ball3 & ~draw_ball4 & ~draw_paddle;
   assign move = (vblank & ~vblank_d1);  // move balls at start of vertical blanking
   
   always @(posedge clk or posedge rst) begin
      if (rst) begin
	 vblank_d1 <= 0;
	 sc <= 0;
	 FSM <= TITLE_SCREEN;
	 lives <= 2'b11;
      end else if (pixpulse) begin
         vblank_d1 <= vblank;
         sc <= sc + scored[0] + scored[1] + scored[2] + scored[3] + scored[4] + scored[5]; 
        // sc <= sc + (|scored);
         lives <= lives;
         FSM <= next_state;   
         if(FSM == TITLE_SCREEN) begin
            sc <= 0;
         end 
         if(FSM == TITLE_SCREEN | FSM == GAME_OVER) begin
            lives <= 2'b11;
         end
         if ((FSM == PLAY_GAME) & (|collision))//(life_det))
            lives <= lives - 1'b1;
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
               //if(|collision) next_state <= GAME_OVER;
               if((lives == 0)) next_state <= GAME_OVER;
               if(sc >= 8'b11111111) next_state <= GAME_OVER;
        end
        GAME_OVER: begin
            if(move_up & move_down & move_left & move_right) begin
                next_state <= TITLE_SCREEN;
                end
            end
       endcase   
   end

   always @(posedge clk) begin
      if (pixpulse)
        case (FSM)
        TITLE_SCREEN: begin
          current_pixel <= (draw_text)? TEXT_COLOR:WALL_COLOR;
        end
        PLAY_GAME: begin
          current_pixel <= 
         ((|draw_ball) | (|draw_balls)) ? BALL_COLOR :
         (draw_paddle) ? PADDLE_COLOR:  
        (draw_score)? SCORE_COLOR:EMPTY_COLOR;
       end
       GAME_OVER: begin
            current_pixel <= (draw_score)? SCORE_COLOR:
            (draw_text)?TEXT_COLOR:WALL_COLOR; // draw on the screen
            
       end
endcase
end   
   
      // Map 12-bit to 4:4:4
   assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   
