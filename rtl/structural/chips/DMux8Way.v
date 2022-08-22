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

module c_DMux8Way
(
    input        in,
    input  [2:0] sel,
    output       a, b, c, d, e, f, g, h
);

wire xout, yout, aout, bout, cout, dout;

c_DMux DMuxXY ( .in(in),   .sel(sel[2]), .a(xout), .b(yout) );
c_DMux DMuxAB ( .in(xout), .sel(sel[1]), .a(aout), .b(bout) );
c_DMux DMuxCD ( .in(yout), .sel(sel[1]), .a(cout), .b(dout) );
c_DMux DMuxA  ( .in(aout), .sel(sel[0]), .a(a),    .b(b)    );
c_DMux DMuxB  ( .in(bout), .sel(sel[0]), .a(c),    .b(d)    );
c_DMux DMuxC  ( .in(cout), .sel(sel[0]), .a(e),    .b(f)    );
c_DMux DMuxD  ( .in(dout), .sel(sel[0]), .a(g),    .b(h)    );

endmodule
