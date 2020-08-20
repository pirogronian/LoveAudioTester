
local class = require('thirdparty/middleclass/middleclass')

local u = require('Utils');

-- local SIClass = require('SourceItem');

local vg = require('VelocityGenerator')

local mr = class("MouseRecorder")

function mr:initialize(sitem, xmap, ymap)
    xmap = xmap and xmap or "x";
    ymap = ymap and ymap or "y";
    self._sitem = sitem;
    self._map = { x = xmap, y = ymap };
    local x, y, z = sitem.source:getPosition();
    self._mapped = { x = x, y = y, z = z };
    self._velgen = vg(5000, x, y, z);
    self.transform = love.math.newTransform();
    self.transform:scale(0.01, 0.01)
    self.active = false;
    self.lastUpdateTime = love.timer.getTime();
end

function mr:setXMap(axis)
    self._map.x = axis;
end

function mr:setYMap(axis)
    self._map.y = axis;
end

function mr:update()
--     print("MR update for:", self._sitem);
    local time = love.timer.getTime();
    local dt = time - self.lastUpdateTime;
    if self.active ~= true then return end
    local w, h = love.window.getMode();
    local x, y = love.mouse.getPosition();
    x = x - w / 2;
    y = y - h / 2;
    x, y = self.transform:transformPoint(x, y);
    self._mapped[self._map.x] = x;
    self._mapped[self._map.y] = y;
    self._velgen:update(dt, self._mapped.x, self._mapped.y, self._mapped.z);
    self._sitem:setPosition(self._mapped.x, self._mapped.y, self._mapped.z);
    local xv, yv, zv = self._velgen:velocity();
    self._sitem:setVelocity(xv, yv, zv);
end

return mr;
