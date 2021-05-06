#!/usr/bin/perl -w

use strict;
use List::Util qw(shuffle); # docstore.mik.ua/orelly/perl4/cook/ch04_19.htm

my $usage = " USAGE: iBPPwrapper.pl [paramsFile]";
die $usage unless $#ARGV == 0;

open(PAR,$ARGV[0]) or die " ERROR: Could not open params file $ARGV[0]\n";

#PARAMETROS
my $rscript;
my $baseCtlFile;
my @alg0e;
my @alg1a;
my @alg1m;
my $sampfreqMultiplier;
my $maxRuns;
my $output;
my $goodESS;
my $path_ibpp;

my $paramsCount = 0;
while(my $line = <PAR>){

	if($line =~ /^rscript\s*=\s*(\S+)\s*;/){
		$rscript = $1;
		$paramsCount++;
	}
	if($line =~ /^baseCtlFile\s*=\s*(\S+)\s*;/){
		$baseCtlFile = $1;
		$paramsCount++;
	}
	if($line =~ /^alg0e\s*=\s*([\d,\s]+);/){
		my $nums = $1;
		$nums =~ s/\s+//g;
		@alg0e = split(/,/,$nums);
		$paramsCount++;
	}
	if($line =~ /^alg1a\s*=\s*([\d,\s\.]+);/){
		my $nums = $1;
		$nums =~ s/\s+//g;
		@alg1a = split(/,/,$nums);
		$paramsCount++;
	}	
	if($line =~ /^alg1m\s*=\s*([\d,\s\.]+);/){
		my $nums = $1;
		$nums =~ s/\s+//g;
		@alg1m = split(/,/,$nums);
		$paramsCount++;
	}
	if($line =~ /^sampfreqMultiplier\s*=\s*(\d+)\s*;/){
		$sampfreqMultiplier = $1;
		$paramsCount++;
	}
	if($line =~ /^maxRuns\s*=\s*(\d+)\s*;/){
		$maxRuns = $1;
		$paramsCount++;
	}
	if($line =~ /^output\s*=\s*(\S+)\s*;/){
		$output = $1;
		$paramsCount++;
	}
	if($line =~ /^goodESS\s*=\s*(\d+)\s*;/){
		$goodESS = $1;
		$paramsCount++;
	}
	if($line =~ /^path_ibpp\s*=\s*(\S+)\s*;/){
		$path_ibpp = $1;
		$paramsCount++;
	}
}

if($paramsCount != 10){
	die " ERROR: there something wrong with the paramsFile $ARGV[0]\n 10 parameters were expected but $paramsCount were found instead\n";
}


#LEITURA DO BASECTLFILE
$/ = "";
open(BASE,$baseCtlFile) or die " ERROR: Could not open base control file $baseCtlFile\n";
my $baseCtlText = <BASE>;
close(BASE);
$/ = "\n";

my $seqfile;
my $burnin;
my $sampfreq;
my $nsample;
my $nLoci;
my $outfile;
my $mcmcfile;

if($baseCtlText =~ /\s*seqfile\s*=\s*(\S+)/){
	$seqfile = $1;
}
else{
	die " ERROR: seqfile name not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*outfile\s*=\s*(\S+)/){
	$outfile = $1;
}
else{
	die " ERROR: outfile name not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*mcmcfile\s*=\s*(\S+)/){
	$mcmcfile = $1;
}
else{
	die " ERROR: mcmcfile name not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*Imapfile\s*=\s*(\S+)/){
	$baseCtlText =~ s/(\s*Imapfile\s*=\s*)(\S+)/$1\.\.\/$2/;
}
else{
	die "ERROR: Imapfile name not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*traitfile\s*=\s*(\S+)/){
	$baseCtlText =~ s/(\s*traitfile\s*=\s*)(\S+)/$1\.\.\/$2/;
}
else{
	die "ERROR: traitfile name not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*burnin\s*=\s*(\d+)/){
	$burnin = $1;
}
else{
	die "ERROR: burnin value not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*sampfreq\s*=\s*(\d+)/){
	$sampfreq = $1;
}
else{
	die "ERROR: sampfreq value not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*nsample\s*=\s*(\d+)/){
	$nsample = $1;
}
else{
	die "ERROR: nsample value not found in $baseCtlFile\n";
}
if($baseCtlText =~ /\s*nloci\s*=\s*(\d+)/){
	$nLoci = $1;
}
else{
	die "ERROR: nloci value not found in $baseCtlFile\n";
}

