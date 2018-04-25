#!/usr/bin/bash

# Script is to align raw reads back to genome assembly
# and then get coverage in non-overlapping 1kb windows

## Change paths to ref and reads ##
ref="/home/greg/genome_pcap/pacbio/HaploMerger2_20161205/run_0326/canu1wm_A_ref.fa"
reads="/home/greg/genome_pcap/pacbio/reads/*"
base="pb_filter"
###################################

echo "Indexing"
bwa index -a bwtsw $ref
echo "Concatenating"
cat $reads > ./merged_reads.fasta
echo "Mapping reads"
bwa mem -t 16 $ref merged_reads.fasta > aligned_$base.sam

#Convert to bam
samtools view -b -h -S aligned_pb.sam > aligned_$base.bam #Change pb to base
#Filter on mapping quality
samtools view -b -q 20 aligned_$base.bam > aligned_${base}_filter.bam
#Sort,index,print stats
samtools sort -m 100G aligned_${base}_filter.bam aligned_${base}_sorted
samtools index aligned_${base}_sorted.bam
samtools flagstat aligned_${base}_sorted.bam > ${base}_flag_stats.txt
samtools idxstats aligned_${base}_sorted.bam > ${base}_reads_to_scaffold.txt


#Get genome coverage by site with bedtools
bedtools genomecov  -ibam aligned_${base}_sorted.bam -d -g $ref > ${base}_cov.txt
python bin_coverage.py ${base}_cov.txt > $(base)_cov_bin.txt





