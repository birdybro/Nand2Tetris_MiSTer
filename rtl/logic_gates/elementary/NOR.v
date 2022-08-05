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

// (NOT(a) AND NOT(b))
// assign out = (~a & ~b);

// ((a NAND a) AND (b NAND b))
// (((a NAND a) NAND (b NAND b)) NAND ((a NAND a) NAND (b NAND b)))

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

wire nand_4_out;

NAND NAND_4
(
    .a(nand_3_out),
    .b(nand_3_out),
    .out(out)
);

endmodule
