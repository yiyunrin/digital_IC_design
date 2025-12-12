`include "./Mul_Mod.v"
module  BU(
    input       [22:0] X,
    input       [22:0] Y,
    input       [22:0] TF,
    output      [22:0] A,
    output      [22:0] B
);

wire [23:0] mod, add;
wire [23:0]Q = 24'd8380417;

Mul_Mod mul_mod(.A(TF), .B(Y), .Z(mod));
assign add = X + mod;
assign A = add >= Q ? (add - Q) : add[22:0];
assign B = X < mod ? (X + Q - mod) : (X - mod);

endmodule