
local lsc = {};

function lsc:callMethod(method, ...)
    if self.source then
        return self.source[method](self.source, ...);
    else
        return love.audio[method](...);
    end
end

function lsc:getVolume()
    return self:callMethod("getVolume");
end

function lsc:setVolume(v)
    if v < 0 then v = 0 end
    local ov = self:callMethod("getVolume");
    if ov ~= v then
        self:callMethod("setVolume", v);
        self.changed:emit();
    end
end

function lsc:getPosition()
    return self:callMethod("getPosition");
end

function lsc:setPosition(x, y, z)
    local ox, oy, oz = self:callMethod("getPosition");
    if ox ~= x or oy ~= y or oz ~= z then
        self:callMethod("setPosition", x, y, z);
        self.changed:emit();
    end
end

function lsc:getVelocity()
    return self:callMethod("getVelocity");
end

function lsc:setVelocity(x, y, z)
    local ox, oy, oz = self:callMethod("getVelocity");
    if ox ~= x or oy ~= y or oz ~= z then
        self:callMethod("setVelocity", x, y, z);
        self.changed:emit();
    end
end

return lsc;
