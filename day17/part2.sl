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

var nhits = 0;

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
			nhits++;
			return 0;
		};
		if (y < ty1) {
			return 0;
		};
		if (x > tx2) {
			return 0;
		};
	};
};

var vx;
var vy = ty1;
while (vy < 200) {
	if (vy > 50) {
		simulate(23,vy);
	} else {
		vx = 0;
		while (vx <= tx2) {
			simulate(vx,vy);
			vx++;
		};
	};
	printf("vy=%d: nhits=%d\n", [vy,nhits]);
	vy++;
};
