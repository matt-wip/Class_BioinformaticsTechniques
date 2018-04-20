#!/bin/sh
####################################################
# Final Project Script
# Matthew Wipfler 12/8/17

# Run on HPC Head Node with this finalProject as the PWD
####################################################

# Target genome file (can be anything!)
#ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/325/GCF_000027325.1_ASM2732v1/GCF_000027325.1_ASM2732v1_protein.faa.gz
file="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/325/GCF_000027325.1_ASM2732v1/GCF_000027325.1_ASM2732v1_protein.faa.gz"
entriesPerFile=10;

# Download file, uncompress, split into X chunks
perl ./programs/fileBreakdown.pl ${file} $entriesPerFile

# Check number of files in folder (should be > 0). //todo: have better check
fileCount=$(ls ./assembly/ | wc -l)
if [ $fileCount -gt 1 ]
	then	
	echo "Download of genome complete";
else
	echo "Error downloading file. Exiting script";
	exit 1;
fi

# Submit arrayjob to HPC -> run blast, get results
# Wait for all jobs in arrayjob to be completed 
#hold_jid=$(qsub -terse -t 1-2 runOne.job | awk -F. '{print $1}')
hold_jid=$(qsub -terse -t 1-$fileCount runblast.job | awk -F. '{print $1}')

# Process BLAST results
qsub -hold_jid $hold_jid analyzeResults.job


#(d) Both a version of the BLAST executables and the RefSeq protein database are provided for you on the HPC in the directory
# /Shared/class-BME5320-dkristensen/

#SGE_TASK_ID=1
#blastpath="/usr/css/opt/ncbi-blast-2.5.0+/"
#"${blastpath}bin/blastp" -db "${blastpath}database/refseq_protein" -out ./results/newSplit$SGE_TASK_ID -query ./assembly/smallFile$SGE_TASK_ID -outfmt "6 qseqid sseqid stitle mismatch evalue pident ppos" -num_alignments 20

#SGE_TASK_ID=2
#"${blastpath}bin/blastp" -db "${blastpath}database/refseq_protein" -out ./results/newSplit$SGE_TASK_ID -query ./assembly/smallFile$SGE_TASK_ID -outfmt "6 qseqid sseqid stitle mismatch evalue pident ppos" -num_alignments 20
