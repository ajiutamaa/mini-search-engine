#!/usr/local/bin/perl

# @arg: corpus
sub index_documents
{
	
}

# @arg: document
sub tokenize
{
	my ($document) = @_;
	%words = ();
	$onDocText = 0;
	my @lines = split(/\n/, $document);
	foreach $line (@lines){
		if($line !~ /TEKS>/ && $line !~ /DOK>/ && $line !~ /JUDUL>/ && $line !~ /NO>/){		
			$line =~ s/'//g;
			$line =~ s/[[:punct:]]/ /g;
			$line =~ s/ [\s]* / /g;
			$line =~ s/\d//g;
			@lineWords = split(/ /, $line);
			foreach $w (@lineWords){
				if(length($w) > 1){
					$words{lc($w)}++;
				}
			}
		}
	}	
	return keys %words;
}