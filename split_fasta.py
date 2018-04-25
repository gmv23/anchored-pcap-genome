#!/usr/bin/py

# This sript is to take a fasta file and return two fasta files:
# One with the largest 5% of sequences
# And the other with the remainder
# Note --- will take more than 5% if there is are tied contig sizes for the fifth percentile


import sys, re, math

genome = sys.argv[1]

seq = open(genome, "r").read()

# Split on fasta headers
contigs = re.split('>.*\n',seq.strip())
contigs[:] = (contig for contig in contigs if contig != '')

# Make separate list of headers
headers = re.findall('>.*\n', seq.strip())

# Count characters in reads IGNORING newline characters
contig_sizes = [len(re.sub('\n','',contig)) for contig in contigs]
n_contigs = len(contigs)

# Get largest sequences
n_fasta1 = int(math.floor(n_contigs*.05))
largest = sorted(contig_sizes)[n_contigs-n_fasta1:n_contigs]

# Open files to write
fasta1 = open("top5seq.fasta", "w")
fasta2 = open("bottom95seq.fasta", "w")

# Loop through contig sizes and print contigs to either file depending on 
# if their size is among largest sizes
for i in range(0,n_contigs):
	size = contig_sizes[i]
	if size in largest:
		fasta1.write(headers[i] + contigs[i])
	else:
		fasta2.write(headers[i] + contigs[i])

fasta1.close()
fasta2.close()
