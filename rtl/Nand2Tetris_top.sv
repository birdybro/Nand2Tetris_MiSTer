
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

module Nand2Tetris_top
(
	input  logic        clk,
	input  logic        reset,

	input  logic        scandoubler,

	output logic        HBlank, VBlank,
	output logic        HSync, VSync,
	output logic        ce_pix,

	output logic [15:0] alu_out,
	output logic        zr_out,
	output logic        ng_out,
	output logic        rd_rdy_out,

	output logic [ 3:0] vga_r,
	output logic [ 3:0] vga_g,
	output logic [ 3:0] vga_b
);

logic        ce = 1;

logic [15:0] x  = 0101011011100101;
logic [15:0] y  = 0110011100001011;
logic        zx = 0;
logic        nx = 1;
logic        zy = 0;
logic        ny = 0;
logic        f  = 1;
logic        no = 1;
logic [15:0] out;
logic        zr;
logic        ng;
logic        rd_rdy;

assign alu_out    = out;
assign zr_out     = zr;
assign ng_out     = ng;
assign rd_rdy_out = rd_rdy;

ALU ALU
(
	.clk(clk),
	.reset(reset),
	.ce(ce),

	// Input 16-bit Data
	.x(x),
	.y(y),

	// Input Control Bits
	.zx(zx),
	.nx(nx),
	.zy(zy),
	.ny(ny),
	.f(f),
	.no(no),

	//Output 16-bit Data
	.out(out),

	// Output Control Bits
	.zr(zr),
	.ng(ng),
	.rd_rdy(rd_rdy)
);

// ALU_alt ALU_alt
// (
// 	.clk(clk),
// 	.reset(reset),

// 	// Input 16-bit Data
// 	.x(x),
// 	.y(y),

// 	// Input Control Bits
// 	.zx(zx),
// 	.nx(nx),
// 	.zy(zy),
// 	.ny(ny),
// 	.f(f),
// 	.no(no),

// 	//Output 16-bit Data
// 	.out(out),

// 	// Output Control Bits
// 	.zr(zr),
// 	.ng(ng)
// );

endmodule
