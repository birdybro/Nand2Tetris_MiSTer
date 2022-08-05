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

module DMUX
(
    input  in,
    input  sel,
    output a,
    output b
);

// |  in   |  sel  |   a   |   b   |
// |   0   |   0   |   0   |   0   |
// |   0   |   1   |   0   |   0   |
// |   1   |   0   |   1   |   0   |
// |   1   |   1   |   0   |   1   |

// This sort of thing could easily be handled with a case statement
// or an always @(*) block with conditionals but we should do it
// the way the course emphasizes, by using components we designed.

wire notsel;

NOT NOT
(
    .in(sel),
    .out(notsel)
);

AND AND1
(
    .a(in),
    .b(notsel),
    .out(a)
);

AND AND2
(
    .a(sel),
    .b(in),
    .out(b)
);

endmodule
