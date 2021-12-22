include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var out = bfdopen(1, O_WRITE);
var l = malloc(128);

var atoi50 = func(s) {
	var n;
	var b = bigatoi(s);
	if (bigcmpw(b, -51) < 0) n = -51
	else if (bigcmpw(b, 51) > 0) n = 51
	else n = bigtow(b);
	free(b);
	return n;
};

var gopast = func(s, ch) {
	while (*s && *s != ch) s++;
	if (*s == ch) s++;
	return s;
};

# on x=a..b,y=c..d,z=e..f\n
var on;
var p;
var x1; var x2; var y1; var y2; var z1; var z2;
while (bgets(in, l, 128)) {
	on = l[1] == 'n';
	p = gopast(l,'=');
	x1 = atoi50(p);
	p = gopast(p, '.'); p++;
	x2 = atoi50(p);
	p = gopast(p, '=');
	y1 = atoi50(p);
	p = gopast(p, '.'); p++;
	y2 = atoi50(p);
	p = gopast(p, '=');
	z1 = atoi50(p);
	p = gopast(p, '.'); p++;
	z2 = atoi50(p);
	bprintf(out, "%d %d %d %d %d %d %d\n", [on,x1,x2,y1,y2,z1,z2]);
};

bclose(out);
