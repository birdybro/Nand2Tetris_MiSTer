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

module c_DMUX4WAY
(
    input        in,
    input  [1:0] sel,
    output       a, b, c, d
);

wire aout, bout;

g_DMUX DMUX1 ( .in(in),   .sel(sel[1]), .a(aout), .b(bout) );
g_DMUX DMUX2 ( .in(aout), .sel(sel[0]), .a(a),    .b(b)    );
g_DMUX DMUX3 ( .in(bout), .sel(sel[0]), .a(c),    .b(d)    );

endmodule