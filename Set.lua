
local class = require('thirdparty/middleclass/middleclass')

local s = class("Set");

function s:initialize()
    self._array = {};
    self._size = 0;
--     print("Set initialize:", self, self._array, self._size);
end

function s:size()
--     print("size()", self, self._size);
    return self._size;
end

function s:has(obj)
    return self._array[obj] ~= nil;
end

function s:get()
    return self._array;
end

function s:clear()
    self._array = {};
    self._size = 0;
end

function s:addSingle(obj)
    if self._array[obj] == nil then
        self._array[obj] = obj;
        self._size = self._size + 1;
    end
end

function s:removeSingle(obj)
    if self._array[obj] ~= nil then
        self._array[obj] = nil;
        self._size = self._size - 1;
    end
end

function s:toggleSingle(obj)
    if self:has(obj) then
        self:removeSingle(obj);
    else
        self:addSingle(obj);
    end
end

function s:add(...)
    i = 1;
    while i <= select('#', ...) do
        self:addSingle(select(i, ...));
        i = i + 1;
    end
end

function s:remove(...)
    i = 1;
    while i <= select('#', ...) do
        self:removeSingle(select(i, ...));
        i = i + 1;
    end
end

function s:toggle(...)
    i = 1;
    while i <= select('#', ...) do
        self:toggleSingle(select(i, ...));
        i = i + 1;
    end
end

function s:addValues(t)
    for _, obj in pairs(t) do
        self:addSingle(obj);
    end
end

function s:removeValues(t)
    for _, obj in pairs(t) do
        self:removeSingle(obj);
    end
end

function s:toggleValues(t)
    for _, obj in pairs(t) do
        self:toggleSingle(obj);
    end
end

function s:addKeys(t)
    for obj, _ in pairs(t) do
        self:addSingle(obj);
    end
end

function s:removeKeys(t)
    for obj, _ in pairs(t) do
        self:removeSingle(obj);
    end
end

function s:toggleKeys(t)
    for obj, _ in pairs(t) do
        self:toggleSingle(obj);
    end
end

function s:dump()
    print("Set dump: size:", self._size);
    for key, value in pairs(self._array) do
        print(key, value);
    end
end

return s;
