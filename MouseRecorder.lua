
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
    self.positionScale = 0.01;
    self.velocityScale = 50;
    local x, y, z = sitem.source:getPosition();
    self._mappedPos = { x = x, y = y, z = z };
    x, y, z = sitem.source:getVelocity();
    self._mappedVel = { x = x, y = y, z = z };
    self._velgen = vg(x, y, z);
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
    self._mappedPos[self._map.x] = x * self.positionScale;
    self._mappedPos[self._map.y] = y * self.positionScale;
    self._sitem:setPosition(self._mappedPos.x, self._mappedPos.y, self._mappedPos.z);
    self._mappedVel[self._map.x] = x * self.velocityScale;
    self._mappedVel[self._map.y] = y * self.velocityScale;
    self._velgen:update(dt, self._mappedVel.x, self._mappedVel.y, self._mappedVel.z);
    local xv, yv, zv = self._velgen:velocity();
    self._sitem:setVelocity(xv, yv, zv);
end

return mr;
