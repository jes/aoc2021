include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);

var ch;
var stack = malloc(1000);
var sp = 0;
var answer = bignew(0);
var chars = [')', ']', '}', '>'];
var score = [3, 57, 1197, 25137];

var addscore = func(ch) {
	var i = 0;
	while (i < 4) {
		if (ch == chars[i]) {
			bigaddw(answer, score[i]);
			return 0;
		};
		i++;
	};
	assert(0, "unrecognised score character: %c\n", [ch]);
};

while (1) {
	ch = bgetc(in);
	if (ch == EOF) break;
	if (ch == '\n') {
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
		addscore(ch);
		while (1) {
			ch = bgetc(in);
			if (ch == EOF) break;
			if (ch == '\n') break;
		};
	};

	assert(sp < 1000, "stack overflow", 0);
};

printf("%b\n", [answer]);
