include "bufio.sl";
include "grarr.sl";
include "hash.sl";

var in = bfdopen(0, O_READ);

var v3d = func(x,y,z) {
	var p = malloc(3);
	p[0] = x; p[1] = y; p[2] = z;
	return p;
};

var v3dclone;

var v3dadd = func(p, q) {
	p[0] = p[0] + q[0];
	p[1] = p[1] + q[1];
	p[2] = p[2] + q[2];
	return p;
};

var v3dsub = func(p, q) {
	p[0] = p[0] - q[0];
	p[1] = p[1] - q[1];
	p[2] = p[2] - q[2];
	return p;
};

var v3dmap = func(p, m) {
	if (m&1) p[0] = -p[0];
	if (m&2) p[1] = -p[1];
	if (m&4) p[2] = -p[2];
	var t;
	if (m&8) { t = p[0]; p[0] = p[1]; p[1] = t; };
	if (m&16) { t = p[0]; p[0] = p[2]; p[2] = t; };
	if (m&32) { t = p[1]; p[1] = p[2]; p[2] = t; };
	return p;
};

var v3dunmap = func(p, m) {
	var t;
	if (m&32) { t = p[1]; p[1] = p[2]; p[2] = t; };
	if (m&16) { t = p[0]; p[0] = p[2]; p[2] = t; };
	if (m&8) { t = p[0]; p[0] = p[1]; p[1] = t; };
	if (m&4) p[2] = -p[2];
	if (m&2) p[1] = -p[1];
	if (m&1) p[0] = -p[0];
	return p;
};

var v3doffset = func(p0, p1, m) {
	v3dunmap(p1, m);
	v3dsub(p1, p0);
	return p1;
};

var v3dapply = func(p, m, offset) {
	v3dadd(p, offset);
	v3dmap(p, m);
	return p;
};

v3dclone = func(p) return v3d(p[0], p[1], p[2]);

var scanners = grnew();
var s;
var n;
var x; var y; var z;
var l = malloc(128);

while(bscanf(in, " --- scanner %d ---", [&n])) {
	assert(n == grlen(scanners), "out-of-order scanner: got %d, expected %d\n", [n, grlen(scanners)]);
	s = grnew();
	grpush(scanners, s);

	while(bgets(in, l, 128)) {
		if (l[0] == '\n') break;
		if (!sscanf(l, "%d,%d,%d", [&x,&y,&z])) break;
		grpush(s, v3d(x,y,z));
	};
};

var hash = htnew();
var beacons = grnew();
var hkey = zmalloc(4);
#var s_key = func(p) {
#	hkey[0] = p[0]; hkey[1] = p[1]; hkey[2] = p[2];
#	if (hkey[0] == 0) hkey[0] = 32000;
#	if (hkey[1] == 0) hkey[1] = 32000;
#	if (hkey[2] == 0) hkey[2] = 32000;
#	return hkey;
#};
var key = asm {
	pop x
	ld r1, x # p
	ld r0, (_hkey)

	ld x, (r1++)
	test x
	jnz key_first
	ld x, 32000
	key_first:
	ld (r0++), x

	ld x, (r1++)
	test x
	jnz key_second
	ld x, 32000
	key_second:
	ld (r0++), x

	ld x, (r1)
	test x
	jnz key_third
	ld x, 32000
	key_third:
	ld (r0), x

	sub r0, 2
	ret
};

var hashhas;

var hashadd = func(p) {
	if (!hashhas(p)) {
		grpush(beacons, v3dclone(p));
		htput(hash, strdup(key(p)), 1);
	};
};

hashhas = func(p) {
	return htget(hash, key(p));
};

var addscanner = func(s) {
	grwalk(s, hashadd);
};

var v3dstatic = v3d(0,0,0);

var scannerapply = func(s, offset, m) {
	var i = 0;
	while (i < grlen(s)) {
		putchar('.');
		v3dapply(grget(s,i), m, offset);
		i++;
	};
	putchar('\n');
};

var v3doff = v3d(0,0,0);

var hkeys = vzmalloc([2000,4]);
var nhkeys = 0;
var hkdup = func(k) {
	assert(nhkeys < 2000, "<2000 hkeys\n", 0);
	memcpy(hkeys[nhkeys], k, 3);
	return hkeys[nhkeys++];
};

