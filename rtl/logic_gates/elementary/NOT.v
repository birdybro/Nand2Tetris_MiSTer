module NOT
(
    input  a,
    output out
);

// | a | out |
// | - | --- |
// | 0 | 1   | NOT(a)
// | 1 | 0   | NOT(a)

// NOT(a) OR NOT(a)
// NOT(a)
// assign out = ~a;

// (a NAND a)

NAND NAND
(
    .a(a),
    .b(a),
    .out(nand_out)
);

assign out = nand_out;

endmodule
