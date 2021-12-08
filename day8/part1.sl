include "bufio.sl";

var in = bfdopen(0, O_READ);

var got = zmalloc(7);
var answer = 0;
var ngot = 0;

var ch;
var on_output;
while (1) {
	ch = bgetc(in);
	if (ch == EOF) break;
	if (isalpha(ch)) {
		if (!got[ch-'a']) ngot++;
		got[ch-'a'] = 1;
	} else if (ch == '|') {
		on_output = 1;
	} else if (ch == ' ') {
		# number terminated
		if (on_output)
			if ((ngot == 2) || (ngot == 3) || (ngot == 4) || (ngot == 7)) answer++;
		ngot = 0;
		memset(got, 0, 7);
	} else if (ch == '\n') {
		# number terminated
		if ((ngot == 2) || (ngot == 3) || (ngot == 4) || (ngot == 7)) answer++;
		ngot = 0;
		memset(got, 0, 7);
		on_output = 0;
	};
};

printf("%d\n", [answer]);
