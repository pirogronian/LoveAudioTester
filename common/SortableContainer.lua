
local Utils = require('common/Utils');

local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('common/Signal');

local SortableContainer = Class("SortableContainer");

function SortableContainer:initialize(id, ItemClass)
    self.indexes = {};
    self.groups = {};
    self.id = id;
    self.ItemClass = ItemClass;
    self.itemCount = 0;
    self.itemAdded = Signal();
    self.itemRemoved = Signal();
    self.itemsSorted = Signal();
    self.creationError = Signal();
    for attrid, attr in pairs(self.ItemClass.attributes) do
        self.indexes[attr.id] = {};
        if self.currentAttribute == nil then
            self.currentAttribute = attr.id;
        end
    end
end

function SortableContainer:groupId(groupid)
    if groupid == nil then
        return "DefaultGroup";
    end
    return groupid;
end

function SortableContainer:getIndex(attrid, groupid, noerror)
    if self.indexes[attrid] == nil then
        if noerr then
            print("Warning:", self.class.name..": attribute \""..attrid.."\" not found in indexes.")
        else
            error(self.class.name..": attribute \""..attrid.."\" not found in indexes.");
        end
    end
    groupid = self:groupId(groupid)
    if self.indexes[attrid][groupid] == nil then
        self.indexes[attrid][groupid] = {};
    end
    return self.indexes[attrid][groupid];
end

function SortableContainer:getAttribute(id)
    local attr = self.ItemClass.attributes[id];
    if type(attr) == nil then
        error(self.class.name..": attribute \""..id.."\" not found in attributes.");
    end
    return attr;
end

function SortableContainer:addItem(item)
--     print("addItem("..Utils.DumpStr(item)..", "..Utils.DumpStr(groupid)..")");
    groupid = self:groupId(item.parent);
    if self.groups[groupid] == nil then
        self.groups[groupid] = { ids = { }, n = 1 };
        self.groups[groupid].ids[item.id] = item;
    else
        self.groups[groupid].n = self.groups[groupid].n + 1;
        if self.groups[groupid].ids[item.id] ~= nil then
            print(self.class.name..":addItem("..tostring(item.id).."): item already exists!");
            return
        end
        self.groups[groupid].ids[item.id] = item;
    end
    for attrid, attr in pairs(self.ItemClass.attributes) do
        local index = self:getIndex(attrid, groupid);
        local entry = { attribute = item.attributes[attrid], item = item };
        table.insert(index, entry);
    end
    item.container = self;
    self.itemCount = self.itemCount + 1;
    self:sort(self.currentAttribute, self.currentDir);
    self.itemAdded:emit(item);
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
--     self.selected[item] = nil;
    self.groups[groupid].ids[item.id] = nil;
    self.groups[groupid].n = self.groups[groupid].n - 1;
    self.itemCount = self.itemCount - 1;
    if self.childContainer then
        self.childContainer:deleteGroup(item);
    end
--     self:dumpIds(groupid);
    self.itemRemoved:emit(item);
end

function SortableContainer:deleteGroup(groupid)
    local group = self.groups[groupid];
    if group == nil then return; end
    for id, item in pairs(group.ids) do
        self:deleteItem(item);
    end
end

function SortableContainer:getItem(id, parent)
    if parent == nil then
        parent = self:groupId(nil);
    end
    local group = self.groups[parent];
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

function SortableContainer:deleteSet(set)
    for item, _ in pairs(set:get()) do
        self:deleteItem(item);
    end
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
    for gid, _ in pairs(self.groups) do
        local index = self:getIndex(attrid, gid);
        table.sort(index, comp);
    end
    self.currentAttribute = attrid;
    self.currentDir = dir;
    self.itemsSorted:emit();
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

function SortableContainer:DumpState(selection)
    local data = {
            currentDir = self.currentDir,
            currentAttribute = self.currentAttribute};
    return data;
end

function SortableContainer:LoadState(data, selection)
    if data == nil then return end
    self.currentAttribute = data.currentAttribute;
    if self:getAttribute(self.currentAttribute, nil, true) == nil then
        self.currentAttribute = nil;
        err = true;
    end
    self.currentDir = data.currentDir;
    self:sort(self.currentAttribute, self.currentDir);
    return err;
end

return SortableContainer;
