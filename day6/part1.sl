include "bufio.sl";
include "bigint.sl";

var args = cmdargs()+1;
var ndays = 80;
if (*args) ndays = atoi(*args);

var in = bfdopen(0, O_READ);

var numfish = malloc(10);
var i;
while (i < 10) {
	numfish[i] = bignew(0);
	i++;
};

var n;
while (bscanf(in, "%d", [&n])) {
	bigaddw(numfish[n], 1);
};

var day = 0;
var p;
while (day < ndays) {
	bigset(numfish[9], numfish[0]);
	bigadd(numfish[7], numfish[0]);

	i = 1;
	while (i != 10) {
		bigset(numfish[i-1], numfish[i]);
		i++;
	};

	day++;
};

var count = bignew(0);
i = 0;
while (i < 9) {
	bigadd(count, numfish[i]);
	i++;
};

printf("%b\n", [count]);
