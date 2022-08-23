# coding: utf-8

#
# python script to scan HACK memory dumps and output the stored boards
#

import sys
import os
import math

ram = []

def dumpboard(name,addr):

	global ram

	print "hack(["
	print ""
	print '"' + name + '",'
	print ""

	# skip guard cells

	addr += 67

	for i in range(0,32):

		print '"' + ''.join(["*" if c == -32768 else " " for c in ram[addr:addr+64]]) + '" ,'
		addr += 66

	print ""
	print "]"
	print ")"
	print ""

if __name__ == '__main__':

	if (len(sys.argv) != 2):
		print 'usage: python boarddump.py {hack dump file}'
		sys.exit(1)

	# allocate ram array

	ram = [0] * 24577

	# read the memory dump

	lines = [line.strip() for line in open(sys.argv[1],'rU')]
	
	# parse it dumbly

	for l in lines:
		if "\t" in l:
			d = [int(i) for i in l.split("\t")]
			if (0 <= d[0]) and (d[0] <= 24576):
				ram[d[0]] = d[1]

	# dump save buffer

	dumpboard("Save Buffer-2",4500)		

	# dump save buffer

	dumpboard("Save Buffer-1",7000)		

	# dump live board

	dumpboard("Live Board",10000)
