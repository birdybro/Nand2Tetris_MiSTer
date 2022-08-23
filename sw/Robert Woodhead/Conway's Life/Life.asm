//
// Conway's Game of Life in Hack Assembly language -- https://en.wikipedia.org/wiki/Conway's_Game_of_Life
//
// (C)2016 Robert Woodhead - trebor@animeigo.com / @madoverlord - Creative Commons Attribution License
//
// I am indebted to http://www.conwaylife.com/wiki/Main_Page, the LifeWiki, which is a great resource
// for finding interesting Life Patterns.
//
// Notes on implementation:
//
// Game Board: a 64x32 matrix of cells, wrapping around at the edges, so the board is effectively a torus.
// This maps onto the display screen with each cell taking up 8x8 pixels. The game board is stored as a
// 66x34 matrix with guard cells around the edges that are used to both simplify the code and implement
// the wrapping feature.
//
// Typical implementations of Life store multiple cells per word and use clever bit-banging techniques
// to update them in parallel to minimize the number of operations (especially memory fetches on machines
// where those are expensive). However, the Hack machine architecture is not well suited to these techniques
// so each cell is implemented as a full word; the sign bit contains the state of the cell in the current
// generation (so live = 1000 ... 0000 and dead = 0000 ... 0000). In the first pass, each cell has 1 added
// to it for each live neighbor. Then in a second pass, a table lookup is used to convert the neighbor count
// into the new value for the cell.
//
// The board starts at location 10000. Compressed boards (1 bit per cell) are loaded into RAM from ROM
// at location 9800, then expanded.
//
// Lookup tables for computing the new state of live and dead cells are placed at 9970 and 9980 respectively.
// Each is 9 elements long (because a cell can have from 0-8 neighbors).
//
// A 64 element divide-by-2 table is located at 9700.
//
// The board temp buffer (a copy of the board @10000) is stored at starting at 7000; the previous temp buffer
// is stored at 4500, so we have a level of undo.
//
// Boy do I wish the assembler had some simple address arithmetic and symbol definition abilities.
//
// Stack: the stack is only used to store return addresses. It grows down from just below the SCREEN
// location. Function parameters are stored in function local variables before calling, so functions
// are generally not re-entrant.
//
// Keyboard commands:
//
// 0-9		Load prestored board (0 = logo board)
// Space 	Compute Next Generation
// Return 	Free-run until another key pressed
// Arrows 	Move editing cursor up/down/right/left
// Q W E 	8-way cursor movement
// A   D
// Z X C
// ` or S 	Toggle current cell
// DEL 		Clear board
// < or ,	Save board in temp buffer (2 levels)
// > or . 	Restore board from temp buffer (2 levels)
//
// Conventions:
//

	@SCREEN 		// SP = SCREEN - 1
	D = A - 1
	@SP
	M = D

// Initialize (INI) will load some tables into RAM from ROM

	@INI.Ret		// D = INI return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Initialize 	// Initialize()
	0 ; JMP

(INI.Ret)			// Return from Initialize here

// Initial Logo Load (ILL) will set up the board

	@ILL.Ret		// D = ILL return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Logo.Board 	// D = Test.Board (address of CODE to run to import the board data from rom)
	D = A

	@Load_Board 	// Load_Board()
	0 ; JMP

(ILL.Ret)			// Return from Load_Board here

// Initialize cursor location and state

	@32 			// Life.x = 32 (x position of cursor)
	D = A
	@Life.x
	M = D

	@16 			// Life.y = 16 (y position of cursor)
	D = A
	@Life.y
	M = D

	@Life.key.repeat 	// autorepeat flag
	M = 0

	@Life.blink 	// Life.blink = 1 (cursor blink counter)
	M = 1

	@32767 			// Life.speed = 32677 (cursor blink speed)
	D = A
	@Life.speed
	M = D

	@KBD 			// Life.key = [KBD]
	D = M
	@Key.Pressed
	M = D

	@Key.Up 		// Skip to end of key processing loop if we have a key
	D ; JNE 		// This handles stale key on program start

// Loop processing keys, blinking cursor while waiting

(Key.Down) 			// Loop until key pressed

	@KBD 			// D = [KBD]
	D = M

	@Key.Pressed 	// if a key has been pressed, process it
	D ; JNE

	D = D 			// NOP instructions to slow down this loop
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D
	D = D

	@Life.blink 	// if --Life.blink == 0, blink cursor
	MD = M - 1
	@Key.Down
	D ; JNE

// Blink the cursor

(Blink)

	@Life.speed 	// Life.blink = Life.speed (resets blink count)
	D = M
	@Life.blink
	M = D

// Compute the location in the screen buffer of the current cursor position.
// There are 32 bytes per row, and 8 rows per cell. 32*8 = 256. We also skip
// 2 rows because we only modify the central 4x4 pixels of a cell.

	@Life.y 		// Blink.row = (Life.y * 256) + SCREEN + 64
	AD = M
	AD = D + A
	AD = D + A
	AD = D + A
	AD = D + A
	AD = D + A
	AD = D + A
	AD = D + A
	AD = D + A
	@16448
	D = D + A
	@Blink.row
	M = D

// Each word in the screen buffer holds the bits for two adjacent cells. Use
// the low bit of Life.x to determine which byte of the word is used by the
// current cell, and create a mask.

	D = -1 			// D = 1111 ... 1110
	D = D - 1
	@Life.x
	D = D & M 		// D = Life.x with low bit masked off

	@Life.x 		// if low bit set, upper byte contains mask
	D = D - M
	@Blink.Upper
	D ; JNE

(Blink.Lower)

	@60 			// D = 0000 0000 0011 1100
	D = A
	@Blink.Xor
	0 ; JMP

(Blink.Upper)

	@15360 			// D = 0011 1100 0000 0000
	D = A

(Blink.Xor)

	@Blink.mask 	// Blink.mask = XOR mask of bits to flip
	M = D

	@Life.x 		// Blink.row = Blink.row + DivByTwo[Life.x]
	D = M 			// Since we don't have a shift-right instruction
	@9700 			// we use a lookup table @ 9700
	A = D + A
	D = M

	@Blink.row 		// Also save Blink.row in A, so M then points
	AM = D + M 		// to the first word in screem memory we want to alter

	D = M 			// Blink.word = [Blink.row]
	@Blink.word
	M = D

	@Blink.mask 	// Blink.new = Blink.word XOR Blink.mask
	D = D | M 		// XOR(A,B) = (A|B) & !(A&B)
	@Blink.or
	M = D

	@Blink.word
	D = M
	@Blink.mask
	D = D & M
	D = !D

	@Blink.or
	D = D & M

	@Blink.new
	M = D

	@Blink.row 		// [Blink.row] = Blink.new
	A = M
	M = D

	@Blink.row 		// [Blink.row += 32] = Blink.new
	D = M
	@32
	D = D + A
	@Blink.row
	M = D

	@Blink.new
	D = M

	@Blink.row
	A = M
	M = D

	@Blink.row 		// [Blink.row += 32] = Blink.new
	D = M
	@32
	D = D + A
	@Blink.row
	M = D

	@Blink.new
	D = M

	@Blink.row
	A = M
	M = D

	@Blink.row 		// [Blink.row += 32] = Blink.new
	D = M
	@32
	D = D + A
	@Blink.row
	M = D

	@Blink.new
	D = M

	@Blink.row
	A = M
	M = D

	@Key.Down 		// Resume looking for a key
	0 ; JMP

(Key.Pressed)

	@Life.key 		// @Life.key = D
	M = D

	// Arrow keys

	@Life.key 		// Up
	D = M
	@131
	D = D - A
	@Key.MoveUp
	D ; JEQ

	@Life.key 		// Down
	D = M
	@133
	D = D - A
	@Key.MoveDown
	D ; JEQ

	@Life.key 		// Right
	D = M
	@132
	D = D - A
	@Key.MoveRight
	D ; JEQ

	@Life.key 		// Left
	D = M
	@130
	D = D - A
	@Key.MoveLeft
	D ; JEQ

	// 8-way keys

	@Life.key 		// W = Up
	D = M
	@87
	D = D - A
	@Key.MoveUp
	D ; JEQ

	@Life.key 		// X = Down
	D = M
	@88
	D = D - A
	@Key.MoveDown
	D ; JEQ

	@Life.key 		// D = Right
	D = M
	@68
	D = D - A
	@Key.MoveRight
	D ; JEQ

	@Life.key 		// A = Left
	D = M
	@65
	D = D - A
	@Key.MoveLeft
	D ; JEQ

	@Life.key 		// Q = Up-Left
	D = M
	@81
	D = D - A
	@Key.MoveUpLeft
	D ; JEQ

	@Life.key 		// E = Up-Right
	D = M
	@69
	D = D - A
	@Key.MoveUpRight
	D ; JEQ

	@Life.key 		// Z = Down-Left
	D = M
	@90
	D = D - A
	@Key.MoveDownLeft
	D ; JEQ

	@Life.key 		// C = Down-Right
	D = M
	@67
	D = D - A
	@Key.MoveDownRight
	D ; JEQ

	@Life.key 		// Space bar?
	D = M
	@32 			
	D = D - A
	@Key.Space 			
	D ; JEQ

	@Life.key 		// Enter
	D = M
	@128
	D = D - A
	@Key.Enter
	D ; JEQ

	@Life.key 		// DEL
	D = M
	@139
	D = D - A
	@Key.Clear
	D ; JEQ

	@Life.key 		// ` = Toggle cell
	D = M
	@96
	D = D - A
	@Key.Toggle
	D ; JEQ

	@Life.key 		// S = Toggle cell
	D = M
	@83
	D = D - A
	@Key.Toggle
	D ; JEQ

	@Life.key 		// < = Save buffer
	D = M
	@60
	D = D - A
	@Key.Save
	D ; JEQ

	@Life.key 		// > = Restore buffer
	D = M
	@62
	D = D - A
	@Key.Restore
	D ; JEQ

	@Life.key 		// , = Save buffer
	D = M
	@44
	D = D - A
	@Key.Save
	D ; JEQ

	@Life.key 		// . = Restore buffer
	D = M
	@46
	D = D - A
	@Key.Restore
	D ; JEQ

	// other keys here

	// Last thing we check is loading prestored patterns. First, we
	// prepare for an eventual function call to Load_Board(), with
	// a direct return to the end of our keyboard handler

	@Key.Up
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	// Next, we look for a pattern key and set the D register with the
	// address of the board.

	@Life.key
	D = M
	@48
	D = D - A

	@Key.Pattern0
	D ; JEQ

	D = D - 1
	@Key.Pattern1
	D ; JEQ

	D = D - 1
	@Key.Pattern2
	D ; JEQ

	D = D - 1
	@Key.Pattern3
	D ; JEQ

	D = D - 1
	@Key.Pattern4
	D ; JEQ

	D = D - 1
	@Key.Pattern5
	D ; JEQ

	D = D - 1
	@Key.Pattern6
	D ; JEQ

	D = D - 1
	@Key.Pattern7
	D ; JEQ

	D = D - 1
	@Key.Pattern8
	D ; JEQ

	D = D - 1
	@Key.Pattern9
	D ; JEQ

	// room for more patterns as needed

(Key.Pattern6)
(Key.Pattern7)
(Key.Pattern8)
(Key.Pattern9)

	// If we get to here, we don't have a valid board, so we need
	// to restore the SP

	@SP 			// Pop the un-needed return address off stack
	M = M + 1

	@Key.Up 		// And skip to the bottom of the handler
	0 ; JMP
	0 ; JMP

(Key.Pattern0)
	
	@Logo.Board
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

(Key.Pattern1)

	@Oscillator.Board
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

(Key.Pattern2)

	@Gliders.Board
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

(Key.Pattern3)

	@Gosper.Glider.Gun
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

(Key.Pattern4)

	@Beacon.Maker
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

(Key.Pattern5)

	@Blinker.Puffer
	D = A
	@Load_Board 	// Load_Board() will return to Key.Up
	0 ; JMP

// Space bar - run a generation

(Key.Space)

	@Key.Space.Ret	// D = Generation return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Generation 	// Generation()
	0 ; JMP

(Key.Space.Ret)

	@Key.Up
	0 ; JMP

// C - clear the board

(Key.Clear)

	@Key.Change		// D = return directly to Key.Change handler below
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Clear_Board 	// Clear_Board()
	0 ; JMP

// S - save the board (two levels of save)

(Key.Save)

	@Key.Save.2		// D = return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@6999 			// Key.Board.From = 7000 - 1
	D = A
	@Key.Board.From
	M = D

	@4499 			// Key.Board.To = 4500 - 1
	D = A
	@Key.Board.To
	M = D

	@Key.Buffer.Copy
	0 ; JMP

(Key.Save.2)

	@Key.Change		// D = return directly to Key.Change handler below
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@9999 			// Key.Board.From = 10000 - 1
	D = A
	@Key.Board.From
	M = D

	@6999 			// Key.Board.To = 7000 - 1
	D = A
	@Key.Board.To
	M = D

	@Key.Buffer.Copy
	0 ; JMP

// R - Restore the board

(Key.Restore)

	@Key.Restore.2	// D = return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@9999 			// Key.Board.To = 10000 - 1
	D = A
	@Key.Board.To
	M = D

	@6999 			// Key.Board.From = 7000 - 1
	D = A
	@Key.Board.From
	M = D

	@Key.Buffer.Copy
	0 ; JMP

(Key.Restore.2)

	@Key.Change		// D = return directly to Key.Change handler below
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@6999 			// Key.Board.To = 7000 - 1
	D = A
	@Key.Board.To
	M = D

	@4499 			// Key.Board.From = 4500 - 1
	D = A
	@Key.Board.From
	M = D

	// fall through to copy

(Key.Buffer.Copy)

	@2244 				// Key.Board.Count = 2244 (Board Size + 1)
	D = A
	@Key.Board.Count
	M = D

