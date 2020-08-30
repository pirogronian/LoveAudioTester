
local class = require('thirdparty/middleclass/middleclass');

local u = require('Utils');

local am = class("Mapper");

function am:initialize(...)
    self:clear();
    self:set(...);
end

function am:clear()
    self._map = {};
    self._n = 0;
end

function am:setArray(t)
    for key, val in ipairs(t) do
        self:setSingle(key, val);
    end
end

function am:set(...)
    local i = 1;
    while i <= select("#", ...) do
        self:setSingle(i, select(i, ...));
        i = i + 1;
    end
--     self:printDebug();
end

function am:get()
    return unpack(self._map);
end

function am:getArray()
    return self._map;
end

function am:getSingleArray(pos)
    local t = {};
    for k, v in pairs(self._map) do
        if v == pos then
            table.insert(t, k);
        end
    end
    return t;
end

function am:getSingle(pos)
    return unpack(self:getSingleArray(pos));
end

function am:getSingleReverse(npos)
    return self._map[npos];
end

function am:removeSingleReverse(npos)
    if self._map[npos] ~= nil then
        self._n = self._n - 1;
    end
    self._map[npos] = nil;
end

function am:setSingle(pos, npos)
    if self._map[npos] == nil then
        self._n = self._n + 1;
    end
    self._map[npos] = pos;
--     self:printDebug();
end

function am:map(...)
    return u.Unpack(self:mapArray(...));
end

function am:mapArray(...)
    local ret = { max = 0 };
    for npos, pos in pairs(self._map) do
        ret[npos] = select(pos, ...);
        if npos > ret.max then ret.max = npos; end
    end
    return ret;
end

function am:printDebug()
    print("Map size:", self._n);
    for key, val in pairs(self._map) do
        print(key, "<=", val)
    end
end

return am;
