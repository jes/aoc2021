include "bufio.sl";

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

var risk = 0;

y = 1;
var g;
while (y != height-1) {
	x = 1;
	while (x != width-1) {
		g = grid[y][x];
		if ((g < grid[y-1][x]) && (g < grid[y+1][x]) && (g < grid[y][x-1]) && (g < grid[y][x+1]))
			risk = risk + g + 1;
		x++;
	};
	y++;
};

printf("%d\n", [risk]);
