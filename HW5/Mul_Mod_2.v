module Mul_Mod_2 (
    input  [22:0] A,
    input  [22:0] B,
    output [23:0] Z
);

wire [28:0]times1;
wire [39:0]times2;
wire [45:0]shift1;
wire [46:0] add1;
wire [24:0] add2;
wire [25:0] add3;
wire [34:0] add4;
wire [10:0]sub1;
wire [23:0]sub2, sub3;
wire sign, xor1;
wire [23:0]Q = 24'd8380417;

assign times1 = A[22:0] * B[22:17]; 
assign times2 = A[22:0] * B[16:0]; 
assign shift1 = times1 << 17;

assign add1 = shift1 + times2;
assign add2 = add1[45:22] + add1[45:32];
assign add3 = (add1[45:22] << 1) + add1[45:22] + add1[45:23];
assign add4 = add3[25:12] + {add2[24:0], add1[31:22]};

assign sub1 = add4[34:24] - add4[21:11];
assign xor1 = sub1[10] ^ add4[11];
assign sub2 = add1[23:0] - {xor1, sub1[9:0], add4[23:11]};
assign {sign, sub3} = sub2 - Q;
assign Z = (sign) ? sub2 : sub3;

endmodule
