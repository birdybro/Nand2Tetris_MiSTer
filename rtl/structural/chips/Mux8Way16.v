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

module c_Mux8Way16
(
    input  [15:0] a, b, c, d, e, f, g, h,
    input  [ 2:0] sel,
    output [15:0] out
);

wire [15:0] aout, bout, cout, dout, xout, yout;

c_Mux16 MuxA ( .a(a),    .b(b),    .sel(sel[0]), .out(aout)  );
c_Mux16 MuxB ( .a(b),    .b(d),    .sel(sel[0]), .out(bout)  );
c_Mux16 MuxC ( .a(e),    .b(f),    .sel(sel[0]), .out(cout)  );
c_Mux16 MuxD ( .a(g),    .b(h),    .sel(sel[0]), .out(dout)  );
c_Mux16 MuxX ( .a(aout), .b(bout), .sel(sel[1]), .out(xout)  );
c_Mux16 MuxY ( .a(cout), .b(dout), .sel(sel[1]), .out(yout)  );
c_Mux16 Mux  ( .a(xout), .b(yout), .sel(sel[2]), .out(out)   );

endmodule
