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

module c_4to2Enc
(
    input  [3:0] in,
    output [1:0] out
);

wire Not1Out, And1Out;
g_NOT Not1 ( .in(in[2]),               .out(Not1Out) );
g_AND And1 ( .a(Not1Out), .b(in[1]),   .out(And1Out) );
g_OR  Or1  ( .a(in[2]),   .b(in[3]),   .out(out[1])  );
g_OR  Or2  ( .a(in[3]),   .b(And1Out), .out(out[0])  );

endmodule
