module NAND
(
    input  a,
    input  b,
    output out
);

// | a | b | out |
// | - | - | --- |
// | 0 | 0 | 1   | (NOT(a) AND NOT(b))
// | 0 | 1 | 1   | (NOT(a) AND b)
// | 1 | 0 | 1   | (a AND NOT(b))
// | 1 | 1 | 0   |

// (NOT(a) AND NOT(b)) OR (NOT(a) AND b) OR (a AND NOT(b))
// NOT(a AND b) = (a NAND b)

assign out = ~(a & b);

endmodule
