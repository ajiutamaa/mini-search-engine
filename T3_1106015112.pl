#!/usr/local/bin/perl

my %index = ();
open(TEST, ">test_output.txt");
# @arg: corpus
parse_documents();

# foreach $key (keys %index){
	# print TEST "$key => ". scalar(@{$index{$key}}) . " => ";
	# 
	# foreach $i (@{$index{$key}}){
		# print TEST "$i,",
	# }
	#@arr = @{$index{$key}};
	# 
	# print TEST "$key => ";
	# for(my $i = 0; $i < scalar(@arr); $i++){
		# if(exists(@{$index{$key}}[$i])){
			# print TEST "@{$index{$key}}[$i] | ";
		# }
		# else {
			# print TEST "0 | ";
		# }
	# }
	# print TEST "\n";
# }

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
	print TEST "----------------$docNumber---------------------\n";
	foreach $keyDoc (keys %docTokens){
		# for each term in document, update index
		if(not exists($index{$keyDoc})){
			@new_arr = ();
			$index{$keyDoc} = \@new_arr;
			
			@{$index{$keyDoc}}[$docNumber] = $docTokens{$keyDoc};
			print TEST "$keyDoc => BARU => ";
			foreach $t (@{$index{$keyDoc}}){
				if(not defined($t)){print TEST "0,";}
				else{print TEST "$t,";}
			}
			print TEST "\n";
			#print TEST "@{$index{$keyDoc}}\n";
		}
		else {
			print TEST "$keyDoc => SEBELUM => ";
			foreach $t (@{$index{$keyDoc}}){
				if(not defined($t)){print TEST "0,";}
				else{print TEST "$t,";}
			}
			print TEST " SESUDAH => ";
			@{$index{$keyDoc}}[$docNumber] = $docTokens{$keyDoc};
			foreach $t (@{$index{$keyDoc}}){
				if(not defined($t)){print TEST "0,";}
				else{print TEST "$t,";}
			}
			print TEST "\n";
		}
		#print TEST $keyDoc . " => freq => $docTokens{$keyDoc}\n";
		
		#print TEST $keyDoc . " => array => " . @{$index{$keyDoc}}[$docNumber] . " \n";
	}
	
	print TEST "------------------TOT---------------------\n";
}
