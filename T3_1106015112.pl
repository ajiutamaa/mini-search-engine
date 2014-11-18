#!/usr/local/bin/perl

my %index = ();
open(TEST, ">test_output.txt");
$number = parse_documents();

foreach $keyDoc (keys %index){
	printf TEST "%-15s => ", $keyDoc;
	print TEST scalar(@{$index{$keyDoc}}) . " | ";
	foreach $t (@{$index{$keyDoc}}){
		if(not defined($t)){print TEST "0 ";}
		else{print TEST "$t ";}
	}
	# for($i = 0; $i < scalar(@{$index{$keyDoc}}); $i++){
		# $t = @{$index{$keyDoc}}[$i];
		# foreach $t (@{$index{$keyDoc}}){
			# if(not defined($t)){print TEST "0 ";}
			# else{print TEST "$t ";}
		# }
	# }
	print TEST "|\n";
}

query("tersangkut korupsi");
print "$number\n";
close(TEST);

# @arg: corpus
sub parse_documents
{
	open(KORPUS, "korpus_test.txt");
	
	# Documents data
	my $documentText;
	my $onDocText = 0;
	my $docNumber = 0;
	
	my %docTokens;
	
	while($line = <KORPUS>){
		if($line =~ /<DOK>/){$documentText = ""; %docTokens = ();}
		#Updating index each time iterator find </DOK> tag
		elsif($line =~ /<\/DOK>/){
			%docTokens = tokenize($documentText);
			update_index(\%docTokens, $docNumber);
			$docNumber++;
		}
		
		#Compile lines between <TEKS> tags
		if($line =~ /<TEKS>/){$onDocText = 1; next;}
		elsif($line =~ /<\/TEKS>/){$onDocText = 0;}
		
		if($onDocText){
			$line =~ s/\n/ /g;
			$documentText .= $line;
		}
	}
	return $docNumber;
}

# @arg: document
sub tokenize
{
	my ($doc) = @_;
	%words = ();

	$doc =~ s/'//g;
	$doc =~ s/[[:punct:]]/ /g;
	$doc =~ s/“/ /g;
	$doc =~ s/”/ /g;
	$doc =~ s/ [\s]* / /g;
	$doc =~ s/^\s+|\s+$|\t//g;
	$doc =~ s/\d//g;
	@docWords = split(/ /, $doc);
	foreach $w (@docWords){
		if(length($w) > 1){
			$words{lc($w)}++;
		}
	}
		
	return %words;
}

# @arg: document tokens
sub update_index
{
	my (%docTokens) = %{$_[0]};
	my ($docNumber) = $_[1];
		
	foreach $keyDoc (keys %docTokens){
		# for each term in document, update index
		if(not exists($index{$keyDoc})){
			my @new_arr = ();
			$index{$keyDoc} = \@new_arr;
			
			@{$index{$keyDoc}}[$docNumber] = $docTokens{$keyDoc};
		}
		else {
			@{$index{$keyDoc}}[$docNumber] = $docTokens{$keyDoc};
		}
	}
}

# @arg: query string
sub query
{
	my ($query_string) = $_[0];
	
	my @query_words = split(/\s/, $query_string);
	my @match = ();
	
	foreach $w (@query_words){
		if(exists($index{$w})){
			push(@match, $index{$w});
		}
	}
	
	foreach $arr (@match){
		print "------\n";
		@list = @{$arr};
		for($i = 0; $i < scalar(@list); $i++){
			print "$i: $list[$i]\n";
		}
	}
	
	# @arr = @{$index{$query}};
	# for($i = 0; $i < scalar(@arr); $i++){
		# print "$i: $arr[$i]\n";
	# }
}
