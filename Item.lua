
local Class = require('thirdparty/middleclass/middleclass');

local u = require('Utils');

local IAttribute = require('ItemAttribute');

local Item = Class("Item");

Item.static.Attribute = IAttribute;

Item.static.attributes = {};

function Item.static:addAttribute(attr)
    self.attributes[attr.id] = attr;
end

function Item.static:deleteAttribute(id)
    local attr = self.attributes[id];
    if attr == nil then return; end
    self.attributes[id] = nil;
end

function Item:initialize(data, parent)
    self.visibility = {};
    if type(data) == 'table' then
        self.id = data.id;
        self.visibility = u.TryValue(data.visibility, {}, 'table', 'warning');
    else
        self.id = data;
    end
    self.parent = parent;
    if self.parent ~= nil then
--         print("Item:", self.id, "parent:", parent, parent.class);
        if type(self.parent.class) ~= 'table' or not u.IsClassOrSubClass(self.parent.class, Item) then
            error("Item parent is not from class Item! ("..u.DumpStr(self.parent)..")");
        end
    end
end

function Item:setVisible(option, show)
    if self.visibility[option] ~= show then
        self.visibility[option] = show;
        self.changed:emit();
    end
end

function Item:getVisible(option)
    return self.visibility[option];
end

function Item:getSerializableData()
    local data = {
        id = self.id,
        classname = self.class.name,
        visibility = self.visibility };
    if self.parent ~= nil then
        data.parent = self.parent:getSerializableData();
    end
    return data;
end

function Item:__tostring()
    return tostring(self.id);
end

function Item:destroy()
end

return Item;
