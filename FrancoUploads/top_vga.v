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
    wire [9:0] hcount;
   wire [9:0] vcount;
   wire	      hblank;
   wire	      vblank;
   wire	      pixpulse;
   wire       wall = ((hcount > 132) & (hcount < 137) & (hcount >408) & (hcount < 413));
                      //Gives boundaries for thin wall on sides. Note that there aren't provisions
                      //for walls on the top or bottom.
   wire       empty;
   wire       empty_ship = wall | ((|draw_asteroids[19:0]));
   
   
   wire       draw_ship,draw_score;
   wire [1:0] draw_bullets;
   //if (&draw_bullets) don't draw
   wire [19:0] draw_asteroids;//Arbitrary 4 bits, didn't think more than 16 could be on screen
   wire [19:0] broken_asteroids;//Broken and draw for blocks was a package deal
   wire all_broken;
   
   wire [7:0] timer_RNG;//Use for pseudo random calculations
   wire [7:0] display = 8'b00000000;
   
   wire move;
    reg [11:0] current_pixel;
   reg vblank_d1;
   reg [7:0] scores;
   wire [1:0] lives;
   wire [2:0] inc_scores;//Asteroids
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
    /*module ship # (parameter xloc_start=320,
	      parameter yloc_start=400)(

    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    input mU,input mD,input mL,input mR,
    output	     draw_ship, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc // y-location of the ball
    );*/
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
    .xloc (),
    .yloc ()
    );
    /*module score #(parameter xloc = 20, parameter yloc = 20)
(
    input         clk,        // 100 MHz system clock
    input         pixpulse,   // every 4 clocks for 25MHz pixel rate
    input         rst,
    input  [9:0]  hcount,     // x-location where we are drawing
    input  [9:0]  vcount,     // y-location where we are drawing
    input  [7:0]  score,
    output        draw_score
);*/
score #() score1(
    .clk (clk),
    .pixpulse (pixpulse),
    .rst (rst),
    .hcount (hcount),
    .vcount (vcount),
    .score (scores),
    .draw_score(draw_score)
);


   always @(posedge clk or posedge rst) 
     begin
        if(rst) begin
            vblank_d1 <= 0;
            scores <= 0;
        end else if (pixpulse)
             begin
        //if (inc_score) scores = scores + 1;
             end
             
             
             
             //FSM Part
             
             
             //If lives output from ship module == 0, 
     end

    
    assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
endmodule
