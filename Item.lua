
local Class = require('thirdparty/middleclass/middleclass');

local u = require('Utils');

local Item = Class("Item");

function Item:initialize(data, parent)
    if type(data) == 'table' then
        self.id = data.id;
    else
        self.id = data;
    end
    self.parent = parent;
    if self.parent ~= nil then
--         print("Item:", self.id, "parent:", parent, parent.class);
        if type(self.parent.class) ~= 'table' or u.IsClassOrSubClass(self.parent.class, "Item") then
            error("Item parent is not from class Item! ("..u.DumpStr(self.parent)..")");
        end
    end
end

function Item:getSerializableData()
    local data = { id = self.id };
    if self.parent ~= nil then
        data.parent = self.parent:getSerializableData();
    end
    return data;
end

function Item:__tostring()
    return tostring(self.id);
end

return Item;
