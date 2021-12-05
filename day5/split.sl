include "bufio.sl";

var args = cmdargs()+1;
assert(args[0] && args[1], "usage: split CELLSIZE INPUTFILE\n", 0);
var cellsize = atoi(args[0]);
assert(cellsize > 0, "cellsize should be >0, got %d", [cellsize]);
var inputname = args[1];

var in = bopen(inputname, O_READ);
assert(in, "open %s failed", [inputname]);

var cellfile = malloc(9);

var i = 0;
while (i < 9) {
	cellfile[i] = bopen(sprintf("%s.%d", [inputname, i]), O_WRITE|O_CREAT);
	assert(cellfile[i], "open a file", 0);
	i++;
};

var cellprintf = func(cx, cy, fmt, args) {
	var i = mul(cy,3) + cx;
	if (i >= 9) {
		printf("skip %d,%d\n", [cx,cy]);
		return 0;
	};
	var f = cellfile[i];
	bprintf(f, fmt, args);
};

var diag = func(x1,y1,x2,y2) {
	#printf("diag: %d,%d -> %d,%d\n", [x1,y1,x2,y2]);
	var dx = x2-x1;
	var dy = y2-y1;
	var t;
	if (dx < 0) {
		t = x1; x1 = x2; x2 = t;
		t = y1; y1 = y2; y2 = t;
	};
	# now we know x increases from x1 to x2, but
	# y can increase or decrease as we move right
	if (y1 < y2) dy = 1
	else dy = -1;
	var x = x1;
	var y = y1;

	var cx = div(x, cellsize);
	var cy = div(y, cellsize);
	var cx2 = div(x2, cellsize)+1;

	var steps;
	var endx;
	var endy;
	var endcy;
	var midx;
	var midy;
	var midcy;

	while (cx != cx2) {
		# at what coordinate do we move to the next X cell?
		endx = mul(cx+1, cellsize)-1;
		if (endx > x2) endx = x2;
		steps = endx - x;
		endy = y + mul(dy, steps);
		endcy = div(endy, cellsize);

		# if we have 2 Y cells at this X cell, do the first now
		if (endcy != cy) {
			#printf("(mid) ", 0);
			# at what coordinate do we move to the next Y cell?
			if (dy == 1) midy = mul(cy+1, cellsize)-1
			else midy = mul(cy,cellsize);
			steps = midy-y;
			if (steps < 0) steps = -steps;
			midx = x + steps;
			midcy = div(midy, cellsize);
			#printf("[%d,%d], %d,%d -> %d,%d\n", [cx,cy,x,y,midx,midy]);
			cellprintf(cx, cy, "%d,%d -> %d,%d\n", [mod(x,cellsize),mod(y,cellsize), mod(midx,cellsize),mod(midy,cellsize)]);
			x = midx+1;
			y = midy+dy;
			cy = div(y, cellsize);
		};

		#printf("[%d,%d], %d,%d -> %d,%d\n", [cx,cy,x,y,endx,endy]);
		cellprintf(cx, cy, "%d,%d -> %d,%d\n", [mod(x,cellsize),mod(y,cellsize), mod(endx,cellsize),mod(endy,cellsize)]);

		x = endx+1;
		y = endy+dy;
		cx++;
		cy = div(y, cellsize);
	};
};

var _horiz = func(x1, x2, y, cb) {
	var t;
	if (x1 > x2) { t = x1; x1 = x2; x2 = t; };
	var cell1 = div(x1, cellsize);
	var cell2 = div(x2, cellsize)+1;
	var c = cell1;
	var cy = div(y, cellsize);
	var x = x1;
	y = mod(y, cellsize);
	var nextx;
	while (c != cell2) {
		nextx = mul(c+1, cellsize);
		if (nextx > x2) nextx = x2+1;
		cb(c, cy, mod(x,cellsize),y, mod(nextx-1,cellsize),y);
		x = nextx;
		c++;
	};
};

var horiz = func(x1, x2, y) {
	_horiz(x1, x2, y, func(cx, cy, x1, y1, x2, y2) {
		cellprintf(cx, cy, "%d,%d -> %d,%d\n", [x1,y1, x2,y2]);
	});
};

var vert = func(x, y1, y2) {
	# swap x and y, use _horiz, swap back
	_horiz(y1, y2, x, func(cy, cx, y1, x1, y2, x2) {
		cellprintf(cx, cy, "%d,%d -> %d,%d\n", [x1,y1, x2,y2]);
	});
};

var output = func(x1,y1, x2,y2) {
	var dx = x2-x1;
	var dy = y2-y1;
	if ((dx != 0) && (dy != 0) && (dx != dy) && (dx != -dy)) return 0;
	if (dx && dy) diag(x1,y1,x2,y2)
	else if (dx) horiz(x1,x2,y1)
	else vert(x1,y1,y2);
};

var x1;
var y1;
var x2;
var y2;

while (bscanf(in, "%d,%d -> %d,%d", [&x1,&y1, &x2,&y2])) {
	output(x1,y1, x2,y2);
};

i = 0;
while (i < 9) {
	bclose(cellfile[i]);
	i++;
};
