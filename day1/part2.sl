include "stdio.sl";

var deptha = 10000;
var depthb = 10000;
var depthc;
var prevdepth = 0x7fff;
var n = 0;
while (scanf("%d", [&depthc])) {
	if ((deptha+depthb+depthc) > prevdepth) n++;
	prevdepth = deptha+depthb+depthc;
	deptha = depthb;
	depthb = depthc;
};
printf("%d\n", [n]);
