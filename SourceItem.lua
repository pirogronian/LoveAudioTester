
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
        playPos = u.TryValue(data.source.playPos, 0, 'number');
        volume = u.TryValue(data.source.volume, 100, 'number');
        looping = u.TryValue(data.source.looping, false, 'boolean');
        self:seek(playPos);
        self:setVolume(volume);
        self.source:setLooping(looping);
        self._showAdv = u.TryValue(data.showAdv, false, 'boolean');
        if self:isMono() then
            local ref = u.TryValue(data.source.refAttDist, 1, 'number');
            local max = u.TryValue(data.source.maxAttDist, math.huge, 'number');
            self.source:setAttenuationDistances(ref, max);
            local aa = u.TryValue(data.source.airAbs, 0, 'number');
            self.source:setAirAbsorption(aa);
            local x, y, z = nil;
            local pos = u.TryValue(data.source.position, nil, 'table');
            if pos ~= nil then
                x = u.TryValue(pos.x, 0, 'number');
                y = u.TryValue(pos.y, 0, 'number');
                z = u.TryValue(pos.z, 0, 'number');
                self.source:setPosition(x, y, z);
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
    if type(v) ~= 'number' then
        v = 1;
    else
        if v < 0 or v > 1 then v = 1; end
    end
    self.source:setVolume(v);
    self.changed:emit();
end

function SItem:toggleLooping()
    self.source:setLooping(not self.source:isLooping());
    self.changed:emit();
end

function SItem:getPosition(x, y, z)
    if not self:isMono() then return; end
    return self.source:getPosition();
end

function SItem:setPosition(x, y, z)
    if not self:isMono() then
        print("Warning: trying setPosition on non-mono source!");
        return;
    end
    self.source:setPosition(x, y, z);
    self.changed:emit();
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
    if self:isMono() then
        local ref, max = self.source:getAttenuationDistances();
        sdata.refAttDist = ref;
        sdata.maxAttDist = max;
        sdata.airAbs = self.source:getAirAbsorption();
        local x, y, z = self.source:getPosition();
        sdata.position = { x = x, y = y, z = z };
    end
    data.showAdv = self._showAdv;
    data.source = sdata;
    return data;
end

return SItem;
