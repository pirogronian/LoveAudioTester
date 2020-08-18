
local s = require('../Set')

local si = s();

assert(si:size() == 0);

si:dump();

si:add("A", "B", "C", "D");

si:dump();

assert(si:size() == 4);

assert(si:has("A"));
assert(si:has("B"));
assert(si:has("C"));
assert(si:has("D"));
assert(si:has("E") == false);
