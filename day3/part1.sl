include "bufio.sl";
include "bigint.sl";

var l = malloc(128);
var in = bfdopen(0, O_READ);
var count = malloc(32);
memset(count, 0, 32);
var i;
var nlines;
var linelen;
var p;

while(bgets(in, l, 128)) {
	i = 0;
	while (l[i] != '\n') {
		if (l[i] == '1') count[i] = count[i]+1;
		i++;
	};
	linelen = i;
	nlines++;
};

var gamma = 0;
var epsilon = 0;

i = 0;
while (i < linelen) {
	gamma = gamma+gamma;
	epsilon = epsilon+epsilon;
	if (count[i] > (nlines - count[i])) gamma++
	else epsilon++;
	i++;
};

biginit(2);

var b = bignew(gamma);
bigmulw(b, epsilon);
printf("%b\n", [b]);
