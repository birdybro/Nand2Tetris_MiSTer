//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

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
    .b(nand_1_out),
    .out(nand_2_out)
);

wire nand_3_out;

NAND NAND_3
(
    .a(nand_2_out),
    .b(b),
    .out(nand_3_out)
);

wire nand_4_out;

NAND NAND_4
(
    .a(nand_2_out),
    .b(nand_3_out),
    .out(nand_4_out)
);

assign out = nand_4_out;

endmodule