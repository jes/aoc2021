include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
line = malloc(128);
var len;
var dir;
var dist;

var x = 0;
var y = 0;

while (bgets(in, line, 128)) {
	len = strlen(line);
	dir = line[0];
	dist = line[len-2] - '0';
	if (dir == 'u') y = y - dist;
	if (dir == 'd') y = y + dist;
	if (dir == 'f') x = x + dist;
};

var product = bignew(x);
bigmulw(product, y);
printf("%b\n", [product]);
