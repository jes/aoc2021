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
var ndots;
var countdots = func() {
	got = htnew();
	ndots = 0;
	grwalk(dots, func(p) {
		var k = malloc(3);
		assert(p[0] >= 0, "negative x: %d\n", [p[0]]);
		assert(p[1] >= 0, "negative y: %d\n", [p[1]]);
		k[0] = p[0]+1; k[1] = p[1]+1; k[2] = 0;
		if (!htget(got, k)) {
			ndots++;
			htput(got, k, 1);
		} else {
			free(k);
		};
	});
	htwalk(got, func(k,v) free(k));
	htfree(got);
	return ndots;
};

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
		printf("%d\n", [countdots()]);
		break;
	} else {
		assert(sscanf(l, "%d,%d", [&x,&y]), "bad: %s\n", [l]);
		grpush(dots, cons(x,y));
	};
};
