include "bufio.sl";
include "bigint.sl";

biginit(2);

var in = bfdopen(0, O_READ);

var crabs = malloc(1000);
var ncrabs = 0;
while (bscanf(in, "%d", [crabs+ncrabs])) {
	ncrabs++;
	assert(ncrabs <= 1000, "ncrabs=%d", [ncrabs]);
};

printf("%d crabs\n", [ncrabs]);

var fuelcost = func(x) {
	var i = 0;
	var cost = bignew(0);
	var accum = 0;
	var c;
	while (i != ncrabs) {
		c = x - crabs[i];
		if (c < 0) c = -c;
		accum = accum + c;
		if (accum > 30000) {
			bigaddw(cost, accum);
			accum = 0;
		};
		i++;
	};
	bigaddw(cost, accum);
	return cost;
};

sort(crabs, ncrabs, func(a,b) {
	return a - b;
});

var mid = div(ncrabs, 2);
var f = func(x) {
	var c = fuelcost(crabs[x]);
	printf("at %d, cost=0x%04x%04x\n", [crabs[x], c[1], c[0]]);
};
f(mid-1); f(mid); f(mid+1);