(Key.Buffer.Copy.Top)	// repeat [++Key.Board.To] = [++Key.Board.From] until (--Key.Board.Count == 0)

	@Key.Board.From 	// D = [++Key.Board.From]
	M = M + 1
	A = M
	D = M

	@Key.Board.To 		// [++Key.Board.To] = D
	M = M + 1
	A = M
	M = D

	@Key.Board.Count 	// Loop
	MD = M - 1
	@Key.Buffer.Copy.Top
	D ; JNE

	// return to caller

	@SP 			// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// UpLeft - move cursor

(Key.MoveUpLeft)

	@63 		// Life.x = (Life.x-1) & 03F (63)
	D = A 		// then fall through to move up
	@Life.x
	M = M - 1
	M = D & M

// Up - move cursor

(Key.MoveUp)

	@31 		// Life.y = (Life.y-1) & 01F (31)
	D = A
	@Life.y
	M = M - 1
	M = D & M

	@Key.Change
	0 ; JMP

// DownRight - move cursor

(Key.MoveDownRight)

	@63 		// Life.x = (Life.x+1) & 03F (63)
	D = A 		// then fall through to move down
	@Life.x
	M = M + 1
	M = D & M

// Down - move cursor

(Key.MoveDown)

	@31 		// Life.y = (Life.y+1) & 01F (31)
	D = A
	@Life.y
	M = M + 1
	M = D & M

	@Key.Change
	0 ; JMP

// DownLeft - move cursor

(Key.MoveDownLeft)

	@31 		// Life.y = (Life.y+1) & 01F (31)
	D = A 		// then fall through to move left
	@Life.y
	M = M + 1
	M = D & M

// Left - move cursor

(Key.MoveLeft)

	@63 		// Life.x = (Life.x-1) & 03F (63)
	D = A
	@Life.x
	M = M - 1
	M = D & M

	@Key.Change
	0 ; JMP

// UpRight - move cursor

(Key.MoveUpRight)

	@31 		// Life.y = (Life.y-1) & 01F (31)
	D = A 		// then fall through to move right
	@Life.y
	M = M - 1
	M = D & M

// Right - move cursor

(Key.MoveRight)

	@63 		// Life.x = (Life.x+1) & 03F (63)
	D = A
	@Life.x
	M = M + 1
	M = D & M

	@Key.Change
	0 ; JMP

// toggle current cell

(Key.Toggle)

	@66				// R2 = 10067 + 66*Life.y + Life.x
	D = A
	@Mult.b
	M = D

	@Life.y
	D = M
	@Mult.a
	M = D

	@Key.Toggle.Ret	// D = return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Mult 			// Mult.result = Life.y * 66
	0 ; JMP

(Key.Toggle.Ret)

	@10067 			// D = 10067 + Life.x
	D = A
	@Life.x
	D = D + M

	@Mult.result
	M = D + M

	A = M 			// D = ![cell contents]
	D = !M

	@32767 			// A = 0111 ... 1111
	A = A + 1 		// A = 1000 ... 0000
	D = D & A 		// Masked off low bits

	@Mult.result 	// update cell contents
	A = M
	M = D

	@Key.Change
	0 ; JMP

// Enter - run generations until another key pressed

(Key.Enter)

	@Key.Enter.Ret	// D = Generation return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Generation 	// Generation()
	0 ; JMP

(Key.Enter.Ret)

	@KBD 			// Do another generation if KBD == Life.key (either 128 or 0)
	D = M
	@Life.key
	D = D - M
	@Key.Enter
	D ; JEQ

	@Life.key 		// Reset the current key (so we will catch "no key" just above, but now Enter will stop us)
	M = 0

	@KBD 			// If no key, we can loop
	D = M
	@Key.Enter
	D ; JEQ

	@Life.key 		// Restore Life.key to current key, so it'll be debounced below
	M = D

	@Key.Up 		// Terminate looping
	0 ; JMP

// Handle changes in state by repainting the screen (and jump to Key.Up handler on return)

(Key.Change)

	@Key.Up			// D = return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Paint_Board 	// Paint_Board()
	0 ; JMP

// Bottom of key processing loop

(Key.Up)			// Loop until KBD no longer Life.key (either new key or key up)

	@Life.key
	D = M
	@KBD
	D = D - M
	@Key.Up
	D ; JEQ

	@Key.Down 		// Return to checking for new key
	0 ; JMP

// Done infinite loop (not actually reachable)

	@DONE
(DONE)
	0 ; JMP

// Generation: runs a single generation of Life, then updates the board display

(Generation)
(G)

	// Phase 1: for each living cell (not counting the guard cells), increment all
	// the neighbors, so they have a count of how many neighbors they have. Note that
	// we can plow through all the guard cells on left and right because they will
	// always be dead, and it's faster to do this than do a double-loop with skip.

	@10067 			// G.cell = 10067, the first real cell
	D = A
	@G.cell
	M = D

(G.1.Top) 			// repeat check_cell until ++G.cell == 12177 (1 past last cell)

	@G.cell 		// if [G.cell] >= 0, skip to bottom of loop (it's dead)
	A = M
	D = M
	@G.1.Bottom
	D ; JGE

	@G.cell 		// [G.cell-67]++ (top-left neighbor)
	D = M
	@67
	A = D - A
	M = M + 1

	A = A + 1 		// [G.cell-66]++ (top neighbor)
	M = M + 1

	A = A + 1 		// [G.cell-65]++ (top-right neighbor)
	M = M + 1

	D = A 			// [G.cell-1]++ (left neighbor)
	@64
	A = D + A
	M = M + 1

	A = A + 1 		// [G.cell+1]++ (right neighbor)
	A = A + 1
	M = M + 1

	D = A 			// [G.cell+65]++ (bottom-left neighbor)
	@64
	A = D + A
	M = M + 1

	A = A + 1 		// [G.cell+66]++ (bottom neighbor)
	M = M + 1

	A = A + 1 		// [G.cell+67]++ (bottom-right neighbor)
	M = M + 1

(G.1.Bottom)

	@G.cell 		// D,G.cell = G.cell + 1
	MD = M + 1
	@12177 			// if (G.cell != 12177) goto G.1.Top
	D = D - A
	@G.1.Top
	D ; JNE

	// Phase 2: add the counts in the guard cells to their respective border cells
	// on the opposite edge, and clear the guard cells. Here is a map of the guard
	// cells and the edge cells
	//
	// 10000 10001 ..... 10064 10065
	// 10066 10067 ..... 10130 10131
	//   .     .           .     .
	//   .     .           .     .
	// 12112 12113 ..... 12176 12177
	// 12178 12179 ..... 12242 12243
	//
	// The following code was auto-generated by boardmaker.py. This is a case where
	// unrolling the loops is a big win because we don't have to do address arithmetic.

	// The four corners

	@10000
	D = M
	M = 0
	@12176
	M = M + D

	@10065
	D = M
	M = 0
	@12113
	M = M + D

	@12178
	D = M
	M = 0
	@10130
	M = M + D

	@12243
	D = M
	M = 0
	@10067
	M = M + D

	// The top and bottom rows

	@10001
	D = M
	M = 0
	@12113
	M = M + D

	@12179
	D = M
	M = 0
	@10067
	M = M + D

	@10002
	D = M
	M = 0
	@12114
	M = M + D

	@12180
	D = M
	M = 0
	@10068
	M = M + D

	@10003
	D = M
	M = 0
	@12115
	M = M + D

	@12181
	D = M
	M = 0
	@10069
	M = M + D

	@10004
	D = M
	M = 0
	@12116
	M = M + D

	@12182
	D = M
	M = 0
	@10070
	M = M + D

	@10005
	D = M
	M = 0
	@12117
	M = M + D

	@12183
	D = M
	M = 0
	@10071
	M = M + D

	@10006
	D = M
	M = 0
	@12118
	M = M + D

	@12184
	D = M
	M = 0
	@10072
	M = M + D

	@10007
	D = M
	M = 0
	@12119
	M = M + D

	@12185
	D = M
	M = 0
	@10073
	M = M + D

	@10008
	D = M
	M = 0
	@12120
	M = M + D

	@12186
	D = M
	M = 0
	@10074
	M = M + D

	@10009
	D = M
	M = 0
	@12121
	M = M + D

	@12187
	D = M
	M = 0
	@10075
	M = M + D

	@10010
	D = M
	M = 0
	@12122
	M = M + D

	@12188
	D = M
	M = 0
	@10076
	M = M + D

	@10011
	D = M
	M = 0
	@12123
	M = M + D

	@12189
	D = M
	M = 0
	@10077
	M = M + D

	@10012
	D = M
	M = 0
	@12124
	M = M + D

	@12190
	D = M
	M = 0
	@10078
	M = M + D

	@10013
	D = M
	M = 0
	@12125
	M = M + D

	@12191
	D = M
	M = 0
	@10079
	M = M + D

	@10014
	D = M
	M = 0
	@12126
	M = M + D

	@12192
	D = M
	M = 0
	@10080
	M = M + D

	@10015
	D = M
	M = 0
	@12127
	M = M + D

	@12193
	D = M
	M = 0
	@10081
	M = M + D

	@10016
	D = M
	M = 0
	@12128
	M = M + D

	@12194
	D = M
	M = 0
	@10082
	M = M + D

	@10017
	D = M
	M = 0
	@12129
	M = M + D

	@12195
	D = M
	M = 0
	@10083
	M = M + D

	@10018
	D = M
	M = 0
	@12130
	M = M + D

	@12196
	D = M
	M = 0
	@10084
	M = M + D

	@10019
	D = M
	M = 0
	@12131
	M = M + D

	@12197
	D = M
	M = 0
	@10085
	M = M + D

	@10020
	D = M
	M = 0
	@12132
	M = M + D

	@12198
	D = M
	M = 0
	@10086
	M = M + D

	@10021
	D = M
	M = 0
	@12133
	M = M + D

	@12199
	D = M
	M = 0
	@10087
	M = M + D

	@10022
	D = M
	M = 0
	@12134
	M = M + D

	@12200
	D = M
	M = 0
	@10088
	M = M + D

	@10023
	D = M
	M = 0
	@12135
	M = M + D

	@12201
	D = M
	M = 0
	@10089
	M = M + D

	@10024
	D = M
	M = 0
	@12136
	M = M + D

	@12202
	D = M
	M = 0
	@10090
	M = M + D

	@10025
	D = M
	M = 0
	@12137
	M = M + D

	@12203
	D = M
	M = 0
	@10091
	M = M + D

	@10026
	D = M
	M = 0
	@12138
	M = M + D

	@12204
	D = M
	M = 0
	@10092
	M = M + D

	@10027
	D = M
	M = 0
	@12139
	M = M + D

	@12205
	D = M
	M = 0
	@10093
	M = M + D

	@10028
	D = M
	M = 0
	@12140
	M = M + D

	@12206
	D = M
	M = 0
	@10094
	M = M + D

	@10029
	D = M
	M = 0
	@12141
	M = M + D

	@12207
	D = M
	M = 0
	@10095
	M = M + D

	@10030
	D = M
	M = 0
	@12142
	M = M + D

	@12208
	D = M
	M = 0
	@10096
	M = M + D

	@10031
	D = M
	M = 0
	@12143
	M = M + D

	@12209
	D = M
	M = 0
	@10097
	M = M + D

	@10032
	D = M
	M = 0
	@12144
	M = M + D

	@12210
	D = M
	M = 0
	@10098
	M = M + D

	@10033
	D = M
	M = 0
	@12145
	M = M + D

	@12211
	D = M
	M = 0
	@10099
	M = M + D

	@10034
	D = M
	M = 0
	@12146
	M = M + D

	@12212
	D = M
	M = 0
	@10100
	M = M + D

	@10035
	D = M
	M = 0
	@12147
	M = M + D

	@12213
	D = M
	M = 0
	@10101
	M = M + D

	@10036
	D = M
	M = 0
	@12148
	M = M + D

	@12214
	D = M
	M = 0
	@10102
	M = M + D

	@10037
	D = M
	M = 0
	@12149
	M = M + D

	@12215
	D = M
	M = 0
	@10103
	M = M + D

	@10038
	D = M
	M = 0
	@12150
	M = M + D

	@12216
	D = M
	M = 0
	@10104
	M = M + D

	@10039
	D = M
	M = 0
	@12151
	M = M + D

	@12217
	D = M
	M = 0
	@10105
	M = M + D

	@10040
	D = M
	M = 0
	@12152
	M = M + D

	@12218
	D = M
	M = 0
	@10106
	M = M + D

	@10041
	D = M
	M = 0
	@12153
	M = M + D

	@12219
	D = M
	M = 0
	@10107
	M = M + D

	@10042
	D = M
	M = 0
	@12154
	M = M + D

	@12220
	D = M
	M = 0
	@10108
	M = M + D

	@10043
	D = M
	M = 0
	@12155
	M = M + D

	@12221
	D = M
	M = 0
	@10109
	M = M + D

	@10044
	D = M
	M = 0
	@12156
	M = M + D

	@12222
	D = M
	M = 0
	@10110
	M = M + D

	@10045
	D = M
	M = 0
	@12157
	M = M + D

	@12223
	D = M
	M = 0
	@10111
	M = M + D

	@10046
	D = M
	M = 0
	@12158
	M = M + D

	@12224
	D = M
	M = 0
	@10112
	M = M + D

	@10047
	D = M
	M = 0
	@12159
	M = M + D

	@12225
	D = M
	M = 0
	@10113
	M = M + D

	@10048
	D = M
	M = 0
	@12160
	M = M + D

	@12226
	D = M
	M = 0
	@10114
	M = M + D

	@10049
	D = M
	M = 0
	@12161
	M = M + D

	@12227
	D = M
	M = 0
	@10115
	M = M + D

	@10050
	D = M
	M = 0
	@12162
	M = M + D

	@12228
	D = M
	M = 0
	@10116
	M = M + D

	@10051
	D = M
	M = 0
	@12163
	M = M + D

	@12229
	D = M
	M = 0
	@10117
	M = M + D

	@10052
	D = M
	M = 0
	@12164
	M = M + D

	@12230
	D = M
	M = 0
	@10118
	M = M + D

	@10053
	D = M
	M = 0
	@12165
	M = M + D

	@12231
	D = M
	M = 0
	@10119
	M = M + D

	@10054
	D = M
	M = 0
	@12166
	M = M + D

	@12232
	D = M
	M = 0
	@10120
	M = M + D

	@10055
	D = M
	M = 0
	@12167
	M = M + D

	@12233
	D = M
	M = 0
	@10121
	M = M + D

	@10056
	D = M
	M = 0
	@12168
	M = M + D

	@12234
	D = M
	M = 0
	@10122
	M = M + D

	@10057
	D = M
	M = 0
	@12169
	M = M + D

	@12235
	D = M
	M = 0
	@10123
	M = M + D

	@10058
	D = M
	M = 0
	@12170
	M = M + D

	@12236
	D = M
	M = 0
	@10124
	M = M + D

	@10059
	D = M
	M = 0
	@12171
	M = M + D

	@12237
	D = M
	M = 0
	@10125
	M = M + D

	@10060
	D = M
	M = 0
	@12172
	M = M + D

	@12238
	D = M
	M = 0
	@10126
	M = M + D

	@10061
	D = M
	M = 0
	@12173
	M = M + D

	@12239
	D = M
	M = 0
	@10127
	M = M + D

	@10062
	D = M
	M = 0
	@12174
	M = M + D

	@12240
	D = M
	M = 0
	@10128
	M = M + D

	@10063
	D = M
	M = 0
	@12175
	M = M + D

	@12241
	D = M
	M = 0
	@10129
	M = M + D

	@10064
	D = M
	M = 0
	@12176
	M = M + D

	@12242
	D = M
	M = 0
	@10130
	M = M + D

	// The left and right columns

	@10066
	D = M
	M = 0
	@10130
	M = M + D

	@10131
	D = M
	M = 0
	@10067
	M = M + D

	@10132
	D = M
	M = 0
	@10196
	M = M + D

	@10197
	D = M
	M = 0
	@10133
	M = M + D

	@10198
	D = M
	M = 0
	@10262
	M = M + D

	@10263
	D = M
	M = 0
	@10199
	M = M + D

	@10264
	D = M
	M = 0
	@10328
	M = M + D

	@10329
	D = M
	M = 0
	@10265
	M = M + D

	@10330
	D = M
	M = 0
	@10394
	M = M + D

	@10395
	D = M
	M = 0
	@10331
	M = M + D

	@10396
	D = M
	M = 0
	@10460
	M = M + D

	@10461
	D = M
	M = 0
	@10397
	M = M + D

	@10462
	D = M
	M = 0
	@10526
	M = M + D

	@10527
	D = M
	M = 0
	@10463
	M = M + D

	@10528
	D = M
	M = 0
	@10592
	M = M + D

	@10593
	D = M
	M = 0
	@10529
	M = M + D

	@10594
	D = M
	M = 0
	@10658
	M = M + D

	@10659
	D = M
	M = 0
	@10595
	M = M + D

	@10660
	D = M
	M = 0
	@10724
	M = M + D

	@10725
	D = M
	M = 0
	@10661
	M = M + D

	@10726
	D = M
	M = 0
	@10790
	M = M + D

	@10791
	D = M
	M = 0
	@10727
	M = M + D

	@10792
	D = M
	M = 0
	@10856
	M = M + D

	@10857
	D = M
	M = 0
	@10793
	M = M + D

	@10858
	D = M
	M = 0
	@10922
	M = M + D

	@10923
	D = M
	M = 0
	@10859
	M = M + D

	@10924
	D = M
	M = 0
	@10988
	M = M + D

	@10989
	D = M
	M = 0
	@10925
	M = M + D

	@10990
	D = M
	M = 0
	@11054
	M = M + D

	@11055
	D = M
	M = 0
	@10991
	M = M + D

	@11056
	D = M
	M = 0
	@11120
	M = M + D

	@11121
	D = M
	M = 0
	@11057
	M = M + D

	@11122
	D = M
	M = 0
	@11186
	M = M + D

	@11187
	D = M
	M = 0
	@11123
	M = M + D

	@11188
	D = M
	M = 0
	@11252
	M = M + D

	@11253
	D = M
	M = 0
	@11189
	M = M + D

	@11254
	D = M
	M = 0
	@11318
	M = M + D

	@11319
	D = M
	M = 0
	@11255
	M = M + D

	@11320
	D = M
	M = 0
	@11384
	M = M + D

	@11385
	D = M
	M = 0
	@11321
	M = M + D

	@11386
	D = M
	M = 0
	@11450
	M = M + D

	@11451
	D = M
	M = 0
	@11387
	M = M + D

	@11452
	D = M
	M = 0
	@11516
	M = M + D

	@11517
	D = M
	M = 0
	@11453
	M = M + D

	@11518
	D = M
	M = 0
	@11582
	M = M + D

	@11583
	D = M
	M = 0
	@11519
	M = M + D

	@11584
	D = M
	M = 0
	@11648
	M = M + D

	@11649
	D = M
	M = 0
	@11585
	M = M + D

	@11650
	D = M
	M = 0
	@11714
	M = M + D

	@11715
	D = M
	M = 0
	@11651
	M = M + D

	@11716
	D = M
	M = 0
	@11780
	M = M + D

	@11781
	D = M
	M = 0
	@11717
	M = M + D

	@11782
	D = M
	M = 0
	@11846
	M = M + D

	@11847
	D = M
	M = 0
	@11783
	M = M + D

	@11848
	D = M
	M = 0
	@11912
	M = M + D

	@11913
	D = M
	M = 0
	@11849
	M = M + D

	@11914
	D = M
	M = 0
	@11978
	M = M + D

	@11979
	D = M
	M = 0
	@11915
	M = M + D

	@11980
	D = M
	M = 0
	@12044
	M = M + D

	@12045
	D = M
	M = 0
	@11981
	M = M + D

	@12046
	D = M
	M = 0
	@12110
	M = M + D

	@12111
	D = M
	M = 0
	@12047
	M = M + D

	// Phase 3: use the previous generation state and the count of neighbors to update
	// the cells.

	@10067 			// G.cell = 10067 (first possible active cell)
	D = A
	@G.cell
	M = D

