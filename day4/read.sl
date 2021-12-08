include "bufio.sl";

# NOTE: this assumes the input is split into the list of balls, which needs
# to be passed on stdin to part1 and part2, and the list of bingo cards,
# which needs to be passed on stdin to this program; it is annoying and messy
# and I probably won't do it like this again.

var in = bfdopen(0, O_READ);

var ptr = 0xc000;
var lenp = 0xbfff;

var n = 0;

while (bscanf(in, " %d", [ptr])) {
	ptr++;
	n++;
};

*lenp = n;
