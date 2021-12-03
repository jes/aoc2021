include "bufio.sl";
include "bigint.sl";

var l = malloc(128);
var in = bfdopen(0, O_READ);
var count = malloc(32);
memset(count, 0, 32);
var nlines;
var linelen;

var numbers = malloc(1000);

while(bgets(in, l, 128)) {
	linelen = strlen(l)-1;
	numbers[nlines] = atoibase(l, 2);
	nlines++;
	if (nlines > 1000) {
		fprintf(2, "input too long\n", 0);
		exit(1);
	};
};

var process = func(arr, n, ox, bit) {
	if (n == 1) return arr[0];

	var newarr = malloc(n);
	var i = 0;
	var count = 0;
	while (i < n) {
		if (arr[i] & bit) count++;
		i++;
	};

	var r = 0;
	if (ox == (count >= (n - count))) r = bit;

	var newn = 0;
	i = 0;
	while (i < n) {
		if ((arr[i] & bit)==r) newarr[newn++] = arr[i];
		i++;
	};

	r = process(newarr, newn, ox, shr(bit,1));

	free(newarr);

	return r;
};

var startbit = shl(1, linelen-1);

biginit(2);
var oxygen = process(numbers, nlines, 1, startbit);
var co2 = process(numbers, nlines, 0, startbit);
var b = bignew(oxygen);
bigmulw(b, co2);
printf("%b\n", [b]);
