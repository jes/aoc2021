include "bufio.sl";
include "bigint.sl";

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

var readliteral = func() {
	var n = bignew(0);
	var more = 1;
	var l = 0;
	while (more) {
		more = readbit();
		bigmulw(n,16);
		bigaddw(n, readint(4));
		l++;
	};
	return n;
};

var op = [
#0: sum
func(a,b) bigadd(b,a),
#1: product
func(a,b) bigmul(b,a),
#2: min
func(a,b) {
	if (bigcmp(a,b) < 0) bigset(b,a);
},
#3: max
func(a,b) {
	if (bigcmp(a,b) > 0) bigset(b,a);
},
#(4: literal)
0,
#5: gt
func (a,b) {
	bigsetw(b, bigcmp(a,b)>0);
},
#6: lt
func (a,b) {
	bigsetw(b, bigcmp(a,b)<0);
},
#7: =
func (a,b) {
	bigsetw(b, bigcmp(a,b)==0);
}
];

var readoperator = func(pkttype) {
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

	var r = 0;
	var f = op[pkttype];

	while (1) {
		n = readpacket();

		if (r) {
			f(r, n);
			bigfree(r);
		};
		r = n;

		npackets++;
		if (type) {
			assert(npackets <= len, "read too many packets: n=%d,len=%d\n", [npackets,len]);
			if (npackets == len) break;
		} else {
			assert(nread-startbits <= len, "read too many bits: n=%d,len=%d\n", [nread-startbits,len]);
			if (nread-startbits == len) break;
		};
	};

	return r;
};

var sumver = 0;
readpacket = func() {
	var version = readint(3);
	sumver = sumver + version;
	var type = readint(3);

	if (type == 4) return readliteral()
	else return readoperator(type);
};

printf("%b\n", [readpacket()]);
