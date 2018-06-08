#!/usr/bin/bash

# Script is to align raw reads back to genome assembly
# and then get coverage in non-overlapping 1kb windows

## Change paths to ref and reads ##
ref="Falcon_Pcap.fasta"
reads="/home/greg/genome_pcap/reads/pacbio/*"
base="falcon" #Base for names of intermediate and output files
###################################

echo "Indexing"
bwa index -a bwtsw $ref
#Merge reads into one fasta file
echo "Concatenating"
cat $reads > ./merged_reads.fasta
echo "Mapping reads"
bwa mem -t 16 $ref merged_reads.fasta > aligned_$base.sam
rm merged_reads.fasta #Get rid of file with merged reads

#Convert to bam
samtools view -b -h -S aligned_$base.sam > aligned_$base.bam
rm aligned_$base.sam #Get rid of big sam file

#Filter on mapping quality
#samtools view -b -q 20 aligned_$base.bam > aligned_${base}_filter.bam
#Sort,index,print stats
samtools sort -m 100G aligned_${base}.bam aligned_${base}_sorted
samtools index aligned_${base}_sorted.bam
samtools flagstat aligned_${base}_sorted.bam > ${base}_flag_stats.txt
samtools idxstats aligned_${base}_sorted.bam > ${base}_reads_to_scaffold.txt

#Get rid of intermediate bam files
#rm aligned_$base.bam
#rm aligned_${base}_filter.bam

#Get genome coverage by site with bedtools
bedtools genomecov  -ibam aligned_${base}_sorted.bam -d -g $ref > ${base}_cov.txt
#Bin into 1kb windows
python /home/greg/genome_pcap/scripts/bin_coverage.py ${base}_cov.txt ${base}_cov_bin.txt
#Plot histogram
Rscript /home/greg/genome_pcap/scripts/plot_coverage_hist.R ${base}_cov_bin.txt




