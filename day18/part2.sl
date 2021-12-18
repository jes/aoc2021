include "bufio.sl";

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

var snailfree = func(s) {
	if (s lt 0x100) return 0;
	snailfree(s[0]);
	snailfree(s[1]);
	free(s);
	return 0;
};

var snailclone = func(s) {
	if (s lt 0x100) return s;
	return cons(snailclone(s[0]), snailclone(s[1]));
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

	snailfree(s);
	*sptr = 0;

	return 1;
};

var div2 = malloc(256);
var n = 0;
while (n < 256) {
	div2[n] = shr(n,1);
	n++;
};

var split = func(sptr) {
	var s = *sptr;
	var s2;
	if (s lt 0x100) {
		if (s < 10) return 0;
		s2 = div2[s];
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
	if (s lt 0x100) return s;
	return mul(3, snailmul(s[0])) + mul(2, snailmul(s[1]));
};

var snails = malloc(110);
var nsnails = 0;
var s;
while (1) {
	s = snail();
	if (!s) break;
	snails[nsnails++] = s;
	assert(bgetc(in) == '\n', "need newline\n", 0);
};

var i = 0;

var args = cmdargs()+1;
if (*args) i = atoi(*args);

var j;
var k;
var max = 0;
while (i < nsnails) {
	printf("i=%d,N=%d; max=%u\n", [i,nsnails,max]);
	j = 0;
	while (j < nsnails) {
		if (i == j) { j++; continue; };
		s = cons(snailclone(snails[i]), snailclone(snails[j]));
		reduce(&s);
		k = snailmul(s);
		if (k > max) {
			max = k;
			printf("%u\n", [max]);
		};
		snailfree(s);
		j++;
	};
	i++;
};
