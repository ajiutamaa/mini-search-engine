#!/usr/local/bin/perl

my %index = ();
my %index_title = ();

open(TEST, ">test_output.txt");
index_korpus();

foreach $keyDoc (keys %index_title){
	printf TEST "%-15s => ", $keyDoc;
	print TEST scalar(@{$index_title{$keyDoc}}) . " | ";
	foreach $t (@{$index_title{$keyDoc}}){
		if(not defined($t)){print TEST "0 ";}
		else{print TEST "$t ";}
	}
	print TEST "|\n";
}

query("tersangkut korupsi");

close(TEST);

# @arg: corpus
sub index_korpus
{
	open(KORPUS, "korpus_test.txt");
	
	# Documents data
	my $documentText;
	my $onDocText = 0;
	my $docNumber = 0;
	
	my %docTokens;
	my %titleTokens;
	
	while($line = <KORPUS>){
		if($line =~ /<DOK>/){$documentText = ""; %docTokens = ();}
		#Updating index each time iterator find </DOK> tag
		elsif($line =~ /<\/DOK>/){
			%docTokens = tokenize($documentText);
			update_index(\%docTokens, $docNumber);
			$docNumber++;
		}
		
		#Add title lines to document text to be computed
		if($line =~ /<JUDUL>/){
			%titleTokens = tokenize($line);
			update_title_index(\%titleTokens, $docNumber);
		}
		
		#Compile lines between <TEKS> tags
		if($line =~ /<TEKS>/){$onDocText = 1; next;}
		elsif($line =~ /<\/TEKS>/){$onDocText = 0;}
		
		if($onDocText){
			$line =~ s/\n/ /g;
			$documentText .= $line;
		}
	}
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

sub update_title_index
{
	my (%titleTokens) = %{$_[0]};
	my ($docNumber) = $_[1];
	
	foreach $keyTitle (keys %titleTokens){
		# for each term in document title, update title index
		if(not exists ($index_title{$keyTitle})){
			my @new_arr = ();
			$index_title{$keyTitle} = \@new_arr;
			
			@{$index_title{$keyTitle}}[$docNumber] = $titleTokens{$keyTitle};
		}
		else {
			@{$index_title{$keyTitle}}[$docNumber] = $titleTokens{$keyTitle};
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
	
	
	
	# @arr = @{$index{$query}};
	# for($i = 0; $i < scalar(@arr); $i++){
		# print "$i: $arr[$i]\n";
	# }
}