(G.3.Top) 			// repeat ... until ++G.cell = 12177 (guard cell after last live cell)

	@G.cell 		// D = [G.cell]
	A = M
	D = M

	@G.3.Live 		// if D < 0 it's a live cell
	D ; JLT

(G.3.Dead)

	@G.3.Next 		// if D == 0 break (efficiency hack; costs 2 instructions, saves 8 if dead
	D ; JEQ 		// cell has no neighbors. A win if this is the case > 25% of the time)

	@9980 			// D = DeadTable[D]
	A = A + D
	D = M

	@G.3.Set 		// Jump down to setter
	0 ; JMP

(G.3.Live)

	@15 			// D = LiveTable[D & 1111] (we need to mask off the sign bit)
	D = D & A
	@9970
	A = A + D
	D = M

(G.3.Set)

	@G.cell 		// [G.cell] = D
	A = M
	M = D

(G.3.Next)

	@G.cell 		// D = ++G.cell
	MD = M + 1

	@12177 			// if G.cell < 12177 loop
	D = D - A
	@G.3.Top
	D ; JLT

	// Jump directly to Paint_Board() without pushing return
	// address on stack. It will return to my caller!

	@Paint_Board
	0 ; JMP

// Load_Board (LB) function. Expects address of board data loader code in D. Clears the board, unpacks the data,
// and sets up the cells.

(Load_Board)
(LB)

	@20010			// Breakpoint on A=20010 to stop here (protip!)

	@LB.board 		// LB.board = D (address of board bitmap loader subroutine)
	M = D

	// Run the board data loader code (in rom) to copy itself into ram at 9800...

	@LB.Ret1 		// D = Clear board return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@LB.board 		// Indirectly call the board loader!
	A = M
	0 ; JMP

	@20011			// Breakpoint

(LB.Ret1)

	// Clear the board by calling Clear_Board (CB) function

	@LB.Ret2 		// D = Clear board return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Clear_Board 	// Clear_Board()
	0 ; JMP

(LB.Ret2)

	@20011			// Breakpoint

	@9800 			// LB.board = 9800, address of loaded board data
	D = A
	@LB.board
	M = D

	@10067 			// LB.cell = 10067
	D = A 			// Board starts at 10000, first real cell is at 1,1 = +66+1
	@LB.cell
	M = D

	@32 			// LB.row = 32 (number of rows we need to read)
	D = A
	@LB.row
	M = D

(LB.forRow) 		// repeat Load_Board_Row() while (--LB.row > 0)

	@20012

	@LB.forRow.Ret 	// D = Load_Board_Row return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Load_Board_Row // Load_Board_Row()
	0 ; JMP

(LB.forRow.Ret)

	@LB.row 		// LB.row,D = LB.row - 1
	MD = M - 1
	
	@LB.forRow 		// Loop if LB.row > 0
	D ; JGT

	// Paint the board by jumping directly to Paint_Board()
	// It will return to my caller.

	@Paint_Board
	0 ; JMP

// Load_Board_Row function. Load a single row from 4 words starting at LB.board into
// 64 cells starting at LB.cell, then move LB.cell to the first cell of the next row
// and LB.board to the first word of the next row of board information.

(Load_Board_Row)
(LBR)

	@20020				// Breakpoint

	@4 					// LBR.word = 4
	D = A
	@LBR.word
	M = D

(LBR.forWord) 			// repeat Load_Board_Word while (--LBR.word > 0)

	@LBR.forWord.Ret 	// D = Load_Board_Row return address
	D = A

	@SP 				// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Load_Board_Word	// Load_Board_Word()
	0 ; JMP

(LBR.forWord.Ret)

	@LBR.word 			// LBR.word,D = LBR.word - 1
	MD = M - 1
	
	@LBR.forWord		// Loop if LB.row > 0
	D ; JGT

	@20020

	@LB.cell 			// LB.cell = LB.cell + 2
	M = M + 1
	M = M + 1

	// return to caller

	@SP 			// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Load_Board_Word(D): Use the 16 bits of [LB.board] to set the next
// D cells starting at [LB.cell]; increment LB.board and LB.cell.

(Load_Board_Word)
(LBW)

	@20030				// Breakpoint

	@16 				// LBW.count = 16 (# of bits to transfer)
	D = A
	@LBW.count
	M = D

	@LB.board 			// @LBW.bits = [LB.board]
	A = M
	D = M
	@LBW.bits
	M = D

(LBW.forCell)			// repeat [LB.cell++] = Top bit of LBW.bits while (--LBW.count > 0)

	@LBW.bits 			// D = LBW.bits
	D = M

	M = D + M 			// LBW.bits = LBW.bits << 1

	@32767				// D = D & 1000 0000 0000 0000
	D = ! D 			// We have to be tricky to do this because we can't
	D = D | A 			// load a 16 bit constant. The end result is that the
	D = ! D 			// sign bit is preserved and everything else is 0!

	@LB.cell 			// [LB.cell] = D
	A = M
	M = D

	D = A + 1 			// LB.cell++
	@LB.cell
	M = D

	@LBW.count 			// LBW.Count,D = LBW.Count.i - 1
	MD = M - 1
	
	@LBW.forCell		// Loop if CB.i > 0
	D ; JGT

(LBW.incBoard)

	@LB.board 			// LB.board++ 
	M = M + 1

	// return to caller

	@SP 			// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Clear_Board (CB) function. Clears all the cells including the border guard cells
// Should rewrite to not need the count variable. Lazy.

(Clear_Board)
(CB)

	@20040			// Breakpoint

	@2244			// There are 34*66 elements in the board = 2244
	D = A 			// CB.i is the loop counter
	@CB.i
	M = D

	@10000 			// CB.a = Board location (can't assign a block of memory, alas)
	D = A
	@CB.a
	M = D
	
(CB.Top)			// repeat Mem[CB.a++] = 0 while (--CB.i > 0) 

	@CB.a 			// [CB.a] = 0
	A = M
	M = 0
	
	D = A + 1 		// D = CB.a + 1
	@CB.a 			// CB.a = D
	M = D

	@CB.i 			// CB.i,D = CB.i - 1
	MD = M - 1
	
	@CB.Top 		// Loop if CB.i > 0
	D ; JGT

	// return to caller

	@SP 			// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Paint_Board (PB) function; paints the current board onto the screen

(Paint_Board)
(PB)

	@20500

	@SCREEN 		// PB.board = Address of screen
	D = A
	@PB.board
	M = D

	@10067 			// PB.cell = 10067
	D = A 			// Board starts at 10000, first real cell is at 1,1 = +66+1
	@PB.cell
	M = D

	@32 			// PB.row = 32 (number of rows we need to paint)
	D = A
	@PB.row
	M = D

(PB.forRow) 		// repeat Paint_Board_Row() while (--PB.row > 0)

	@20012

	@PB.forRow.Ret 	// D = Paint_Board_Row return address
	D = A

	@SP 			// [SP--] = D (PUSH)
	A = M
	M = D
	@SP
	M = M - 1

	@Paint_Board_Row // Paint_Board_Row()
	0 ; JMP

(PB.forRow.Ret)

	@PB.row 		// PB.row,D = PB.row - 1
	MD = M - 1
	
	@PB.forRow 		// Loop if PB.row > 0
	D ; JGT

	// return to caller

	@SP 			// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Paint_Board_Row(): Paint a single row (64 cells) onto the screen. We use an 8x8 matrix of pixels
// for each cell, so two cells fit into each word of pixels (16 pixels/word), and each row is
// replicated 8 times. On exit, PB.board points to the first word of pixels for the next row of
// cells, and PB.cell points to the first cell of the next row.

(Paint_Board_Row)
(PBR)

	@20600

	@32 				// PBR.pair = 32 (number of pairs of cells we need to paint)
	D = A
	@PBR.pair
	M = D

(PBR.forPair) 			// repeat Paint_Board_Pair() while (--PBR.pair > 0)

// Paint_Board_Pair(): paint a pair of cells [PB.cell],[PB.cell+1] onto the screen at word
// [PB.board]. Repeat for 8 screen rows, then update PB.cell and PB.board for the next
// iteration.
//
// This code is executed so much that all sorts of optimizations are warranted, including
// inserting it here as an inlined function call to avoid the call-return overhead. This
// sucks a bit for readability.

