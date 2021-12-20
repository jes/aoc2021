include "bufio.sl";

var in = bfdopen(0, O_READ);

var enhance = malloc(514);
bgets(in, enhance, 514);
assert(bgetc(in) == '\n', "need newline after enhancement spec\n", 0);

var grid = vzmalloc([209,14]);
var grid2 = vzmalloc([209,14]);
var xdiv16 = malloc(209);
var y;
var x;
var i = 0;
while (i < 209) {
	if (enhance[0] == '#')
		memset(grid2[i], 0xffff, 14);
	xdiv16[i] = div(i,16);
	i++;
};

i = 0;
while (i < 512) {
	enhance[i] = enhance[i]=='#';
	i++;
};

var set = func(grid,x,y,n) {
	if (n)
		grid[y][xdiv16[x]] = grid[y][xdiv16[x]] | powers_of_2[x&0xf]
	else
		grid[y][xdiv16[x]] = grid[y][xdiv16[x]] & ~powers_of_2[x&0xf];
};

var get = func(grid,x,y) {
	return grid[y][xdiv16[x]] & powers_of_2[x&0xf];
};

var ch;
y = 54;
var w;
while (y < 209) {
	x = 54;
	while (x < 209) {
		ch = bgetc(in);
		if (ch == '\n' || ch == EOF) break;
		assert(ch == '#' || ch == '.', "expected . or #: %c\n", [ch]);
		set(grid,x,y,ch=='#');
		x++;
	};
	y++;
	if (x+53 > w) w = x+53;
	if (ch == EOF) break;
};

printf("ended at %d,%d\n", [x,y]);

var h = y+53;

var dump = func(grid) {
	var y = 0;
	var x;
	while (y < h) {
		x = 0;
		while (x < w) {
			if (get(grid,x,y)) putchar('#')
			else putchar('.');
			x++;
		};
		putchar('\n');
		y++;
	};
};

var getnum = func(g, x, y) {
	var n = 0;
	if (get(g,x-1,y-1)) n = n | 256;
	if (get(g,x,y-1))   n = n | 128;
	if (get(g,x+1,y-1)) n = n | 64;
	if (get(g,x-1,y))   n = n | 32;
	if (get(g,x,y))     n = n | 16;
	if (get(g,x+1,y))   n = n | 8;
	if (get(g,x-1,y+1)) n = n | 4;
	if (get(g,x,y+1))   n = n | 2;
	if (get(g,x+1,y+1)) n = n | 1;
	return n;
};

var step = func(g, g2) {
	var y = 1;
	var x;
	puts("step");
	while (y < h-1) {
		putchar('.');
		x = 1;
		while (x < w-1) {
			set(g2, x, y, enhance[getnum(g,x,y)]);
			set(g2, x+1, y, enhance[getnum(g,x+1,y)]);
			set(g2, x+2, y, enhance[getnum(g,x+2,y)]);
			x = x + 3;
		};
		y++;
	};
	putchar('\n');
};

var countlit = func(g) {
	var y = 1;
	var x;
	var n = 0;
	while (y < h-1) {
		x = 1;
		while (x < w-1) {
			if (get(g,x,y)) n++;
			x++;
		};
		y++;
	};
	return n;
};

i = 0;
while (i < 25) {
	step(grid,grid2);
	step(grid2,grid);
	i++;
};
printf("%d\n", [countlit(grid)]);
