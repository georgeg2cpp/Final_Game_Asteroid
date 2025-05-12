// Font ROM module mapping the needed ASCII codes. Can extend if needed
module font8x16(
    input  [7:0] ascii,
    input  [3:0] row,
    output reg [7:0] bits
);
    always @* begin
        case (ascii)
            8'd32: // space
                case (row)
                   4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,
                   4'd8,4'd9,4'd10,4'd11,4'd12,4'd13,4'd14,4'd15:
                    bits = 8'b00000000;
                endcase

            8'd45: // '-' (dash) at row 7
                case (row)
                   4'd6: bits = 8'b00011100; // old 4'd7: bits = 8'b11111111;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'A' (65)
            8'd65:
                case (row)
                   4'd0:  bits = 8'b00011000;
                   4'd1:  bits = 8'b00100100;
                   4'd2:  bits = 8'b01000010;
                   4'd3:  bits = 8'b01000010;
                   4'd4:  bits = 8'b01111110;
                   4'd5:  bits = 8'b01000010;
                   4'd6:  bits = 8'b01000010;
                   4'd7:  bits = 8'b01000010;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'D' (68)
            8'd68:
                case (row)
                   4'd0: bits = 8'b01100000;
                   4'd1: bits = 8'b01011000;
                   4'd2: bits = 8'b01001100;
                   4'd3: bits = 8'b01000110;
                   4'd4: bits = 8'b01001100;
                   4'd5: bits = 8'b01011000;
                   4'd6: bits = 8'b01110000;
                   4'd7: bits = 8'b00000000;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'E' (69)
            8'd69:
                case (row)
                   4'd0: bits = 8'b01111110;
                   4'd1: bits = 8'b01000000;
                   4'd2: bits = 8'b01000000;
                   4'd3: bits = 8'b01111100;
                   4'd4: bits = 8'b01000000;
                   4'd5: bits = 8'b01000000;
                   4'd6: bits = 8'b01000000;
                   4'd7: bits = 8'b01111110;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'G' (71)
            8'd71:
                case (row)
                   4'd0: bits = 8'b00011110;
                   4'd1: bits = 8'b01100011;
                   4'd2: bits = 8'b01100000;
                   4'd3: bits = 8'b01100000;
                   4'd4: bits = 8'b01100000;
                   4'd5: bits = 8'b01100111;
                   4'd6: bits = 8'b01100011;
                   4'd7: bits = 8'b00111110;
                   default: bits = 8'b00000000;
                endcase
                // Letter 'I' (73)
            8'd73:
                case (row)
                   4'd0: bits = 8'b01111110;
                   4'd1: bits = 8'b00010000;
                   4'd2: bits = 8'b00010000;
                   4'd3: bits = 8'b00010000;
                   4'd4: bits = 8'b00010000;
                   4'd5: bits = 8'b00010000;
                   4'd6: bits = 8'b00010000;
                   4'd7: bits = 8'b01111110;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'K' (75)
            8'd75:
                case (row)
                   4'd0: bits = 8'b01000010;
                   4'd1: bits = 8'b01000100;
                   4'd2: bits = 8'b01001000;
                   4'd3: bits = 8'b01110000;
                   4'd4: bits = 8'b01110000;
                   4'd5: bits = 8'b01001000;
                   4'd6: bits = 8'b01000100;
                   4'd7: bits = 8'b01000010;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'L' (76)
            8'd76:
                case (row)
                   4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6: bits = 8'b01000000;
                   4'd7: bits = 8'b01111110;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'M' (77) simple symmetric
            8'd77:
                case (row)
                   4'd0: bits = 8'b10000001;
                   4'd1: bits = 8'b11000011;
                   4'd2: bits = 8'b10100101;
                   4'd3: bits = 8'b10011001;
                   4'd4: bits = 8'b10000001;
                   4'd5: bits = 8'b10000001;
                   4'd6: bits = 8'b10000001;
                   4'd7: bits = 8'b10000001;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'O' (79)
            8'd79:
                case (row)
                   4'd0: bits = 8'b01111110;
                   4'd1: bits = 8'b01000001;
                   4'd2: bits = 8'b01000001;
                   4'd3: bits = 8'b01000001;
                   4'd4: bits = 8'b01000001;
                   4'd5: bits = 8'b01000001;
                   4'd6: bits = 8'b01000001;
                   4'd7: bits = 8'b01111110;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'P' (80)
            8'd80:
                case (row)
                   4'd0: bits = 8'b01111100;
                   4'd1: bits = 8'b01000010;
                   4'd2: bits = 8'b01000010;
                   4'd3: bits = 8'b01111100;
                   4'd4: bits = 8'b01000000;
                   4'd5: bits = 8'b01000000;
                   4'd6: bits = 8'b01000000;
                   4'd7: bits = 8'b01000000;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'R' (82)
            8'd82:
                case (row)
                   4'd0: bits = 8'b01111100;
                   4'd1: bits = 8'b01000010;
                   4'd2: bits = 8'b01000010;
                   4'd3: bits = 8'b01111100;
                   4'd4: bits = 8'b01001000;
                   4'd5: bits = 8'b01000100;
                   4'd6: bits = 8'b01000010;
                   4'd7: bits = 8'b01000001;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'S' (83)
            8'd83:
                case (row)
                   4'd0: bits = 8'b00111110;
                   4'd1: bits = 8'b01000000;
                   4'd2: bits = 8'b01000000;
                   4'd3: bits = 8'b00111100;
                   4'd4: bits = 8'b00000010;
                   4'd5: bits = 8'b00000010;
                   4'd6: bits = 8'b00000010;
                   4'd7: bits = 8'b01111100;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'T' (84)
            8'd84:
                case (row)
                   4'd0: bits = 8'b01111110;
                   4'd1: bits = 8'b00011000;
                   4'd2: bits = 8'b00011000;
                   4'd3: bits = 8'b00011000;
                   4'd4: bits = 8'b00011000;
                   4'd5: bits = 8'b00011000;
                   4'd6: bits = 8'b00011000;
                   4'd7: bits = 8'b00111100;
                   default: bits = 8'b00000000;
                endcase

            // Letter 'U' (85)
            8'd85:
                case (row)
                   4'd0: bits = 8'b10000001;
                   4'd1: bits = 8'b10000001;
                   4'd2: bits = 8'b10000001;
                   4'd3: bits = 8'b10000001;
                   4'd4: bits = 8'b10000001;
                   4'd5: bits = 8'b10000001;
                   4'd6: bits = 8'b01000010;
                   4'd7: bits = 8'b00111100;
                   default: bits = 8'b00000000;
                endcase
            8'd86:
                case (row)
                   4'd0: bits = 8'b10000001;
                   4'd1: bits = 8'b11000011;
                   4'd2: bits = 8'b01100011;
                   4'd3: bits = 8'b01100011;
                   4'd4: bits = 8'b01100110;
                   4'd5: bits = 8'b00110110;
                   4'd6: bits = 8'b00111100;
                   4'd7: bits = 8'b00011100;
                   default: bits = 8'b00000000;
                endcase
            // Letter 'W' (87)
            8'd87:
                case (row)
                   4'd0: bits = 8'b10000001;
                   4'd1: bits = 8'b10000001;
                   4'd2: bits = 8'b10011001;
                   4'd3: bits = 8'b10011001;
                   4'd4: bits = 8'b10100101;
                   4'd5: bits = 8'b10100101;
                   4'd6: bits = 8'b01000010;
                   4'd7: bits = 8'b01000010;
                   default: bits = 8'b00000000;
                endcase

            default:
                bits = 8'b00000000;
        endcase
    end
endmodule
