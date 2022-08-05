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

module g_OR8WAY
(
    input [7:0] in,
    output      out
);

wire orout1;

g_OR OR1
(
    .a(in[0]),
    .b(in[1]),
    .out(orout1)
);

wire orout2;

g_OR OR2
(
    .a(in[2]),
    .b(in[3]),
    .out(orout2)
);

wire orout3;

g_OR OR3
(
    .a(in[4]),
    .b(in[5]),
    .out(orout3)
);

wire orout4;

g_OR OR4
(
    .a(in[6]),
    .b(in[7]),
    .out(orout4)
);

wire oroutx;

g_OR ORx
(
    .a(orout1),
    .b(orout2),
    .out(oroutx)
);

wire orouty;

g_OR ORy
(
    .a(orout3),
    .b(orout4),
    .out(orouty)
);

g_OR ORfinal
(
    .a(oroutx),
    .b(orouty),
    .out(out)
);

endmodule
