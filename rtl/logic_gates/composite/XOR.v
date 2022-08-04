module XOR
(
    input  a,
    input  b,
    output out
);

// | a | b | out |
// | - | - | --- |
// | 0 | 0 | 0   |
// | 0 | 1 | 1   | (NOT(a) AND b)
// | 1 | 0 | 1   | (a AND NOT(b))
// | 1 | 1 | 0   |

// (NOT(a) AND b) OR (a AND NOT(b))

// You can actually make this assign out = (a ^ b); because ^ is a bitwise XOR operator if you wanted to
// another way to do this is just assign out = ((~a & b) | (a & ~b));
// but since this is a composite, let's try and do it at the elementary gate level
// I will probably get this wrong, but doing it early anyways...

wire not_1_out;

NOT NOT_1
(
    .a(a),
    .out(not_1_out)
);

wire not_2_out;

NOT NOT_2
(
    .a(a),
    .out(not_2_out)
);

wire and_1_out;

AND AND_1
(
    .a(a),
    .b(not_2_out),
    .out(and_1_out)
);

wire and_2_out;

AND AND_2
(
    .a(not_1_out),
    .b(a),
    .out(and_2_out)
);

wire or_out;

OR OR
(
    .a(and_1_out),
    .b(and_2_out),
    .out(or_out)
);

assign out = or_out; // voila jtXOR.v is complete

endmodule
