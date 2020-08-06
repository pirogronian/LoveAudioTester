
local Utils = require('Utils');

local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

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

function SortableContainer:initialize(id, name, itemclass)
    self.indexes = {};
    self.attributes = {};
    self.groups = {};
    self.selected = {};
    self.id = id;
    self.name = name;
    self.ItemClass = itemclass;
    self.itemCount = 0;
    self.attributeAdded = Signal();
    self.attributeRemoved = Signal();
    self.itemAdded = Signal();
    self.itemRemoved = Signal();
    self.creationError = Signal();
end

function SortableContainer:addAttribute(attr)
    self.attributes[attr.id] = attr;
    self.indexes[attr.id] = {};
    if self.currentAttribute == nil then
        self.currentAttribute = attr.id;
    end
    self.attributeAdded:emit(attr);
end

function SortableContainer:deleteAttribute(id)
    local attr = self.attributes[id];
    if attr == nil then return; end
    self.attributes[id] = nil;
    self.indexes[id] = nil;
    self.attributeRemoved:emit(attr);
end

function SortableContainer:groupId(groupid)
    if groupid == nil then
        return "DefaultGroup";
    end
    return groupid;
end

function SortableContainer:getIndex(attrid, groupid)
    if self.indexes[attrid] == nil then
        error(self.class.name..": attribute \""..attrid.."\" not found in indexes.");
    end
    groupid = self:groupId(groupid)
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
--     print("addItem("..Utils.DumpStr(item)..", "..Utils.DumpStr(groupid)..")");
    groupid = self:groupId(groupid);
    if self.groups[groupid] == nil then
        self.groups[groupid] = { ids = { }, n = 1 };
        self.groups[groupid].ids[item.id] = item;
    else
        self.groups[groupid].n = self.groups[groupid].n + 1;
        if self.groups[groupid].ids[item.id] ~= nil then
            error(self.class.name..":addItem("..tostring(item.id).."): item already exists!");
        end
        self.groups[groupid].ids[item.id] = item;
    end
    for attrid, attr in pairs(self.attributes) do
        local index = self:getIndex(attrid, groupid);
        local entry = { attribute = item.attributes[attrid], item = item };
        table.insert(index, entry);
    end
    item.container = self;
    self.itemCount = self.itemCount + 1;
    self.itemAdded:emit(item);
end

function SortableContainer:createItem(...)
    local status, value = pcall(self.ItemClass.new, self.ItemClass, ...);
    if status then
        self:addItem(value, value.parent);
        return value;
    end
    self.creationError:emit(value);
end

function SortableContainer:deleteItem(item)
    if not self:hasItem(item) then
        print("Warning: no item for delete:", Utils.DumpStr(item), "parent:", Utils.DumpStr(item.parent));
        return;
    end
    local groupid = item.parent;
    groupid = self:groupId(groupid);
    item.container = nil;
    for attrid, groups in pairs(self.indexes) do
        local index = self:getIndex(attrid, groupid);
        for idx, xitem in ipairs(index) do
            if xitem.item.id == item.id then
                table.remove(index, idx);
                break;
            end
        end
    end
    self.selected[item] = nil;
    self.groups[groupid].ids[item.id] = nil;
    self.groups[groupid].n = self.groups[groupid].n - 1;
    self.itemCount = self.itemCount - 1;
    if self.childContainer then
        self.childContainer:deleteGroup(item);
    end
--     self:dumpIds(groupid);
    self.itemRemoved:emit(item);
end

function SortableContainer:getItem(id, parent)
    local groupid = parent;
    if parent == nil then
        groupid = self:groupId(groupid);
    else
        if parent.class == nil then -- serializable data, probably loading phase
            parent = self.parentContainer:getItem(parent.id, parent.parent);
        end
    end
    local group = self.groups[groupid];
    if group == nil then return nil; end
    return group.ids[id];
end

function SortableContainer:hasItemId(id, groupid)
    return self:getItem(id, groupid) ~= nil;
end

function SortableContainer:hasItem(item)
    return self:getItem(item.id, item.parent) ~= nil;
end

function SortableContainer:getItemCount(groupid)
    if groupid == nil then
        return self.itemCount;
    else
        if self.groups[groupid] == nil then
            return 0;
        else
            return self.groups[groupid].n;
        end
    end
