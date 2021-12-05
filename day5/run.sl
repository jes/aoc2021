include "stdio.sl";

var readanswer = func(name) {
	var fd = open(name, O_READ);
	assert(fd >= 0, "open %s: %s", [name, strerror(fd)]);
	var n;
	fscanf(fd, "%d", [&n]);
	close(fd);
	return n;
};

printf("split input into blocks of 350x350...\n", 0);
system(["./split", "350", "input"]);
printf("split each block into blocks of 117x117...\n", 0);
var i = 0;
while (i < 9) {
	system(["./split", "117", sprintf("input.%d", [i])]);
	putchar('.');
	i++;
};
putchar('\n');
var y = 0;
var x;
var partargs = malloc(100);
i = 1;
while (y < 9) {
	x = 0;
	while (x < 9) {
		partargs[i++] = sprintf("input.%d.%d", [y,x]);
		x++;
	};
	y++;
};
partargs[i] = 0;
printf("run part1 on all 81 inputs...\n", 0);
partargs[0] = "./part1";
system(partargs);
partargs[0] = "./part2";
printf("run part2 on all 81 inputs...\n", 0);
exec(partargs);
