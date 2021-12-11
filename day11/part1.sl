include "bufio.sl";

var in = bfdopen(0, O_READ);

var grid = malloc(10);
var i = 0;
while (i != 10) grid[i++] = malloc(10);

var ch;
var x = 0;
var y = 0;
while (1) {
	ch = bgetc(in);
	if (ch == EOF) break;
	if (ch == '\n') {
		x = 0;
		y++;
	};
	if (isdigit(ch)) {
		grid[y][x] = ch - '0';
		x++;
	};
};

var dumpgrid = func(grid) {
	var x;
	var y = 0;
	while (y != 10) {
		x = 0;
		while (x != 10) {
			putchar(grid[y][x]+'0');
			x++;
		};
		putchar('\n');
		y++;
	};
};

var nflashes = 0;

var flash = func(grid, x, y) {
	# make sure we don't flash the same cell twice
	grid[y][x] = grid[y][x]+1;

	var px;
	var py = y-1;
	while (py != y+2) {
		if ((py == -1) || (py == 10)) {
			py++; continue;
		};
		px = x-1;
		while (px != x+2) {
			if ((px == -1) || (px == 10) || ((px == x) && (py == y))) {
				px++; continue;
			};
			grid[py][px] = grid[py][px] + 1;
			# we only want to recurse when the level is exactly equal to 10,
			# otherwise we'll flash the same cell multiple times
			if (grid[py][px] == 10) flash(grid, px, py);
			px++;
		};
		py++;
	};
};

var step = func(grid) {
	var x;
	var y = 0;
	while (y != 10) {
		x = 0;
		while (x != 10) {
			grid[y][x] = grid[y][x] + 1;
			if (grid[y][x] == 10) flash(grid, x, y);
			x++;
		};
		y++;
	};

	y = 0;
	while (y != 10) {
		x = 0;
		while (x != 10) {
			if (grid[y][x] > 9) {
				grid[y][x] = 0;
				nflashes++;
			};
			x++;
		};
		y++;
	};
};

setbuf(1, malloc(257));

i = 0;
while (i != 100) {
	step(grid);
	i++;
	printf("after %d steps: %d flashes\n", [i, nflashes]);
	dumpgrid(grid);
};

printf("%d\n", [nflashes]);