(Paint_Board_Pair)
(PBP)

	// Convert cells into pixels. There are 4 possible cell combinations (00,01,10,11)
	// and thus 4 possible pixel values. Note however that two of them are 0000 ... 0000
	// and 1111 ... 1111, which are predefined constants available to the ALU. This means
	// for these two cases, we don't have to load the pixel value before storing in
	// the screen buffer.

	@PB.cell 			// D = [PB.cell] (will be negative if cell is alive; 0 if cell is dead
	A = M
	D = M

	@PBP.0X 			// Skip if top pixel is empty
	D ; JEQ

(PBP.1X) 				// Left pixel is set. What about Right pixel?

	@PB.cell 			// D = [++PB.cell] (the second cell in the pair)
	AM = M + 1
	D = M

	@PBP.10 			// Right pixel is empty
	D ; JEQ

(PBP.11)

	// Now we set both pixels in 8 words of the screen buffer

	@32 				// D = Screen buffer row width
	D = A

	@PB.board 			// A = PB.board (location of first screen word to bash)
	A = M

	M = -1 				// [A] = -1 -- row 1

	A = A + D 			// A = A + 32
	M = -1 				// Row 2
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 3
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 4
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 5
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 6
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 7
	
	A = A + D 			// A = A + 32
	M = -1 				// Row 8
	
	@PB.board 			// PB.board = PB.board + 1
	M = M + 1

	@PB.cell 			// PB.cell = PB.cell + 1
	M = M + 1

	// return to caller

	@PBR.forPair.Ret 	// direct jump since this is an inline function call
	0 ; JMP

(PBP.0X) 				// Left pixel is clear. What about Right pixel?

	@PB.cell 			// D = [++PB.cell] (the second cell in the pair)
	AM = M + 1
	D = M

	@PBP.01 			// Right pixel is *not* empty
	D ; JNE

(PBP.00)

	// Now we clear both pixels in 8 words of the screen buffer

	@32 				// D = Screen buffer row width
	D = A

	@PB.board 			// A = PB.board (location of first screen word to bash)
	A = M

	M = 0 				// [A] = 0 -- row 1

	A = A + D 			// A = A + 32
	M = 0 				// Row 2
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 3
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 4
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 5
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 6
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 7
	
	A = A + D 			// A = A + 32
	M = 0 				// Row 8
	
	@PB.board 			// PB.board = PB.board + 1
	M = M + 1

	@PB.cell 			// PB.cell = PB.cell + 1
	M = M + 1

	// return to caller

	@PBR.forPair.Ret 	// direct jump since this is an inline function call
	0 ; JMP

(PBP.10)

	@255 				// D = 00FF (remember, least significant bits in screen memory are the leftmost ones)
	D = A

	@PBP.Paint
	0 ; JMP

(PBP.01)

	@255 				// D = ! 00FF
	D = !A

(PBP.Paint)

	// Paint the pixels in D into 8 successive rows of the screen. Loop is unrolled for
	// efficiency.

	@PBP.pixels 		// Save our pixels
	M = D

	@PB.board 			// A = PB.board (location of first screen word to bash)
	A = M

	M = D 				// [PB.board] = PBP.pixels (still in D) -- row 1

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 2
	D = M
	@PB.board
	A = M
	M = D


	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 3
	D = M
	@PB.board
	A = M
	M = D

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 4
	D = M
	@PB.board
	A = M
	M = D

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 5
	D = M
	@PB.board
	A = M
	M = D

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 6
	D = M
	@PB.board
	A = M
	M = D

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 7
	D = M
	@PB.board
	A = M
	M = D

	D = A 				// PB.board = PB.board + 32
	@32
	D = D + A
	@PB.board
	M = D

	@PBP.pixels 		// [PB.board] = PBP.pixels -- row 8
	D = M
	@PB.board
	A = M
	M = D

	// PB.board now contains an address in the 8th row. We need to go back to
	// the first row, then move forward to the next word. Since we moved 7 x 32
	// words, we simply subtract (7*32)-1. Similarly, we need to increment
	// PB.cell to move to the first cell of the next pair.

(PBP.NextPair)

	@223 				// PB.board = PB.board - 223
	D = A
	@PB.board
	M = M - D

	@PB.cell
	M = M + 1

	// return to caller (fall through)

	// end of inline function call

(PBR.forPair.Ret)

	@PBR.pair 			// PB.pair,D = PB.pair - 1
	MD = M - 1
	
	@PBR.forPair		// Loop if PBR.pair > 0
	D ; JGT

	// Update PB.cell and PB.board so they are correct for the next iteration

	@PB.cell 			// PB.cell = PB.cell + 2 (skips border cells)
	M = M + 1
	M = M + 1

	@224 				// PB.board = PB.board + 32 * 7 (skips 7 pixel rows)
	D = A
	@PB.board
	M = M + D

	// return to caller

	@SP 				// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Initialize RAM data structures. We have two lookup tables that contain the new state of a cell, one
// for dead cells, and one for living cells. Since there are up to 8 neighbors, the index can range from
// 0 to 8, so we need 9 elements per table.

(Initialize)
(INI)

	@9970		// LiveTable: Cell lives if it has 2 or 3 neighbors, dies otherwise
	M = 0 		// DeadTable: Cell is born if it has 3 neighbors, stays dead otherwise
	@9971 		// Initialize all the dead cells first
	M = 0
	@9974
	M = 0
	@9975
	M = 0
	@9976
	M = 0
	@9977
	M = 0
	@9978
	M = 0

	@9980
	M = 0
	@9981
	M = 0
	@9982
	M = 0
	@9984
	M = 0
	@9985
	M = 0
	@9986
	M = 0
	@9987
	M = 0
	@9988
	M = 0

	@16384 		// A = 0100 ... 0000
	D = A
	D = D + A 	// D = 1000 ... 0000 (live cell value)

	@9972
	M = D
	@9973
	M = D
	@9983
	M = D

	// Divide by 2 table

	@0
	D = A
	@9700
	M = D
	@9701
	M = D

	@1
	D = A
	@9702
	M = D
	@9703
	M = D

	@2
	D = A
	@9704
	M = D
	@9705
	M = D

	@3
	D = A
	@9706
	M = D
	@9707
	M = D

	@4
	D = A
	@9708
	M = D
	@9709
	M = D

	@5
	D = A
	@9710
	M = D
	@9711
	M = D

	@6
	D = A
	@9712
	M = D
	@9713
	M = D

	@7
	D = A
	@9714
	M = D
	@9715
	M = D

	@8
	D = A
	@9716
	M = D
	@9717
	M = D

	@9
	D = A
	@9718
	M = D
	@9719
	M = D

	@10
	D = A
	@9720
	M = D
	@9721
	M = D

	@11
	D = A
	@9722
	M = D
	@9723
	M = D

	@12
	D = A
	@9724
	M = D
	@9725
	M = D

	@13
	D = A
	@9726
	M = D
	@9727
	M = D

	@14
	D = A
	@9728
	M = D
	@9729
	M = D

	@15
	D = A
	@9730
	M = D
	@9731
	M = D

	@16
	D = A
	@9732
	M = D
	@9733
	M = D

	@17
	D = A
	@9734
	M = D
	@9735
	M = D

	@18
	D = A
	@9736
	M = D
	@9737
	M = D

	@19
	D = A
	@9738
	M = D
	@9739
	M = D

	@20
	D = A
	@9740
	M = D
	@9741
	M = D

	@21
	D = A
	@9742
	M = D
	@9743
	M = D

	@22
	D = A
	@9744
	M = D
	@9745
	M = D

	@23
	D = A
	@9746
	M = D
	@9747
	M = D

	@24
	D = A
	@9748
	M = D
	@9749
	M = D

	@25
	D = A
	@9750
	M = D
	@9751
	M = D

	@26
	D = A
	@9752
	M = D
	@9753
	M = D

	@27
	D = A
	@9754
	M = D
	@9755
	M = D

	@28
	D = A
	@9756
	M = D
	@9757
	M = D

	@29
	D = A
	@9758
	M = D
	@9759
	M = D

	@30
	D = A
	@9760
	M = D
	@9761
	M = D

	@31
	D = A
	@9762
	M = D
	@9763
	M = D

	// return to caller

	@SP 				// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Multiply Mult.a by Mult.b, return in Mult.result
// Mult.a and Mult.b are not modified. No R-variables are used

(Mult)

	@Mult.result 		// Initialize product (R2) to 0
	M = 0

	@Mult.mask 			// Initialize Mult.mask to 1111...1110
	M = -1 				// which is -2
	M = M - 1

	@Mult.a 			// Check if Mult.a >= Mult.b
	D = M 				// If so, Mult.b is Multiplicand
	@Mult.b 			// If not, Mult.a is Multiplicand
	D = D - M 			// This minimizes the number of times
	@Mult.R0_GE_R1 		// through the main loop.
	D ; JGE

	@Mult.b 			// Initialize Multiplicand to Mult.b
	D = M
	@Mult.c
	M = D

	@Mult.a				// Initialize Multiplier to Mult.a
	D = M
	@Mult.p
	M = D

	@Mult.loop 			// Jump to top of loop
	0 ; JMP

(Mult.R0_GE_R1) 		// Mult.a >= Mult.b, so Mult.b is Mult.p

	@Mult.a 			// Initialize Multiplicand to Mult.a
	D = M
	@Mult.c
	M = D

	@Mult.b				// Initialize Multiplier to Mult.b
	D = M
	@Mult.p
	M = D

// Efficiency note: We could place a check here to see if Mult.p is 0 and exit immediately. This costs
// 2 instructions on every multiply. Omitting this check means that if Mult.p is 0, we'll go through the
// loop once (20 instructions), so this is only a win if we expect Mult.p to be 0 more than 10% of the
// time.

(Mult.loop) 			// D = Mult.p and non-zero at this point (unless it starts as zero).

	@Mult.p.o 			// Save a copy of Mult.p as it currently is
	M = D

	@Mult.mask 			// Mult.p = Mult.p & Mult.mask. Because mask is a negative mask, only the bit
	D = D & M 			// we currently care about is set to 0 if it is 1. We save the
	@Mult.p 			// *changed* version back into Mult.p
	M = D

	@Mult.p.o 			// if Mult.p == Mult.p.o, nothing to do on this round
	D = D - M
	@Mult.next
	D ; JEQ

	@Mult.c 			// Mult.result = Mult.result + Mult.c
	D = M
	@Mult.result
	M = M + D

(Mult.next)

	@Mult.c 			// Mult.c = Mult.c * 2 (Shift Left 1 bit)
	D = M
	M = M + D

	@Mult.mask 			// Mult.mask = Mult.mask * 2 (Shift left 1 bit)
	D = M
	M = M + D

	@Mult.p 			// Load up Mult.p again
	D = M
	@Mult.loop 			// and loop if non-zero
	D ; JNE

	// return to caller

	@SP 				// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Logo board data storage. Boards are 64x32, which would be 4 word per row, but we can't store 16 bits
// per word since A instructions only load 15 bits. So each row in the board is stored in 5 words,
// 15-15-15-15-4, using the most significant bits first (other than the sign bit). We can thus rotate
// the bits into the sign bit to test them.

// To add another level of horribleness to all of this, we can't directly access the data in the ROM,
// so we need to structure it as a program that copies the boards into a fixed location in the RAM!
// See the boardmaker.py script for code that does this.

(Logo.Board)

// [****************************************************************]
// [*                                                              *]
// [*  ****    *****   **  **  **   **   *****  **   **  *  *****  *]
// [* **  **  **   **  *** **  **   **  **   ** **   ** *  **      *]
// [* **      **   **  ******  ** * **  *******  ******     *****  *]
// [* **  **  **   **  ** ***  *******  **   **      **         ** *]
// [*  ****    *****   **  **   ** **   **   **  *****      *****  *]
// [*                                                              *]
// [*  ****    *****   *** ***  ******             *****   ******* *]
// [* **  **  **   **  *******  **                **   **  **      *]
// [* **      *******  ** * **  ******            **   **  *****   *]
// [* **  **  **   **  **   **  **                **   **  **      *]
// [*  *****  **   **  **   **  ******             *****   **      *]
// [*                                                              *]
// [*   ****            ********    ************    ************   *]
// [*   ****            ********    ************    ************   *]
// [*   ****            ********    ************    ************   *]
// [*   ****              ****      ****            ****           *]
// [*   ****              ****      ********        ********       *]
// [*   ****              ****      ********        ********       *]
// [*   ****              ****      ****            ****           *]
// [*   ************    ********    ****            ************   *]
// [*   ************    ********    ****            ************   *]
// [*   ************    ********    ****            ************   *]
// [*                                                              *]
// [*  ****                   *                    *             * *]
// [* *    *                  *                    *             * *]
// [* * ** *     * *   ***  ***  **  *   *  **  ** *  **   **  *** *]
// [* * ****    * * * *  * *  * *  *  * *  **  *   * *  * *   *  * *]
// [*  *        *   *  ***  ***  **    *    ** *   *  **  *    *** *]
// [*                                                              *]
// [****************************************************************]

// [****************************************************************] (Row 1)

	@09800		// [****************] 65535
	M = -1
	@09801		// [****************] 65535
	M = -1
	@09802		// [****************] 65535
	M = -1
	@09803		// [****************] 65535
	M = -1

// [*                                                              *] (Row 2)

	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09804
	M = D
	@09805		// [                ] 0
	M = 0
	@09806		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09807
	M = D

// [*  ****    *****   **  **  **   **   *****  **   **  *  *****  *] (Row 3)

	D = -1		// [*  ****    *****] 40479
	@25056
	D = D - A
	@09808
	M = D
	@06552		// [   **  **  **   ] 6552
	D = A
	@09809
	M = D
	D = -1		// [**   *****  **  ] 51148
	@14387
	D = D - A
	@09810
	M = D
	@25849		// [ **  *  *****  *] 25849
	D = A
	@09811
	M = D

