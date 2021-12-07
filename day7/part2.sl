include "bufio.sl";
include "bigint.sl";

biginit(2);

var in = bfdopen(0, O_READ);

var crabs = malloc(1000);
var ncrabs = 0;
var meancrab = bignew(0);
while (bscanf(in, "%d", [crabs+ncrabs])) {
	bigaddw(meancrab, crabs[ncrabs]);
	ncrabs++;
	assert(ncrabs <= 1000, "ncrabs=%d", [ncrabs]);
};

bigdivw(meancrab, ncrabs);
meancrab = bigtow(meancrab);

printf("%d crabs\n", [ncrabs]);

var bign = bignew(0);
var addsumton = func(cost, n) {
	# add n(n+1)/2 to cost
	bigsetw(bign, n);
	bigmulw(bign, n+1);
	bigadd(cost, bign);
};

var fuelcost = func(x) {
	var i = 0;
	var cost = bignew(0);
	var dist;
	while (i != ncrabs) {
		dist = x - crabs[i];
		if (dist < 0) dist = -dist;
		addsumton(cost, dist);
		i++;
	};
	bigdivw(cost, 2);
	return cost;
};

printf("at %d, cost=%b\n", [meancrab-1, fuelcost(meancrab-1)]);
printf("at %d, cost=%b\n", [meancrab, fuelcost(meancrab)]);
printf("at %d, cost=%b\n", [meancrab+1, fuelcost(meancrab+1)]);
