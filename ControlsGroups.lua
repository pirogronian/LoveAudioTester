
local class = require('thirdparty/middleclass/middleclass');

local cg = class("ControlsGroups");

function cg:initialize()
    self.og = {};
end

function cg.hideButton(obj, ogr)
    if Slab.Button("Hide "..ogr.." options") then
        obj:setVisible(ogr, false);
    end
end

function cg:optionsGroup(obj, ogr)
    if not obj:getVisible(ogr) then
        if Slab.Button("Show "..ogr.." options") then
            obj:setVisible(ogr, true);
        end
        return false;
    else
        self.og[ogr](obj, ogr);
        return true;
    end
end

return cg;
