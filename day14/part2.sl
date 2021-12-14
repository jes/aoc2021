include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var template = malloc(128);

bgets(in, template, 128);
template[strlen(template)-1] = 0;

var map = malloc(10);
var i = 0;
while (i < 10) {
	map[i] = malloc(10);
	memset(map[i], -1, 10);
	i++;
};

var letterch = malloc(10);
var nletters = 0;
var letter = func(c) {
	var i = 0;
	while (i < nletters) {
		if (letterch[i] == c) return i;
		i++;
	};
	letterch[nletters] = c;
	return nletters++;
};

var left;
var right;
var replace;
while (bscanf(in, " %c%c -> %c", [&left, &right, &replace])) {
	map[letter(left)][letter(right)] = letter(replace);
};

var args = cmdargs()+1;
var nlevels = 40;
if (*args) nlevels = atoi(*args);

var countpair = malloc(10);
var newcountpair = malloc(10);
i = 0;
var j = 0;
while (i < 10) {
	countpair[i] = malloc(10);
	newcountpair[i] = malloc(10);
	j = 0;
	while (j < 10) {
		countpair[i][j] = bignew(0);
		newcountpair[i][j] = bignew(0);
		j++;
	};
	i++;
};

i = 0;
var l;
var r;
while (template[i+1]) {
	l = letter(template[i]);
	r = letter(template[i+1]);
	bigaddw(countpair[l][r], 1);
	i++;
};

var m;
var p;

while (nlevels--) {
	i = 0;
	while (i < 10) {
		j = 0;
		while (j < 10) {
			bigsetw(newcountpair[i][j], 0);
			j++;
		};
		i++;
	};

	l = 0;
	while (l < nletters) {
		r = 0;
		while (r < nletters) {
			m = map[l][r];
			bigadd(newcountpair[l][m], countpair[l][r]);
			bigadd(newcountpair[m][r], countpair[l][r]);
			r++;
		};
		l++;
	};
	
	p = newcountpair;
	newcountpair = countpair;
	countpair = p;
};

var count = malloc(10);
i = 0;
while (i < 10) {
	count[i] = bignew(0);
	i++;
};

l = 0;
while (l < nletters) {
	r = 0;
	while (r < nletters) {
		bigadd(count[l], countpair[l][r]);
		bigadd(count[r], countpair[l][r]);
		r++;
	};
	l++;
};

l = letter(template[0]);
r = letter(template[strlen(template)-1]);
bigaddw(count[l], 1);
bigaddw(count[r], 1);

var min = 0;
var max = 0;
i = 0;
while (i < nletters) {
	if (!min) min = count[i]
	else if (bigcmp(count[i], min) < 0) min = count[i];
	if (!max) max = count[i]
	else if (bigcmp(count[i], max) > 0) max = count[i];
	i++;
};

bigsub(max, min);
bigdivw(max, 2);

printf("%b\n", [max]);
