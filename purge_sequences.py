#!/usr/bin/py

#Give me a file of sequences to remove from a fasta file
#and the fasta file
#and I'll return a new fasta file without those sequences

import sys, os

#Get arguments
[fasta_file, seq_ids, out_file] = sys.argv[1::]

#Make list of sequences that should be removed
purge_seqs = []
fh = open(seq_ids, "r")
for line in fh:
	line = line.strip()
	purge_seqs.append(line)
fh.close()

#Get number of lines of fasta file
systemcall = 'wc -l %s > tmp' %fasta_file
os.system(systemcall)
fasta_nl = int(open('tmp', 'r').read().strip().split(" ")[0])
os.system('rm tmp')

#Go through fasta file line by line
fh = open(fasta_file, "r")
out = open(out_file, "w")

add = True #Toggle this variable based on sequence ID

for i in range(0, fasta_nl):
	line = fh.readline()
	line = line.strip()
	if line[0] == ">":
		if line[1::] in purge_seqs:
			add = False
		else:
			add = True
	if add:
		out.write(line + "\n")
fh.close()
out.close()
		

	
