
local m = require('../Mapper');

local u = require('../Utils');

local mi = m(3, 1);

local r = mi:mapArray("a", "b", "c");

assert(r[1] == "b");
assert(r[2] == nil);
assert(r[3] == "a");

local a, b, c = mi:map("a", "b", "c");

assert(a == "b");
assert(b == nil);
assert(c == "a");
