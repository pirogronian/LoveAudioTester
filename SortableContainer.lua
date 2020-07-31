
local Class = require('thirdparty/middleclass/middleclass');

local Comm = require('Communicator');

local SortableAttribute = Class("SortableAttribute");

function SortableAttribute.sortAsc(sitem1, sitem2)
    return sitem1.attribute < sitem2.attribute;
end

function SortableAttribute.sortDesc(sitem1, sitem2)
    return sitem1.attribute > sitem2.attribute;
end

function SortableAttribute:initialize(id, name)
    self.id = id;
    self.name = name;
end

function SortableAttribute:dump()
    print(self.class.name..":\n  id: "..self.id.."\n  name: "..self.name)
end

local SortableContainer = Class("SortableContainer", Comm);

SortableContainer.Attribute = SortableAttribute;

function SortableContainer:initialize(id, name)
    Comm.initialize(self);
    self.ids = {};
    self.indexes = {};
    self.attributes = {};
    self.selected = {};
    self.id = id;
    self.name = name;
    self.isSortableContainer = true;
    self:DeclareSignal("AttributeAdded");
    self:DeclareSignal("AttributeRemoved");
    self:DeclareSignal("ItemAdded");
    self:DeclareSignal("ItemRemoved");
end

function SortableContainer:addAttribute(attr)
    self.attributes[attr.id] = attr;
    self.indexes[attr.id] = {};
    if self.currentAttribute == nil then
        self.currentAttribute = attr.id;
    end
    self:EmitSignal("AttributeAdded", attr);
end

function SortableContainer:deleteAttribute(id)
    local attr = self.attributes[id];
    if attr == nil then return; end
    self.attributes[id] = nil;
    self.indexes[id] = nil;
    self:EmitSignal("AttributeRemoved", attr);
end

function SortableContainer:getIndex(attrid, groupid)
    if self.indexes[attrid] == nil then
        error(self.class.name..": attribute \""..attrid.."\" not found in indexes.");
    end
    if groupid == nil then
        groupid = "DefaultGroup";
    end
    if self.indexes[attrid][groupid] == nil then
        self.indexes[attrid][groupid] = {};
    end
    return self.indexes[attrid][groupid];
end

function SortableContainer:getAttribute(id)
    local attr = self.attributes[id];
    if type(attr) == nil then
        error(self.class.name..": attribute \""..id.."\" not found in attributes.");
    end
    return attr;
end

function SortableContainer:addItem(item, groupid)
    if self.ids[item.id] ~= nil then
        error(self.class.name..":addItem("..item.id.."): item already exists!");
    end
    self.ids[item.id] = item;
    for id, attr in pairs(self.attributes) do
        local index = self:getIndex(id, groupid);
        table.insert(index, { attribute = item.attributes[id], item = item });
    end
end

function SortableContainer:deleteItem(id, groupid)
    for attrid, groups in pairs(self.indexes) do
        if groupid == nil then
            for gid, index in pairs(groups) do
                for idx, item in ipairs(index) do
                    if item.item.id == id then
                        table.remove(index, idx);
                        break;
                    end
                end
            end
        else
            local index = self:getIndex(attrid, groupid);
            for idx, item in ipairs(index) do
                if item.item.id == id then
                    table.remove(index, idx);
                    break;
                end
            end
        end
    end
    self.selected[id] = nil;
    self.ids[id] = nil;
    self:EmitSignal("ItemRemoved", id);
end

function SortableContainer:deleteSelected()
--     self:dumpSelection();
    for id, selected in pairs(self.selected) do
        if selected then
            self:deleteItem(id);
        end
    end
end

function SortableContainer:select(id)
    self.selected[id] = true;
    self.lastSelected = id;
end

function SortableContainer:deselect(id)
    self.selected[id] = nil;
    if self.lastSelected == id then
        self.lastSelected = nil;
    end
end

function SortableContainer:isSelected(id)
    return self.selected[id] == true;
end

function SortableContainer:toggleSelection(id)
    if self:isSelected(id) then
        self:deselect(id);
    else
        self:select(id);
    end
end

function SortableContainer:selectedNumber()
    local count = 0;
    for key, value in pairs(self.selected) do
        if value == true then
            count = count + 1;
        end
    end
    return count;
end

function SortableContainer:sort(attrid, dir)
    local attr = self:getAttribute(attrid);
    local comp = nil;
    if dir == "asc" then
        comp = attr.sortAsc;
    else
        comp = attr.sortDesc;
    end
    local index = self:getIndex(attrid);
    table.sort(index, comp);
    self.currentAttribute = attrid;
end

function SortableContainer:dumpAttributes()
    print("Attributes ("..table.getn(self.attributes).."):");
    for id, attr in pairs(self.attributes) do
        attr:dump();
    end
end

function SortableContainer.dumpIndexArray(array)
    for idx, item in ipairs(array) do
        print("["..idx.."] => { id: "..item.item.id..", attribute: "..item.attribute.." }");
    end
end

function SortableContainer:dumpIndex(attrid, groupid)
    if groupid == nil then
        groupid = "DefaultGroup";
    end
    local index = self:getIndex(attrid, groupid);
    print("Index of group \""..groupid.."\"("..table.getn(index)..":");
    self.dumpIndexArray(index);
end

function SortableContainer:dumpSelection()
    print("Selected ("..self:selectedNumber().."):");
    for id, val in pairs(self.selected) do
        print("  ["..id.."] =>", val);
    end
end

function SortableContainer:dumpIds()
    print("Container set:");
    for id, val in pairs(self.ids) do
        print(id, val);
    end
end

return SortableContainer;