// [* **  **  **   **  *** **  **   **  **   ** **   ** *  **      *] (Row 4)

	D = -1		// [* **  **  **   *] 45873
	@19662
	D = D - A
	@09812
	M = D
	D = -1		// [*  *** **  **   ] 40344
	@25191
	D = D - A
	@09813
	M = D
	D = -1		// [**  **   ** **  ] 52332
	@13203
	D = D - A
	@09814
	M = D
	@27009		// [ ** *  **      *] 27009
	D = A
	@09815
	M = D

// [* **      **   **  ******  ** * **  *******  ******     *****  *] (Row 5)

	D = -1		// [* **      **   *] 45105
	@20430
	D = D - A
	@09816
	M = D
	D = -1		// [*  ******  ** * ] 40858
	@24677
	D = D - A
	@09817
	M = D
	D = -1		// [**  *******  ***] 53223
	@12312
	D = D - A
	@09818
	M = D
	D = -1		// [***     *****  *] 57593
	@07942
	D = D - A
	@09819
	M = D

// [* **  **  **   **  ** ***  *******  **   **      **         ** *] (Row 6)

	D = -1		// [* **  **  **   *] 45873
	@19662
	D = D - A
	@09820
	M = D
	D = -1		// [*  ** ***  *****] 39839
	@25696
	D = D - A
	@09821
	M = D
	D = -1		// [**  **   **     ] 52320
	@13215
	D = D - A
	@09822
	M = D
	@24589		// [ **         ** *] 24589
	D = A
	@09823
	M = D

// [*  ****    *****   **  **   ** **   **   **  *****      *****  *] (Row 7)

	D = -1		// [*  ****    *****] 40479
	@25056
	D = D - A
	@09824
	M = D
	@06541		// [   **  **   ** *] 6541
	D = A
	@09825
	M = D
	D = -1		// [*   **   **  ***] 35943
	@29592
	D = D - A
	@09826
	M = D
	D = -1		// [**      *****  *] 49401
	@16134
	D = D - A
	@09827
	M = D

// [*                                                              *] (Row 8)

	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09828
	M = D
	@09829		// [                ] 0
	M = 0
	@09830		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09831
	M = D

// [*  ****    *****   *** ***  ******             *****   ******* *] (Row 9)

	D = -1		// [*  ****    *****] 40479
	@25056
	D = D - A
	@09832
	M = D
	@07631		// [   *** ***  ****] 7631
	D = A
	@09833
	M = D
	D = -1		// [**             *] 49153
	@16382
	D = D - A
	@09834
	M = D
	D = -1		// [****   ******* *] 61949
	@03586
	D = D - A
	@09835
	M = D

// [* **  **  **   **  *******  **                **   **  **      *] (Row 10)

	D = -1		// [* **  **  **   *] 45873
	@19662
	D = D - A
	@09836
	M = D
	D = -1		// [*  *******  **  ] 40908
	@24627
	D = D - A
	@09837
	M = D
	@00003		// [              **] 3
	D = A
	@09838
	M = D
	@06529		// [   **  **      *] 6529
	D = A
	@09839
	M = D

// [* **      *******  ** * **  ******            **   **  *****   *] (Row 11)

	D = -1		// [* **      ******] 45119
	@20416
	D = D - A
	@09840
	M = D
	D = -1		// [*  ** * **  ****] 39631
	@25904
	D = D - A
	@09841
	M = D
	D = -1		// [**            **] 49155
	@16380
	D = D - A
	@09842
	M = D
	@06641		// [   **  *****   *] 6641
	D = A
	@09843
	M = D

// [* **  **  **   **  **   **  **                **   **  **      *] (Row 12)

	D = -1		// [* **  **  **   *] 45873
	@19662
	D = D - A
	@09844
	M = D
	D = -1		// [*  **   **  **  ] 39116
	@26419
	D = D - A
	@09845
	M = D
	@00003		// [              **] 3
	D = A
	@09846
	M = D
	@06529		// [   **  **      *] 6529
	D = A
	@09847
	M = D

// [*  *****  **   **  **   **  ******             *****   **      *] (Row 13)

	D = -1		// [*  *****  **   *] 40753
	@24782
	D = D - A
	@09848
	M = D
	D = -1		// [*  **   **  ****] 39119
	@26416
	D = D - A
	@09849
	M = D
	D = -1		// [**             *] 49153
	@16382
	D = D - A
	@09850
	M = D
	D = -1		// [****   **      *] 61825
	@03710
	D = D - A
	@09851
	M = D

// [*                                                              *] (Row 14)

	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09852
	M = D
	@09853		// [                ] 0
	M = 0
	@09854		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09855
	M = D

// [*   ****            ********    ************    ************   *] (Row 15)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09856
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09857
	M = D
	D = -1		// [************    ] 65520
	@00015
	D = D - A
	@09858
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09859
	M = D

// [*   ****            ********    ************    ************   *] (Row 16)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09860
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09861
	M = D
	D = -1		// [************    ] 65520
	@00015
	D = D - A
	@09862
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09863
	M = D

// [*   ****            ********    ************    ************   *] (Row 17)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09864
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09865
	M = D
	D = -1		// [************    ] 65520
	@00015
	D = D - A
	@09866
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09867
	M = D

// [*   ****              ****      ****            ****           *] (Row 18)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09868
	M = D
	@00960		// [      ****      ] 960
	D = A
	@09869
	M = D
	D = -1		// [****            ] 61440
	@04095
	D = D - A
	@09870
	M = D
	D = -1		// [****           *] 61441
	@04094
	D = D - A
	@09871
	M = D

// [*   ****              ****      ********        ********       *] (Row 19)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09872
	M = D
	@00960		// [      ****      ] 960
	D = A
	@09873
	M = D
	D = -1		// [********        ] 65280
	@00255
	D = D - A
	@09874
	M = D
	D = -1		// [********       *] 65281
	@00254
	D = D - A
	@09875
	M = D

// [*   ****              ****      ********        ********       *] (Row 20)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09876
	M = D
	@00960		// [      ****      ] 960
	D = A
	@09877
	M = D
	D = -1		// [********        ] 65280
	@00255
	D = D - A
	@09878
	M = D
	D = -1		// [********       *] 65281
	@00254
	D = D - A
	@09879
	M = D

// [*   ****              ****      ****            ****           *] (Row 21)

	D = -1		// [*   ****        ] 36608
	@28927
	D = D - A
	@09880
	M = D
	@00960		// [      ****      ] 960
	D = A
	@09881
	M = D
	D = -1		// [****            ] 61440
	@04095
	D = D - A
	@09882
	M = D
	D = -1		// [****           *] 61441
	@04094
	D = D - A
	@09883
	M = D

// [*   ************    ********    ****            ************   *] (Row 22)

	D = -1		// [*   ************] 36863
	@28672
	D = D - A
	@09884
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09885
	M = D
	D = -1		// [****            ] 61440
	@04095
	D = D - A
	@09886
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09887
	M = D

// [*   ************    ********    ****            ************   *] (Row 23)

	D = -1		// [*   ************] 36863
	@28672
	D = D - A
	@09888
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09889
	M = D
	D = -1		// [****            ] 61440
	@04095
	D = D - A
	@09890
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09891
	M = D

// [*   ************    ********    ****            ************   *] (Row 24)

	D = -1		// [*   ************] 36863
	@28672
	D = D - A
	@09892
	M = D
	@04080		// [    ********    ] 4080
	D = A
	@09893
	M = D
	D = -1		// [****            ] 61440
	@04095
	D = D - A
	@09894
	M = D
	D = -1		// [************   *] 65521
	@00014
	D = D - A
	@09895
	M = D

// [*                                                              *] (Row 25)

	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09896
	M = D
	@09897		// [                ] 0
	M = 0
	@09898		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09899
	M = D

// [*  ****                   *                    *             * *] (Row 26)

	D = -1		// [*  ****         ] 40448
	@25087
	D = D - A
	@09900
	M = D
	@00032		// [          *     ] 32
	D = A
	@09901
	M = D
	@00001		// [               *] 1
	D = A
	@09902
	M = D
	@00005		// [             * *] 5
	D = A
	@09903
	M = D

// [* *    *                  *                    *             * *] (Row 27)

	D = -1		// [* *    *        ] 41216
	@24319
	D = D - A
	@09904
	M = D
	@00032		// [          *     ] 32
	D = A
	@09905
	M = D
	@00001		// [               *] 1
	D = A
	@09906
	M = D
	@00005		// [             * *] 5
	D = A
	@09907
	M = D

// [* * ** *     * *   ***  ***  **  *   *  **  ** *  **   **  *** *] (Row 28)

	D = -1		// [* * ** *     * *] 44293
	@21242
	D = D - A
	@09908
	M = D
	@07398		// [   ***  ***  ** ] 7398
	D = A
	@09909
	M = D
	@17613		// [ *   *  **  ** *] 17613
	D = A
	@09910
	M = D
	@12701		// [  **   **  *** *] 12701
	D = A
	@09911
	M = D

// [* * ****    * * * *  * *  * *  *  * *  **  *   * *  * *   *  * *] (Row 29)

	D = -1		// [* * ****    * * ] 44810
	@20725
	D = D - A
	@09912
	M = D
	D = -1		// [* *  * *  * *  *] 42281
	@23254
	D = D - A
	@09913
	M = D
	@10641		// [  * *  **  *   *] 10641
	D = A
	@09914
	M = D
	@18981		// [ *  * *   *  * *] 18981
	D = A
	@09915
	M = D

// [*  *        *   *  ***  ***  **    *    ** *   *  **  *    *** *] (Row 30)

	D = -1		// [*  *        *   ] 36872
	@28663
	D = D - A
	@09916
	M = D
	D = -1		// [*  ***  ***  ** ] 40166
	@25369
	D = D - A
	@09917
	M = D
	@04305		// [   *    ** *   *] 4305
	D = A
	@09918
	M = D
	@12829		// [  **  *    *** *] 12829
	D = A
	@09919
	M = D

// [*                                                              *] (Row 31)

	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09920
	M = D
	@09921		// [                ] 0
	M = 0
	@09922		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09923
	M = D

// [****************************************************************] (Row 32)

	@09924		// [****************] 65535
	M = -1
	@09925		// [****************] 65535
	M = -1
	@09926		// [****************] 65535
	M = -1
	@09927		// [****************] 65535
	M = -1

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

(Oscillator.Board)

// [     **                                                         ]
// [***  *      ***     ***   ***                                   ]
// [        *  ***                                   *              ]
// [       **         *    * *    *                * *              ]
// [                  *    * *    *               * *               ]
// [  **              *    * *    *         **   *  *           **  ]
// [                    ***   ***           **    * *           **  ]
// [*   *                                          * *              ]
// [*    *              ***   ***                    *              ]
// [  * * *           *    * *    *                                 ]
// [   * * *          *    * *    *                                 ]
// [    *    *        *    * *    *                                 ]
// [     *   *                                                      ]
// [                    ***   ***                                   ]
// [      **                                                        ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                 **                             ]
// [                **               * *       **                   ]
// [                **                 *       **                   ]
// [                                 ***                            ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                 ***                            ]
// [                **                 *                            ]
// [                **               * *                            ]
// [                                 **                             ]
// [                                                                ]
// [                                                                ]
// [                                                                ]

// [     **                                                         ] (Row 1)

	@01536		// [     **         ] 1536
	D = A
	@09800
	M = D
	@09801		// [                ] 0
	M = 0
	@09802		// [                ] 0
	M = 0
	@09803		// [                ] 0
	M = 0

// [***  *      ***     ***   ***                                   ] (Row 2)

	D = -1		// [***  *      *** ] 58382
	@07153
	D = D - A
	@09804
	M = D
	@03640		// [    ***   ***   ] 3640
	D = A
	@09805
	M = D
	@09806		// [                ] 0
	M = 0
	@09807		// [                ] 0
	M = 0

// [        *  ***                                   *              ] (Row 3)

	@00156		// [        *  ***  ] 156
	D = A
	@09808
	M = D
	@09809		// [                ] 0
	M = 0
	@09810		// [                ] 0
	M = 0
	@16384		// [ *              ] 16384
	D = A
	@09811
	M = D

// [       **         *    * *    *                * *              ] (Row 4)

	@00384		// [       **       ] 384
	D = A
	@09812
	M = D
	@08514		// [  *    * *    * ] 8514
	D = A
	@09813
	M = D
	@00001		// [               *] 1
	D = A
	@09814
	M = D
	@16384		// [ *              ] 16384
	D = A
	@09815
	M = D

// [                  *    * *    *               * *               ] (Row 5)

	@09816		// [                ] 0
	M = 0
	@08514		// [  *    * *    * ] 8514
	D = A
	@09817
	M = D
	@00002		// [              * ] 2
	D = A
	@09818
	M = D
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09819
	M = D

// [  **              *    * *    *         **   *  *           **  ] (Row 6)

	@12288		// [  **            ] 12288
	D = A
	@09820
	M = D
	@08514		// [  *    * *    * ] 8514
	D = A
	@09821
	M = D
	@00196		// [        **   *  ] 196
	D = A
	@09822
	M = D
	D = -1		// [*           **  ] 32780
	@32755
	D = D - A
	@09823
	M = D

// [                    ***   ***           **    * *           **  ] (Row 7)

	@09824		// [                ] 0
	M = 0
	@03640		// [    ***   ***   ] 3640
	D = A
	@09825
	M = D
	@00194		// [        **    * ] 194
	D = A
	@09826
	M = D
	D = -1		// [*           **  ] 32780
	@32755
	D = D - A
	@09827
	M = D

// [*   *                                          * *              ] (Row 8)

	D = -1		// [*   *           ] 34816
	@30719
	D = D - A
	@09828
	M = D
	@09829		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09830
	M = D
	@16384		// [ *              ] 16384
	D = A
	@09831
	M = D

// [*    *              ***   ***                    *              ] (Row 9)

	D = -1		// [*    *          ] 33792
	@31743
	D = D - A
	@09832
	M = D
	@03640		// [    ***   ***   ] 3640
	D = A
	@09833
	M = D
	@09834		// [                ] 0
	M = 0
	@16384		// [ *              ] 16384
	D = A
	@09835
	M = D

