include "bufio.sl";
include "bigint.sl";

var args = cmdargs()+1;
var ndays = 80;
if (*args) ndays = atoi(*args);

var in = bfdopen(0, O_READ);

var numfish = malloc(9);
var numfish2 = malloc(9);
var i;
while (i < 9) {
	numfish[i] = bignew(0);
	numfish2[i] = bignew(0);
	i++;
};

var n;
while (bscanf(in, "%d", [&n])) {
	bigaddw(numfish[n], 1);
};

var day = 0;
var p;
while (day < ndays) {
	i = 1;
	while (i != 9) {
		bigset(numfish2[i-1], numfish[i]);
		i++;
	};
	bigset(numfish2[8], numfish[0]);
	bigadd(numfish2[6], numfish[0]);

	p = numfish;
	numfish = numfish2;
	numfish2 = p;
	day++;
};

var count = bignew(0);
i = 0;
while (i < 9) {
	bigadd(count, numfish[i]);
	i++;
};

printf("%b\n", [count]);
