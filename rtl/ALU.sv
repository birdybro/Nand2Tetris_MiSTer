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

// The ALU (Arithmetic Logic Unit).
// Computes one of the following functions:
// x+y, x-y, y-x, 0, 1, -1, x, y, -x, -y, !x, !y,
// x+1, y+1, x-1, y-1, x&y, x|y on two 16-bit inputs, 
// according to 6 input bits denoted zx,nx,zy,ny,f,no.
// In addition, the ALU computes two 1-bit outputs:
// if the ALU output == 0, zr is set to 1; otherwise zr is set to 0;
// if the ALU output < 0, ng is set to 1; otherwise ng is set to 0.

// Implementation: the ALU logic manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1)  set x = 0        // 16-bit constant
// if (nx == 1)  set x = !x       // bitwise not
// if (zy == 1)  set y = 0        // 16-bit constant
// if (ny == 1)  set y = !y       // bitwise not
// if (f == 1)   set out = x + y  // integer 2's complement addition
// if (f == 0)   set out = x & y  // bitwise and
// if (no == 1)  set out = !out   // bitwise not
// if (out == 0) set zr = 1
// if (out < 0)  set ng = 1

module ALU
(
    input  logic        clk, reset, ce,
    input  logic [15:0] x, y,
    input  logic        zx, nx, zy, ny, f, no,

    output logic [15:0] out,
    output logic        zr, ng,

    output logic        rd_rdy
);

always_ff begin
    logic [15:0] last_x   = 0;
    logic [15:0] last_y   = 0;
    logic [15:0] last_out = 0;
    logic        x_done   = 0;
    logic        y_done   = 0;
    logic        out_done = 0;
    logic        complete = 0;
    logic        finish   = 0;
    if (ce) begin
        if (zx && nx) begin
            last_x <= 16'b1;
            x_done <= 1;
        end else if (zx && ~nx) begin
            last_x <= 16'b0;
            x_done <= 1;
        end else if (~zx && nx) begin
            last_x <= ~x;
            x_done <= 1;
        end else begin
            last_x <= x;
            x_done <= 1;
        end
        if (zy && ny) begin
            last_y <= 16'b1;
            y_done <= 1;
        end else if (zy && ~ny) begin
            last_y <= 16'b0;
            y_done <= 1;
        end else if (~zy && ny) begin
            last_y <= ~y;
            y_done <= 1;
        end else begin
            last_y <= y;
            y_done <= 1;
        end
        if (x_done & y_done & ~out_done) begin
            if (f == 1) begin
                last_out <= last_x + last_y;
                out_done <= 1;
            end else if (f == 0) begin
                last_out <= x & y;
                out_done <= 1;
            end
            if (out_done == 1) begin
                if (no == 1) begin
                    out <= ~last_out;
                    complete <= 1;
                end else begin
                    out <= last_out;
                    complete <= 1;
                end
            end
            if (complete == 1) begin
                if (out == 0) begin
                    zr <= 1;
                    finish <= 1;
                end else if (out[15] == 16'b1) begin
                    ng <= 1;
                    finish <= 1;
                end
            end
            if (finish == 1) rd_rdy <= 1;
        end
    end
end

endmodule
