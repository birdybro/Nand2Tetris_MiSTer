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

module DMUX4WAY
(
    input       in,
    input [1:0] sel,
    output      a,
    output      b,
    output      c,
    output      d
);

// | in  | sel  |  a  |  b  |  c  |  d  |
// |  0  |  00  |  0  |  0  |  0  |  0  |
// |  0  |  01  |  0  |  0  |  0  |  0  |
// |  0  |  10  |  0  |  0  |  0  |  0  |
// |  0  |  11  |  0  |  0  |  0  |  0  |
// |  1  |  00  |  1  |  0  |  0  |  0  |
// |  1  |  01  |  0  |  1  |  0  |  0  |
// |  1  |  10  |  0  |  0  |  1  |  0  |
// |  1  |  11  |  0  |  0  |  0  |  1  |

// Normally in verilog you could very easily handle this with something
// like a case statement or an always @(*) block, etc... however we want
// to build this out of our elementary and composite blocks instead.

wire aout;
wire bout;

DMUX DMUX1
(
    .in(in),
    .sel(sel[1]),
    .a(aout),
    .b(bout)
);

DMUX DMUX2
(
    .in(aout),
    .sel(sel[0]),
    .a(a),
    .b(b)
);

DMUX DMUX3
(
    .in(bout),
    .sel(sel[0]),
    .a(c),
    .b(d)
);

endmodule
