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

module c_RAM8
(
    input         clk,
    input  [15:0] in,
    input         load,
    input  [ 2:0] address,
    output [15:0] out
);

wire        SelA, SelB, SelC, SelD, SelE, SelF, SelG, SelH;
wire [15:0] OutA, OutB, OutC, OutD, OutE, OutF, OutG, OutH;

c_DMux8Way  ( .in(load), .sel(address), .a(SelA), .b(SelB), .c(SelC), .d(SelD), .e(SelE), .f(SelF), .g(SelG), .h(SelH) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutA) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutB) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutC) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutD) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutE) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutF) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutG) );
c_Register  ( .clk(clk), .in(in), .load(Sel), .out(OutH) );
c_Mux8Way16 ( .a(OutA), .b(OutB), .c(OutC), .d(OutD), .e(OutE), .f(OutF), .g(OutG), .h(OutH), .sel(address), .out(out) );

endmodule
