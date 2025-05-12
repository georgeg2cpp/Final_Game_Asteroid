`timescale 1ns / 1ps


module text_render # (xloc = 300, yloc = 232) (
        input clk,
        input [9:0] vcount,
        input [9:0] hcount,
        input [1:0] state_set,
        output reg char_on,
        output reg [2:0] char_pixel
    );
    localparam X0 = 300, Y0 = 232;
    reg [7:0] msg [0:8];
    reg [3:0] char_col, char_row; //Which character and row within
    reg [2:0] px_bit;   //Which bit within row
    wire [7:0] rowbits; //Bits for this row from font module
    
 always @* begin
        if (state_set == 2'b00) begin
            msg[0] = "A"; msg[1] = "S"; msg[2] = "T"; msg[3] = "E";
            msg[4] = "R"; msg[5] = "O"; msg[6] = "I"; msg[7] = "D"; msg[8] = "S";
        end else if (state_set == 2'b01) begin
          //  msg[0] = "R"; msg[1] = "E"; msg[2] = "-"; msg[3] = "A";
          //  msg[4] = "R"; msg[5] = "M"; msg[6] = " "; msg[7] = " "; msg[8] = 8'h00;
        end else if (state_set == 2'b10) begin
            msg[0] = "G"; msg[1] = "A"; msg[2] = "M"; msg[3] = "E";
            msg[4] = "O"; msg[5] = "V"; msg[6] = "E"; msg[7] = "R"; msg[8] = 8'h00;
        end
    end

    // Font lookup; Font Instantiation module
    font8x16 font_inst(
        .ascii(msg[char_col]),
        .row(char_row),
        .bits(rowbits)
    );

    // Compute char_on & pixel
    always @(posedge clk) begin
        if (hcount>=xloc && hcount< xloc+9*8 && vcount>=yloc && vcount<yloc+16) begin
            char_col = (hcount - xloc) >> 3;
            char_row = vcount - Y0;
            px_bit   = 7 - ((hcount - xloc) & 3'd7);
            char_on  = rowbits[px_bit];
            char_pixel = 3'b111;
        end else begin
            char_on = 1'b0;
            char_pixel = 3'b000;
        end
    end
endmodule


