#!/usr/bin/python

# Goal of this script is to get:
#  mean coverage for each contig
#  percent bases low, haploid, diploid, high for each contig
#  contig size

import sys

[in_file, out_file, low, mid, high] = sys.argv[1::]
[low, mid, high] = [int(x) for x in [low, mid, high]]

def get_range(x, low, mid, high):
	if x < low:
		return 0
	elif x >= low and x < mid:
		return 1
	elif x >= mid and x < high:
		return 2
	elif x >= high:
		return 3
fh = open(in_file, "r")

scaffold_info = {}

for line in fh:
	line = line.strip().split("\t")
	scaffold = line[0]
	cov = int(line[2])
	if scaffold not in scaffold_info.keys():
		scaffold_info[scaffold] = [[cov],0,0,0,0]
		scaffold_info[scaffold][get_range(cov,low,mid,high)+1] += 1
	else:
		scaffold_info[scaffold][0].append(cov)
		scaffold_info[scaffold][get_range(cov,low,mid,high)+1] += 1

fh.close()
out = open(out_file, "w")
out.write("\t".join(["scaffold", "size", "mean", "low", "haploid", "diploid", "high"]) + "\n")


for scaffold in scaffold_info.keys():
	size = len(scaffold_info[scaffold][0])
	total = sum(scaffold_info[scaffold][0])
	[low,hap,dip,high] = scaffold_info[scaffold][1::]
	out.write("\t".join([str(scaffold), str(size)]))
	out.write("\t" + "\t".join([str(x/float(size)) for x in [total, low, hap, dip, high]]) + "\n")
