include "bufio.sl";
include "grarr.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);

var l = malloc(128);

var grid = malloc(102);
var i = 0;
while (i != 102) {
	grid[i] = malloc(102);
	i++;
};

var width;
var height;
var x;
var y = 1;

while (bgets(in, l, 128)) {
	width = strlen(l)-1;
	grid[y][0] = 10;
	grid[y][width+1] = 10;

	x = 0;
	while (x < width) {
		grid[y][x+1] = l[x]-'0';
		x++;
	};

	y++;
};
height = y+1;
width = width+2;

memset(grid[0], 10, 102);
memset(grid[height-1], 10, 102);

var scanbasin = func(x,y) {
	if (grid[y][x] >= 9) return 0;
	grid[y][x] = 9;
	return 1 + scanbasin(x-1,y) + scanbasin(x+1,y) + scanbasin(x,y-1) + scanbasin(x,y+1);
};

y = 1;
var g;
var sz;
var sizes = grnew();
while (y != height-1) {
	x = 1;
	while (x != width-1) {
		g = grid[y][x];
		if ((g < grid[y-1][x]) && (g < grid[y+1][x]) && (g < grid[y][x-1]) && (g < grid[y][x+1])) {
			grpush(sizes, scanbasin(x,y));
		};
		x++;
	};
	y++;
};

grsort(sizes, func(a,b) { return b-a; });

var answer = bignew(grget(sizes, 0));
bigmulw(answer, grget(sizes, 1));
bigmulw(answer, grget(sizes, 2));

printf("%b\n", [answer]);
