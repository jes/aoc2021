include "bufio.sl";
include "hash.sl";
include "grarr.sl";

var in = bfdopen(0, O_READ);
var l = malloc(128);
var p;

var nodes = htnew();
var nodename = malloc(1000);
var issmall = zmalloc(1000);
var nextnode = 0;
var edges = grnew();

var node = func(s) {
	var r = htgetkv(nodes, s);
	if (r) return r[1];
	nodename[nextnode] = strdup(s);
	if (islower(*s)) issmall[nextnode] = 1;
	htput(nodes, nodename[nextnode], nextnode);
	grpush(edges, grnew());
	assert(nextnode < 999, "too many nodes\n", 0);
	return nextnode++;
};

var addedge = func(s1, s2) {
	var n1 = node(s1);
	var n2 = node(s2);
	grpush(grget(edges,n1), n2);
	grpush(grget(edges,n2), n1);
};

while (bgets(in, l, 128)) {
	l[strlen(l)-1] = 0;
	p = strchr(l, '-');
	*p = 0;
	addedge(l, p+1);
};

var visited = zmalloc(1000);
var anytwice = 0;

var startn = node("start");
var endn = node("end");

var answer = bignew(0);
var extra = 0;

var countpaths = func(n1) {
	if (n1 == endn) {
		extra++;
		if (extra == 30000) {
			bigaddw(answer, extra);
			extra = 0;
		};
		return 0;
	};
	var v = visited+n1;
	if (issmall[n1])
		if (*v)
			if (anytwice)
				return 0;
	*v = (*v) + 1;
	var unanytwice = 0;
	if (issmall[n1])
		if (*v == 2) {
			unanytwice = 1;
			anytwice = 1;
		};
	var i = 0;
	var edgesn1 = grbase(grget(edges, n1));
	var len = grlen(grget(edges, n1));
	var sum = 0;
	while (len--) {
		if (edgesn1[len] - startn)
			countpaths(edgesn1[len]);
	};
	if (unanytwice) anytwice = 0;
	*v = *v - 1;
};

countpaths(startn);
bigaddw(answer, extra);
printf("%b\n", [answer]);
