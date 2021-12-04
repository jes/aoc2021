include "bufio.sl";
include "bigint.sl";

biginit(2);

var in = bfdopen(0, O_READ);
var input = 0xc000;
var inputlen = *(0xbfff);
var i = 0;
var j = 0;
var j5 = 0;

assert(inputlen == 2500, "inputlen = %d\n", [inputlen]);

var ball;
var got = malloc(101);
memset(got, 0, 101);

var gotline = func(p, stride) {
	var i = 0;
	while (i < 5) {
		if (!got[*p]) return 0;
		p = p + stride;
		i++;
	};
	return 1;
};

var answer = func(p, ball) {
	var i = 0;
	var sum = 0;
	while (i < 25) {
		if (!got[*p]) sum = sum + *p;
		p++;
		i++;
	};
	var b = bignew(sum);
	bigmulw(b, ball);
	printf("%b\n", [b]);
	exit(0);
};

var havewon = malloc(100);
memset(havewon, 0, 100);

var k;
var nwinners = 0;

while (bscanf(in, "%d", [&ball])) {
	got[ball] = 1;
	i = 0;
	
	k = 0;
	while (i < inputlen) {
		j = 0;
		j5 = 0;
		while (j < 5) {
			if (!havewon[k]) {
				if (gotline(input+i+j, 5) || gotline(input+i+j5, 1)) {
					havewon[k] = 1;
					nwinners++;
					if (nwinners == 100) {
						answer(input+i, ball);
					};
					break;
				};
			};
			j++;
			j5 = j5 + 5;
		};
		i = i + 25;
		k++;
	};
};

printf("no winner\n", 0);
