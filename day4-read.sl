include "bufio.sl";

var in = bfdopen(0, O_READ);

var ptr = 0xc000;
var lenp = 0xbfff;

var n = 0;

while (bscanf(in, " %d", [ptr])) {
	ptr++;
	n++;
};

*lenp = n;
