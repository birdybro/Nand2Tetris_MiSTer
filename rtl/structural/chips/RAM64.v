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

module c_RAM64
(
    input         clk,
    input  [15:0] in,
    input         load,
    input  [ 5:0] address,
    output [15:0] out
);

wire        SelA, SelB, SelC, SelD, SelE, SelF, SelG, SelH;
wire [15:0] OutA, OutB, OutC, OutD, OutE, OutF, OutG, OutH;

c_DMux8Way DMux8Way   ( .in(load), .sel(address[5:3]), .a(SelA), .b(SelB), .c(SelC), .d(SelD), .e(SelE), .f(SelF), .g(SelG), .h(SelH) );
c_RAM8 RAM8A          ( .in(in), .load(SelA), .address(address[2:0]), .out(OutA) );
c_RAM8 RAM8B          ( .in(in), .load(SelB), .address(address[2:0]), .out(OutB) );
c_RAM8 RAM8C          ( .in(in), .load(SelC), .address(address[2:0]), .out(OutC) );
c_RAM8 RAM8D          ( .in(in), .load(SelD), .address(address[2:0]), .out(OutD) );
c_RAM8 RAM8E          ( .in(in), .load(SelE), .address(address[2:0]), .out(OutE) );
c_RAM8 RAM8F          ( .in(in), .load(SelF), .address(address[2:0]), .out(OutF) );
c_RAM8 RAM8G          ( .in(in), .load(SelG), .address(address[2:0]), .out(OutG) );
c_RAM8 RAM8H          ( .in(in), .load(SelH), .address(address[2:0]), .out(OutH) );
c_Mux8Way16 Mux8Way16 ( .a(OutA), .b(OutB), .c(OutC), .d(OutD), .e(OutE), .f(OutF), .g(OutG), .h(OutH), .sel(address[5:3]), .out(out) );

endmodule
