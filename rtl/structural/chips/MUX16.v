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

module c_MUX16
(
    input  [15:0] a, b,
    input         sel,
    output [15:0] out
);

c_MUX MUX1  ( .a(a[0]),  .b(b[0]),  .sel(sel), .out(out[0])  );
c_MUX MUX2  ( .a(a[1]),  .b(b[1]),  .sel(sel), .out(out[1])  );
c_MUX MUX3  ( .a(a[2]),  .b(b[2]),  .sel(sel), .out(out[2])  );
c_MUX MUX4  ( .a(a[3]),  .b(b[3]),  .sel(sel), .out(out[3])  );
c_MUX MUX5  ( .a(a[4]),  .b(b[4]),  .sel(sel), .out(out[4])  );
c_MUX MUX6  ( .a(a[5]),  .b(b[5]),  .sel(sel), .out(out[5])  );
c_MUX MUX7  ( .a(a[6]),  .b(b[6]),  .sel(sel), .out(out[6])  );
c_MUX MUX8  ( .a(a[7]),  .b(b[7]),  .sel(sel), .out(out[7])  );
c_MUX MUX9  ( .a(a[8]),  .b(b[8]),  .sel(sel), .out(out[8])  );
c_MUX MUX10 ( .a(a[9]),  .b(b[9]),  .sel(sel), .out(out[9])  );
c_MUX MUX11 ( .a(a[10]), .b(b[10]), .sel(sel), .out(out[10]) );
c_MUX MUX12 ( .a(a[11]), .b(b[11]), .sel(sel), .out(out[11]) );
c_MUX MUX13 ( .a(a[12]), .b(b[12]), .sel(sel), .out(out[12]) );
c_MUX MUX14 ( .a(a[13]), .b(b[13]), .sel(sel), .out(out[13]) );
c_MUX MUX15 ( .a(a[14]), .b(b[14]), .sel(sel), .out(out[14]) );
c_MUX MUX16 ( .a(a[15]), .b(b[15]), .sel(sel), .out(out[15]) );

endmodule
