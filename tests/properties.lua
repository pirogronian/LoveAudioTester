
local class = require('../thirdparty/middleclass/middleclass');

local props = require('../Properties');

local propclass = class('PropClass');

propclass:include(props);

function propclass:setVar1(a)
    print("setVar1", a)
    self._var1 = a;
end

function propclass:getVar1()
    print("getVar1", self._var1)
    return self._var1;
end

local pci = propclass();

-- pci:setVar1(1);
print(1);
pci.Var1 = 13;
print(2);
assert(pci.Var1 == 13);
print(3);
assert(pci:getVar1() == 13);
print(4);
pci.Var1 = "a";

assert(pci.Var1 == "a");
assert(pci:getVar1() == "a");
--[[
function listMethods(t)
    for key, val in pairs(t) do
        if type(val) == 'function' then
            print(key)
        end
    end
end

local mt = {};

function mt.__index(self, key)
    print(self, "__index", key);
    listMethods(self);
    local getter = rawget(self, "get" .. key);
    print("getter", getter);
    if type(getter) == 'function' then
        return getter(self);
    else
        print("   rawget");
        return rawget(self, key)
    end
end


function mt.__newindex(self, key, val)
    print(self, "__newIndex", key, val);
    listMethods(self);
    local setter = rawget(self, "set" .. key);
    print("setter", setter);
    if type(setter) == 'function' then
        return setter(self, key, val);
    else
        print("   rawset");
        return rawset(self, key, val)
    end
end

function propclass:initialize()
    self:setVar1(0);
    local smt = getmetatable(self);
    smt.__index = mt.__index;
    smt.__newindex = mt.__newindex;
end

function propclass:setVar1(a)
    print("setVar1", a)
    self._var1 = a;
end

function propclass:getVar1()
    print("getVar1", self._var1)
    return self._var1;
end

local pci = propclass();

print(1);
print(pci.Var1);
print(2);
pci.Var1 = 1;
print(3);
print(pci.Var1);
print(4);]]
