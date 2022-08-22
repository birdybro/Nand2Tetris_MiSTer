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

module c_And16
(
    input  [15:0] a, b,
    output [15:0] out
);

g_AND AND1  ( .a(a[0]),  .b(b[0]),  .out(out[0] ) );
g_AND AND2  ( .a(a[1]),  .b(b[1]),  .out(out[1] ) );
g_AND AND3  ( .a(a[2]),  .b(b[2]),  .out(out[2] ) );
g_AND AND4  ( .a(a[3]),  .b(b[3]),  .out(out[3] ) );
g_AND AND5  ( .a(a[4]),  .b(b[4]),  .out(out[4] ) );
g_AND AND6  ( .a(a[5]),  .b(b[5]),  .out(out[5] ) );
g_AND AND7  ( .a(a[6]),  .b(b[6]),  .out(out[6] ) );
g_AND AND8  ( .a(a[7]),  .b(b[7]),  .out(out[7] ) );
g_AND AND9  ( .a(a[8]),  .b(b[8]),  .out(out[8] ) );
g_AND AND10 ( .a(a[9]),  .b(b[9]),  .out(out[9] ) );
g_AND AND11 ( .a(a[10]), .b(b[10]), .out(out[10]) );
g_AND AND12 ( .a(a[11]), .b(b[11]), .out(out[11]) );
g_AND AND13 ( .a(a[12]), .b(b[12]), .out(out[12]) );
g_AND AND14 ( .a(a[13]), .b(b[13]), .out(out[13]) );
g_AND AND15 ( .a(a[14]), .b(b[14]), .out(out[14]) );
g_AND AND16 ( .a(a[15]), .b(b[15]), .out(out[15]) );

endmodule
