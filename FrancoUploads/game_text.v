`timescale 1ns / 1ps

module game_text #(parameter xloc = 100, parameter yloc = 20)
(
    input         clk,        // 100 MHz system clock
    input         pixpulse,   // every 4 clocks for 25MHz pixel rate
    input         rst,
    input  [9:0]  hcount,     // x-location where we are drawing
    input  [9:0]  vcount,     // y-location where we are drawing
    input  [1:0] what, //whats the occassion, or rather, what text is being written?
    output        draw_text
);
    localparam SCORE = 2'b00;
    localparam HIGH_SCORE = 2'b01;
    localparam LIVES = 2'b10;
    
    
    reg [2:0] row;
    reg [3:0] digit;
    reg [19:0] position;

    (* rom_style = "block" *) reg [7:0] chr_pix;

    // Draw enable wires
    wire draw_text_100, draw_text_10, draw_text_1;
    wire draw_text_1K, draw_text_10K;

    // Digit ROM lookup
    always @(posedge clk) begin
        case (what)
            SCORE: begin
            //0x00-0x27
            position <= 20'h01234;
            end
            HIGH_SCORE: begin
            position <= 20'h56789;
            end
            LIVES: begin
            position <= 20'habcde;
            end
            
        endcase
        case ({1'b0, digit, row})
            8'h00: chr_pix <= 8'b00111100; // 'S'
            8'h01: chr_pix <= 8'b01100011;
            8'h02: chr_pix <= 8'b10000000;
            8'h03: chr_pix <= 8'b10000000;
            8'h04: chr_pix <= 8'b01111100;
            8'h05: chr_pix <= 8'b00000110;
            8'h06: chr_pix <= 8'b01000010;
            8'h07: chr_pix <= 8'b00111100;
            
            8'h08: chr_pix <= 8'b00111100; // 'C'
            8'h09: chr_pix <= 8'b10000011;
            8'h0A: chr_pix <= 8'b10000000;
            8'h0B: chr_pix <= 8'b10000000;
            8'h0C: chr_pix <= 8'b10000000;
            8'h0D: chr_pix <= 8'b10000000;
            8'h0E: chr_pix <= 8'b10010011;
            8'h0F: chr_pix <= 8'b00111100;
            
            8'h10: chr_pix <= 8'b00000000; // 'O'
            8'h11: chr_pix <= 8'b00111100;
            8'h12: chr_pix <= 8'b01000010;
            8'h13: chr_pix <= 8'b01000010;
            8'h14: chr_pix <= 8'b01000010;
            8'h15: chr_pix <= 8'b01000010;
            8'h16: chr_pix <= 8'b01000010;
            8'h17: chr_pix <= 8'b01111110;
            
            8'h18: chr_pix <= 8'b00000000; // 'R'
            8'h19: chr_pix <= 8'b00111100;
            8'h1A: chr_pix <= 8'b01000010;
            8'h1B: chr_pix <= 8'b01000010;
            8'h1C: chr_pix <= 8'b01111100;
            8'h1D: chr_pix <= 8'b01100110;
            8'h1E: chr_pix <= 8'b01100011;
            8'h1F: chr_pix <= 8'b01100011;
            
            8'h20: chr_pix <= 8'b00000000; // 'E'
            8'h21: chr_pix <= 8'b11111111;
            8'h22: chr_pix <= 8'b11000000;
            8'h23: chr_pix <= 8'b11000000;
            8'h24: chr_pix <= 8'b11111111;
            8'h25: chr_pix <= 8'b11000000;
            8'h26: chr_pix <= 8'b11000100;
            8'h27: chr_pix <= 8'b11111111;
            
            8'h28: chr_pix <= 8'b00000000; // 'L'
            8'h29: chr_pix <= 8'b11000000;
            8'h2A: chr_pix <= 8'b11000000;
            8'h2B: chr_pix <= 8'b11000000;
            8'h2C: chr_pix <= 8'b11000000;
            8'h2D: chr_pix <= 8'b11000010;
            8'h2E: chr_pix <= 8'b11000000;
            8'h2F: chr_pix <= 8'b11111100;
            
            8'h30: chr_pix <= 8'b00000000; // 'I'
            8'h31: chr_pix <= 8'b00011000;
            8'h32: chr_pix <= 8'b00011000;
            8'h33: chr_pix <= 8'b00011000;
            8'h34: chr_pix <= 8'b00011000;
            8'h35: chr_pix <= 8'b00011000;
            8'h36: chr_pix <= 8'b00011000;
            8'h37: chr_pix <= 8'b00011000;
            
            8'h38: chr_pix <= 8'b00000000; // 'V'
            8'h39: chr_pix <= 8'b11000011;
            8'h3A: chr_pix <= 8'b11000011;
            8'h3B: chr_pix <= 8'b11100111;
            8'h3C: chr_pix <= 8'b01100110;
            8'h3D: chr_pix <= 8'b01100110;
            8'h3E: chr_pix <= 8'b01100110;
            8'h3F: chr_pix <= 8'b00111100;
            
            
            8'h40: chr_pix <= 8'b00000000; // 'E'
            8'h41: chr_pix <= 8'b11111111;
            8'h42: chr_pix <= 8'b11000000;
            8'h43: chr_pix <= 8'b11000000;
            8'h44: chr_pix <= 8'b11111111;
            8'h45: chr_pix <= 8'b11000000;
            8'h46: chr_pix <= 8'b11000100;
            8'h47: chr_pix <= 8'b11111111;
            
            8'h48: chr_pix <= 8'b00111100; // 'S'
            8'h49: chr_pix <= 8'b01100011;
            8'h4A: chr_pix <= 8'b10000000;
            8'h4B: chr_pix <= 8'b10000000;
            8'h4C: chr_pix <= 8'b01111100;
            8'h4D: chr_pix <= 8'b00000110;
            8'h4E: chr_pix <= 8'b01000010;
            8'h4F: chr_pix <= 8'b00111100;
            
            8'h50: chr_pix <= 8'b00000000; // 'H'
            8'h51: chr_pix <= 8'b11000011;
            8'h52: chr_pix <= 8'b11000011;
            8'h53: chr_pix <= 8'b11000011;
            8'h54: chr_pix <= 8'b11111101;
            8'h55: chr_pix <= 8'b11000011;
            8'h56: chr_pix <= 8'b11000011;
            8'h57: chr_pix <= 8'b11000011;
            
             8'h58: chr_pix <= 8'b00000000; // 'I'
            8'h59: chr_pix <= 8'b00011000;
            8'h5A: chr_pix <= 8'b00011000;
            8'h5B: chr_pix <= 8'b00011000;
            8'h5C: chr_pix <= 8'b00011000;
            8'h5D: chr_pix <= 8'b00011000;
            8'h5E: chr_pix <= 8'b00011000;
            8'h5F: chr_pix <= 8'b00011000;
            
            8'h60: chr_pix <= 8'b00000000; // 'G'
            8'h61: chr_pix <= 8'b00111100;
            8'h62: chr_pix <= 8'b01000011;
            8'h63: chr_pix <= 8'b01001111;
            8'h64: chr_pix <= 8'b01000000;
            8'h65: chr_pix <= 8'b01000010;
            8'h66: chr_pix <= 8'b00100010;
            8'h67: chr_pix <= 8'b00111100;
            
            8'h68: chr_pix <= 8'b00000000; // 'H'
            8'h69: chr_pix <= 8'b11000011;
            8'h6A: chr_pix <= 8'b11000011;
            8'h6B: chr_pix <= 8'b11000011;
            8'h6C: chr_pix <= 8'b11111101;
            8'h6D: chr_pix <= 8'b11000011;
            8'h6E: chr_pix <= 8'b11000011;
            8'h6F: chr_pix <= 8'b11000011;
            
            
            
            default: chr_pix <= 8'b00000000;
        endcase
        
    end

    // Pixel mask logic with conditional gating
    
    
    assign draw_text_10K = (hcount >= xloc && hcount < xloc + 8  &&
                             vcount >= yloc - 7 && vcount <= yloc) ?
                             chr_pix[7 - (hcount - xloc)] : 1'b0;

    assign draw_text_1K  = (hcount >= xloc + 8 && hcount < xloc + 16 &&
                             vcount >= yloc - 7 && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 8))] : 1'b0;

    assign draw_text_100   = (hcount >= xloc + 16 && hcount < xloc + 24 &&
                             vcount >= yloc - 7  && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 16))] : 1'b0;
    assign draw_text_10   = (hcount >= xloc + 24 && hcount < xloc + 32 &&
                             vcount >= yloc - 7  && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 24))] : 1'b0;        
    assign draw_text_1   = (hcount >= xloc + 32 && hcount < xloc + 40 &&
                             vcount >= yloc - 7  && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 32))] : 1'b0; 

    assign draw_text = draw_text_10K | draw_text_1K |draw_text_100 | draw_text_10 | draw_text_1;

    

    // Row and digit tracker with cleanup
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row   <= 0;
            digit <= 0;
        end else if (pixpulse) begin
            if (vcount >= yloc - 7 && vcount <= yloc) begin
                row <= 7 - (yloc - vcount); 
                if (hcount == xloc)
                    digit <= position[19:16];
                else if (hcount == xloc + 8)
                    digit <= position[15:12];
                else if (hcount == xloc + 16)
                    digit <= position[11:8];
                 else if(hcount == xloc + 24) digit <= position[7:4];
                 else if(hcount == xloc + 32) digit <= position[3:0];
            end else begin
                row   <= 0;
                digit <= 0;
            end
        end
    end

endmodule
