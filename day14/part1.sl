include "bufio.sl";

var in = bfdopen(0, O_READ);
var template = malloc(128);

bgets(in, template, 128);
template[strlen(template)-1] = 0;

var map = malloc(10);
var i = 0;
while (i < 10) {
	map[i] = malloc(10);
	memset(map[i], -1, 10);
	i++;
};

var letterch = malloc(10);
var nletters = 0;
var letter = func(c) {
	var i = 0;
	while (i < nletters) {
		if (letterch[i] == c) return i;
		i++;
	};
	letterch[nletters] = c;
	return nletters++;
};

var left;
var right;
var replace;
while (bscanf(in, " %c%c -> %c", [&left, &right, &replace])) {
	map[letter(left)][letter(right)] = letter(replace);
};

var count = zmalloc(10);

var runpair = func(l, r, levels) {
	if (levels == 0) {
		count[l] = count[l] + 1;
		count[r] = count[r] + 1;
		return 0;
	};
	assert(map[l][r] != -1, "map[%d][%d] = -1\n", [l,r]);
	runpair(l, map[l][r], levels-1);
	runpair(map[l][r], r, levels-1);
};

i = 0;
while (template[i+1]) {
	runpair(letter(template[i]), letter(template[i+1]), 10);
	i++;
};

var min = 0x7fff;
var max = 0;
i = 0;
while (i < nletters) {
	if (count[i] < min) min = count[i];
	if (count[i] > max) max = count[i];
	i++;
};

printf("%d\n", [max-min]);
