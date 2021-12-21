include "stdio.sl";
include "bigint.sl";

var args = cmdargs()+1;
assert(args[0] && args[1], "usage: part1 P1 P2\n", 0);
pos = [atoi(args[0]), atoi(args[1])];

# player, position, turns mod 2, score
var table = vzmalloc([2,11,2,32,bigint_prec]);

bigsetw(table[0][pos[0]][0][0], 1);
bigsetw(table[1][pos[1]][0][0], 1);

var bigtmp = bignew(0);
var roll = func(player, pos, rolled, nways, turns) {
	var newpos = 1 + mod(pos + rolled - 1, 10);
	var s = 0;
	var i;
	var b;
	while (s < 21) {
		b = table[player][pos][!(turns&1)][s];
		bigset(bigtmp, b);
		i = 1;
		while (i < nways) {
			bigadd(bigtmp, b);
			i++;
		};
		bigadd(table[player][newpos][turns&1][s+newpos], bigtmp);
		s++;
	};
};

var calc = func(p, t) {
	var i = 1; # positon

	while (i <= 10) { # 10 possible positions
		roll(p, i, 3, 1, t);
		roll(p, i, 4, 3, t);
		roll(p, i, 5, 6, t);
		roll(p, i, 6, 7, t);
		roll(p, i, 7, 6, t);
		roll(p, i, 8, 3, t);
		roll(p, i, 9, 1, t);
		i++;
	};
};

var win = vzmalloc([2,22,bigint_prec]);
var dontwin = vzmalloc([2,22,bigint_prec]);

var addwins = func(p, turns) {
	var s = 0;
	var i;
	while (s < 32) {
		i = 1;
		while (i <= 10) {
			if (s >= 21)
				bigadd(win[p][turns], table[p][i][turns&1][s])
			else
				bigadd(dontwin[p][turns], table[p][i][turns&1][s]);
			i++;
		};
		s++;
	};
};

var zeroout = func(t) {
	# player, pos, t mod 2, score
	var p = 0;
	var s;
	while (p <= 10) {
		s = 0;
		while (s < 32) {
			bigsetw(table[0][p][t&1][s], 0);
			bigsetw(table[1][p][t&1][s], 0);
			s++;
		};
		p++;
	};
};

bigsetw(dontwin[0][0], 1);
bigsetw(dontwin[1][0], 1);

var t = 1;
while (t <= 21) {
	printf("turn %d...\n", [t]);
	zeroout(t);
	calc(0,t);
	addwins(0,t);
	calc(1,t);
	addwins(1,t);
	if (bigcmpw(dontwin[0][t],0)==0 && bigcmpw(dontwin[1][t],0)==0) break;
	t++;
};

var w = [bignew(0), bignew(0)];
t = 1;
while (t <= 21) {
	bigmul(win[0][t], dontwin[1][t-1]);
	bigadd(w[0], win[0][t]);

	bigmul(win[1][t], dontwin[0][t]);
	bigadd(w[1], win[1][t]);

	t++;
};

printf("player 0: %b\n", [w[0]]);
printf("player 1: %b\n", [w[1]]);
