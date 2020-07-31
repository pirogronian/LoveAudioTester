
local class = require('thirdparty/middleclass/middleclass');

local Item = class("Item");

function Item:initialize(data, parent)
    if type(data) == 'table' then
        self.id = data.id;
        selfparent = data.parent
    else
        self.id = data;
        self.parent = parent;
    end
end

function Item:getSerializableData()
    local data = { id = self.id };
    if self.parent ~= nil then
        data.parent = self.parent.id;
    end
    return data;
end

function Item:__tostring()
    return tostring(self.id);
end

return Item;
