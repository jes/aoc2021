include "bufio.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);
var grid = vzmalloc([150,150]);
var y = 0;
var w;
var h;
while (bgets(in, grid[y], 150)) {
	w = strlen(grid[y])-1;
	y++;
};
h = y;

var moved = 1;
var nsteps = 0;
var tosweep = grnew();

var move = func(x0,y0, dx,dy) {
	var x1 = x0+dx;
	var y1 = y0+dy;
	if (x1 == w) x1 = 0;
	if (y1 == h) y1 = 0;
	if (grid[y1][x1] != '.') return 0;
	grid[y1][x1] = grid[y0][x0];
	grpush(tosweep, x0); grpush(tosweep, y0);
	moved = 1;
	return 1;
};

var sweep = func() {
	var i;
	i = 0;
	var x; var y;
	var arr = grbase(tosweep);
	var len = grlen(tosweep);
	while (i != len) {
		x = arr[i++];
		y = arr[i++];
		grid[y][x] = '.';
	};
	grtrunc(tosweep, 0);
};

var step = func(ch, horiz) {
	var i; var j;
	var x; var y;
	var I = h;
	var J = w;
	if (!horiz) {
		I=w;
		J=h;
	};
	i = 0;
	while (i < I) {
		if (horiz) y=i else x=i;
		j = 0;
		while (j < J) {
			if (horiz) x=j else y=j;
			if (grid[y][x] == ch)
				if (move(x,y, horiz,!horiz))
					j++; # don't re-move this sea cucumber
			j++;
		};
		i++;
	};
};

var dump = func() {
	var x;
	var y = 0;
	while (y<h) {
		x = 0; while (x<w) {
			putchar(grid[y][x]);
		x++; };
	putchar('\n');
	y++; };
};

while (moved) {
	moved = 0;
	step('>', 1);
	sweep();
	step('v', 0);
	sweep();
	nsteps++;
};

printf("%d\n", [nsteps]);
