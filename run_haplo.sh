#!/usr/bin/bash

#Script is to run all steps involved in haplomerger software

#Give me an argument with the name of the folder that contains all the scripts and files for haplomerger
# (ie everything in the project_template directory that comes with HaploMerger with scripts edited as needed

run=$1
set -e

echo "First soft mask assembly, get alignment score matrix, and set everything up"
paste <(echo "Time is") <(date +%T)

# Put directories in PATH
PATH=$PATH:/home/greg/genome_pcap/pacbio/HaploMerger2_20161205/chainNet_jksrc20100603_ubuntu64bit
PATH=$PATH:/home/greg/genome_pcap/pacbio/HaploMerger2_20161205/lastz_1.02.00_unbuntu64bit

# Soft mask repetetive regions
./winMasker/windowmasker -checkdup true -mk_counts \
-in ../canu_assembly/assembly1/canu.contigs.fasta -out $run/masking_library.ustat -mem 250000

./winMasker/windowmasker -ustat $run/masking_library.ustat \
-in ../canu_assembly/assembly1/canu.contigs.fasta -out $run/canu1wm.fasta -outfmt fasta -dust true

############ Get alignment score matrix
cd $run

# Divide genome into two files -> one with 5% biggest contigs and one with the rest
python /home/greg/genome_pcap/scripts/split_fasta.py canu1wm.fasta

#Use wrapper to get genome specific score matrix
../bin/lastz_D_Wrapper.pl --target=top5seq.fasta --query=bottom95seq.fasta --identity=93
tail -n 5 top5seq.bottom95seq.*.q > scoreMatrix.q

#gzip fasta file
gzip canu1wm.fasta
mv canu1wm.fasta.gz canu1wm.fa.gz

############# Haplomerger

echo "Running haplomerger batch A -- fixing mis-joins"
paste <(echo "Time is") <(date +%T)

bash hm.batchA1.initiation_and_all_lastz canu1wm
bash hm.batchA2.chainNet_and_netToMaf canu1wm
bash hm.batchA3.misjoin_processing canu1wm

echo "Do batch A again"
paste <(echo "Time is") <(date +%T)

bash hm.batchA1.initation_and_all_lastz canu1wm_A
bash hm.batchA2.chainNet_and_netToMaf canu1wm_A
bash hm.batchA3.misjoin_processing canu1wm_A

echo "Running haplomerger batch B -- reconstructing haploid sub-assemblies"
paste <(echo "Time is") <(date +%T)

bash hm.batchB1.initiation_and_all_lastz canu1wm_A_A
bash hm.batchB2.chainNet_and_netToMaf canu1wm_A_A
bash hm.batchB3.haplomerger canu1wm_A_A
bash hm.batchB4.refine_unpaired_sequences canu1wm_A_A
bash hm.batchB5.merge_paired_and_unpaired_sequences canu1wm_A_A

echo "Running haplomerger batch D -- removing tandem misassemblies"
paste <(echo "Time is") <(date +%T)

bash hm.batchD1.initiation_and_all_lastz canu1wm_A_A_ref
bash hm.batchD2.chainNet_and_netToMaf canu1wm_A_A_ref
bash hm.batchD3.remove_tandem_assemblies canu1wm_A_A_ref
