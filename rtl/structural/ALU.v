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

// Implementation: the ALU manipulates the x and y
// inputs and then operates on the resulting values,
// as follows:
// if (zx  == 1) sets x = 0        // 16-bit constant
// if (nx  == 1) sets x = ~x       // bitwise "not"
// if (zy  == 1) sets y = 0        // 16-bit constant
// if (ny  == 1) sets y = ~y       // bitwise "not"
// if (f   == 1) sets out = x + y  // integer 2's-complement addition
// if (f   == 0) sets out = x & y  // bitwise And
// if (no  == 1) sets out = ~out   // bitwise Not
// if (out == 0) sets zr = 1
// if (out < 0)  sets ng = 1

module c_ALU
(
    input  [15:0] x, y,
    input         zx, nx,
    input         zy, ny,
    input         f, no,

    output [15:0] out,
    output        zr, ng
);

wire [15:0] x1, x2;
wire [15:0] y1, y2;
wire [15:0] notx1, noty1;
wire [15:0] and16, add16;
wire [15:0] func16, notfunc16;
wire [15:0] ngOut16;
wire        or1, or2, or_fin;

// zx
c_MUX16 MuxZX   ( .a(x), .b(16'b0000000000000000), .sel(zx), .out(x1) );

// nx
c_NOT16 Not16NX ( .in(x1),                     .out(notx1) );
c_MUX16 MuxNX   ( .a(x1), .b(notx1), .sel(nx), .out(x2)    );

// zy
c_MUX16 MuxZY   ( .a(y), .b(16'b0000000000000000), .sel(zy), .out(y1) );

// ny
c_NOT16 Not16NY ( .in(y1),                     .out(noty1) );
c_MUX16 MuxNY   ( .a(y1), .b(noty1), .sel(ny), .out(y2)    );

// f
c_AND16 And16f  ( .a(x2),    .b(y2),             .out(and16)  );
c_Add16 Add16f  ( .a(x2),    .b(y2),             .out(add16)  );
c_MUX16 Mux16f  ( .a(and16), .b(add16), .sel(f), .out(func16) );

// no
c_NOT16 Not16no ( .in(func16),                         .out(notfunc16) );
c_MUX16 Mux16zr ( .a(func16), .b(notfunc16), .sel(no), .out(ngOut16)   );

// ng
assign ng = ngOut16[15];

// zr
c_OR8WAY Or8Wayzr1 ( .in(ngOut16[ 7:0]), .out(or1)    );
c_OR8WAY Or8Wayzr2 ( .in(ngOut16[15:8]), .out(or2)    );
c_OR     Orzr      ( .a(or1), .b(or2),   .out(or_fin) );
g_NOT    Notzr     ( .in(or_fin),        .out(zr)     );

endmodule
