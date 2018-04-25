#!/usr/bin/bash

#Script is to run all steps involved in haplomerger software

#Give me an argument with the name of the folder that contains all the scripts and files for haplomerger
# (ie everything in the project_template directory that comes with HaploMerger with scripts edited as needed

set -e

######### Variables to change ################################################################################

run="run_0425" 			       					       # directory to store everything
assembly="/home/greg/genome_pcap/assemblies/1534_Phytophthora_capsici_consensus.fasta"  # path to assembly with both haplotypes present
base="falcon"    	         					       # base name for all intermediate and output files

###############################################################################################################

#If directory doesnt exist, make new directory with all necessary files from project template directory
if [ ! -d $run ]; then
        mkdir $run
	cp -r project_template_amended/* $run
fi


echo "First soft mask assembly, get alignment score matrix, and set everything up"
paste <(echo "Time is") <(date +%T)

# Put directories in PATH
export PATH=$PATH:/home/greg/genome_pcap/HaploMerger2_20161205/chainNet_jksrc20100603_ubuntu64bit
export PATH=$PATH:/home/greg/genome_pcap/HaploMerger2_20161205/lastz_1.02.00_unbuntu64bit

# Soft mask repetetive regions
./winMasker/windowmasker -checkdup true -mk_counts \
-in $assembly -out $run/masking_library.ustat -mem 250000

./winMasker/windowmasker -ustat $run/masking_library.ustat \
-in $assembly -out $run/${base}wm.fasta -outfmt fasta -dust true

############ Get alignment score matrix
cd $run

# Divide genome into two files -> one with 5% biggest contigs and one with the rest
python /home/greg/genome_pcap/scripts/split_fasta.py ${base}wm.fasta

#Use wrapper to get genome specific score matrix
../bin/lastz_D_Wrapper.pl --target=top5seq.fasta --query=bottom95seq.fasta --identity=93
tail -n 5 top5seq.bottom95seq.*.q > scoreMatrix.q

#I think the | in the headers is causing a problem
#So replace with a _
cat ${base}wm.fasta | sed 's/|/_/g' > ${base}wm1.fasta

#gzip fasta file
gzip ${base}wm1.fasta
mv ${base}wm1.fasta.gz ${base}wm1.fa.gz

############# Haplomerger

echo "Running haplomerger batch A -- fixing mis-joins"
paste <(echo "Time is") <(date +%T)

bash hm.batchA1.initiation_and_all_lastz ${base}wm1
bash hm.batchA2.chainNet_and_netToMaf ${base}wm1
bash hm.batchA3.misjoin_processing ${base}wm1

rm -r ${base}wm1.${base}wm1x.result/raw.axt #Get rid of large temporary files

#Rename log files because they will be written over when redoing batch A
mv _A1.all_lastz.log _A1.all_lastz.log1
mv _A1.initiation.log _A1.initiation.log1
mv _A2.axtChainRecipBestNet.log _A2.axtChainRecipBestNet.log1
mv _A3.faDnaPolishing.log _A3.faDnaPolishing.log1
mv _A3.misjoin_processing.log _A3.misjoin_processing.log1
mv _A3.pathFinder.log _A3.pathFinder.log1
mv _A3.pathFinder_preparation.log _A3.pathFinder_preparation.log1

echo "Do batch A again"
paste <(echo "Time is") <(date +%T)

cp ${base}wm1_A.fa.gz ${base}wm2.fa.gz

bash hm.batchA1.initiation_and_all_lastz ${base}wm2
bash hm.batchA2.chainNet_and_netToMaf ${base}wm2
bash hm.batchA3.misjoin_processing ${base}wm2

rm -r  ${base}wm2.${base}wm2x.result/raw.axt #Get rid of large temporary files

echo "Running haplomerger batch B -- reconstructing haploid sub-assemblies"
paste <(echo "Time is") <(date +%T)

bash hm.batchB1.initiation_and_all_lastz ${base}wm2_A
bash hm.batchB2.chainNet_and_netToMaf ${base}wm2_A
bash hm.batchB3.haplomerger ${base}wm2_A
bash hm.batchB4.refine_unpaired_sequences ${base}wm2_A
bash hm.batchB5.merge_paired_and_unpaired_sequences ${base}wm2_A

rm -r ${base}wm2_A.${base}wm2_Ax.result/raw.axt #Get rid of large temporary files

echo "Running haplomerger batch D -- removing tandem misassemblies"
paste <(echo "Time is") <(date +%T)

bash hm.batchD1.initiation_and_all_lastz ${base}wm2_A_ref
bash hm.batchD2.chainNet_and_netToMaf ${base}wm2_A_ref
bash hm.batchD3.remove_tandem_assemblies ${base}wm2_A_ref

rm -r ${base}wm2_A_ref.${base}wm2_A_refx.result/raw.axt #Get rid of large temporary files

