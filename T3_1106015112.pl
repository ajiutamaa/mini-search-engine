#!/usr/local/bin/perl
require("module_stemming.pl");
require("module_soundex.pl");

my %index = ();
my %index_title = ();

my %docs_no = ();
my %docs_title = ();

my @docs_number = ();

open(TEST, ">test_output_title.txt");
open(TEST2, ">test_output_document.txt");

my $num_of_docs = index_korpus();
print "READY!\n";
#--------------------------DEBUG---------------------------------
# print TEST "--------------TITLE INDEX----------------\n";	#
# foreach $keyDoc (keys %index_title){				#
	# printf TEST "%-15s => ", $keyDoc;			#
	# print TEST scalar(@{$index_title{$keyDoc}}) . " | ";	#
	# foreach $t (@{$index_title{$keyDoc}}){			#
		# if(not defined($t)){print TEST "0 ";}		#
		# else{print TEST "$t ";}				#
	# }							#
	# print TEST "|\n";					#
# }								#
# print TEST2 "--------------DOCUMENTS INDEX----------------\n";	#
# foreach $keyDoc (keys %index){					#
	# printf TEST2 "%-15s => ", $keyDoc;			#
	# print TEST2 scalar(@{$index{$keyDoc}}) . " | ";		#
	# foreach $t (@{$index{$keyDoc}}){			#
		# if(not defined($t)){print TEST2 "0 ";}		#
		# else{print TEST2 "$t ";}			#
	# }							#
	# print TEST2 "|\n";					#
# }								#
#----------------------------------------------------------------
close(TEST);

while($_ = <>){
	query($_);
}

# @arg: corpus
sub index_korpus
{
	open(KORPUS, "korpus.txt");
	
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
			$line =~ s/<JUDUL>//g;
			$line =~ s/<\/JUDUL>//g;
			$line =~ s/^\s+|\s+$|\t//g;
			
			$docs_title{$docNumber} = $line;
			
			%titleTokens = tokenize($line);
			update_title_index(\%titleTokens, $docNumber);
		}
		
		if($line =~ /<NO>/){
			$line =~ s/<NO>//g;
			$line =~ s/<\/NO>//g;
			$line =~ s/^\s+|\s+$|\t//g;
			$docs_no{$docNumber} = $line;
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

# @arg: documents title word tokens
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
	
	$query_string = lc($query_string);
	
	# expand query with stemmed words
	$query_string = expand_query($query_string);
	
	my @query_words = split(/\s/, $query_string);
	# contains vector of particular word tf in documents
	my %document_match = ();
	# contains vector of particular word tf in titles
	my %title_match = ();
	
	my @match_list = ();
	
	foreach $w (@query_words){
		my $distinct_word = $w;
		if(not exists($index{$w}) and not exists($index_title{$distinct_word})){
			$w_soundex = soundex($distinct_word);
			foreach $keyword ((keys %index), (keys %index_title)){
				$keyword_soundex = soundex($keyword);
				if($keyword_soundex eq $w_soundex){
					$distinct_word = $keyword;
					next;
				}
			}
		}
		
		if(exists($index{$distinct_word})){
			my @hasil = @{$index{$distinct_word}};
			#print "query: \"$distinct_word\" DOCUMENT: ADA";
			# foreach $h (@hasil){
				# if(defined($h)){print " $h ";}
				# else {print " 0 ";}
			# }
			# print "\n";
			$document_match{$distinct_word} = $index{$distinct_word};
		}
		if(exists($index_title{$distinct_word})){
			my @hasil = @{$index_title{$distinct_word}};
			#print "query: \"$distinct_word\" TITLE ADA";
			# foreach $h (@hasil){
				# if(defined($h)){print " $h ";}
				# else {print " 0 ";}
			# }
			# print "\n";
			$title_match{$distinct_word} = $index_title{$distinct_word};
		}
	}
	print "------------------------------HASIL--------------------------------------------\n";
	for($i = 0; $i < $num_of_docs; $i++){
		my $match = 0;
		
		my $tf_title = 0;
		my $tf_doc = 0;
		
		foreach $w (keys %document_match){
			$freq = @{$document_match{$w}}[$i];
			if(defined($freq)){
				$match = 1;
				$tf_doc += $freq;
			}
		}
		foreach $w (keys %title_match){
			$freq = @{$title_match{$w}}[$i];
			if(defined($freq)){
				$match = 1;
				$tf_title += $freq;
			}
		}
		if($match){
			$scoring = 0.6 * $tf_title + 0.4 * $tf_doc;
			my @tuple = ();
			$tuple[0] = $i;
			$tuple[1] = $scoring;
			push(@match_list, \@tuple);
			#print "Dokumen $docs_no{$i}, tf_t: $tf_title, tf_doc: $tf_doc, score: $scoring\n";
		}
	}
	
	@match_list = sort {@{$b}[1] cmp @{$a}[1]} @match_list;
	
	$counter = 0;
	foreach $m (@match_list){
		my @tuple = @{$m};
		print $counter . "\t" . $docs_no{$tuple[0]} . "\t" . $docs_title{$tuple[0]} . "\tScore: $tuple[1]\n"; 
		$counter++;
	}
	print "-------------------------------------------------------------------------------\n";
}

# @arg: initial query
sub expand_query
{
	my ($query_string) = $_[0];
	
	@words = split(/\s/, $query_string);
	@expanded = ();
	
	foreach $w (@words){
		$stemmed = stem($w);
		push(@expanded, $stemmed);
		#push(@words, $stemmed);
	}

	print join(" ", (@words, @expanded)) . "\n";
	return join(" ", (@words, @expanded));
}