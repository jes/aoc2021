include "bufio.sl";
include "bigint.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);

var ch;
var stack = malloc(1000);
var sp = 0;
var chars = [')', ']', '}', '>'];
var score = [1, 2, 3, 4];

var getscore = func(ch) {
	var i = 0;
	while (i < 4) {
		if (ch == chars[i]) {
			return score[i];
		};
		i++;
	};
	assert(0, "unrecognised score character: %c\n", [ch]);
};

var scores = grnew();
var linescore;

while (1) {
	ch = bgetc(in);
	if (ch == EOF) break;
	if (ch == '\n') {
		linescore = bignew(0);
		while (sp--) {
			bigmulw(linescore, 5);
			bigaddw(linescore, getscore(stack[sp]));
		};
		grpush(scores, linescore);
		sp = 0;
	} else if (ch == '(') {
		stack[sp++] = ')';
	} else if (ch == '{') {
		stack[sp++] = '}';
	} else if (ch == '[') {
		stack[sp++] = ']';
	} else if (ch == '<') {
		stack[sp++] = '>';
	} else if ((sp > 0) && (ch == stack[sp-1])) {
		sp--;
	} else {
		sp = 0;
		while (1) {
			ch = bgetc(in);
			if (ch == EOF) break;
			if (ch == '\n') break;
		};
	};

	assert(sp < 1000, "stack overflow", 0);
};

grsort(scores, bigcmp);

var mid = div(grlen(scores), 2);

printf("%b\n", [grget(scores, mid)]);
