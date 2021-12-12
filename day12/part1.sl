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

var countpaths = func(n1, n2) {
	if (n1 == n2) return 1;
	if (issmall[n1] && visited[n1]) return 0;
	visited[n1] = 1;
	var sum = 0;
	var i = 0;
	var edgesn1 = grget(edges, n1);
	while (i != grlen(edgesn1)) {
		sum = sum + countpaths(grget(edgesn1, i), n2);
		i++;
	};
	visited[n1] = 0;
	return sum;
};

printf("%d\n", [countpaths(node("start"), node("end"))]);
