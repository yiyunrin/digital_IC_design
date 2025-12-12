module Mul_Mod (
    input  [22:0] A,
    input  [22:0] B,
    output [23:0] Z
);

wire [28:0]times1;
wire [39:0]times2;
wire [45:0]shift1;
wire [47:0]add1, add2, add_tmp, add3, add4;
wire [10:0]sub1;
wire [23:0]sub2, sub3;
wire sign, xor1;
wire [23:0]Q = 24'd8380417;

assign times1 = A[22:0] * B[22:17]; 
assign times2 = A[22:0] * B[16:0]; 
assign shift1 = times1 << 17;

Adder_48 adder1(.A({2'b0, shift1}), .B({8'b0, times2}), .S(add1));
Adder_48 adder2(.A({24'b0, add1[45:22]}), .B({34'b0, add1[45:32]}), .S(add2));
Adder_48 adder3(.A({23'b0, add1[45:22], 1'b0}), .B({24'b0, add1[45:22]}), .S(add_tmp));
Adder_48 adder4(.A(add_tmp), .B({25'b0, add1[45:23]}), .S(add3));
Adder_48 adder5(.A({34'b0,add3[25:12]}), .B({13'b0, add2[24:0], add1[31:22]}), .S(add4));

assign sub1 = add4[34:24] - add4[21:11];
assign xor1 = sub1[10] ^ add4[11];
assign sub2 = add1[23:0] - {xor1, sub1[9:0], add4[23:11]};
assign {sign, sub3} = sub2 - Q;
assign Z = (sign) ? sub2 : sub3;

endmodule

module Adder_48(
    input [47:0] A,
    input [47:0] B,
    output [47:0] S
);

assign S = A + B;

endmodule