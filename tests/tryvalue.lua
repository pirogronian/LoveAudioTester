
local u = require('../Utils');

local table = { a = "a", b = "b", c = 1 }

assert(u.TryValue(_u) == nil);
assert(u.TryValue(_u, "def") == "def");
assert(u.TryValue(_u, "def", 'string') == "def");
assert(u.TryValue(_u, "def", 'string', 'default') == "def");
assert(u.TryValue(_u, "def", 'string', 'warning') == "def");

local status, value = pcall(u.TryValue, _u, "def", 'string', 'error');
assert(not status);
print(value);

local status, value = pcall(u.TryValue, _u, "def", 'string', '_wrong_');
assert(not status);
print(value);

assert(u.TryValue(table.a, "_a") == "a");

print("ok");
