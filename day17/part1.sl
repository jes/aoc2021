include "bufio.sl";

var in = bfdopen(0, O_READ);
var console = bfdopen(3, O_READ);
var l = malloc(128);

var tx1;
var ty1;
var tx2;
var ty2;

bgets(in, l, 128);
sscanf(l, "target area: x=%d..%d, y=%d..%d", [&tx1,&tx2, &ty1,&ty2]);

var t;
if (ty2 < ty1) {
	t = ty1;
	ty1 = ty2;
	ty2 = t;
};

printf("target area is %d,%d to %d,%d\n", [tx1,ty1, tx2,ty2]);

var besty = 0;

var simulate = func(vx,vy) {
	var x = 0;
	var y = 0;

	if (x < 0) {
		printf("negative x\n",0);
		return 0;
	};

	var mybesty = 0;

	while (1) {
		x = x + vx;
		y = y + vy;
		if (vx) vx--; # drag
		vy--; # gravity

		if (y > mybesty) mybesty = y;

		if (x >= tx1 && y >= ty1 && x <= tx2 && y <= ty2) {
			printf("HIT! at %d,%d; mybesty=%d\n", [x,y,mybesty]);
			if (mybesty > besty) besty = mybesty;
			return 0;
		};
		if (y < ty1) {
			printf("miss, underneath at %d,%d\n", [x,y]);
			return 0;
		};
		if (x > tx2) {
			printf("miss, past at %d,%d\n", [x,y]);
			return 0;
		};
	};
};

var vx;
var vy;

puts("> ");
while (bgets(console, l, 128)) {
	if (sscanf(l, "%d,%d", [&vx,&vy]) == 2) {
		simulate(vx,vy);
		printf("besty=%d\n", [besty]);
	};
	puts("> ");
};