// [  * * *           *    * *    *                                 ] (Row 10)

	@10752		// [  * * *         ] 10752
	D = A
	@09836
	M = D
	@08514		// [  *    * *    * ] 8514
	D = A
	@09837
	M = D
	@09838		// [                ] 0
	M = 0
	@09839		// [                ] 0
	M = 0

// [   * * *          *    * *    *                                 ] (Row 11)

	@05376		// [   * * *        ] 5376
	D = A
	@09840
	M = D
	@08514		// [  *    * *    * ] 8514
	D = A
	@09841
	M = D
	@09842		// [                ] 0
	M = 0
	@09843		// [                ] 0
	M = 0

// [    *    *        *    * *    *                                 ] (Row 12)

	@02112		// [    *    *      ] 2112
	D = A
	@09844
	M = D
	@08514		// [  *    * *    * ] 8514
	D = A
	@09845
	M = D
	@09846		// [                ] 0
	M = 0
	@09847		// [                ] 0
	M = 0

// [     *   *                                                      ] (Row 13)

	@01088		// [     *   *      ] 1088
	D = A
	@09848
	M = D
	@09849		// [                ] 0
	M = 0
	@09850		// [                ] 0
	M = 0
	@09851		// [                ] 0
	M = 0

// [                    ***   ***                                   ] (Row 14)

	@09852		// [                ] 0
	M = 0
	@03640		// [    ***   ***   ] 3640
	D = A
	@09853
	M = D
	@09854		// [                ] 0
	M = 0
	@09855		// [                ] 0
	M = 0

// [      **                                                        ] (Row 15)

	@00768		// [      **        ] 768
	D = A
	@09856
	M = D
	@09857		// [                ] 0
	M = 0
	@09858		// [                ] 0
	M = 0
	@09859		// [                ] 0
	M = 0

// [                                                                ] (Row 16)

	@09860		// [                ] 0
	M = 0
	@09861		// [                ] 0
	M = 0
	@09862		// [                ] 0
	M = 0
	@09863		// [                ] 0
	M = 0

// [                                                                ] (Row 17)

	@09864		// [                ] 0
	M = 0
	@09865		// [                ] 0
	M = 0
	@09866		// [                ] 0
	M = 0
	@09867		// [                ] 0
	M = 0

// [                                                                ] (Row 18)

	@09868		// [                ] 0
	M = 0
	@09869		// [                ] 0
	M = 0
	@09870		// [                ] 0
	M = 0
	@09871		// [                ] 0
	M = 0

// [                                 **                             ] (Row 19)

	@09872		// [                ] 0
	M = 0
	@09873		// [                ] 0
	M = 0
	@24576		// [ **             ] 24576
	D = A
	@09874
	M = D
	@09875		// [                ] 0
	M = 0

// [                **               * *       **                   ] (Row 20)

	@09876		// [                ] 0
	M = 0
	D = -1		// [**              ] 49152
	@16383
	D = D - A
	@09877
	M = D
	@20504		// [ * *       **   ] 20504
	D = A
	@09878
	M = D
	@09879		// [                ] 0
	M = 0

// [                **                 *       **                   ] (Row 21)

	@09880		// [                ] 0
	M = 0
	D = -1		// [**              ] 49152
	@16383
	D = D - A
	@09881
	M = D
	@04120		// [   *       **   ] 4120
	D = A
	@09882
	M = D
	@09883		// [                ] 0
	M = 0

// [                                 ***                            ] (Row 22)

	@09884		// [                ] 0
	M = 0
	@09885		// [                ] 0
	M = 0
	@28672		// [ ***            ] 28672
	D = A
	@09886
	M = D
	@09887		// [                ] 0
	M = 0

// [                                                                ] (Row 23)

	@09888		// [                ] 0
	M = 0
	@09889		// [                ] 0
	M = 0
	@09890		// [                ] 0
	M = 0
	@09891		// [                ] 0
	M = 0

// [                                                                ] (Row 24)

	@09892		// [                ] 0
	M = 0
	@09893		// [                ] 0
	M = 0
	@09894		// [                ] 0
	M = 0
	@09895		// [                ] 0
	M = 0

// [                                                                ] (Row 25)

	@09896		// [                ] 0
	M = 0
	@09897		// [                ] 0
	M = 0
	@09898		// [                ] 0
	M = 0
	@09899		// [                ] 0
	M = 0

// [                                 ***                            ] (Row 26)

	@09900		// [                ] 0
	M = 0
	@09901		// [                ] 0
	M = 0
	@28672		// [ ***            ] 28672
	D = A
	@09902
	M = D
	@09903		// [                ] 0
	M = 0

// [                **                 *                            ] (Row 27)

	@09904		// [                ] 0
	M = 0
	D = -1		// [**              ] 49152
	@16383
	D = D - A
	@09905
	M = D
	@04096		// [   *            ] 4096
	D = A
	@09906
	M = D
	@09907		// [                ] 0
	M = 0

// [                **               * *                            ] (Row 28)

	@09908		// [                ] 0
	M = 0
	D = -1		// [**              ] 49152
	@16383
	D = D - A
	@09909
	M = D
	@20480		// [ * *            ] 20480
	D = A
	@09910
	M = D
	@09911		// [                ] 0
	M = 0

// [                                 **                             ] (Row 29)

	@09912		// [                ] 0
	M = 0
	@09913		// [                ] 0
	M = 0
	@24576		// [ **             ] 24576
	D = A
	@09914
	M = D
	@09915		// [                ] 0
	M = 0

// [                                                                ] (Row 30)

	@09916		// [                ] 0
	M = 0
	@09917		// [                ] 0
	M = 0
	@09918		// [                ] 0
	M = 0
	@09919		// [                ] 0
	M = 0

// [                                                                ] (Row 31)

	@09920		// [                ] 0
	M = 0
	@09921		// [                ] 0
	M = 0
	@09922		// [                ] 0
	M = 0
	@09923		// [                ] 0
	M = 0

// [                                                                ] (Row 32)

	@09924		// [                ] 0
	M = 0
	@09925		// [                ] 0
	M = 0
	@09926		// [                ] 0
	M = 0
	@09927		// [                ] 0
	M = 0

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Automatically generated board loading code

(Gliders.Board)

// [                                                                ]
// [     *                                                          ]
// [   *   *                                                *       ]
// [        *                                                *      ]
// [   *    *                                              ***      ]
// [    *****                                                       ]
// [                    *                                           ]
// [                     *                                          ]
// [                   ***      **                                  ]
// [                          *    *                                ]
// [                                *                               ]
// [                          *     *                               ]
// [                           ******                               ]
// [                                                                ]
// [                                                    ****        ]
// [                                                   ******       ]
// [                                          *        **** **      ]
// [                                           *           **       ]
// [                                         ***                    ]
// [                                               **               ]
// [      *                                      *            *     ]
// [       *                                                   *    ]
// [     ***                                     *             *    ]
// [                                              **************    ]
// [                                  *                             ]
// [                                   *                            ]
// [                                 ***                ****        ]
// [                                                   ******       ]
// [                                                   **** **      ]
// [                                                       **       ]
// [                                                                ]
// [                                                                ]

// [                                                                ] (Row 1)

	@09800		// [                ] 0
	M = 0
	@09801		// [                ] 0
	M = 0
	@09802		// [                ] 0
	M = 0
	@09803		// [                ] 0
	M = 0

// [     *                                                          ] (Row 2)

	@01024		// [     *          ] 1024
	D = A
	@09804
	M = D
	@09805		// [                ] 0
	M = 0
	@09806		// [                ] 0
	M = 0
	@09807		// [                ] 0
	M = 0

// [   *   *                                                *       ] (Row 3)

	@04352		// [   *   *        ] 4352
	D = A
	@09808
	M = D
	@09809		// [                ] 0
	M = 0
	@09810		// [                ] 0
	M = 0
	@00128		// [        *       ] 128
	D = A
	@09811
	M = D

// [        *                                                *      ] (Row 4)

	@00128		// [        *       ] 128
	D = A
	@09812
	M = D
	@09813		// [                ] 0
	M = 0
	@09814		// [                ] 0
	M = 0
	@00064		// [         *      ] 64
	D = A
	@09815
	M = D

// [   *    *                                              ***      ] (Row 5)

	@04224		// [   *    *       ] 4224
	D = A
	@09816
	M = D
	@09817		// [                ] 0
	M = 0
	@09818		// [                ] 0
	M = 0
	@00448		// [       ***      ] 448
	D = A
	@09819
	M = D

// [    *****                                                       ] (Row 6)

	@03968		// [    *****       ] 3968
	D = A
	@09820
	M = D
	@09821		// [                ] 0
	M = 0
	@09822		// [                ] 0
	M = 0
	@09823		// [                ] 0
	M = 0

// [                    *                                           ] (Row 7)

	@09824		// [                ] 0
	M = 0
	@02048		// [    *           ] 2048
	D = A
	@09825
	M = D
	@09826		// [                ] 0
	M = 0
	@09827		// [                ] 0
	M = 0

// [                     *                                          ] (Row 8)

	@09828		// [                ] 0
	M = 0
	@01024		// [     *          ] 1024
	D = A
	@09829
	M = D
	@09830		// [                ] 0
	M = 0
	@09831		// [                ] 0
	M = 0

// [                   ***      **                                  ] (Row 9)

	@09832		// [                ] 0
	M = 0
	@07180		// [   ***      **  ] 7180
	D = A
	@09833
	M = D
	@09834		// [                ] 0
	M = 0
	@09835		// [                ] 0
	M = 0

// [                          *    *                                ] (Row 10)

	@09836		// [                ] 0
	M = 0
	@00033		// [          *    *] 33
	D = A
	@09837
	M = D
	@09838		// [                ] 0
	M = 0
	@09839		// [                ] 0
	M = 0

// [                                *                               ] (Row 11)

	@09840		// [                ] 0
	M = 0
	@09841		// [                ] 0
	M = 0
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09842
	M = D
	@09843		// [                ] 0
	M = 0

// [                          *     *                               ] (Row 12)

	@09844		// [                ] 0
	M = 0
	@00032		// [          *     ] 32
	D = A
	@09845
	M = D
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09846
	M = D
	@09847		// [                ] 0
	M = 0

// [                           ******                               ] (Row 13)

	@09848		// [                ] 0
	M = 0
	@00031		// [           *****] 31
	D = A
	@09849
	M = D
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09850
	M = D
	@09851		// [                ] 0
	M = 0

// [                                                                ] (Row 14)

	@09852		// [                ] 0
	M = 0
	@09853		// [                ] 0
	M = 0
	@09854		// [                ] 0
	M = 0
	@09855		// [                ] 0
	M = 0

// [                                                    ****        ] (Row 15)

	@09856		// [                ] 0
	M = 0
	@09857		// [                ] 0
	M = 0
	@09858		// [                ] 0
	M = 0
	@03840		// [    ****        ] 3840
	D = A
	@09859
	M = D

// [                                                   ******       ] (Row 16)

	@09860		// [                ] 0
	M = 0
	@09861		// [                ] 0
	M = 0
	@09862		// [                ] 0
	M = 0
	@08064		// [   ******       ] 8064
	D = A
	@09863
	M = D

// [                                          *        **** **      ] (Row 17)

	@09864		// [                ] 0
	M = 0
	@09865		// [                ] 0
	M = 0
	@00032		// [          *     ] 32
	D = A
	@09866
	M = D
	@07872		// [   **** **      ] 7872
	D = A
	@09867
	M = D

// [                                           *           **       ] (Row 18)

	@09868		// [                ] 0
	M = 0
	@09869		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09870
	M = D
	@00384		// [       **       ] 384
	D = A
	@09871
	M = D

// [                                         ***                    ] (Row 19)

	@09872		// [                ] 0
	M = 0
	@09873		// [                ] 0
	M = 0
	@00112		// [         ***    ] 112
	D = A
	@09874
	M = D
	@09875		// [                ] 0
	M = 0

// [                                               **               ] (Row 20)

	@09876		// [                ] 0
	M = 0
	@09877		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09878
	M = D
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09879
	M = D

// [      *                                      *            *     ] (Row 21)

	@00512		// [      *         ] 512
	D = A
	@09880
	M = D
	@09881		// [                ] 0
	M = 0
	@00004		// [             *  ] 4
	D = A
	@09882
	M = D
	@00032		// [          *     ] 32
	D = A
	@09883
	M = D

// [       *                                                   *    ] (Row 22)

	@00256		// [       *        ] 256
	D = A
	@09884
	M = D
	@09885		// [                ] 0
	M = 0
	@09886		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09887
	M = D

// [     ***                                     *             *    ] (Row 23)

	@01792		// [     ***        ] 1792
	D = A
	@09888
	M = D
	@09889		// [                ] 0
	M = 0
	@00004		// [             *  ] 4
	D = A
	@09890
	M = D
	@00016		// [           *    ] 16
	D = A
	@09891
	M = D

// [                                              **************    ] (Row 24)

	@09892		// [                ] 0
	M = 0
	@09893		// [                ] 0
	M = 0
	@00003		// [              **] 3
	D = A
	@09894
	M = D
	D = -1		// [************    ] 65520
	@00015
	D = D - A
	@09895
	M = D

// [                                  *                             ] (Row 25)

	@09896		// [                ] 0
	M = 0
	@09897		// [                ] 0
	M = 0
	@08192		// [  *             ] 8192
	D = A
	@09898
	M = D
	@09899		// [                ] 0
	M = 0

// [                                   *                            ] (Row 26)

	@09900		// [                ] 0
	M = 0
	@09901		// [                ] 0
	M = 0
	@04096		// [   *            ] 4096
	D = A
	@09902
	M = D
	@09903		// [                ] 0
	M = 0

// [                                 ***                ****        ] (Row 27)

	@09904		// [                ] 0
	M = 0
	@09905		// [                ] 0
	M = 0
	@28672		// [ ***            ] 28672
	D = A
	@09906
	M = D
	@03840		// [    ****        ] 3840
	D = A
	@09907
	M = D

