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

assign out = a & b;

endmodule
