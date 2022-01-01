include "bufio.sl";
include "heap.sl";

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

var endx = mul(w,5)-1;
var endy = mul(h,5)-1;

var xdiv16 = malloc(500);
var i = 0;
while (i != 500) xdiv16[i++] = div(i, 16);

var visited = vzmalloc([500,32]);
var seen = func(x,y) {
	var px = xdiv16[x];
	var bx = powers_of_2[x&0xf];
	var r = visited[y][px] & bx;
	visited[y][px] = visited[y][px] | bx;
	return r;
};

var q = heapnew(func(a,b) {
	return a[2] - b[2];
});

var qpush = func(x,y,risk) {
	if (seen(x,y)) return 0;
	var p = malloc(3);
	p[0] = x;
	p[1] = y;
	p[2] = risk;
	heappush(q, p);
};

var add = func(p, dx, dy) {
	var x = p[0]+dx;
	var y = p[1]+dy;

	if (x < 0) return 0;
	if (y < 0) return 0;
	if (x > endx) return 0;
	if (y > endy) return 0;

	var cx;
	var cy;
	var qx;
	var qy;
	divmod(x,w, &qx, &cx);
	divmod(y,h, &qy, &cy);
	var risk = p[2] + 1 + mod(grid[cy][cx]-'0'-1+qx+qy,9);

	qpush(x,y,risk);
};

qpush(0,0,0);

var max = 0;

var p;
while (heaplen(q)) {
	p = heappop(q);
	if (p[0] == endx && p[1] == endy) {
		printf("%d\n", [p[2]]);
		exit(0);
	};
	if (p[2] > max) {
		printf("visit %d,%d: risk is %d, q has %d elements\n", [p[0], p[1], p[2], heaplen(q)]);
		max = p[2];
	};
	add(p, -1, 0);
	add(p, 0, -1);
	add(p, 1, 0);
	add(p, 0, 1);
	free(p);
};

printf("no route\n", 0);
