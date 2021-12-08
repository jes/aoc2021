include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
line = malloc(128);
var len;
var dir;
var dist;

var aim = 0;
var x = 0;
var y = bignew(0);
var t = bignew(0);

while (bgets(in, line, 128)) {
	len = strlen(line);
	dir = line[0];
	dist = line[len-2] - '0';
	if (dir == 'u') aim = aim - dist;
	if (dir == 'd') aim = aim + dist;
	if (dir == 'f') {
		x = x + dist;
		bigsetw(t, dist);
		bigmulw(t, aim);
		bigadd(y, t);
	};
};

bigmulw(y, x);
printf("%b\n", [y]);
