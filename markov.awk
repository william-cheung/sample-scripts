# markov.awk: markov chain algorithm for 2-word prefixes

BEGIN {
	MAXGEN = 1000; NOWORD = "\n"; w1 = w2 = NOWORD
}

{
	for (i = 1; i <= NF; i++) {
		statetab[w1, w2, ++nsuffix[w1, w2]] = $i
		w1 = w2; w2 = $i
	}
}

END {
	statetab[w1, w2, ++nsuffix[w1, w2]] = NOWORD
	w1 = w2 = NOWORD
	for (i = 0; i < MAXGEN; i++) {
		r = int(rand() * nsuffix[w1, w2]) + 1
		w = statetab[w1, w2, r]
		if (w == NOWORD)
			exit
		print w
		w1 = w2; w2 = w
	}
}
