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

module c_Mux4Way16
(
    input  [15:0] a, b, c, d,
    input  [ 1:0] sel,
    output [15:0] out
);

wire [15:0] aout, bout;

c_Mux16 MuxA ( .a(a),    .b(b),    .sel(sel[0]), .out(aout) );
c_Mux16 MuxB ( .a(b),    .b(d),    .sel(sel[0]), .out(bout) );
c_Mux16 Mux  ( .a(aout), .b(bout), .sel(sel[1]), .out(out)  );

endmodule
