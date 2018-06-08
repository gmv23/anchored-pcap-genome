#!/usr/bin/env Rscript

library(plotrix)
library(vioplot)

cov_file <- commandArgs(trailingOnly=TRUE)[1]
base <- gsub("_cov_bin.txt", "", cov_file)
cov <- read.table(cov_file, header=F)

pdf(paste(base,"_read_coverage_dist.pdf", sep = ""))
weighted.hist(cov$V4, cov$V3-cov$V2, xlim=c(0,100), breaks=15000,
		xlab = "Read depth",
		main = "Distribution of read depth in 1kb bins")

#for(v in c(12,48,100)){
#	abline(v = v, col = "red")
#}

dev.off()

