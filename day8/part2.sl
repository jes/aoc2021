include "bufio.sl";
include "bigint.sl";

setbuf(1, malloc(257));

var in = bfdopen(0, O_READ);

var got = zmalloc(7);
var cantbe = zmalloc(7);
var i = 0;
while (i != 7) {
	cantbe[i] = zmalloc(7);
	i++;
};
var ngot = 0;

var ch;
var on_output;

var dumpgot;

# mark all of the segments that we don't have in got[] as unable to be
# anything in nums[] - because we know the segments we have must contain
# all of the nums[]
var mcbe = func(nums, n) {
	var i;

	while (n--) {
		i = 0;
		while (i != 7) {
			if (!got[i] && !cantbe[i][nums[n]]) {
				#dumpgot();
				#printf("  -> %c can't be %c\n", [i+'a', nums[n]+'a']);
				cantbe[i][nums[n]] = 1;
			};
			i++;
		};
	};
};

# mark "must be" - all of the segments in got[] must be one of the
# segments named in nums[]
var havenum = malloc(7);
var mmb = func(nums, n) {
	memset(havenum, 0, 7);
	while (n--) havenum[nums[n]] = 1;
	var i = 0;
	var j;
	while (i != 7) {
		j = 0;
		while (j != 7) {
			if (!havenum[j] && got[i] && !cantbe[i][j]) {
				#dumpgot();
				#printf(" -> %c can't be %c because it must be in nums[]\n", [i+'a', j+'a']);
				cantbe[i][j] = 1;
			};
			j++;
		};
		i++;
	};
};

var newnum = func() {
	if (ngot == 2) { mcbe([2,5], 2); mmb([2,5], 2); }; # 1
	if (ngot == 4) { mcbe([1,2,3,5], 4); mmb([1,2,3,5], 4); }; # 4
	if (ngot == 3) { mcbe([0,2,5], 3); mmb([0,2,5], 3); }; # 7
	if (ngot == 5) { mcbe([0,3,6], 3); }; # 2,3,5
	if (ngot == 6) { mcbe([0,1,5,6], 4); }; # 0,6,9
	ngot = 0;
	memset(got, 0, 7);
};

var answer = bignew(0);
var output = 0;

var newline = func() {
	printf("output=%d\n", [output]);
	bigaddw(answer, output);
	output = 0;
	on_output = 0;
	var i = 0;
	while (i != 7) {
		memset(cantbe[i], 0, 7);
		i++;
	};
	ngot = 0;
	newnum();
	printf("----\n", 0);
};

dumpgot = func() {
	var i = 0;
	while (i != 7) {
		if (got[i]) putchar(i+'a');
		i++;
	};
	putchar('\n');
};

var canhave = malloc(7);
var whatnum = func() {
	if (ngot == 0) return 0;

	if (ngot == 2) return 1;
	if (ngot == 4) return 4;
	if (ngot == 3) return 7;
	if (ngot == 7) return 8;

	#dumpgot();

	# which segments can we have?
	memset(canhave, 0, 7);
	var i = 0;
	var can;
	var j;
	while (i != 7) {
		can = 0;
		j = 0;
		while (j != 7) {
			# ideally, cantbe[n][m] should be true for 6 m's for each n, meaning each n can be exactly 1 segment
			if (got[j] && !cantbe[j][i]) {
				#printf("can have %c because input %c can be %c\n", [i+'a', j+'a', i+'a']);
				can = 1;
				break;
			};
			j++;
		};
		if (can) canhave[i] = 1;
		i++;
	};

	if (ngot == 5) { # 2,3,5
		if (canhave[2] && canhave[5]) return 3;
		if (canhave[1] && canhave[5]) return 5;
		if (canhave[2] && canhave[4]) return 2;
		assert(0, "illegal 5-segment", 0);
	} else if (ngot == 6) { # 6,9
		if (canhave[2] && canhave[3]) return 9;
		if (canhave[2] && canhave[4]) return 0;
		if (canhave[3] && canhave[4]) return 6;
		assert(0, "illegal 6-segment", 0);
	} else {
		assert(0, "illegal %d-segment", [ngot]);
	};
};

var used = malloc(7);
var dfs = func(inputseg) {
	if (inputseg == 7) return 1;

	var i = 0;
	var oldcantbe = malloc(7);
	while (i != 7) {
		if (!used[i] && !cantbe[inputseg][i]) {
			memcpy(oldcantbe, cantbe[inputseg], 7);
			memset(cantbe[inputseg], 1, 7);
			cantbe[inputseg][i] = 0;
			used[i] = 1;
			if (dfs(inputseg+1)) {
				free(oldcantbe);
				return 1;
			};
			used[i] = 0;
			memcpy(cantbe[inputseg], oldcantbe, 7);
		};
		i++;
	};

	free(oldcantbe);
	return 0;
};

var computemapping = func() {
	memset(used, 0, 7);
	assert(dfs(0), "dfs found no solution\n", 0);
};

newline();

while (1) {
	ch = bgetc(in);
	if (ch == EOF) break;
	if (isalpha(ch)) {
		if (!got[ch-'a']) ngot++;
		got[ch-'a'] = 1;
	} else if (ch == '|') {
		on_output = 1;
		computemapping();
	} else if (ch == ' ') {
		# number terminated
		if (on_output) output = mul(10, output) + whatnum();
		newnum();
	} else if (ch == '\n') {
		# number terminated
		output = mul(10, output) + whatnum();
		newline();
	};
};

printf("%b\n", [answer]);
