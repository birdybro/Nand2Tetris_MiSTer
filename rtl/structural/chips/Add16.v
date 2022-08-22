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

module c_Add16
(
    input  [15:0] a, b,
    output [15:0] out
);

wire [15:0] carry;

c_HalfAdder HalfAdder0  (                .a(a[0]),  .b(b[0]),  .sum(out[0]),  .carry(carry[0])  );
c_FullAdder FullAdder1  ( .a(carry[0]),  .b(a[1]),  .c(b[1]),  .sum(out[1]),  .carry(carry[1])  );
c_FullAdder FullAdder2  ( .a(carry[1]),  .b(a[2]),  .c(b[2]),  .sum(out[2]),  .carry(carry[2])  );
c_FullAdder FullAdder3  ( .a(carry[2]),  .b(a[3]),  .c(b[3]),  .sum(out[3]),  .carry(carry[3])  );
c_FullAdder FullAdder4  ( .a(carry[3]),  .b(a[4]),  .c(b[4]),  .sum(out[4]),  .carry(carry[4])  );
c_FullAdder FullAdder5  ( .a(carry[4]),  .b(a[5]),  .c(b[5]),  .sum(out[5]),  .carry(carry[5])  );
c_FullAdder FullAdder6  ( .a(carry[5]),  .b(a[6]),  .c(b[6]),  .sum(out[6]),  .carry(carry[6])  );
c_FullAdder FullAdder7  ( .a(carry[6]),  .b(a[7]),  .c(b[7]),  .sum(out[7]),  .carry(carry[7])  );
c_FullAdder FullAdder8  ( .a(carry[7]),  .b(a[8]),  .c(b[8]),  .sum(out[8]),  .carry(carry[8])  );
c_FullAdder FullAdder9  ( .a(carry[8]),  .b(a[9]),  .c(b[9]),  .sum(out[9]),  .carry(carry[9])  );
c_FullAdder FullAdder10 ( .a(carry[9]),  .b(a[10]), .c(b[10]), .sum(out[10]), .carry(carry[10]) );
c_FullAdder FullAdder11 ( .a(carry[10]), .b(a[11]), .c(b[11]), .sum(out[11]), .carry(carry[11]) );
c_FullAdder FullAdder12 ( .a(carry[11]), .b(a[12]), .c(b[12]), .sum(out[12]), .carry(carry[12]) );
c_FullAdder FullAdder13 ( .a(carry[12]), .b(a[13]), .c(b[13]), .sum(out[13]), .carry(carry[13]) );
c_FullAdder FullAdder14 ( .a(carry[13]), .b(a[14]), .c(b[14]), .sum(out[14]), .carry(carry[14]) );
c_FullAdder FullAdder15 ( .a(carry[14]), .b(a[15]), .c(b[15]), .sum(out[15]), .carry(carry[15]) );

endmodule