// [                                                   ******       ] (Row 28)

	@09908		// [                ] 0
	M = 0
	@09909		// [                ] 0
	M = 0
	@09910		// [                ] 0
	M = 0
	@08064		// [   ******       ] 8064
	D = A
	@09911
	M = D

// [                                                   **** **      ] (Row 29)

	@09912		// [                ] 0
	M = 0
	@09913		// [                ] 0
	M = 0
	@09914		// [                ] 0
	M = 0
	@07872		// [   **** **      ] 7872
	D = A
	@09915
	M = D

// [                                                       **       ] (Row 30)

	@09916		// [                ] 0
	M = 0
	@09917		// [                ] 0
	M = 0
	@09918		// [                ] 0
	M = 0
	@00384		// [       **       ] 384
	D = A
	@09919
	M = D

// [                                                                ] (Row 31)

	@09920		// [                ] 0
	M = 0
	@09921		// [                ] 0
	M = 0
	@09922		// [                ] 0
	M = 0
	@09923		// [                ] 0
	M = 0

// [                                                                ] (Row 32)

	@09924		// [                ] 0
	M = 0
	@09925		// [                ] 0
	M = 0
	@09926		// [                ] 0
	M = 0
	@09927		// [                ] 0
	M = 0

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Automatically generated board loading code

(Gosper.Glider.Gun)

// [                                                                ]
// [                         *                                      ]
// [                       * *                                      ]
// [             **      **            **                           ]
// [            *   *    **            **                           ]
// [ **        *     *   **                                         ]
// [ **        *   * **    * *                                      ]
// [           *     *       *                                      ]
// [            *   *                                               ]
// [             **                                                 ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                         **                     ]
// [                                         * *                    ]
// [                                           *                    ]
// [                                           **                   ]
// [                                                                ]

// [                                                                ] (Row 1)

	@09800		// [                ] 0
	M = 0
	@09801		// [                ] 0
	M = 0
	@09802		// [                ] 0
	M = 0
	@09803		// [                ] 0
	M = 0

// [                         *                                      ] (Row 2)

	@09804		// [                ] 0
	M = 0
	@00064		// [         *      ] 64
	D = A
	@09805
	M = D
	@09806		// [                ] 0
	M = 0
	@09807		// [                ] 0
	M = 0

// [                       * *                                      ] (Row 3)

	@09808		// [                ] 0
	M = 0
	@00320		// [       * *      ] 320
	D = A
	@09809
	M = D
	@09810		// [                ] 0
	M = 0
	@09811		// [                ] 0
	M = 0

// [             **      **            **                           ] (Row 4)

	@00006		// [             ** ] 6
	D = A
	@09812
	M = D
	@01536		// [     **         ] 1536
	D = A
	@09813
	M = D
	@06144		// [   **           ] 6144
	D = A
	@09814
	M = D
	@09815		// [                ] 0
	M = 0

// [            *   *    **            **                           ] (Row 5)

	@00008		// [            *   ] 8
	D = A
	@09816
	M = D
	D = -1		// [*    **         ] 34304
	@31231
	D = D - A
	@09817
	M = D
	@06144		// [   **           ] 6144
	D = A
	@09818
	M = D
	@09819		// [                ] 0
	M = 0

// [ **        *     *   **                                         ] (Row 6)

	@24592		// [ **        *    ] 24592
	D = A
	@09820
	M = D
	@17920		// [ *   **         ] 17920
	D = A
	@09821
	M = D
	@09822		// [                ] 0
	M = 0
	@09823		// [                ] 0
	M = 0

// [ **        *   * **    * *                                      ] (Row 7)

	@24593		// [ **        *   *] 24593
	D = A
	@09824
	M = D
	@24896		// [ **    * *      ] 24896
	D = A
	@09825
	M = D
	@09826		// [                ] 0
	M = 0
	@09827		// [                ] 0
	M = 0

// [           *     *       *                                      ] (Row 8)

	@00016		// [           *    ] 16
	D = A
	@09828
	M = D
	@16448		// [ *       *      ] 16448
	D = A
	@09829
	M = D
	@09830		// [                ] 0
	M = 0
	@09831		// [                ] 0
	M = 0

// [            *   *                                               ] (Row 9)

	@00008		// [            *   ] 8
	D = A
	@09832
	M = D
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09833
	M = D
	@09834		// [                ] 0
	M = 0
	@09835		// [                ] 0
	M = 0

// [             **                                                 ] (Row 10)

	@00006		// [             ** ] 6
	D = A
	@09836
	M = D
	@09837		// [                ] 0
	M = 0
	@09838		// [                ] 0
	M = 0
	@09839		// [                ] 0
	M = 0

// [                                                                ] (Row 11)

	@09840		// [                ] 0
	M = 0
	@09841		// [                ] 0
	M = 0
	@09842		// [                ] 0
	M = 0
	@09843		// [                ] 0
	M = 0

// [                                                                ] (Row 12)

	@09844		// [                ] 0
	M = 0
	@09845		// [                ] 0
	M = 0
	@09846		// [                ] 0
	M = 0
	@09847		// [                ] 0
	M = 0

// [                                                                ] (Row 13)

	@09848		// [                ] 0
	M = 0
	@09849		// [                ] 0
	M = 0
	@09850		// [                ] 0
	M = 0
	@09851		// [                ] 0
	M = 0

// [                                                                ] (Row 14)

	@09852		// [                ] 0
	M = 0
	@09853		// [                ] 0
	M = 0
	@09854		// [                ] 0
	M = 0
	@09855		// [                ] 0
	M = 0

// [                                                                ] (Row 15)

	@09856		// [                ] 0
	M = 0
	@09857		// [                ] 0
	M = 0
	@09858		// [                ] 0
	M = 0
	@09859		// [                ] 0
	M = 0

// [                                                                ] (Row 16)

	@09860		// [                ] 0
	M = 0
	@09861		// [                ] 0
	M = 0
	@09862		// [                ] 0
	M = 0
	@09863		// [                ] 0
	M = 0

// [                                                                ] (Row 17)

	@09864		// [                ] 0
	M = 0
	@09865		// [                ] 0
	M = 0
	@09866		// [                ] 0
	M = 0
	@09867		// [                ] 0
	M = 0

// [                                                                ] (Row 18)

	@09868		// [                ] 0
	M = 0
	@09869		// [                ] 0
	M = 0
	@09870		// [                ] 0
	M = 0
	@09871		// [                ] 0
	M = 0

// [                                                                ] (Row 19)

	@09872		// [                ] 0
	M = 0
	@09873		// [                ] 0
	M = 0
	@09874		// [                ] 0
	M = 0
	@09875		// [                ] 0
	M = 0

// [                                                                ] (Row 20)

	@09876		// [                ] 0
	M = 0
	@09877		// [                ] 0
	M = 0
	@09878		// [                ] 0
	M = 0
	@09879		// [                ] 0
	M = 0

// [                                                                ] (Row 21)

	@09880		// [                ] 0
	M = 0
	@09881		// [                ] 0
	M = 0
	@09882		// [                ] 0
	M = 0
	@09883		// [                ] 0
	M = 0

// [                                                                ] (Row 22)

	@09884		// [                ] 0
	M = 0
	@09885		// [                ] 0
	M = 0
	@09886		// [                ] 0
	M = 0
	@09887		// [                ] 0
	M = 0

// [                                                                ] (Row 23)

	@09888		// [                ] 0
	M = 0
	@09889		// [                ] 0
	M = 0
	@09890		// [                ] 0
	M = 0
	@09891		// [                ] 0
	M = 0

// [                                                                ] (Row 24)

	@09892		// [                ] 0
	M = 0
	@09893		// [                ] 0
	M = 0
	@09894		// [                ] 0
	M = 0
	@09895		// [                ] 0
	M = 0

// [                                                                ] (Row 25)

	@09896		// [                ] 0
	M = 0
	@09897		// [                ] 0
	M = 0
	@09898		// [                ] 0
	M = 0
	@09899		// [                ] 0
	M = 0

// [                                                                ] (Row 26)

	@09900		// [                ] 0
	M = 0
	@09901		// [                ] 0
	M = 0
	@09902		// [                ] 0
	M = 0
	@09903		// [                ] 0
	M = 0

// [                                                                ] (Row 27)

	@09904		// [                ] 0
	M = 0
	@09905		// [                ] 0
	M = 0
	@09906		// [                ] 0
	M = 0
	@09907		// [                ] 0
	M = 0

// [                                         **                     ] (Row 28)

	@09908		// [                ] 0
	M = 0
	@09909		// [                ] 0
	M = 0
	@00096		// [         **     ] 96
	D = A
	@09910
	M = D
	@09911		// [                ] 0
	M = 0

// [                                         * *                    ] (Row 29)

	@09912		// [                ] 0
	M = 0
	@09913		// [                ] 0
	M = 0
	@00080		// [         * *    ] 80
	D = A
	@09914
	M = D
	@09915		// [                ] 0
	M = 0

// [                                           *                    ] (Row 30)

	@09916		// [                ] 0
	M = 0
	@09917		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09918
	M = D
	@09919		// [                ] 0
	M = 0

// [                                           **                   ] (Row 31)

	@09920		// [                ] 0
	M = 0
	@09921		// [                ] 0
	M = 0
	@00024		// [           **   ] 24
	D = A
	@09922
	M = D
	@09923		// [                ] 0
	M = 0

// [                                                                ] (Row 32)

	@09924		// [                ] 0
	M = 0
	@09925		// [                ] 0
	M = 0
	@09926		// [                ] 0
	M = 0
	@09927		// [                ] 0
	M = 0

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Automatically generated board loading code

(Beacon.Maker)

// [                               *                                ]
// [                              *                               **]
// [                             *                               * *]
// [                            *                               *   ]
// [                           *                               *    ]
// [                          *                               *     ]
// [                         *                               *      ]
// [                        *                               *       ]
// [                       *                               *        ]
// [                      *                               *         ]
// [                     *                               *          ]
// [                    *                               *           ]
// [                   *                               *            ]
// [                  *                               *             ]
// [                 *                               *              ]
// [                *                               *               ]
// [               *                               *                ]
// [              *                               *                 ]
// [             *                               *                  ]
// [            *                               *                   ]
// [           *                               *                    ]
// [          *                               *                     ]
// [         *                               *                      ]
// [        *                               *                       ]
// [       *                               *                        ]
// [      *                               *                         ]
// [     *                               *                          ]
// [    *                               *                           ]
// [ ***                               *                            ]
// [   *                              *                             ]
// [   *                             *                              ]
// [                                *                               ]

// [                               *                                ] (Row 1)

	@09800		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09801
	M = D
	@09802		// [                ] 0
	M = 0
	@09803		// [                ] 0
	M = 0

// [                              *                               **] (Row 2)

	@09804		// [                ] 0
	M = 0
	@00002		// [              * ] 2
	D = A
	@09805
	M = D
	@09806		// [                ] 0
	M = 0
	@00003		// [              **] 3
	D = A
	@09807
	M = D

// [                             *                               * *] (Row 3)

	@09808		// [                ] 0
	M = 0
	@00004		// [             *  ] 4
	D = A
	@09809
	M = D
	@09810		// [                ] 0
	M = 0
	@00005		// [             * *] 5
	D = A
	@09811
	M = D

// [                            *                               *   ] (Row 4)

	@09812		// [                ] 0
	M = 0
	@00008		// [            *   ] 8
	D = A
	@09813
	M = D
	@09814		// [                ] 0
	M = 0
	@00008		// [            *   ] 8
	D = A
	@09815
	M = D

// [                           *                               *    ] (Row 5)

	@09816		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09817
	M = D
	@09818		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09819
	M = D

// [                          *                               *     ] (Row 6)

	@09820		// [                ] 0
	M = 0
	@00032		// [          *     ] 32
	D = A
	@09821
	M = D
	@09822		// [                ] 0
	M = 0
	@00032		// [          *     ] 32
	D = A
	@09823
	M = D

// [                         *                               *      ] (Row 7)

	@09824		// [                ] 0
	M = 0
	@00064		// [         *      ] 64
	D = A
	@09825
	M = D
	@09826		// [                ] 0
	M = 0
	@00064		// [         *      ] 64
	D = A
	@09827
	M = D

// [                        *                               *       ] (Row 8)

	@09828		// [                ] 0
	M = 0
	@00128		// [        *       ] 128
	D = A
	@09829
	M = D
	@09830		// [                ] 0
	M = 0
	@00128		// [        *       ] 128
	D = A
	@09831
	M = D

// [                       *                               *        ] (Row 9)

	@09832		// [                ] 0
	M = 0
	@00256		// [       *        ] 256
	D = A
	@09833
	M = D
	@09834		// [                ] 0
	M = 0
	@00256		// [       *        ] 256
	D = A
	@09835
	M = D

// [                      *                               *         ] (Row 10)

	@09836		// [                ] 0
	M = 0
	@00512		// [      *         ] 512
	D = A
	@09837
	M = D
	@09838		// [                ] 0
	M = 0
	@00512		// [      *         ] 512
	D = A
	@09839
	M = D

// [                     *                               *          ] (Row 11)

	@09840		// [                ] 0
	M = 0
	@01024		// [     *          ] 1024
	D = A
	@09841
	M = D
	@09842		// [                ] 0
	M = 0
	@01024		// [     *          ] 1024
	D = A
	@09843
	M = D

// [                    *                               *           ] (Row 12)

	@09844		// [                ] 0
	M = 0
	@02048		// [    *           ] 2048
	D = A
	@09845
	M = D
	@09846		// [                ] 0
	M = 0
	@02048		// [    *           ] 2048
	D = A
	@09847
	M = D

// [                   *                               *            ] (Row 13)

	@09848		// [                ] 0
	M = 0
	@04096		// [   *            ] 4096
	D = A
	@09849
	M = D
	@09850		// [                ] 0
	M = 0
	@04096		// [   *            ] 4096
	D = A
	@09851
	M = D

