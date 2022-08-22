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

module g_XNOR
(
    input  a, b,
    output out
);

wire nor1_out, nor2_out, nor3_out;

g_NOR NOR1 ( .a(a),        .b(b),        .out(nor1_out) );
g_NOR NOR2 ( .a(a),        .b(nor1_out), .out(nor2_out) );
g_NOR NOR3 ( .a(nor1_out), .b(b),        .out(nor3_out) );
g_NOR NOR4 ( .a(nor2_out), .b(nor3_out), .out(out)      );

endmodule
