include "bufio.sl";

var args = cmdargs()+1;
assert(*args, "usage: part1 INPUTNAME", 0);

var in;

var x1;
var y1;
var x2;
var y2;

var map = malloc(14400);
var count;

var visit = func(x,y) {
#	printf("visit %d,%d: ", [x,y]);
	var i = mul(y,120) + x;
	assert(i < 14400, "%d,%d out of range", [x,y]);
	map[i] = map[i]+1;
	if (map[i] == 2) count++;
};

var drawline = func(x1,y1,x2,y2) {
	var dx = 0;
	var dy = 0;
	if (x2 > x1) dx = 1;
	if (x2 < x1) dx = -1;
	if (y2 > y1) dy = 1;
	if (y2 < y1) dy = -1;
	var x = x1;
	var y = y1;
	while ((x != x2) || (y != y2)) {
		visit(x, y);
		x = x + dx;
		y = y + dy;
	};
	visit(x, y);
};

while (*args) {
	in = bopen(*args, O_READ);
	assert(in, "can't open %s", [*args]);
	memset(map, 0, 14400);
	while (bscanf(in, "%d,%d -> %d,%d", [&x1,&y1, &x2,&y2])) {
		drawline(x1,y1, x2,y2);
	};
	bclose(in);
	putchar('.');
	args++;
};
putchar('\n');

printf("%d\n", [count]);
