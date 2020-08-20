
local class = require('thirdparty/middleclass/middleclass');

local u = require('Utils');

local vg = class("VelocityGenerator");

function vg:initialize(sx, sy, sz)
    self._oldPos = { x = sx, y = sy, z = sz };
    self._pos = { x = sx, y = sy, z = sz };
    self._vel = { x = 0, y = 0, z = 0 };
    self._dtime = 0;
end

function vg:updateVelocity()
    if self._dtime <= 0 then return; end
    self._vel.x = (self._pos.x - self._oldPos.x) / self._dtime;
    self._vel.y = (self._pos.y - self._oldPos.y) / self._dtime;
    self._vel.z = (self._pos.z - self._oldPos.z) / self._dtime;
end

function vg:update(dt, x, y, z)
    self._dtime = dt;
    self._oldPos.x = self._pos.x;
    self._oldPos.y = self._pos.y;
    self._oldPos.z = self._pos.z;
    self._pos.x = x;
    self._pos.y = y;
    self._pos.z = z;
    self:updateVelocity();
end

function vg:velocity()
    return self._vel.x, self._vel.y, self._vel.z;
end

return vg;
