sub soundex {
	my ($string) = @_;

	# Kata dijadikan lowercase
	$string = lc($string);
	# Huruf pertama dijadikan uppercase
	$string = ucfirst($string);
	# Translate setiap karakter dengan aturan yang telah ditentukan
	$string =~ s/[aiueoyhw]//g;
	$string =~ s/[bfpv]/1/g;
	$string =~ s/[cgjkqsxz]/2/g;
	$string =~ s/[dt]/3/g;
	$string =~ s/[l]/4/g;
	$string =~ s/[mn]/5/g;
	$string =~ s/[r]/6/g;

	# Menghilangkan elemen sama yang berurutan
	@split = split(//,$string);
	@hasil = ();
	push(@hasil, $split[0]);
	for($i = 1; $i < scalar(@split); $i++){
		if($split[$i] != $split[$i-1]){
			push(@hasil, $split[$i]);
		}
	}

	# Melengkapi hasil yang kurang dari 4 elemen
	# Memotong hasil yang lebih dari 4 elemen
	if(scalar(@hasil) >= 4){
		@hasil = @hasil[0...3];
	}
	else{
		for($i = 0; $i <= (4 - scalar(@hasil)); $i++){
			push(@hasil, 0);
		}
	}

	return join("", @hasil);
}

1;