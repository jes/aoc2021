include "stdio.sl";

var depth;
var prevdepth = 0x7fff;
var n = 0;
while (scanf("%d", [&depth])) {
	printf("depth = %d, prev = %d\n", [depth, prevdepth]);
	if (depth > prevdepth) n++;
	prevdepth = depth;
};
printf("%d\n", [n]);
