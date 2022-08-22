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

module c_PC
(
    input [15:0] in,
    input        load, inc, reset,
    output [15:0] out
);

wire [15:0] regOut, incReg, incMuxOut, loadOut, resetOut;
wire false_b = 16'b0000000000000000;
wire true_b  = 16'b1111111111111111;

c_Inc16 Inc16       ( .in(regOut),                              .out(incReg)    );
c_Mux16 Mux16inc    ( .a(regOut),    .b(incReg),  .sel(inc),    .out(incMuxOut) );
c_Mux16 Mux16load   ( .a(incMuxOut), .b(in),      .sel(load),   .out(resetOut)  );
c_Mux16 Mux16reset  ( .a(loadOut),   .b(false_b),  .sel(reset), .out(resetOut)  );
c_Register Register ( .in(resetOut), .load(true_b),             .out(regOut)    );

assign out = regOut;

endmodule
