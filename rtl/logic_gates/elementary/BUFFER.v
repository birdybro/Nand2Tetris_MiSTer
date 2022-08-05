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

module g_BUFFER
(
    input  in,
    output out
);

// | in | out |
// | -- | --- |
// | 0  | 0   | (a)
// | 1  | 1   | (a)

// (a) OR (a)
// (a)
// assign out = a;

// NAND(a NAND a)

// The most pointless elementary logic gate for FPGA possible
// This will just get synth'd away unless I specified the synthesis settings
// to not change the design at all, which might fail.

// But let's do it anyway!

wire n_out;

g_NAND NANDin
(
    .in(in),
    .out(n_out)
);

g_NAND NANDout
(
    .in(n_out),
    .out(out)
);

endmodule
