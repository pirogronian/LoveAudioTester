
local class = require('thirdparty/middleclass/middleclass');

local Set = require('Set');

local Mapper = require('Mapper');

local d = class("Diagram");

function d:initialize(container)
    self._cont = container;
    self._axisMap = Mapper(1, 2);
    self._transform = love.math.newTransform();
    self._sitems = Set();
    self._transform:scale(100);
    self._dirScale = 10;
    self._velScale = 10;
    self._srcColor = { 1, 1, 1, 1 };
    self._dirColor = { 0.9, 0.9, 1 };
    self._velColor = { 0.5, 0.5, 1, 1 }
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

function d:drawAxes()
    local w, h = love.window.getMode();
    w = w / 2;
    h = h / 2;
    love.graphics.line(-w, 0, w, 0);
    love.graphics.line(0, -h, 0, h);
end

function d:drawSourceItem(sourceitem)
    local x, y, z = sourceitem:getPosition();
    x, y = self._axisMap:map(x, y, z);
    x, y = self._transform:transformPoint(x, y);
    love.graphics.push();
    love.graphics.translate(x, y);
    local font = love.graphics.getFont();
    love.graphics.setColor(unpack(self._srcColor));
    love.graphics.circle("fill", 0, 0, 3)
    x, y, z = sourceitem:getDirection();
    x, y = self._axisMap:map(x, y, z);
    x = x * self._dirScale;
    y = y * self._dirScale;
    love.graphics.setColor(unpack(self._dirColor));
    love.graphics.line(0, 0, x, y);
    x, y, z = sourceitem:getVelocity();
    x, y = self._axisMap:map(x, y, z);
    x = x * self._velScale;
    y = y * self._velScale;
    love.graphics.setColor(unpack(self._velColor));
    love.graphics.line(0, 0, x, y);
    local sin = x / (x^2 + y^2)^0.5;
    local cos = y / (x^2 + y^2)^0.5;
    local angle = math.asin(sin);
    if cos > 0 then
        angle = math.pi - angle;
    end
    love.graphics.push();
    love.graphics.translate(x, y);
    love.graphics.rotate(angle);
    love.graphics.polygon("fill", 0, 0, 5, 10, -5, 10);
    love.graphics.pop();
    love.graphics.setColor(unpack(self._srcColor));
    love.graphics.print(sourceitem.id, 5);
    love.graphics.pop();
end

function d:draw()
    love.graphics.push();
    local w, h = love.window.getMode();
    love.graphics.translate(w / 2, h / 2);
    self:drawAxes();
    for key, item in pairs(self._sitems:get()) do
        self:drawSourceItem(item);
    end
    love.graphics.pop();
end

return d;
