 
#Script for getting closest match for blast results
#assumes original sequence is top hit in blast results
use warnings;

# arguments entered in: address of blast result file, num of alignments per entry, output annotation file

#check for argument count:
if(scalar @ARGV != 3) {die("Error: perl annotation results: not enough arguments");}
$blastFile = $ARGV[0];
$numAlignPerEntry = $ARGV[1];
$resultFile = $ARGV[2];

#Check arguments
if($numAlignPerEntry < 1) {die("num alignments per entry has to be 1 or greater");}
# open output annotation file
open(IN,$blastFile) or die("Error opening blast results: $blastFile");
# open final annotation file
open($out, ">>", $resultFile) or die("Error opening results file");

# BLAST RESULT FILE FORMAT:
# QSEQID SSEQID STITLE MISMATCH EVALUE PIDENT PPOS
#    0		1 		2		  3		  4		5     6

#Initialize local variables
$sortIndex=6; #index to sort arrays by (high to low)
@group = ();
$count = 1;
#$totalEntries = 0;
while($line=<IN>){
	chomp($line);
	
	# Get group of lines
	if($line ne ""){
		@values = split(/\t+/,$line);
		
		if($values[3] < 8  && @group && $count>3){
			# Analyze existing group
			$species = $1 if $group[0][2] =~ /\[([^\[\]]*)\]/; #Get query ID

			# Sort by Percent Positive (or other) and
			#	iterate over results
			foreach $entry (sort {$b->[$sortIndex] <=> $a->[$sortIndex]} @group){
				next if (@$entry[2] =~ /$species/);	
				print $out @$entry[1]."\t".@$entry[6]."\t".@$entry[2]."\n";
                #$totalEntries++;
                last;
			}
			
			# Clear variables
			@group = ();
			$count = 1;	
		}
		# Push values to new group
		push @group, [@values];
		$count++;
	}
}
# Analyze last output in file (due to logic above)

$species = $1 if $group[0][2] =~ /\[([^\[\]]*)\]/;
foreach $entry (sort {$b->[$sortIndex] <=> $a->[$sortIndex]} @group){
    next if (@$entry[2] =~ /$species/);
    print $out @$entry[1]."\t".@$entry[6]."\t".@$entry[2]."\n";# $totalEntries++;
#    print $out "Entries: ".$totalEntries."  ".$blastFile."\n";
    last;
}

close IN;
close $out;
