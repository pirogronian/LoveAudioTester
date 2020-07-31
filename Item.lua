
local class = require('thirdparty/middleclass/middleclass');

local Item = class("Item");

function Item:initialize(id, parent)
    self.id = id;
    self.parent = parent;
end

function Item:getSeralizableData()
    return { id = id, parent = parent.id };
end

function Item:__tostring()
    return tostring(self.id);
end

return Item;
