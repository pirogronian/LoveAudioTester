
local Item = require('Item');

local Signal = require('Signal');

local SItem = Item:subclass("SourceItem");

function SItem:initialize(data, parent)
    local playPos = 0;
    if type(data) == 'table' then
        playPos = data.source.playPos;
    end
    Item.initialize(self, data, parent);
    self.played = Signal();
    self.stopped = Signal();
    self.paused = Signal();
    self.attributes = { name = self.id };
    self.source = love.audio.newSource(self.parent.id, "static");
    self.source:seek(playPos);
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

function SItem:rewindBy(dtime, units)
    local ctime = self.source:tell(units);
    local dur = self.source:getDuration(units);
    local rtime = ctime + dtime;
    if rtime < 0 then rtime = 0; else if dur >= 0 and rtime > dur then rtime = dur; end end
    self.source:seek(rtime, units);
end

function SItem:getSerializableData()
    local data = Item.getSerializableData(self);
    local sdata = {};
    sdata.playPos = self.source:tell();
    data.source = sdata;
    return data;
end

return SItem;
