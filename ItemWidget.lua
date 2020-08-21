
local class = require('thirdparty/middleclass/middleclass');

local iw = class("ItemWidget");

iw.static.og = {}; -- options groups

function iw.static.hideButton(item, ogr)
    if Slab.Button("Hide "..ogr.." options") then
        item:setVisible(ogr, false);
    end
end

function iw.static.optionsGroup(item, ogr)
    if not item:getVisible(ogr) then
        if Slab.Button("Show "..ogr.." options") then
            item:setVisible(ogr, true);
        end
        return false;
    else
        iw.static.og[ogr](item, ogr);
        return true;
    end
end

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
