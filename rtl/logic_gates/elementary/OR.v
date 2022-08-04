module OR
(
    input  a,
    input  b,
    output out
);

// | a | b | out |
// | - | - | --  |
// | 0 | 0 | 0   |
// | 0 | 1 | 1   | (NOT(a) AND b)
// | 1 | 0 | 1   | (a AND NOT(b))
// | 1 | 1 | 1   | (a AND b)

// (NOT(a) AND b) OR (a AND NOT(b)) OR (a AND b)
// NOT(NOT(a) and NOT(b))
// (a OR b)
// assign out = a | b;

// NOT(NOT(a) AND NOT(b))
// ((a NAND a) NAND (b NAND b))

wire nand_1_out;

NAND NAND_1
(
    .a(a),
    .b(a),
    .out(nand_1_out)
);

wire nand_2_out;

NAND NAND_2
(
    .a(b),
    .b(b),
    .out(nand_2_out)
);

wire nand_3_out;

NAND NAND_3
(
    .a(nand_1_out),
    .b(nand_2_out),
    .out(nand_3_out)
);

assign out = nand_3_out;

endmodule
