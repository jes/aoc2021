include "bufio.sl";
include "hash.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);
var l = malloc(128);

var dots = grnew();

var _coord;
var _pos;
var fold = func(coord, pos) {
	_coord = coord;
	_pos = pos;
	grwalk(dots, func(p) {
		if (p[_coord] > _pos) p[_coord] = _pos - (p[_coord] - _pos);
	});
};

var got;
var maxx;
var maxy;
var dumpgrid = func() {
	got = htnew();
	maxx = 0;
	maxy = 0;
	grwalk(dots, func(p) {
		var k = malloc(3);
		if (p[0] > maxx) maxx = p[0];
		if (p[1] > maxy) maxy = p[1];
		assert(p[0] >= 0, "negative x: %d\n", [p[0]]);
		assert(p[1] >= 0, "negative y: %d\n", [p[1]]);
		k[0] = p[0]+1; k[1] = p[1]+1; k[2] = 0;
		if (!htget(got, k)) {
			htput(got, k, 1);
		} else {
			free(k);
		};
	});

	var x;
	var y = 0;
	var k = malloc(3);
	k[2] = 0;
	while (y <= maxy) {
		k[1] = y+1;
		x = 0;
		while (x <= maxx) {
			k[0] = x+1;
			if (htget(got, k)) putchar('#')
			else putchar(' ');
			x++;
		};
		putchar('\n');
		y++;
	};
	free(k);

	htwalk(got, func(k,v) free(k));
	htfree(got);
};

setbuf(1, malloc(257));

var x;
var y;
var axis;
var n;
while (bgets(in, l, 128)) {
	if (*l == '\n') continue;
	if (*l == 'f') {
		assert(sscanf(l, "fold along %c=%d", [&axis, &n]), "bad: %s\n", [l]);
		if (axis == 'x') fold(0, n)
		else fold(1, n);
	} else {
		assert(sscanf(l, "%d,%d", [&x,&y]), "bad: %s\n", [l]);
		grpush(dots, cons(x,y));
	};
};

dumpgrid();
