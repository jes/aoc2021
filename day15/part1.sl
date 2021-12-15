include "bufio.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);

var grid = vzmalloc([100,128]);

var w = 0;
var h;
var y = 0;
var x;
while (bgets(in, grid[y], 128)) {
	w = strlen(grid[y])-1;
	y++;
};
h = y;

var bestpath = 0x7fff;
var lastbestpath = 0x7fff;

var risk = vzmalloc([h,w]);

var update = func(x,y) {
	var g = grid[y][x] - '0';
	var r = 0x7fff;
	var gx = 0; var gy = 0;
	if (x > 0) r = g + risk[y][x-1];
	if ((y > 0) && (g+risk[y-1][x] < r))
		r = g + risk[y-1][x];
	if ((x < w-1) && risk[y][x+1])
		if ((g + risk[y][x+1]) < r)
			r = g + risk[y][x+1];
	if ((y < h-1) && risk[y+1][x])
		if ((g + risk[y+1][x]) < r)
			r = g + risk[y+1][x];

	if (x == 0 && y == 0) r = g;

	if ((risk[y][x] == 0) || (r < risk[y][x]))
		risk[y][x] = r;
};

while (1) {
	y = 0;
	while (y < h) {
		x = 0;
		while (x < w) {
			update(x,y);
			x++;
		};
		y++;
	};
	bestpath = risk[h-1][w-1];
	printf("%d\n", [bestpath]);
	if (bestpath < lastbestpath) {
		lastbestpath = bestpath;
	} else {
		printf("%d\n", [bestpath-(grid[0][0]-'0')]);
		break;
	};
};
