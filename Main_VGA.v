`timescale 1ns / 1ps

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
   wire [1:0] game_state;//Could be used in FSM functionality or something else to tell
                          //when the game is supposed to be in 
   wire [2:0] draw_bullet = 0;
   wire [9:0] hcount;
   wire [9:0] vcount;
   wire	      hblank;
   wire	      vblank;
   wire	      pixpulse;
   wire       wall = ((hcount < 132) & (hcount > 137) & (hcount >408) & (hcount < 413));
                      //Gives boundaries for thin wall on sides. Note that there aren't provisions
                      //for walls on the top or bottom.
   wire       empty;
   
   wire [9:0]       Ship_X, Ship_Y;
      
   wire       draw_ship,draw_score;
   wire [7:0] draw_asteroids;//Arbitrary 4 bits, didn't think more than 16 could be on screen
   wire [7:0] broken_asteroids;//Broken and draw for blocks was a package deal
   
   wire [7:0] timer_RNG;//Use for pseudo random calculations
   wire [7:0] display = 8'b00000000;
   
   wire move;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire [7:0] scores;
   //
   reg [3:0]  val;
   wire [31:0] seed = 4;  // prefer 32b value
   //
   localparam SHIP_COLOR = 12'hfd0;//Yellow
   localparam SCORE_COLOR = 12'hfff;//White
   localparam BULLET_COLOR = 12'h0ff;//Turqouise
   localparam WALL_COLOR = 12'hf00;//Red, Note: Make walls thin so we don't get flashbanged upon loading game
   localparam AST_COLOR = 12'h850;//Brown
   localparam EMPTY_COLOR = 12'h001;//Background, black with a very small amount of blue
    
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
		       
    ship # () ship1(
    .clk    (clk),
    .pixpulse (pixpulse),
    .rst (rst),
    .hcount(hcount),
    .vcount(vcount),
    .empty (empty), //Make sure to adjust for lives and collision with various objects, m
    .move (move),                //Make sure that ship does not collide with bullet upon shooting
    .mU (move_up),
    .mD (move_down),
    .mL (move_left),
    .mR (move_right),
    .draw_ship (draw_ship),
    .xloc (Ship_X),
    .yloc (Ship_Y)
    );
    


score #() score1(
    .clk (clk),
    .pixpulse (pixpulse),
    .rst (rst),
    .hcount (hcount),
    .vcount (vcount),
    .score (scores),
    .draw_score(draw_score)
);
    
    //~~~~~~~~~~~~~~~~~~~~~~~~
    // Generate 3 bullet
    //~~~~~~~~~~~~~~~~~~~~~~~~
    genvar i;
    generate
        for(i = 0; i < 3; i = i + 1) begin
        
            bullet #(Ship_X, Ship_Y) bullet_u
            (
    .clk        (clk),
    .pixpulse   (pixpulse), 
    .rst        (rst),
    // bullet count change to check if bullet can fire
    .bullet_count(), //If # of bullets is 2'b11, do not draw bullet /// might omit, main_VGA will track bullet amount
    .hcount     (hcount), 
    .vcount     (vcount),
    .fire(~draw_bullet[i] && shoot), // check if we can fire this bullet max 3 bullet
    .firePosX(Ship_X),
    .firePosX(Ship_Y - 20),
    .button_pressed      (shoot), //Needs to be incorporated into code, if statement or case statement
    .empty      (empty & ~asteroid), 
    .move       (move), // signal to update the location of the ball
    .draw_bullet(draw_bullet[i]), //
    .xloc(),
    .yloc(),
    .new_bullet_count(), // might not be used, draw_bullet is taking care 
    .broken()
    );
    end
    endgenerate 
    //~~~~~~~~~~~~~~~~~~~~~~~~
    // Generate 8 asteroid
    //~~~~~~~~~~~~~~~~~~~~~~~~
    always@(posedge clk)begin
    val = $random(seed) % 271 + 137;
    end
    genvar j;
    generate
    for(j = 0; j < 3; i = i + 1) begin
        asteroid # () asteroid_u(//Can adjust in top module to increase speed
    .clk    (clk), 
    .pixpulse(pixpulse), 
    .rst(rst),
    .hcount(hcount), 
    .vcount(vcount),
    .unbreak(),                //Adapted from 'block' module. Uncertain whether this will be used
    .break_conditions(),//What did the asteroid collide with? 
    .pre_score(), //Have the score be carried into asteroid module and have it be-
    .empty(empty),       //-incremented by the module depending on what the asteroid hit.
    .pre_lives(),  //See above comment, except for 'lives' of the ship
    .move(move),      //Note: Need to have bus in top module for lives_next-
    .draw_ast(), //-and other buses as to properly change value in following clk cycle
    .xloc(), //Note: If we are including life tracking capabilities, I am not-
    .yloc(),//-sure if checking for 0 lives happens here or in top module (probs latter)
    .broken(),
    .post_score(),
    .post_lives(),
    .inc_score()
    );
    end
    endgenerate 
    
    assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
    assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
    assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
endmodule
