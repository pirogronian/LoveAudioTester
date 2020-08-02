
local Item = require('Item');

local SItem = Item:subclass("SourceItem");

function SItem:initialize(data, parent)
    local id = data;
    local playPos = 0;
    if type(data) == 'table' then
        id = data.id;
        parent = data.parent;
        playPos = data.source.playPos;
    end
    Item.initialize(self, id, parent);
    self.attributes = { name = id };
    self.source = love.audio.newSource(self.parent.id, "static");
    self.source:seek(playPos);
end

function SItem:getSerializableData()
    local data = Item.getSerializableData(self);
    local sdata = {};
    sdata.playPos = self.source:tell();
    data.source = sdata;
    return data;
end

return SItem;
