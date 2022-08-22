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

module c_Register
(
    input         clk,
    input  [15:0] in,
    input         load,
    output [15:0] out
);

c_Bit Bit0  ( .clk(clk), .in(in[0]),  .load(load), .out(out[0])  );
c_Bit Bit1  ( .clk(clk), .in(in[1]),  .load(load), .out(out[1])  );
c_Bit Bit2  ( .clk(clk), .in(in[2]),  .load(load), .out(out[2])  );
c_Bit Bit3  ( .clk(clk), .in(in[3]),  .load(load), .out(out[3])  );
c_Bit Bit4  ( .clk(clk), .in(in[4]),  .load(load), .out(out[4])  );
c_Bit Bit5  ( .clk(clk), .in(in[5]),  .load(load), .out(out[5])  );
c_Bit Bit6  ( .clk(clk), .in(in[6]),  .load(load), .out(out[6])  );
c_Bit Bit7  ( .clk(clk), .in(in[7]),  .load(load), .out(out[7])  );
c_Bit Bit8  ( .clk(clk), .in(in[8]),  .load(load), .out(out[8])  );
c_Bit Bit9  ( .clk(clk), .in(in[9]),  .load(load), .out(out[9])  );
c_Bit Bit10 ( .clk(clk), .in(in[10]), .load(load), .out(out[10]) );
c_Bit Bit11 ( .clk(clk), .in(in[11]), .load(load), .out(out[11]) );
c_Bit Bit12 ( .clk(clk), .in(in[12]), .load(load), .out(out[12]) );
c_Bit Bit13 ( .clk(clk), .in(in[13]), .load(load), .out(out[13]) );
c_Bit Bit14 ( .clk(clk), .in(in[14]), .load(load), .out(out[14]) );
c_Bit Bit15 ( .clk(clk), .in(in[15]), .load(load), .out(out[15]) );

endmodule
