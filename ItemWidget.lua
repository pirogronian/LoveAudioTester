
local class = require('thirdparty/middleclass/middleclass');

local iw = class("ItemWidget");

function iw.static.basicInfo(item)
    Slab.BeginLayout(tostring(name).."ItemInfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Item class:");
    Slab.Text("Item id:");
    Slab.SetLayoutColumn(2);
    Slab.Text(item.class.name);
    Slab.Text(tostring(item.id));
    Slab.EndLayout();
end

function iw.static.update(item)
    iw.basicInfo(item);
end

return iw;
