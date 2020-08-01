
local Item = require('Item');

local SItem = Item:subclass("SourceItem");

function SItem:initialize(data, parent)
    local id = data;
    if type(data) == 'table' then
        id = data.id;
        parent = data.parent;
    end
    Item.initialize(self, id, parent);
    self.attributes = { name = id };
    self.source = love.audio.newSource(self.parent.id, "static");
end

return SItem;
