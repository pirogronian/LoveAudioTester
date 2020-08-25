
local class = require('thirdparty/middleclass/middleclass');

local Set = require('Set');

local Mapper = require('Mapper');

local d = class("Diagram");

function d:initialize(container)
    self._cont = container;
    self._axisMap = Mapper(1, 2);
    self._transform = love.math.newTransform();
    self._sitems = Set();
    self._transform:scale(10);
end

function d:addSourceItem(sitem)
    if sitem:isMono() then
        self._sitems:addSingle(sitem);
    end
end

function d:removeSourceItem(sitem)
    self._sitems:removeSingle(sitem);
end

function d:hasSourceItem(sitem)
    return self._sitems:has(sitem);
end

function d:drawSourceItem(sourceitem)
    local x, y, z = sourceitem:getPosition();
    x, y = self._axisMap:map(x, y, z);
    x, y = self._transform:transformPoint(x, y);
    love.graphics.push();
    love.graphics.translate(x, y);
    love.graphics.circle("fill", 0, 0, 5)
    love.graphics.print(sourceitem.id);
    love.graphics.pop();
end

function d:draw()
    love.graphics.push();
    local w, h = love.window.getMode();
    love.graphics.translate(w / 2, h / 2);
    for key, item in pairs(self._sitems:get()) do
        self:drawSourceItem(item);
    end
    love.graphics.pop();
end

return d;
