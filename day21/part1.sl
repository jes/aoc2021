include "stdio.sl";
include "bigint.sl";

var args = cmdargs()+1;
assert(args[0] && args[1], "usage: part1 P1 P2\n", 0);
pos = [atoi(args[0]), atoi(args[1])];
var score = [0, 0];

die = 0;
var nrolls = 0;

var roll = func() {
	die = die+1;
	if (die > 100) die = 1;
	nrolls++;
	return die;
};

var win = func(p) {
	var b = bignew(nrolls);
	bigmulw(b, score[!p]);
	printf("%b\n", [b]);
	exit(0);
};

var play = func(p) {
	var n = roll() + roll() + roll();
	pos[p] = 1 + mod(pos[p] + n - 1, 10);
	score[p] = score[p] + pos[p];
	#printf("Player %d rolls %d, is now at pos %d, score %d\n", [p+1, n, pos[p], score[p]]);
	if (score[p] >= 1000) {
		win(p);
	};
};

while (1) {
	play(0);
	play(1);
};
