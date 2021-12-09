include "lib/bufio.sl";

var x1;
var y1;
var x2;
var y2;

# some structs to help remember what variables contain
# struct line { x1, y1, x2, y2 };
# struct list_node { data, next };

var this_line; # line
var this_node; # list_node

var in = bfdopen(0, O_READ);

# ordered is an ordered linked list of lines in incrementing x1 order
var ordered = 0; # list_node (where data = line)
var node;
var line;

while (bscanf(in, "%d,%d -> %d,%d", [&x1, &y1, &x2, &y2]) == 4) {

    # get lower x into x1
    if (x2 < x1) {
        swap(&x1, &x2);
        swap(&y1, &y2);
    };
    # only straight lines
    if (x1 != x2 && y1 != y2) {
        continue;
    };

    this_line = malloc(4);
    this_line[0] = x1;
    this_line[1] = y1;
    this_line[2] = x2;
    this_line[3] = y2;

    this_node = malloc(2);
    this_node[0] = this_line;
    this_node[1] = 0;


    node = ordered;
    # we are the lowest line, replace ordered pointer
    if (!node || node[0][0] > x1) {
        this_node[1] = node;
        ordered = this_node;
        continue;
    };

    # find insertion point
    while (node[1]) {
        line = node[1][0];
        if (line[0] < x1) {
            node = node[1];
        } else {
            break;
        };
    };

    # insert node and join next pointer
    if (!node) {
        this_node[1] = ordered;
        ordered = this_node;
    } else if (!node[1]) {
        node[1] = this_node;
    } else {
        this_node[1] = node[1];
        node[1] = this_node;
    };
};

var out = 0;
var traces = zmalloc(1000);

var curr_line;
var curr_trace;
var on_line;

var active_count;
var n;
var new;
var new_prev;
var next_n;

var x = 0;
var y;
var max;
while (x < 1000) {

    # loop over all lines on this x coord
    while (ordered && ordered[0][0] == x) {

        curr_line = ordered;
        on_line = ordered[0];
        ordered = ordered[1];
        # get min/max y
        if (on_line[1] < on_line[3]) y = on_line[1] else y = on_line[3];
        if (on_line[1] > on_line[3]) max = on_line[1] else max = on_line[3];
        while (y <= max) {

            # list_node where data = x2
            node = malloc(2);
            node[0] = on_line[2];
            node[1] = 0;

            # add to traces on this y position
            curr_trace = traces[y];
            if (!curr_trace) {
                traces[y] = node;
            } else {
                while (curr_trace[1]) curr_trace = curr_trace[1];
                curr_trace[1] = node;
            };

            y++;
        };
        free(curr_line[0]);
        free(curr_line);
    };

    y = 0;
    # scan up the y axis
    while (y < 1000) {
        # number of lines on this y position
        active_count = 0;
        n = traces[y];
        new = 0;
        new_prev = 0;
        # loop over lines, if the line ends here then remove
        # from the list, otherwise we rebuild the list 
        while (n) {
            active_count++;
            next_n = n[1];
            if (n[0] > x) {
                if (!new) new = n
                else new_prev[1] = n;
                new_prev = n;
            } else {
               free(n);
            };
            n = next_n;
        };
        if (new_prev) new_prev[1] = 0;
        traces[y] = new;
        if (active_count > 1) out++; # more than one line intersects
        y++;
    };

    x++;
};

free(traces);
printf("%d\n", [out]);
