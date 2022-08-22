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

module c_RAM4K
(
    input         clk,
    input  [15:0] in,
    input         load,
    input  [11:0] address,
    output [15:0] out
);

wire        SelA, SelB, SelC, SelD, SelE, SelF, SelG, SelH;
wire [15:0] OutA, OutB, OutC, OutD, OutE, OutF, OutG, OutH;

c_DMux8Way DMuxy8Way  ( .in(load), .sel(address[11:9]), .a(SelA), .b(SelB), .c(SelC), .d(SelD), .e(SelE), .f(SelF), .g(SelG), .h(SelH) );
c_RAM512 RAM512A      ( .clk(clk), .in(in), .load(SelA), .address(address[8:0]), .out(OutA) );
c_RAM512 RAM512B      ( .clk(clk), .in(in), .load(SelB), .address(address[8:0]), .out(OutB) );
c_RAM512 RAM512C      ( .clk(clk), .in(in), .load(SelC), .address(address[8:0]), .out(OutC) );
c_RAM512 RAM512D      ( .clk(clk), .in(in), .load(SelD), .address(address[8:0]), .out(OutD) );
c_RAM512 RAM512E      ( .clk(clk), .in(in), .load(SelE), .address(address[8:0]), .out(OutE) );
c_RAM512 RAM512F      ( .clk(clk), .in(in), .load(SelF), .address(address[8:0]), .out(OutF) );
c_RAM512 RAM512G      ( .clk(clk), .in(in), .load(SelG), .address(address[8:0]), .out(OutG) );
c_RAM512 RAM512H      ( .clk(clk), .in(in), .load(SelH), .address(address[8:0]), .out(OutH) );
c_Mux8Way16 Mux8Way16 ( .a(OutA), .b(OutB), .c(OutC), .d(OutD), .e(OutE), .f(OutF), .g(OutG), .h(OutH), .sel(address[11:9]), .out(out) );

endmodule
