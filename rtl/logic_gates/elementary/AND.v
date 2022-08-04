module AND
(
    input  a,
    input  b,
    output out
);

// | a | b | out |
// | - | - | --- |
// | 0 | 0 | 0   |
// | 0 | 1 | 0   |
// | 1 | 0 | 0   |
// | 1 | 1 | 1   | (a AND b)

// (a AND b)
// assign out = a & b;

// NOT(a NAND b)
// ((a NAND b) NAND (a NAND b))

wire nand_1_out;

NAND NAND_1
(
    .a(a),
    .b(b),
    .out(nand_1_out)
);

wire nand_2_out;

NAND NAND_2
(
    .a(a),
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
