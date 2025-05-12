`timescale 1ns / 1ps

module doubdab_8bits(
    input [7:0] b_in,
    output [11:0] bcd_out
    );
  
    wire [3:0] i1 = {1'b0,b_in[7:5]};
    wire [3:0] i2;
    dd_add3 u1 (.i(i1),.o(i2));
    wire [3:0] i3 = {i2[2:0],b_in[4]};
    wire [3:0] i4;
    dd_add3 u2 (.i(i3),.o(i4));
    wire [3:0] i5 = {i4[2:0],b_in[3]};
    wire [3:0] i6;
    dd_add3 u3 (.i(i5),.o(i6));
    wire [3:0] i7 = {i6[2:0],b_in[2]};
    wire [3:0] i8;
    dd_add3 u4 (.i(i7),.o(i8));
    
    dd_add3 u6 (.i({i8[2:0],b_in[1]}),.o(bcd_out[4:1]));
    wire [3:0] i9;
    dd_add3 u5 (.i({1'b0,i2[3],i4[3],i6[3]}),.o(i9));
    assign bcd_out[9] = i9[3];
    dd_add3 u7 (.i({i9[2:0],i8[3]}),.o(bcd_out[8:5]));
    
    assign bcd_out[11:10] = 2'b00;
    assign bcd_out[0] = b_in[0];
     
endmodule