// [                  *                               *             ] (Row 14)

	@09852		// [                ] 0
	M = 0
	@08192		// [  *             ] 8192
	D = A
	@09853
	M = D
	@09854		// [                ] 0
	M = 0
	@08192		// [  *             ] 8192
	D = A
	@09855
	M = D

// [                 *                               *              ] (Row 15)

	@09856		// [                ] 0
	M = 0
	@16384		// [ *              ] 16384
	D = A
	@09857
	M = D
	@09858		// [                ] 0
	M = 0
	@16384		// [ *              ] 16384
	D = A
	@09859
	M = D

// [                *                               *               ] (Row 16)

	@09860		// [                ] 0
	M = 0
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09861
	M = D
	@09862		// [                ] 0
	M = 0
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09863
	M = D

// [               *                               *                ] (Row 17)

	@00001		// [               *] 1
	D = A
	@09864
	M = D
	@09865		// [                ] 0
	M = 0
	@00001		// [               *] 1
	D = A
	@09866
	M = D
	@09867		// [                ] 0
	M = 0

// [              *                               *                 ] (Row 18)

	@00002		// [              * ] 2
	D = A
	@09868
	M = D
	@09869		// [                ] 0
	M = 0
	@00002		// [              * ] 2
	D = A
	@09870
	M = D
	@09871		// [                ] 0
	M = 0

// [             *                               *                  ] (Row 19)

	@00004		// [             *  ] 4
	D = A
	@09872
	M = D
	@09873		// [                ] 0
	M = 0
	@00004		// [             *  ] 4
	D = A
	@09874
	M = D
	@09875		// [                ] 0
	M = 0

// [            *                               *                   ] (Row 20)

	@00008		// [            *   ] 8
	D = A
	@09876
	M = D
	@09877		// [                ] 0
	M = 0
	@00008		// [            *   ] 8
	D = A
	@09878
	M = D
	@09879		// [                ] 0
	M = 0

// [           *                               *                    ] (Row 21)

	@00016		// [           *    ] 16
	D = A
	@09880
	M = D
	@09881		// [                ] 0
	M = 0
	@00016		// [           *    ] 16
	D = A
	@09882
	M = D
	@09883		// [                ] 0
	M = 0

// [          *                               *                     ] (Row 22)

	@00032		// [          *     ] 32
	D = A
	@09884
	M = D
	@09885		// [                ] 0
	M = 0
	@00032		// [          *     ] 32
	D = A
	@09886
	M = D
	@09887		// [                ] 0
	M = 0

// [         *                               *                      ] (Row 23)

	@00064		// [         *      ] 64
	D = A
	@09888
	M = D
	@09889		// [                ] 0
	M = 0
	@00064		// [         *      ] 64
	D = A
	@09890
	M = D
	@09891		// [                ] 0
	M = 0

// [        *                               *                       ] (Row 24)

	@00128		// [        *       ] 128
	D = A
	@09892
	M = D
	@09893		// [                ] 0
	M = 0
	@00128		// [        *       ] 128
	D = A
	@09894
	M = D
	@09895		// [                ] 0
	M = 0

// [       *                               *                        ] (Row 25)

	@00256		// [       *        ] 256
	D = A
	@09896
	M = D
	@09897		// [                ] 0
	M = 0
	@00256		// [       *        ] 256
	D = A
	@09898
	M = D
	@09899		// [                ] 0
	M = 0

// [      *                               *                         ] (Row 26)

	@00512		// [      *         ] 512
	D = A
	@09900
	M = D
	@09901		// [                ] 0
	M = 0
	@00512		// [      *         ] 512
	D = A
	@09902
	M = D
	@09903		// [                ] 0
	M = 0

// [     *                               *                          ] (Row 27)

	@01024		// [     *          ] 1024
	D = A
	@09904
	M = D
	@09905		// [                ] 0
	M = 0
	@01024		// [     *          ] 1024
	D = A
	@09906
	M = D
	@09907		// [                ] 0
	M = 0

// [    *                               *                           ] (Row 28)

	@02048		// [    *           ] 2048
	D = A
	@09908
	M = D
	@09909		// [                ] 0
	M = 0
	@02048		// [    *           ] 2048
	D = A
	@09910
	M = D
	@09911		// [                ] 0
	M = 0

// [ ***                               *                            ] (Row 29)

	@28672		// [ ***            ] 28672
	D = A
	@09912
	M = D
	@09913		// [                ] 0
	M = 0
	@04096		// [   *            ] 4096
	D = A
	@09914
	M = D
	@09915		// [                ] 0
	M = 0

// [   *                              *                             ] (Row 30)

	@04096		// [   *            ] 4096
	D = A
	@09916
	M = D
	@09917		// [                ] 0
	M = 0
	@08192		// [  *             ] 8192
	D = A
	@09918
	M = D
	@09919		// [                ] 0
	M = 0

// [   *                             *                              ] (Row 31)

	@04096		// [   *            ] 4096
	D = A
	@09920
	M = D
	@09921		// [                ] 0
	M = 0
	@16384		// [ *              ] 16384
	D = A
	@09922
	M = D
	@09923		// [                ] 0
	M = 0

// [                                *                               ] (Row 32)

	@09924		// [                ] 0
	M = 0
	@09925		// [                ] 0
	M = 0
	D = -1		// [*               ] 32768
	@32767
	D = D - A
	@09926
	M = D
	@09927		// [                ] 0
	M = 0

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

// Automatically generated board loading code

(Blinker.Puffer)

// [                                                                ]
// [                                                                ]
// [        *                                                       ]
// [      *   *                                                     ]
// [     *                                                          ]
// [     *    *                                             **      ]
// [     *****                                             ** ****  ]
// [                                                        ******  ]
// [                                                         ****   ]
// [                                                                ]
// [      **                                                        ]
// [     ** ***                                                     ]
// [      ****   *** *** *** *** *** *** *** *** *** *** *** ***    ]
// [       **                                                       ]
// [                                                                ]
// [          **                                                    ]
// [        *    *                                                  ]
// [       *                                                        ]
// [       *     *                                                  ]
// [       ******                                                   ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]
// [                                                                ]

// [                                                                ] (Row 1)

	@09800		// [                ] 0
	M = 0
	@09801		// [                ] 0
	M = 0
	@09802		// [                ] 0
	M = 0
	@09803		// [                ] 0
	M = 0

// [                                                                ] (Row 2)

	@09804		// [                ] 0
	M = 0
	@09805		// [                ] 0
	M = 0
	@09806		// [                ] 0
	M = 0
	@09807		// [                ] 0
	M = 0

// [        *                                                       ] (Row 3)

	@00128		// [        *       ] 128
	D = A
	@09808
	M = D
	@09809		// [                ] 0
	M = 0
	@09810		// [                ] 0
	M = 0
	@09811		// [                ] 0
	M = 0

// [      *   *                                                     ] (Row 4)

	@00544		// [      *   *     ] 544
	D = A
	@09812
	M = D
	@09813		// [                ] 0
	M = 0
	@09814		// [                ] 0
	M = 0
	@09815		// [                ] 0
	M = 0

// [     *                                                          ] (Row 5)

	@01024		// [     *          ] 1024
	D = A
	@09816
	M = D
	@09817		// [                ] 0
	M = 0
	@09818		// [                ] 0
	M = 0
	@09819		// [                ] 0
	M = 0

// [     *    *                                             **      ] (Row 6)

	@01056		// [     *    *     ] 1056
	D = A
	@09820
	M = D
	@09821		// [                ] 0
	M = 0
	@09822		// [                ] 0
	M = 0
	@00192		// [        **      ] 192
	D = A
	@09823
	M = D

// [     *****                                             ** ****  ] (Row 7)

	@01984		// [     *****      ] 1984
	D = A
	@09824
	M = D
	@09825		// [                ] 0
	M = 0
	@09826		// [                ] 0
	M = 0
	@00444		// [       ** ****  ] 444
	D = A
	@09827
	M = D

// [                                                        ******  ] (Row 8)

	@09828		// [                ] 0
	M = 0
	@09829		// [                ] 0
	M = 0
	@09830		// [                ] 0
	M = 0
	@00252		// [        ******  ] 252
	D = A
	@09831
	M = D

// [                                                         ****   ] (Row 9)

	@09832		// [                ] 0
	M = 0
	@09833		// [                ] 0
	M = 0
	@09834		// [                ] 0
	M = 0
	@00120		// [         ****   ] 120
	D = A
	@09835
	M = D

// [                                                                ] (Row 10)

	@09836		// [                ] 0
	M = 0
	@09837		// [                ] 0
	M = 0
	@09838		// [                ] 0
	M = 0
	@09839		// [                ] 0
	M = 0

// [      **                                                        ] (Row 11)

	@00768		// [      **        ] 768
	D = A
	@09840
	M = D
	@09841		// [                ] 0
	M = 0
	@09842		// [                ] 0
	M = 0
	@09843		// [                ] 0
	M = 0

// [     ** ***                                                     ] (Row 12)

	@01760		// [     ** ***     ] 1760
	D = A
	@09844
	M = D
	@09845		// [                ] 0
	M = 0
	@09846		// [                ] 0
	M = 0
	@09847		// [                ] 0
	M = 0

// [      ****   *** *** *** *** *** *** *** *** *** *** *** ***    ] (Row 13)

	@00967		// [      ****   ***] 967
	D = A
	@09848
	M = D
	@30583		// [ *** *** *** ***] 30583
	D = A
	@09849
	M = D
	@30583		// [ *** *** *** ***] 30583
	D = A
	@09850
	M = D
	@30576		// [ *** *** ***    ] 30576
	D = A
	@09851
	M = D

// [       **                                                       ] (Row 14)

	@00384		// [       **       ] 384
	D = A
	@09852
	M = D
	@09853		// [                ] 0
	M = 0
	@09854		// [                ] 0
	M = 0
	@09855		// [                ] 0
	M = 0

// [                                                                ] (Row 15)

	@09856		// [                ] 0
	M = 0
	@09857		// [                ] 0
	M = 0
	@09858		// [                ] 0
	M = 0
	@09859		// [                ] 0
	M = 0

// [          **                                                    ] (Row 16)

	@00048		// [          **    ] 48
	D = A
	@09860
	M = D
	@09861		// [                ] 0
	M = 0
	@09862		// [                ] 0
	M = 0
	@09863		// [                ] 0
	M = 0

// [        *    *                                                  ] (Row 17)

	@00132		// [        *    *  ] 132
	D = A
	@09864
	M = D
	@09865		// [                ] 0
	M = 0
	@09866		// [                ] 0
	M = 0
	@09867		// [                ] 0
	M = 0

// [       *                                                        ] (Row 18)

	@00256		// [       *        ] 256
	D = A
	@09868
	M = D
	@09869		// [                ] 0
	M = 0
	@09870		// [                ] 0
	M = 0
	@09871		// [                ] 0
	M = 0

// [       *     *                                                  ] (Row 19)

	@00260		// [       *     *  ] 260
	D = A
	@09872
	M = D
	@09873		// [                ] 0
	M = 0
	@09874		// [                ] 0
	M = 0
	@09875		// [                ] 0
	M = 0

// [       ******                                                   ] (Row 20)

	@00504		// [       ******   ] 504
	D = A
	@09876
	M = D
	@09877		// [                ] 0
	M = 0
	@09878		// [                ] 0
	M = 0
	@09879		// [                ] 0
	M = 0

// [                                                                ] (Row 21)

	@09880		// [                ] 0
	M = 0
	@09881		// [                ] 0
	M = 0
	@09882		// [                ] 0
	M = 0
	@09883		// [                ] 0
	M = 0

// [                                                                ] (Row 22)

	@09884		// [                ] 0
	M = 0
	@09885		// [                ] 0
	M = 0
	@09886		// [                ] 0
	M = 0
	@09887		// [                ] 0
	M = 0

// [                                                                ] (Row 23)

	@09888		// [                ] 0
	M = 0
	@09889		// [                ] 0
	M = 0
	@09890		// [                ] 0
	M = 0
	@09891		// [                ] 0
	M = 0

// [                                                                ] (Row 24)

	@09892		// [                ] 0
	M = 0
	@09893		// [                ] 0
	M = 0
	@09894		// [                ] 0
	M = 0
	@09895		// [                ] 0
	M = 0

// [                                                                ] (Row 25)

	@09896		// [                ] 0
	M = 0
	@09897		// [                ] 0
	M = 0
	@09898		// [                ] 0
	M = 0
	@09899		// [                ] 0
	M = 0

// [                                                                ] (Row 26)

	@09900		// [                ] 0
	M = 0
	@09901		// [                ] 0
	M = 0
	@09902		// [                ] 0
	M = 0
	@09903		// [                ] 0
	M = 0

// [                                                                ] (Row 27)

	@09904		// [                ] 0
	M = 0
	@09905		// [                ] 0
	M = 0
	@09906		// [                ] 0
	M = 0
	@09907		// [                ] 0
	M = 0

// [                                                                ] (Row 28)

	@09908		// [                ] 0
	M = 0
	@09909		// [                ] 0
	M = 0
	@09910		// [                ] 0
	M = 0
	@09911		// [                ] 0
	M = 0

// [                                                                ] (Row 29)

	@09912		// [                ] 0
	M = 0
	@09913		// [                ] 0
	M = 0
	@09914		// [                ] 0
	M = 0
	@09915		// [                ] 0
	M = 0

// [                                                                ] (Row 30)

	@09916		// [                ] 0
	M = 0
	@09917		// [                ] 0
	M = 0
	@09918		// [                ] 0
	M = 0
	@09919		// [                ] 0
	M = 0

// [                                                                ] (Row 31)

	@09920		// [                ] 0
	M = 0
	@09921		// [                ] 0
	M = 0
	@09922		// [                ] 0
	M = 0
	@09923		// [                ] 0
	M = 0

// [                                                                ] (Row 32)

	@09924		// [                ] 0
	M = 0
	@09925		// [                ] 0
	M = 0
	@09926		// [                ] 0
	M = 0
	@09927		// [                ] 0
	M = 0

// return to caller

	@SP		// Jump to [++SP]
	AM = M + 1
	A = M
	0 ; JMP

