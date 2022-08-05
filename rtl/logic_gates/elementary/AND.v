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

module g_AND
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

g_NAND NAND_1
(
    .a(a),
    .b(b),
    .out(nand_1_out)
);

g_NAND NAND_2
(
    .a(nand_1_out),
    .b(nand_1_out),
    .out(out)
);

endmodule