var offhash = htnew();

var scanneroff = grnew();
grpush(scanneroff, v3d(0,0,0));

var axes = [
	0x00, 0x24, 0x06, 0x22, 0x03, 0x27,
	0x05, 0x21, 0x28, 0x09, 0x2d, 0x0c,
	0x2e, 0x0f, 0x2b, 0x0a, 0x18, 0x12,
	0x1b, 0x11, 0x17, 0x1e, 0x14, 0x1d
];

var solve = func(beacons, s) {
	var i = 0;
	var j = 0;
	var k;
	var n;
	var beacon;
	var sbase = grbase(s);
	var bbase = grbase(beacons);
	var point;
	var m = 0;
	var im = 0;
	var h;
	var lens = grlen(s);
	var lenbeacons = grlen(beacons);
	var max;
	while (im < 24) {
		printf("%d", [im]);
		m = axes[im];
		# clear out hash table
		memset(offhash[2], 0, offhash[0]+offhash[0]);
		offhash[1] = 0;
		nhkeys = 0;
		max = 0;
		printf(";",0);

		# iterate over all beacons in "s"
		i = lens;
		while (i--) {
			if (i+max < 11) break;
			beacon = sbase[i];

			# iterate over "beacons"
			j = lenbeacons;
			while (j--) {
				# work out what offset is required, count these in a hash table
				memcpy(v3doff, bbase[j], 3);
				v3doffset(beacon, v3doff, m);
				k = key(v3doff);
				h = htgetkv(offhash, k);
				# if any offset has >= 12 hits, then we've solved:
				if (h) {
					if (h[1] == 11) {
						#	apply the offset to every beacon in "s" and return 1
						printf("solved with m=%d, off=[%d,%d,%d]\n", [m, v3doff[0], v3doff[1], v3doff[2]]);
						scannerapply(s, v3doff, m);
						addscanner(s);
						grpush(scanneroff, v3dmap(v3dclone(v3doff), m));
						return 1;
					};
					htputp(offhash, h, h[0], h[1]+1);
					if (h[1]+1 > max) max = h[1]+1;
				} else {
					htput(offhash, hkdup(k), 1);
					if (1 > max) max = 1;
				};
			};
		};
		im++;
	};
	return 0;
};

addscanner(grget(scanners, 0));

var nunsolved = grlen(scanners)-1;
var solved = zmalloc(grlen(scanners));
solved[0] = 1;

var tested = vzmalloc([30,30]);

var i;
var j;
while (nunsolved) {
	printf("--- len=%d, unsolved=%d\n", [grlen(beacons), nunsolved]);
	i = 0;
	while (nunsolved && i < grlen(scanners)) {
		if (solved[i]) { i++; continue; };

		j = 0;
		while (j < grlen(scanners)) {
			if (!solved[j] || i==j || tested[i][j]) { j++; continue; };
			printf("try %d against %d\n", [i,j]);
			tested[i][j] = 1;
			if (solve(grget(scanners, j), grget(scanners, i))) {
				solved[i] = 1;
				nunsolved--;
				printf("solved %d! %d remain; len(beacons)=%d\n", [i, nunsolved, grlen(beacons)]);
				break;
			};
			j++;
		};

		i++;
	};
};

printf("%d\n", [grlen(beacons)]);

var dist = func(a,b) {
	var dx = a[0]-b[0];
	var dy = a[1]-b[1];
	var dz = a[2]-b[2];
	if (dx < 0) dx = -dx;
	if (dy < 0) dy = -dy;
	if (dz < 0) dz = -dz;
	return dx+dy+dz;
};

var maxdist = 0;
var d;
i = 0;
while (i < grlen(scanneroff)) {
	j = i+1;
	while (j < grlen(scanneroff)) {
		d = dist(grget(scanneroff,i), grget(scanneroff,j));
		if (d > maxdist) {
			printf("%d,%d,%d to ", grget(scanneroff,i));
			printf("%d,%d,%d is ", grget(scanneroff,j));
			printf("%d\n", [d]);
			maxdist = d;
		};
		j++;
	};
	i++;
};
printf("%d\n", [maxdist]);
