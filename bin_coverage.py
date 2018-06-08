#!/usr/bin/python

#Take per base coverage as returned by bedtools and average it into non-overlapping windows
#This script takes some time to run, there is probably a more efficient way to do this

import sys

cov_file, out_file = sys.argv[1::]

window_size = 1000

fh = open(cov_file, "r")

cov_bins = []
scaffolds = []
window_covs = []

for line in fh:
	line = line.strip().split("\t")
	scaffold, bp, cov  = line
	if scaffold not in scaffolds:
		print "Working on chromosome: " + scaffold
		window = [0,window_size]
		scaffolds.append(scaffold)
		if len(scaffolds) != 0 and len(window_covs) != 0:
			last_window.append(float(sum(window_covs))/len(window_covs))
			cov_bins.append(last_window)
	window_covs.append(int(cov))
	if window[1] == int(bp):
		cov_info = [scaffold,window[0]+1,window[1],float(sum(window_covs))/len(window_covs)]
		window_covs = []
		window = [pos + window_size for pos in window]
		cov_bins.append(cov_info)
	last_window = [scaffold, window[0]+1, bp]
fh.close()		

out = open(out_file, "w")
for line in cov_bins:
	out.write("\t".join([str(x) for x in line]) + "\n")
out.close()
		

