include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);
var mk7 = func(v) {
	var p = malloc(7);
	memcpy(p, v, 7);
	return p;
};

var instructions = grnew();

var on;
var p;
var x1; var x2; var y1; var y2; var z1; var z2;
while (bscanf(in, "%d %d %d %d %d %d %d", [&on, &x1, &x2, &y1, &y2, &z1, &z2])) {
	grpush(instructions, mk7([on,x1,x2,y1,y2,z1,z2]));
};

var CUBESZ = 51;
var CUBESZX = 7;
var cube = vzmalloc([CUBESZ,CUBESZ,CUBESZX]);
var xdiv16 = malloc(128);
var i = 0;
while (i < 128) {
	xdiv16[i] = div(i,16);
	i++;
};

var bitget = func(x,y,z) {
	return !!(cube[z][y][xdiv16[x]] & powers_of_2[x&0xf]);
};
var bitset = func(x,y,z,n) {
	var p = cube[z][y] + xdiv16[x];
	if (n)
		*p = *p | powers_of_2[x&0xf]
	else
		*p = *p & ~powers_of_2[x&0xf];
};
var setxrange = func(z,y,x1,x2,n) {
	var v = 0;
	if (n) v = 0xffff;
	var x = x1;
	while (x <= x2) {
		if ((x&0xf == 0) && (x+15 <= x2)) {
			cube[z][y][xdiv16[x]] = v;
			x = x + 16;
		} else {
			bitset(x,y,z,n);
			x++;
		};
	};
};

var setrange = func(x1,x2, y1,y2, z1,z2, n) {
	var z = z1;
	var y;
	while (z <= z2) {
		y = y1;
		while (y <= y2) {
			setxrange(z,y,x1,x2,n);
			y++;
		};
		z++;
	};
};

var count = bignew(0);
var count_latent = 0;

var countbits = func(x) {
	var i = 1;
	var n = 0;
	while (i) {
		if (x&i) n++;
		i = i+i;
	};
	return n;
};

var cubecount = func() {
	var z = 0;
	var y;
	var x;
	while (z < CUBESZ) {
		y = 0;
		while (y < CUBESZ) {
			x = 0;
			while (x < CUBESZX) {
				if (cube[z][y][x]) {
					if (cube[z][y][x] == 0xffff) count_latent = count_latent + 16
					else count_latent = count_latent + countbits(cube[z][y][x]);
					if (count_latent > 30000) {
						bigaddw(count, count_latent);
						count_latent = 0;
					};
					cube[z][y][x] = 0;
				};
				x++;
			};
			y++;
		};
		z++;
	};
};

var minx = -50; var maxx = 50;
var miny; var maxy;
var minz; var maxz;

var rangex = maxx - minx;
var rangey;
var rangez;

minz = -50;
while (minz <= 50) {
	maxz = minz + 50;
	if (maxz > 50) maxz = 50;
	rangez = maxz - minz;

	miny = -50;
	while (miny <= 50) {
		maxy = miny + 50;
		if (maxy > 50) maxy = 50;
		rangey = maxy - miny;

		printf("minz=%d, miny=%d\n", [minz,miny]);
		grwalk(instructions, func(v) {
			on = v[0];
			x1 = v[1]-minx; x2 = v[2]-minx;
			y1 = v[3]-miny; y2 = v[4]-miny;
			z1 = v[5]-minz; z2 = v[6]-minz;

			assert(x1<=x2 && y1<=y2 && z1<=z2, "%d,%d %d,%d %d,%d order violation\n", v+1);

			if (x1 > rangex || x2 < 0 || y1 > rangey || y2 < 0 || z1 > rangez || z2 < 0)
				return 0;
			if (x1 < 0) x1 = 0; if (x2 > rangex) x2 = rangex;
			if (y1 < 0) y1 = 0; if (y2 > rangey) y2 = rangey;
			if (z1 < 0) z1 = 0; if (z2 > rangez) z2 = rangez;
			setrange(x1, x2, y1, y2, z1, z2, on);
		});
		cubecount();
		printf("%b ...\n", [count]);

		miny = miny + 51;
	};
	minz = minz + 51;
};

bigaddw(count, count_latent);
printf("%b\n", [count]);
