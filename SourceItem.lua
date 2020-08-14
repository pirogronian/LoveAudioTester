
local u = require('Utils');

local Item = require('Item');

local Signal = require('Signal');

local SItem = Item:subclass("SourceItem");

SItem.static.attributes = {};

SItem:addAttribute(Item.Attribute("name", "Name"));

function SItem:initialize(data, parent)
    Item.initialize(self, data, parent);
    self.attributes = { name = self.id };
    self.played = Signal();
    self.stopped = Signal();
    self.paused = Signal();
    self.changed = Signal();
    self.source = love.audio.newSource(self.parent.id, "static");
    if type(data) == 'table' then
        local playPos = u.TryValue(data.source.playPos, 0, 'number');
        local volume = u.TryValue(data.source.volume, 100, 'number');
        local looping = u.TryValue(data.source.looping, false, 'boolean');
        local minv = u.TryValue(data.source.minVol, 0, 'number');
        local maxv = u.TryValue(data.source.maxVol, 1, 'number');
        self:seek(playPos);
        self:setVolume(volume);
        self.source:setLooping(looping);
        self.source:setVolumeLimits(minv, maxv);
        self._showAdv = u.TryValue(data.showAdv, false, 'boolean');
        if self:isMono() then
            local ref = u.TryValue(data.source.refAttDist, 1, 'number');
            local max = u.TryValue(data.source.maxAttDist, math.huge, 'number');
            self.source:setAttenuationDistances(ref, max);
            local aa = u.TryValue(data.source.airAbs, 0, 'number');
            self.source:setAirAbsorption(aa);
            local rf = u.TryValue(data.source.rolloff, 0, 'number');
            self.source:setRolloff(rf);
            local x, y, z = nil;
            local pos = u.TryValue(data.source.position, nil, 'table');
            if pos ~= nil then
                x = u.TryValue(pos.x, 0, 'number');
                y = u.TryValue(pos.y, 0, 'number');
                z = u.TryValue(pos.z, 0, 'number');
                self.source:setPosition(x, y, z);
            end
            local dir = u.TryValue(data.source.direction, nil, 'table');
            if dir ~= nil then
                x = u.TryValue(dir.x, 0, 'number');
                y = u.TryValue(dir.y, 0, 'number');
                z = u.TryValue(dir.z, 0, 'number');
                self.source:setDirection(x, y, z);
            end
        end
    end
end

function SItem:play()
    if self.source:isPlaying() then return; end
    self.source:play();
    self.played:emit();
end

function SItem:pause()
    if not self.source:isPlaying() then return; end
    self.source:pause();
    self.paused:emit();
end

function SItem:stop()
    local wasplaying = false;
    if self.source:isPlaying() then wasplaying = true; end
    self.source:stop();
    self.stopped:emit();
    if wasplaying then
        self.paused:emit();
    end
end

function SItem:seek(time, units)
    local dur = self.source:getDuration(units);
    if time < 0 then time = 0; else if dur >= 0 and time > dur then time = dur; end end
    self.source:seek(time, units);
    self.changed:emit();
end

function SItem:rewindBy(dtime, units)
    local ctime = self.source:tell(units);
    local rtime = ctime + dtime;
    self:seek(rtime);
end

function SItem:setVolume(v)
    if v < 0 then v = 0 end
    local ov = self.source:getVolume();
    if ov ~= v then
        self.source:setVolume(v);
        self.changed:emit();
    end
end

function SItem:setVolumeLimits(min, max)
    if min < 0 then min = 0 end
    if max < 0 then max = 0 end
    local omin, omax = self.source:getVolumeLimits();
    if omin ~= min or omax ~= max then
        self.source:setVolumeLimits(min, max);
        self.changed:emit();
    end
end

function SItem:toggleLooping()
    self.source:setLooping(not self.source:isLooping());
    self.changed:emit();
end

function SItem:getPosition()
    return self.source:getPosition();
end

function SItem:setPosition(x, y, z)
    local ox, oy, oz = self.source:getPosition();
    if ox ~= x or oy ~= y or oz ~= z then
        self.source:setPosition(x, y, z);
        self.changed:emit();
    end
end

function SItem:setDirection(x, y, z)
    local ox, oy, oz = self.source:getDirection();
    if ox ~= x or oy ~= y or oz ~= z then
        self.source:setDirection(x, y, z);
        self.changed:emit();
    end
end

function SItem:setAttenuationDistances(ref, max)
    local oref, omax = self.source:getAttenuationDistances();
    if oref ~= ref or omax ~= max then
        self.source:setAttenuationDistances(ref, max);
        self.changed:emit();
    end
end

function SItem:setAirAbsorption(val)
    if val < 0 then val = 0; end
    local aa = self.source:getAirAbsorption();
    if aa ~= val then
        self.source:setAirAbsorption(val);
        self.changed:emit();
    end
end

function SItem:setRolloff(val)
    if val < 0 then val = 0; end
    local rf = self.source:getRolloff();
    if rf ~= val then
        self.source:setRolloff(val);
        self.changed:emit();
    end
end

function SItem:isMono()
    return self.source:getChannelCount() == 1;
end

function SItem:setShowAdvanced(show)
    if self._showAdv ~= show then
        self._showAdv = show;
        self.changed:emit();
    end
end

function SItem:advancedVisible()
    return self._showAdv;
end

function SItem:getSerializableData()
    local data = Item.getSerializableData(self);
    local sdata = {};
    sdata.playPos = self.source:tell();
    sdata.volume = self.source:getVolume();
    sdata.looping = self.source:isLooping();
    local minv, maxv = self.source:getVolumeLimits();
    sdata.minVol = minv;
    sdata.maxVol = maxv;
    if self:isMono() then
        local ref, max = self.source:getAttenuationDistances();
        sdata.refAttDist = ref;
        sdata.maxAttDist = max;
        sdata.airAbs = self.source:getAirAbsorption();
        sdata.rolloff = self.source:getRolloff();
        local x, y, z = self.source:getPosition();
        sdata.position = { x = x, y = y, z = z };
        x, y, z = self.source:getDirection();
        sdata.direction = { x = x, y = y, z = z };
    end
    data.showAdv = self._showAdv;
    data.source = sdata;
    return data;
end

return SItem;
