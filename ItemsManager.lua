
local SModule = require('StateModule');

local SContainer = require('SortableContainer')

local IQueue = require('InfoQueue');

local OEMsg = require('ErrorMessage');

local IWManager = require('ItemWindowsManager');

local Utils = require('Utils');

local im = SModule:subclass("ItemsManager");

function im:initialize(id, naming, ItemClass, itemWindowFunc)
    SModule.initialize(self, id);
    self.parents = {};
    self.naming = naming;
    self.ItemClass = ItemClass;
    self.onWindowUpdate = itemWindowFunc;
    self.container = SContainer(id, ItemClass);
    self.currentItem = nil;
    self.selectMode = false;
    self.container.itemAdded:connect(self.onAddNewItem, self);
    self.container.itemRemoved:connect(self.onDeleteItem, self);
    self.container.itemSelected:connect(self.StateChanged, self);
    self.container.itemDeselected:connect(self.StateChanged, self);
    self.container.itemsSorted:connect(self.StateChanged, self);
    IWManager:registerModule(self:windowsManagerId(), self.naming.title,
                         { onWindowUpdate = self.onWindowUpdate, context = self });
end

function im:windowsManagerId()
    return self.id.."Windows";
end

function im:onClick(item)
    if not self.container:hasItem(item) then
        print(self, "Warning: clicked item is not in container:", item);
    end
    if self.selectMode then
        self.container:toggleSelection(item);
    end
    if self.currentItem ~= item then
        self.currentItem = item;
    else
        self.currentItem = nil;
--         IWManager:unsetCurrentModule(self:windowsManagerId());
    end
    if self.currentItem ~= nil then
        IWManager:setCurrentModule(self:windowsManagerId());
    end
    self:StateChanged();
end

function im:onAddNewItem(item)
--     print("New item:", item)
    self:StateChanged();
end

function im:onDeleteItem(item)
    if item == self.currentItem then
        self.currentItem = nil;
    end
    IWManager:delItem(self:windowsManagerId(), item, true);
    self:StateChanged();
end

function im:onItemLoad(id, parent)
    return self.container:getItem(id, parent);
end

function im:createItem(...)
    local status, value = OEMsg(
        "Cannot create item!",
        "An error occured while creating item of class "..tostring(self.ItemClass),
        self.ItemClass.new, self.ItemClass, ...);
    if not status then return; end
    if self.container:hasItem(value) then
        IQueue:pushMessage("Item already exists!", "Item "..tostring(value).." already exists!");
        return;
    end
    self.container:addItem(value, value.parent);
--     self.container:dumpGroups();
    return value;
end

function im:addParent(manager)
    if not Utils.IsClassOrSubClass(manager.class, im) then
        error(tostring(manager).." is not of class "..self.class.name.."!");
    end
    self.parents[manager.ItemClass.name] = manager;
    manager.child = self;
    manager.container.child = self.container;
end

function im:getActiveParents()
    local list = { n = 0 };
    for class, manager in pairs(self.parents) do
        if manager.currentItem ~= nil then
             list[class] = manager;
             list.n = list.n + 1;
        end
    end
--     print(list.n);
--     for class, manager in pairs(list) do
--         print(class, manager);
--     end
    return list;
end

function im:LoadState(data)
    if data == nil then return; end
--     Utils.Dump(data, -1);
    self:SetLoadPhase(true);
    IWManager:SetLoadPhase(true);
    self.container:LoadState(data.container, self.ItemClass);
    if data.currentItem then
--         print("Loading current item:");
--         Utils.Dump(data.currentItem, -1)
        self.currentItem = self.container:getItem(data.currentItem.id, data.currentItem.parent);
--         print(self.currentItem);
    end
    if data.selectMode == true then
        self.selectMode = true;
    end
    IWManager:SetLoadPhase(false);
    self:SetLoadPhase(false);
    self:LoadSubmodulesState(data.children);
end

function im:DumpState()
    local data = {
        container = self.container:DumpState()
        };
    if self.currentItem then
        data.currentItem = self.currentItem:getSerializableData();
    end
    data.selectMode = self.selectMode;
    data.children = self:DumpSubmodulesState();
--     Utils.Dump(data, -1);
    return data;
end

function im:selectMenu()
    if Slab.MenuItemChecked("Select on click", self.selectMode) then
        self.selectMode = not self.selectMode;
    end
end

function im:itemContextMenu(item)
    local seltext = "Select";
    if self.container:isSelected(item) then
        seltext = "Deselect";
    end
    if Slab.MenuItem(seltext) then
        self.container:toggleSelection(item);
    end
    if Slab.MenuItem("Delete") then
        self:confirmDelete(item);
    end
end

function im:confirmDelete(item)
    self._confirmDelete = item;
end

function im:confirmDeleteSelected()
    self._confirmDeleteSelected = true;
end

function im:updateConfirmDelete()
    if self._confirmDeleteSelected then
        local count = self.container:selectedNumber();
        if count == 0 then
            self._confirmDeleteSelected = false;
            return;
        end
        local name = self.naming.name;
        if count > 1 then name = self.naming.names; end
        local result = Slab.MessageBox("Are You sure?", "Are You sure to delete "..count.." "..name.."?", { Buttons = { "Yes", "No" } });
        if result ~= "" then
            self._confirmDeleteSelected = false;
            if result == "Yes" then
                self.container:deleteSelected();
            end
        end
    end
    if self._confirmDelete then
        local result = Slab.MessageBox("Are You sure?", "Are You sure to delete "..self.naming.name.."\n\""..tostring(self._confirmDelete).."\"?", { Buttons = { "Yes", "No" } });
        if result ~= "" then
            if result == "Yes" then
                self.container:deleteItem(self._confirmDelete);
            end
            self._confirmDelete = nil;
        end
    end
end

function im:update()
    self:updateConfirmDelete();
end

return im;
