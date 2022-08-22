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

module c_2to4Dec
(
    input  [1:0] in,
    output [3:0] out
);

wire NOTaOut, NOTbOut;
g_NOT NOTa ( .in(in[0]),               .out(NOTaOut) );
g_NOT NOTb ( .in(in[1]),               .out(NOTbOut) );
g_AND AND1 ( .a(NOTaOut), .b(NOTbOut), .out(out[0])  );
g_AND AND2 ( .a(NOTaOut), .b(in[1]),   .out(out[1])  );
g_AND AND3 ( .a(in[0]),   .b(NOTbOut), .out(out[2])  );
g_AND AND4 ( .a(in[0]),   .b(in[1]),   .out(out[3])  );

endmodule