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
    input  [13:0] address,
    output [15:0] out
);

wire        SelA, SelB, SelC, SelD;
wire [15:0] OutA, OutB, OutC, OutD;

c_DMux4Way DMux4Way   ( .in(load), .sel(address[13:12]), .a(SelA), .b(SelB), .c(SelC), .d(SelD) );
c_RAM4K RAM4K_A       ( .clk(clk), .in(in), .load(SelA), .address(address[8:0]), .out(OutA) );
c_RAM4K RAM4K_B       ( .clk(clk), .in(in), .load(SelB), .address(address[8:0]), .out(OutB) );
c_RAM4K RAM4K_C       ( .clk(clk), .in(in), .load(SelC), .address(address[8:0]), .out(OutC) );
c_RAM4K RAM4K_D       ( .clk(clk), .in(in), .load(SelD), .address(address[8:0]), .out(OutD) );
c_RAM4K RAM4K_E       ( .clk(clk), .in(in), .load(SelE), .address(address[8:0]), .out(OutE) );
c_RAM4K RAM4K_F       ( .clk(clk), .in(in), .load(SelF), .address(address[8:0]), .out(OutF) );
c_RAM4K RAM4K_G       ( .clk(clk), .in(in), .load(SelG), .address(address[8:0]), .out(OutG) );
c_RAM4K RAM4K_H       ( .clk(clk), .in(in), .load(SelH), .address(address[8:0]), .out(OutH) );
c_Mux4Way16 Mux4Way16 ( .a(OutA), .b(OutB), .c(OutC), .d(OutD), .sel(address[13:12]), .out(out) );

endmodule
