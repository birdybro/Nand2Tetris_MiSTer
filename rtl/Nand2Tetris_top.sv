
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

endmodule
