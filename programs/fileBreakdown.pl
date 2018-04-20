#Script for splitting .faa into smaller files
use warnings;

###OPEN FILE###
# arguments entered in: ftp address of genome, number of sequences_ per file
# PWD has to be finalProject folder (not programs folder)

#check for argument count:
if(scalar @ARGV != 2) {die("Error: perl file splitter: not enough arguments");}
$GenomeLink = $ARGV[0];
$numSeqPerFile = $ARGV[1];
#Check arguments
if($numSeqPerFile < 1) {die("num sequences per file has to be 1 or greater");}

########
#Download file and unzip
system("wget -O ./programs/completeGenome.faa.gz $GenomeLink"); # assumes is valid ftp link
system("gunzip -f  ./programs/completeGenome.faa.gz"); # unzip -removes .gz

#Check if it exists
open(IN,"./programs/completeGenome.faa") or die("Error:Downloaded genome.faa could not be opened");

########
#Initialize local variables
$currCount = 9999; #currCount tracks number of sequences per file
$fileCount = 1; #current file number for naming
$ready = -1; #if an output file exists (used to start initial output)

#Read in file and write to new files
while($line=<IN>){
	chomp($line);
	if(substr($line,0,1) eq(">")){
		#Create new file with ID (first word) as name
		if($currCount >= $numSeqPerFile){ #create new file if number of sequences is at the limit
			open($out, ">", "./assembly/splitFile".$fileCount) or die("Error creating split file");
			$fileCount++;	$currCount = 0; $ready = 1; #set variables
		}
		print $out "\n$line \n";
		$currCount++;
	}
	elsif($line ne "" && $ready){
		#Add line to output file on same line
		print $out $line;
	}
}
close IN;

#ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/325/GCF_000027325.1_ASM2732v1/GCF_000027325.1_ASM2732v1_protein.faa.gz
