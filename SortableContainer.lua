
local Utils = require('Utils');

local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

local SortableContainer = Class("SortableContainer");

SortableContainer.static.instances = {};

function SortableContainer:initialize(id, ItemClass)
    SortableContainer.static.instances[ItemClass.name] = self;
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
    else
--         if parent.class == nil then -- serializable data, probably loading phase
--             if parent.classname then
--                 local parentcon = SortableContainer.static.instances[parent.classname];
--                 if parentcon then
--                     parent = parentcon:getItem(parent.id, parent.parent);
--                 end
--             end
--         end
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
            currentAttribute = self.currentAttribute,
            items = {}};
    for gid, group in pairs(self.groups) do
        for id, item in pairs(group.ids) do
            local itemdata = item:getSerializableData();
            if selection ~= nil and selection:has(item) then
                itemdata.selected = true;
            end
            table.insert(data.items, itemdata);
        end
    end
    return data;
end

function SortableContainer:LoadState(data, selection)
    if data == nil then return end
--     local err = false;
--     local parent = nil;
--     if data.items == nil then return err; end
--     for _, itemdata in pairs(data.items) do
--         if itemdata.parent then
--             local parentdata = Utils.TryValue(itemdata.parent, nil, 'table', 'warning');
--             if parentdata == nil then
--                 print("Warning:", self, "Cannot get parent item:", itemdata.parent.id);
--                 err = true; -- need to abort item loading
--             else
--                 local parentclass = parentdata.classname;
--                 if parentclass == nil then
--                     print("Warning:", self, "Cannot get parent item class.");
--                     err = true; -- need to abort item loading
--                 else
--                     local parentcontainer = SortableContainer.static.instances[parentclass];
--                     if parentcontainer == nil then
--                         print("Warning:", self, "Cannot get parent container for class: "..tostring(parentclass));
--                         err = true; -- need to abort item loading
--                     else
--                         parent = parentcontainer:getItem(
--                             Utils.TryValue(parentdata.id, nil, 'string', 'warning'), 
--                             Utils.TryValue(parentdata.parent, nil, 'string', 'warning'));
--                         if parent == nil then
--                             print("Warning:", self, "Cannot get parent item:", itemdata.parent.id);
--                             err = true; -- need to abort item loading
--                         end
--                     end
--                 end
--             end
--         end
--         if not err then
--             local status, value = pcall(self.ItemClass.new, self.ItemClass, itemdata, parent);
--             if status then
--                 local item = value;
--                 if item ~= nil then
--                     self:addItem(item, parent);
--                     if itemdata.selected then
--                         selection:addSingle(item);
--                     end
--                 else
--                     print("Warning:", self, "Cannot recreate item:", key);
--                     err = true;
--                 end
--             else
--                 print("Warning:", self, "Cannot create item:", key, value);
--                 err = true;
--             end
--         end
--     end
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
