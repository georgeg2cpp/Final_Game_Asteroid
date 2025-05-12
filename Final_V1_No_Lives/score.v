module score #(parameter xloc = 20, parameter yloc = 20)
(
    input         clk,        // 100 MHz system clock
    input         pixpulse,   // every 4 clocks for 25MHz pixel rate
    input         rst,
    input  [9:0]  hcount,     // x-location where we are drawing
    input  [9:0]  vcount,     // y-location where we are drawing
    input  [8:0]  score,
    output        draw_score
);

    reg [2:0] row;
    reg [3:0] digit;
    wire [11:0] score_bcd;

    (* rom_style = "block" *) reg [7:0] chr_pix;

    // Draw enable wires
    wire draw_score_100, draw_score_10, draw_score_1;

    // Digit ROM lookup
    always @(posedge clk) begin
        case ({1'b0, digit, row})
            8'h00: chr_pix <= 8'b00000000; // '0'
            8'h01: chr_pix <= 8'b00111100;
            8'h02: chr_pix <= 8'b01000010;
            8'h03: chr_pix <= 8'b01000010;
            8'h04: chr_pix <= 8'b01000010;
            8'h05: chr_pix <= 8'b01000010;
            8'h06: chr_pix <= 8'b01000010;
            8'h07: chr_pix <= 8'b00111100;
            8'h08: chr_pix <= 8'b00000000; // '1'
            8'h09: chr_pix <= 8'b00110000;
            8'h0A: chr_pix <= 8'b01010000;
            8'h0B: chr_pix <= 8'b00010000;
            8'h0C: chr_pix <= 8'b00010000;
            8'h0D: chr_pix <= 8'b00010000;
            8'h0E: chr_pix <= 8'b00010000;
            8'h0F: chr_pix <= 8'b01111100;
            8'h10: chr_pix <= 8'b00000000; // '2'
            8'h11: chr_pix <= 8'b00111100;
            8'h12: chr_pix <= 8'b01000010;
            8'h13: chr_pix <= 8'b00000010;
            8'h14: chr_pix <= 8'b00001100;
            8'h15: chr_pix <= 8'b00110000;
            8'h16: chr_pix <= 8'b01000000;
            8'h17: chr_pix <= 8'b01111110;
            8'h18: chr_pix <= 8'b00000000; // '3'
            8'h19: chr_pix <= 8'b00111100;
            8'h1A: chr_pix <= 8'b01000010;
            8'h1B: chr_pix <= 8'b00000010;
            8'h1C: chr_pix <= 8'b00011100;
            8'h1D: chr_pix <= 8'b00000010;
            8'h1E: chr_pix <= 8'b01000010;
            8'h1F: chr_pix <= 8'b00111100;
            8'h20: chr_pix <= 8'b00000000; // '4'
            8'h21: chr_pix <= 8'b00000100;
            8'h22: chr_pix <= 8'b00011100;
            8'h23: chr_pix <= 8'b00100100;
            8'h24: chr_pix <= 8'b01000100;
            8'h25: chr_pix <= 8'b01111110;
            8'h26: chr_pix <= 8'b00000100;
            8'h27: chr_pix <= 8'b00000100;
            8'h28: chr_pix <= 8'b00000000; // '5'
            8'h29: chr_pix <= 8'b01111110;
            8'h2A: chr_pix <= 8'b01000000;
            8'h2B: chr_pix <= 8'b01000000;
            8'h2C: chr_pix <= 8'b01111100;
            8'h2D: chr_pix <= 8'b00000010;
            8'h2E: chr_pix <= 8'b01000010;
            8'h2F: chr_pix <= 8'b00111100;
            8'h30: chr_pix <= 8'b00000000; // '6'
            8'h31: chr_pix <= 8'b00111100;
            8'h32: chr_pix <= 8'b01000000;
            8'h33: chr_pix <= 8'b01000000;
            8'h34: chr_pix <= 8'b01111100;
            8'h35: chr_pix <= 8'b01000010;
            8'h36: chr_pix <= 8'b01000010;
            8'h37: chr_pix <= 8'b00111100;
            8'h38: chr_pix <= 8'b00000000; // '7'
            8'h39: chr_pix <= 8'b01111110;
            8'h3A: chr_pix <= 8'b00000010;
            8'h3B: chr_pix <= 8'b00000100;
            8'h3C: chr_pix <= 8'b00001000;
            8'h3D: chr_pix <= 8'b00010000;
            8'h3E: chr_pix <= 8'b00010000;
            8'h3F: chr_pix <= 8'b00010000;
            8'h40: chr_pix <= 8'b00000000; // '8'
            8'h41: chr_pix <= 8'b00111100;
            8'h42: chr_pix <= 8'b01000010;
            8'h43: chr_pix <= 8'b01000010;
            8'h44: chr_pix <= 8'b00111100;
            8'h45: chr_pix <= 8'b01000010;
            8'h46: chr_pix <= 8'b01000010;
            8'h47: chr_pix <= 8'b00111100;
            8'h48: chr_pix <= 8'b00000000; // '9'
            8'h49: chr_pix <= 8'b00111100;
            8'h4A: chr_pix <= 8'b01000010;
            8'h4B: chr_pix <= 8'b01000010;
            8'h4C: chr_pix <= 8'b00111110;
            8'h4D: chr_pix <= 8'b00000010;
            8'h4E: chr_pix <= 8'b00000010;
            8'h4F: chr_pix <= 8'b00111100;
            default: chr_pix <= 8'b00000000;
        endcase
    end

    // Pixel mask logic with conditional gating
    assign draw_score_100 = (hcount >= xloc && hcount < xloc + 8  &&
                             vcount >= yloc - 7 && vcount <= yloc) ?
                             chr_pix[7 - (hcount - xloc)] : 1'b0;

    assign draw_score_10  = (hcount >= xloc + 8 && hcount < xloc + 16 &&
                             vcount >= yloc - 7 && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 8))] : 1'b0;

    assign draw_score_1   = (hcount >= xloc + 16 && hcount < xloc + 24 &&
                             vcount >= yloc - 7  && vcount <= yloc) ?
                             chr_pix[7 - (hcount - (xloc + 16))] : 1'b0;

    assign draw_score = draw_score_100 | draw_score_10 | draw_score_1;

    // BCD conversion
    doubdab_8bits udd (
        .b_in(score),
        .bcd_out(score_bcd)
    );

    // Row and digit tracker with cleanup
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row   <= 0;
            digit <= 0;
        end else if (pixpulse) begin
            if (vcount >= yloc - 7 && vcount <= yloc) begin
                row <= 7 - (yloc - vcount); 
                if (hcount == xloc)
                    digit <= score_bcd[11:8];
                else if (hcount == xloc + 8)
                    digit <= score_bcd[7:4];
                else if (hcount == xloc + 16)
                    digit <= score_bcd[3:0];
            end else begin
                row   <= 0;
                digit <= 0;
            end
        end
    end

endmodule