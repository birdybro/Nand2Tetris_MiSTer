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

module c_FullAdder
(
    input  a, b, c,
    output sum, carry
);

wire sum_1, carry_1, carry_2;

c_HalfAdder HalfAdder1 ( .a(a),       .b(b),       .sum(sum_1), .carry(carry_1) );
c_HalfAdder HalfAdder2 ( .a(c),       .b(sum_1),   .sum(sum),   .carry(carry_2) );
g_OR OR1               ( .a(carry_1), .b(carry_2), .out(carry)                  );

endmodule
