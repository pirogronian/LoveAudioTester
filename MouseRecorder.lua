
local class = require('thirdparty/middleclass/middleclass')

local u = require('Utils');

-- local SIClass = require('SourceItem');

local Set = require('Set');

local Mapper = require('Mapper');

local vg = require('VelocityGenerator')

local mr = class("MouseRecorder")

mr.static._activeRecorders = Set();

function mr.static:updateActiveRecorders()
    for _, r in pairs(self._activeRecorders:get()) do
--         print("update recorder:", r)
        r:update();
    end
end

function mr:initialize(sitem)
    self._sitem = sitem;
    self._mapper = Mapper(1, 2);
    self.positionScale = 0.01;
    self.velocityScale = 500;
    self._mPos = { 0, 0 };
end

function mr:initRecording()
    local x, y, z = self._sitem:getPosition();
    self._mappedPos = { x, y, z };
    local xv, yv, zv = self._sitem:getVelocity();
    self._mappedVel = { xv, yv, zv };
    self._velgen = vg(xv, yv, zv);
    self.active = false;
    self.lastUpdateTime = love.timer.getTime();
end

function mr:setActive(active)
    if active then
        self:initRecording();
        self.class.static._activeRecorders:addSingle(self);
    else
        self.class.static._activeRecorders:removeSingle(self);
    end
end

function mr:isActive()
    return self.class.static._activeRecorders:has(self);
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
--     if self.active ~= true then return end
    local w, h = love.window.getMode();
    local x, y = love.mouse.getPosition();
    x = (x - w / 2) * self.positionScale;
    y = (y - h / 2) * self.positionScale;
    local xp = self._mapper:getSingleReverse(1);
    local yp = self._mapper:getSingleReverse(2)
    if xp ~= nil then
        self._mappedPos[xp] = x;
    end
    if yp ~= nil then
        self._mappedPos[yp] = y;
    end
    self._sitem:setPosition(self._mappedPos[1], self._mappedPos[2], self._mappedPos[3]);
    self._velgen:update(dt, self._mappedPos[1], self._mappedPos[2], self._mappedPos[3]);
    local v = self._velgen:velocityArray();
    if xp ~= nil then
        self._mappedVel[xp] = v[xp] * self.velocityScale;
    end
    if yp ~= nil then
        self._mappedVel[yp] = v[yp] * self.velocityScale;
    end
    self._sitem:setVelocity(self._mappedVel[1], self._mappedVel[2], self._mappedVel[3]);
end

function mr:load(data)
    local mr = u.TryValue(data, nil, 'table', 'warning');
    if mr then
        self._mapper:setArray(u.TryValue(mr.map, { 1, 2 }, 'table'));
        self.positionScale = u.TryValue(mr.positionScale, 0.01, 'number');
        self.velocityScale = u.TryValue(mr.velocityScale, 500, 'number');
    end
end

function mr:getSerializableData()
    local data = {};
    data.map = self._mapper:getArray();
    data.positionScale = self.positionScale;
    data.velocityScale = self.velocityScale;
    return data;
end

return mr;