#LEITURA DO SEQSFILE
my @loci = ();
open(SEQS,$seqfile) or die " ERROR: Could not open SEQFILE $seqfile\n";
my $locus = "";
while(my $line = <SEQS>){
	if($line =~ /^\s*\d+\s+\d+\s*$/){
# 		print "$line";
		if($locus !~ /\w/){
			$locus = $line;
		}
		else{
			push(@loci,$locus);
			$locus = $line;
		}
	}
	else{
		$locus .= $line;
	}
}
push(@loci,$locus);
close SEQS;

#EXECUÇÃO
open(OF,">$output") or die;
print OF "#run\talgorithm\tburnin\tsampfreq\tinitialSppTree\tfinalSppTree\tworstESS\n";
printf("%s %15s %10s %10s %20s %15s %10s\n","#run","algorithm","burnin","sampfreq","initialSppTree","finalSppTree","worstESS");

for(my $run=0;$run<$maxRuns;$run++){
	
	my $alg = shuffle((0,1));
	if($alg == 0){
		my $e = shuffle(@alg0e);
		$alg = "0 $e";
		$baseCtlText =~ s/.*speciesdelimitation.*/speciesdelimitation = 1 $alg/;
	}
	else{
		my $a = shuffle(@alg1a);
		my $m = shuffle(@alg1m);
		$alg = "1 $a $m";
		$baseCtlText =~ s/.*speciesdelimitation.*/speciesdelimitation = 1 $alg/;
	}
	
# 	print "$run\t$alg\t$burnin\t$sampfreq\n";
	
	mkdir("run$run") or die " ERROR: Could not create directory run$run\n" if(!-d "run$run");
	
	open(CTL,">run$run/ibpp.ctl") or die " ERROR: Could not create file run$run/ibpp.ctl\n";
	print CTL $baseCtlText;
	close CTL;
	
	my @randLoci = shuffle(@loci);

	my @seqs = @randLoci[0..($nLoci-1)];
	
	open(SEQS,">run$run/$seqfile") or die " ERROR: Could not create file run$run/$seqfile\n";
	print SEQS "@seqs";
	close SEQS;
	
	chdir "run$run";
	my $stdout = `$path_ibpp ibpp.ctl 2> stderr`;
	my $initial = "NA";
	if($stdout =~ /Starting species tree = (\d+)/){
		$initial = $1;
	}
	
	open(OUT,$outfile) or die " ERROR: Could not open OUTFILE run$run/$outfile\n";
	my $sppTree;
	while(my $line = <OUT>){
		if($line =~ /Summarizing the posterior of parameters under the MAP tree (\d+)/){
			$sppTree = $1;
		}
	}
	close OUT;
	
	open(MCMC,$mcmcfile) or die " ERROR:  Could not open MCMCFILE run$run/$mcmcfile\n";
	open(TEMP,">tempmcmc.txt") or die " ERROR: Could not create tempmcmc.txt\n";
	while(my $line = <MCMC>){
		if($line =~ /^\d/){
			my @splitLine = split(/\t/,$line);
# 			print "TESTE: $sppTree $splitLine[2]\n";
			my $sp = $splitLine[2];
			$sp =~ s/\s//g;
			if($sp eq $sppTree){
				print TEMP $line;
			}
		}
	}
	close MCMC;
	close TEMP;
	
	my $tracer = `run_ibpp_ESS.R tempmcmc.txt`;
	my @tracerSplit = split(/\s+/,$tracer);
	my $melhorBurninStep = $tracerSplit[0];
	my $menorESS = $tracerSplit[1];
	
	chdir "..";
	
	print OF "$run\t$alg\t$burnin\t$sampfreq\t$initial\t$sppTree\t$menorESS\n";
	printf("%4s %15s %10s %10s %20s %15s %10d\n",$run,$alg,$burnin,$sampfreq,$initial,$sppTree,$menorESS);
	
	$burnin += ($melhorBurninStep-1) * $sampfreq;
	$baseCtlText =~ s/.*burnin.*/ burnin = $burnin/;
	
	if($menorESS < $goodESS and $menorESS > 1){
# 		$sampfreq *= $sampfreqMultiplier;
		$sampfreq *= $sampfreqMultiplier;
		$baseCtlText =~ s/.*sampfreq.*/ sampfreq = $sampfreq/;
	}
}
close OF;
