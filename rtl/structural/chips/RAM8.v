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

c_DMux8Way DMux8Way   ( .in(load), .sel(address), .a(SelA), .b(SelB), .c(SelC), .d(SelD), .e(SelE), .f(SelF), .g(SelG), .h(SelH) );
c_Register RegisterA  ( .clk(clk), .in(in), .load(SelA), .out(OutA) );
c_Register RegisterB  ( .clk(clk), .in(in), .load(SelB), .out(OutB) );
c_Register RegisterC  ( .clk(clk), .in(in), .load(SelC), .out(OutC) );
c_Register RegisterD  ( .clk(clk), .in(in), .load(SelD), .out(OutD) );
c_Register RegisterE  ( .clk(clk), .in(in), .load(SelE), .out(OutE) );
c_Register RegisterF  ( .clk(clk), .in(in), .load(SelF), .out(OutF) );
c_Register RegisterG  ( .clk(clk), .in(in), .load(SelG), .out(OutG) );
c_Register RegisterH  ( .clk(clk), .in(in), .load(SelH), .out(OutH) );
c_Mux8Way16 Mux8Way16 ( .a(OutA), .b(OutB), .c(OutC), .d(OutD), .e(OutE), .f(OutF), .g(OutG), .h(OutH), .sel(address), .out(out) );

endmodule
