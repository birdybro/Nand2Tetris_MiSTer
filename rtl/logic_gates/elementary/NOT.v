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

assign out = ~a;

endmodule
