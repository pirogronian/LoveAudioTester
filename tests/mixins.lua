
local class = require('../thirdparty/middleclass/middleclass');

local mixin = { static = {} };

mixin.static.sv = 1;

mixin.static.st = {};

function mixin.static:setV(var)
    self.static.sv = var;
end

function mixin.static:getV()
    return self.sv;
end

local mclass = class("MClass");

mclass.static.spv = "b";

mclass:include(mixin);

assert(mclass:getV() == 1);

mclass:setV("a");

assert(mclass:getV() == "a");

assert(mclass.spv == "b");
assert(mclass.static.spv == "b");
