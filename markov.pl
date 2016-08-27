# markov.pl: markov chain algorithm for 2-word prefixes

$MAXGEN = 1000;
$NONWORD = "\n";

$w1 = $w2 = $NONWORD;
while (<>) {  # read each line of input
    foreach(split) {  # for each field of a line
        push(@{$statetab{$w1}{$w2}}, $_);  # $_: the field
        ($w1, $w2) = ($w2, $_); # multiple assignment
    }
}
push(@{$statetab{$w1}{$w2}}, NONWORD);

$w1 = $w2 = $NONWORD;
for ($i = 0; $i < $MAXGEN; $i++) {
    $suf = $statetab{$w1}{$w2}; # array reference
    $idx = int(rand @$suf);     # @$suf: array length
    exit if (($w = $suf->[$idx]) eq $NONWORD);
    print "$w ";
    ($w1, $w2) = ($w2, $w);
}
print "\n";
