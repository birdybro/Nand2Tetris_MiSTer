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

assign out = a | b;

endmodule
