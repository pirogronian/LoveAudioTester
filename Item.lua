
local Comm = require('Communicator');

local Item = Comm:subclass("Item");

function Item:initialize(data, parent)
    if type(data) == 'table' then
        self.id = data.id;
    else
        self.id = data;
    end
    self.parent = parent;
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
