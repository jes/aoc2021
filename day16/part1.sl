include "bufio.sl";

var in = bfdopen(0, O_READ);

var ch;
var chbit = 0;
var chbits = [0, 0x01, 0x02, 0x04, 0x08];
var nread = 0;
var readbit = func() {
	if (!chbit) {
		ch = bgetc(in);
		assert(ch != EOF, "eof on stdin\n", []);
		ch = atoibase([ch, 0], 16);
		chbit = 4;
	};
	nread++;
	return !!(ch & chbits[chbit--]);
};

# assume width <= 16
var readint = func(width) {
	var n = 0;
	while (width--)
		n = (n+n) | readbit();
	return n;
};

var readpacket;

# assume width <= 16
var readliteral = func() {
	var n = 0;
	var more = 1;
	var l = 0;
	while (more) {
		more = readbit();
		n = shl(n,4) | readint(4);
		l++;
	};
	return n;
};

var readoperator = func() {
	var type = readbit();
	var len;

	if (type) {
		# 11 bit number-of-packets
		len = readint(11);
	} else {
		# 15 bit number-of-bits
		len = readint(15);
	};

	var npackets = 0;
	var startbits = nread;
	var n;

	while (1) {
		n = readpacket();

		npackets++;
		if (type) {
			assert(npackets <= len, "read too many packets: n=%d,len=%d\n", [npackets,len]);
			if (npackets == len) break;
		} else {
			assert(nread-startbits <= len, "read too many bits: n=%d,len=%d\n", [nread-startbits,len]);
			if (nread-startbits == len) break;
		};
	};
};

var sumver = 0;
readpacket = func() {
	var version = readint(3);
	sumver = sumver + version;
	var type = readint(3);

	if (type == 4) return readliteral()
	else return readoperator();
};

readpacket();
printf("%d\n", [sumver]);
