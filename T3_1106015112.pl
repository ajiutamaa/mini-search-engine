#!/usr/local/bin/perl

my %index = ();
open(TEST, ">test_output.txt");
# @arg: corpus
parse_documents();

foreach $key (%index){
	print TEST "$key => $index{$key}\n";
	# @arr = @{$index{$key}};
	# 
	# print TEST "$key => ";
	# for(my $i = 0; $i < scalar(@arr); $i++){
		# if(exists($arr[$i])){
			# print TEST "$arr[$i] | ";
		# }
		# else {
			# print TEST "0 | ";
		# }
	# }
	# print TEST "\n";
}

close(TEST);
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
	
	$itr = 0;
	foreach $keyDoc (keys %docTokens){
		#print TEST "$keyDoc: $docTokens{$keyDoc}\n";
		# for each term in document, update index
		if(not exists($index{$keyDoc})){
			$index{$keyDoc} = ();
		}
		@arr = ();
		@arr = @{$index{$keyDoc}};
		print TEST $keyDoc . "=>" . scalar(@arr) . "\n";
		$arr[0] = $docTokens{$keyDoc};
		print TEST $keyDoc . "=>" . scalar(@arr) . "\n";
	}
	print TEST "------------------TOT---------------------\n";	
}
