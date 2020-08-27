
local class = require('thirdparty/middleclass/middleclass');

local am = class("Mapper");

function am:initialize(...)
    self._map = {};
    self:setMap(...);
end

function am:setMap(...)
    local i = 1;
    while i <= select("#", ...) do
        self._map[i] = select(i, ...);
        i = i + 1;
    end
end

function am:setMapArray(a)
    self._map = a;
end

function am:getMap()
    return unpack(self._map);
end

function am:getMapArray()
    return self._map;
end

function am:map(...)
    return unpack(self:mapArray(...));
end

function am:mapArray(...)
    local ret = {};
    local i = 1;
    while i <= select("#", ...) do
        if self._map[i] ~= nil then
            ret[self._map[i]] = select(i, ...);
        end
        i = i + 1;
    end
    return ret;
end

function am:getSingleMap(pos)
    return self._map[pos];
end

function am:setSingleMap(pos, val)
    self._map[pos] = val;
end

return am;
