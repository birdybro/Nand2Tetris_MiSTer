module NOR
(
    input  a,
    input  b,
    output out
);

// | a | b | out |
// | - | - | --- |
// | 0 | 0 | 1   | (NOT(a) AND NOT(b))
// | 0 | 1 | 0   |
// | 1 | 0 | 0   |
// | 1 | 1 | 0   |

assign out = (~a & ~b);

endmodule
