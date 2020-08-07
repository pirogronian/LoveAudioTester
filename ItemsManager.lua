
local SModule = require('StateModule');

local SContainer = require('SortableContainer')

local DConfirmator = require('DeleteConfirmator');

local IQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local Utils = require('Utils');

local im = SModule:subclass("ItemsManager");

function im:initialize(id, title, ItemClass, itemWindowFunc)
    SModule.initialize(self, id, title);
    self.ItemClass = ItemClass;
    self.windowFunc = itemWindowFunc;
    self.container = SContainer(id, title);
    self.currentItem = nil;
    self.deleteConfirmator = DConfirmator(self.container, self.title);
    self.container.itemAdded:connect(self.onAddNewItem, self);
    self.container.itemRemoved:connect(self.onDeleteItem, self);
    IWManager:registerModule(self:windowsManagerId(), self.title,
                         { onWindowUpdate = self.windowFunc, context = self });
end

function im:windowsManagerId()
    return self.id.."Windows";
end

function im:onClick(item)
    if not self.container:hasItem(item) then
        print(self, "Warning: clicked item is not in container:", item);
    end
    self.container:toggleSelection(item);
    self.currentItem = item;
    IWManager:setCurrentItem(self:windowsManagerId(), item);
    self:StateChanged();
end

function im:onAddNewItem(item)
--     print("New item:", item)
    self:StateChanged();
end

function im:onDeleteSelectedConfirm()
    self.deleteConfirmator.active = true;
end

function im:onDeleteItem(item)
    if item == self.currentItem then
        self.currentItem = nil;
    end
    IWManager:delItem(self.id, item, true);
    self:StateChanged();
end

function im:onItemLoad(id, parent)
    return self.container:getItem(id, parent);
end

function im:createItem(...)
    local status, value = pcall(self.ItemClass.new, self.ItemClass, ...);
    if not status then
        IQueue:pushMessage("Cannot create item!", value);
        return;
    end
    if self.container:hasItem(value) then
        IQueue:pushMessage("Item already exists!", "Item "..tostring(value).." already exists!");
        return;
    end
    self.container:addItem(value, value.parent);
    self.container:dumpGroups();
    return value;
end

function im:setParent(manager)
    if manager == nil then
        self.parent = nil;
        if self.container.parent then
            self.container.parent.child = nil;
        end
        self.container.parent = nil;
        return;
    end
    if not Utils.IsClassOrSubClass(manager.class, self.class) then
        error(tostring(manager).." is not of class "..self.class.name.."!");
    end
    self.parent = manager;
    self.container.parent = manager.container
    manager.container.child = self.container;
end

function im:LoadState(data)
    if data == nil then return; end
    Utils.Dump(data, -1);
    self.container:LoadState(data.container, self.ItemClass);
    if data.currentItem then
--         print("Loading current item:");
--         Utils.Dump(data.currentItem, -1)
        self.currentItem = self.container:getItem(data.currentItem.id, data.currentItem.parent);
        print(self.currentItem);
    end
    if self.currentItem then
--         print("Setting current item:", self.currentItem)
        IWManager:setCurrentItem(self:windowsManagerId(), self.currentItem);
--         print("Current item set.");
    end
    self:LoadSubmodulesState(data.children);
end

function im:DumpState()
    local data = {
        container = self.container:DumpState()
        };
    if self.currentItem then
        data.currentItem = self.currentItem:getSerializableData();
    end
    data.children = self:DumpSubmodulesState();
--     Utils.Dump(data, -1);
    return data;
end

function im:update()
    self.deleteConfirmator:update();
end

return im;
