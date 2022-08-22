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

module c_Not16
(
    input  [15:0] in,
    output [15:0] out
);

g_NOT NOT1  ( .in(in[0]),  .out(out[0])  );
g_NOT NOT2  ( .in(in[1]),  .out(out[1])  );
g_NOT NOT3  ( .in(in[2]),  .out(out[2])  );
g_NOT NOT4  ( .in(in[3]),  .out(out[3])  );
g_NOT NOT5  ( .in(in[4]),  .out(out[4])  );
g_NOT NOT6  ( .in(in[5]),  .out(out[5])  );
g_NOT NOT7  ( .in(in[6]),  .out(out[6])  );
g_NOT NOT8  ( .in(in[7]),  .out(out[7])  );
g_NOT NOT9  ( .in(in[8]),  .out(out[8])  );
g_NOT NOT10 ( .in(in[9]),  .out(out[9])  );
g_NOT NOT11 ( .in(in[10]), .out(out[10]) );
g_NOT NOT12 ( .in(in[11]), .out(out[11]) );
g_NOT NOT13 ( .in(in[12]), .out(out[12]) );
g_NOT NOT14 ( .in(in[13]), .out(out[13]) );
g_NOT NOT15 ( .in(in[14]), .out(out[14]) );
g_NOT NOT16 ( .in(in[15]), .out(out[15]) );

endmodule