end

function SortableContainer:deleteSelected()
--     self:dumpSelection();
    for item, selected in pairs(self.selected) do
        if selected then
--             print("deleteing selected", item, item.class);
            self:deleteItem(item);
        end
    end
end

function SortableContainer:select(item)
    self.selected[item] = true;
    self.lastSelected = item;
end

function SortableContainer:deselect(item)
    self.selected[item] = nil;
    if self.lastSelected == item then
        self.lastSelected = nil;
    end
end

function SortableContainer:isSelected(item)
    return self.selected[item] == true;
end

function SortableContainer:toggleSelection(item)
    if self:isSelected(item) then
        self:deselect(item);
    else
        self:select(item);
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

function SortableContainer:deleteGroup(gid)
    local ret = 0;
    local group = self.groups[gid];
    if group == nil then
        print(self, "Warning: No such group:", Utils.DumpStr(gid, 0));
        return ret;
    end
    for id, item in pairs(group.ids) do
        self:deleteItem(item);
        ret = ret + 1;
    end
    self.groups[gid] = nil;
    return ret;
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
    print("Attributes:");
    for id, attr in pairs(self.attributes) do
        attr:dump();
    end
end

function SortableContainer.dumpIndexArray(array)
    for idx, item in ipairs(array) do
        print("["..idx.."] => { id: ", item.item.id, ", attribute: ", item.attribute, " }");
    end
end

function SortableContainer:dumpIndex(attrid, groupid)
    if groupid == nil then
        groupid = "DefaultGroup";
    end
    local index = self:getIndex(attrid, groupid);
    print("Index of group \"", groupid, type(groupid), "\"(", table.getn(index), "):");
    self.dumpIndexArray(index);
end

function SortableContainer:dumpIndexes(groupid)
    for key, index in pairs(self.indexes) do
        print(key, index);
        if groupid == true then
            for gid, group in pairs(index) do
                self:dumpIndex(key, gid);
            end
        else
            self:dumpIndex(key, groupid);
        end
    end
end

function SortableContainer:dumpSelection()
    print("Selected ("..self:selectedNumber().."):");
    for item, selected in pairs(self.selected) do
        print("   ["..tostring(item).."] =>", selected);
    end
end

function SortableContainer:dumpIds(groupid)
    groupid = self:groupId(groupid);
    if self.groups[groupid] == nil then
        print(self, "dumpIds: No such group:", groupid);
        return;
    end
    print("Group:", groupid, type(groupid), "size:", self.groups[groupid].n);
    for item, val in pairs(self.groups[groupid].ids) do
        print(item, type(item), val, type(val));
    end
end

function SortableContainer:dumpGroups()
    print("Items:", self.itemCount)
    for gid, group in pairs(self.groups) do
        self:dumpIds(gid);
    end
end

function SortableContainer:DumpState()
    local data = {
            currentAttribute = self.currentAttribute,
            items = {}};
    for gid, group in pairs(self.groups) do
        for id, item in pairs(group.ids) do
            local itemdata = item:getSerializableData();
            if self:isSelected(item) then
                itemdata.selected = true;
            end
            table.insert(data.items, itemdata);
        end
    end
    return data;
end

function SortableContainer:LoadState(data)
    if data == nil then return end
    local err = false;
    local parent = nil;
    self.currentAttribute = data.currentAttribute;
    if data.items == nil then return err; end
    for _, itemdata in pairs(data.items) do
        if itemdata.parent then
            parent = self.parentContainer:getItem(itemdata.parent.id, itemdata.parent.parent);
            if parent == nil then
                print("Warning:", self, "Cannot get parent item:", itemdata.parent.id);
                err = true; -- need to abort item loading
            end
        end
        if not err then
            local status, value = pcall(self.ItemClass.new, self.ItemClass, itemdata, parent);
            if status then
                local item = value;
                if item ~= nil then
                    self:addItem(item, parent);
                    if itemdata.selected then
                        self:select(item);
                    end
                else
                    print("Warning:", self, "Cannot recreate item:", key);
                    err = true;
                end
            else
                print("Warning:", self, "Cannot create item:", key, value);
                err = true;
            end
        end
    end
    return err;
end

return SortableContainer;
