#!/usr/bin/py

# The goal of this script is to take a list of contig sizes
# and the output of blasting the assembly to a database of bacterial genomes
# and return the percentage of nucleotides of each contig that match a bacterial genome

cov_stats = "/home/greg/genome_pcap/get_coverage/falcon_wm22_coverage/coverage_stats.txt"
blast_results = "/home/greg/genome_pcap/contamination/test3_out.txt"

#First let's make dictionary of contig sizes

fh = open(cov_stats, "r")
fh.readline()
contig_sizes = {}
for line in fh:
	line = line.strip().split("\t")
	[contig,size] = line[0:2]
	contig_sizes[contig] = size
fh.close()

#Now let's make a dictionary collection of the nucleotides for each scaffold that match bacteria

contig_matches = {key:[] for key in contig_sizes.keys()}

fh = open(blast_results, "r")
for line in fh:
	line = line.strip().split("\t")
	[contig, start, stop, e] = [line[0], int(line[6]), int(line[7]), float(line[10])]
	if e < 10e-5:
		for pos in range(start, stop+1):
			if pos not in contig_matches[contig]:
				contig_matches[contig].append(pos)
fh.close()

#Print results

for contig in contig_sizes.keys():
	print contig + "\t" + contig_sizes[contig] + "\t" + str(round(len(contig_matches[contig])/float(contig_sizes[contig]),2))
