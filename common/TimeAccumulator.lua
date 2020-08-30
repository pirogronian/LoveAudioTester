
local class = require('thirdparty/middleclass/middleclass');

local ta = class("TimeAccumulator");

function ta:initialize(period)
    self._last = love.timer.getTime();
    self._current = love.timer.getTime();
    self._period = period or 0;
end

function ta:update()
    local ret = false;
    self._current = love.timer.getTime();
    if self._current - self._last >= self._period then
        self._last = self._current;
        ret = true;
    end
    return ret;
end

function ta:passed()
    return self._current - self._last;
end

function ta:remained()
    return self._period - self._current + self._last;
end

function ta:setPeriod(p)
    self._period = p;
end

function ta:getPeriod()
    return self._period;
end

return ta;
