include "bufio.sl";
include "bigint.sl";

var in = bfdopen(0, O_READ);

var snail = func() {
	var ch = bgetc(in);
	if (ch == EOF) return 0;
	if (isdigit(ch)) return ch - '0';
	assert(ch == '[', "need open paren: %c\n", [ch]);
	var left = snail();
	ch = bgetc(in);
	assert(ch == ',', "need comma: %c\n", [ch]);
	var right = snail();
	ch = bgetc(in);
	assert(ch == ']', "need close paren: %c\n", [ch]);
	return cons(left,right);
};

var dump = func(s) {
	if (s gt 0x100) {
		putchar('[');
		dump(s[0]);
		putchar(',');
		dump(s[1]);
		putchar(']');
	} else {
		printf("%d", [s]);
	};
};

var addtoleafl = func(s, n) {
	if (s[0] lt 0x100) {
		s[0] = s[0] + n;
		return 1;
	};
	return addtoleafl(s[0], n);
};

var addtoleafr = func(s, n) {
	if (s[1] lt 0x100) {
		s[1] = s[1] + n;
		return 1;
	};
	return addtoleafr(s[1], n);
};

var explode = func(sptr, l, r, levels) {
    var s = *sptr;
	if (s lt 0x100) return 0;
	if (levels > 0) {
		if (explode(s+0, l, s+1, levels-1)) return 1;
		if (explode(s+1, s+0, r, levels-1)) return 1;
		return 0;
	};

	# do the explosion
	if (l) {
		if (*l lt 0x100) *l = *l + s[0]
		else addtoleafr(*l, s[0]);
	};
	if (r) {
		if (*r lt 0x100) *r = *r + s[1]
		else addtoleafl(*r, s[1]);
	};

	#snailfree(s)
	*sptr = 0;

	return 1;
};

var split = func(sptr) {
	var s = *sptr;
	var s2;
	if (s lt 0x100) {
		if (s < 10) return 0;
		s2 = shr(s,1);
		*sptr = cons(s2,s-s2);
		return 1;
	};
	if (split(s+0)) return 1;
	if (split(s+1)) return 1;
	return 0;
};

var reduce = func(sptr) {
	while (1) {
		if (explode(sptr, 0, 0, 4)) continue;
		if (split(sptr)) continue;
		break;
	};
};

var snailmul = func(s) {
	if (s lt 0x100) return bignew(s);
	var b = snailmul(s[0]);
	bigmulw(b,3);
	var b2 = snailmul(s[1]);
	bigmulw(b2,2);
	bigadd(b, b2);
	bigfree(b2);
	return b;
};

var s = snail();
reduce(&s); dump(s); putchar('\n');
assert(bgetc(in) == '\n', "need newline\n", 0);
var s2;

while (1) {
	s2 = snail();
	if (!s2) break;
	s = cons(s, s2);
	reduce(&s);
	dump(s); putchar('\n');
	assert(bgetc(in) == '\n', "need newline\n", 0);
};

dump(s); putchar('\n');

printf("%b\n", [snailmul(s)]);
