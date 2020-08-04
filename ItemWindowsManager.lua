
local utils = require('Utils');

local Item = require('Item');

local Module = require('Module');

local dTable = require('DumpTable');

local iwm = Module:subclass("ItemWindowsManager");

function iwm:initialize(id, name)
    Module.initialize(self, id, name);
    self.modules = {};
    self._globalCurrent = false;
end

function iwm:registerModule(id, title, options)
    self.modules[id] = {
            id = id,
            title = title,
            options = options,
            items = {},
            currentItem = nil,
            currentWindow = false
        };
end

function iwm:getModule(id)
    local module = self.modules[id];
    if module == nil then
        error(string.format("No such module: %s", utils.DumpStr(id)));
    end
    return module;
end

function iwm:setGlobalCurrent(isglobal)
    self._globalCurrent = isglobal;
end

function iwm:isGlobalCurrent()
    return self._globalCurrent;
end

function iwm:setCurrentItem(modid, item)
    local module = self:getModule(modid);
    module.currentItem = item;
    self._currentModuleId = modid;
    self:StateChanged();
end

function iwm:unsetCurrentItem(modid, tem)
    local module = self:getModule(modid);
    if module.currentItem == nil then return; end
    if id ~= nil then
        if module.currentItem ~= item then return; end
    end
    module.currentItem = nil;
    self:StateChanged();
end

function iwm:showCurrentItemWindow(modid)
    local module = self:getModule(modid);
    module.currentWindow = true;
    self:StateChanged();
end

function iwm:addItem(modid, item)
    local module = self:getModule(modid);
    module.items[item] = item;
    self:StateChanged();
end

function iwm:delItem(modid, itemid, current)
    local module = self:getModule(modid);
    module.items[itemid] = nil;
    if current then
        self:unsetCurrentItem(modid, itemid);
    end
    self:StateChanged();
end

function iwm.getCurrentWindowId(module)
    return module.id.."CurrentItemWindow";
end

function iwm:UpdateCurrentItemWindow(module)
    if module.currentItem == nil or not module.currentWindow then return; end
    if Slab.BeginWindow(iwm.getCurrentWindowId(module),
                        {
                         Title = module.title,
                         IsOpen = module.currentWindow,
                         AutoSizeWindow = false,
                         W = 300,
                         H = 200
                         }) then
        if module.options.onWindowUpdate ~= nil then
            module.options.onWindowUpdate(module.currentItem, module.options.context);
        end
    else
        module.currentWindow = false;
        self:StateChanged();
    end
    Slab.EndWindow();
end

function iwm:UpdateCurrentItemWindows()
    if self._globalCurrent and _self._currentModuleId  ~= nil then
        local module = self:getModule(self.__currentModuleId);
        self.UpdateCurrentItemWindow(module);
    else
        for id, module in pairs(self.modules) do
            self:UpdateCurrentItemWindow(module);
        end
    end
end

function iwm:LoadState(data)
    if type(data) ~= "table" then return; end
    self:SetLoadPhase(true);
    self._globalModuleId = data.globalModuleId;
    self._globalCurrent = data.globalCurrent;
    if type(data.modules) == "table" then
        for modid, moddata in pairs(data.modules) do
            local module = self:getModule(modid);
            if moddata.currentItemId ~= nil then
                local item = module.options.onItemLoad(moddata.currentItemId, currentItemParent, module.options.context);
                if item == nil then
                    print("Warning:", self, "Cannot recreate item:", moddata.currentItemId);
                    self:StateChanged(true);
                else
                    self:setCurrentItem(modid, item);
                    if moddata.currentWindow == true then
                        module.currentWindow = true;
                    end
                end
            end
        end
    end
    self:SetLoadPhase(false);
end

function iwm:DumpState()
    local data = {
        globalModuleId = self._globalModuleId,
        globalCurrent = self._globalCurrent,
        modules = {} };
    for modid, module in pairs(self.modules) do
        local moddata = {};
        if module.currentItem ~= nil then
            moddata.currentItem = Item.getSerializableData(module.currentItem);
        end
        if module.currentWindow == true then
            moddata.currentWindow = true;
        end
        data.modules[modid] = moddata;
    end
    return data;
end

function iwm:dumpModules()
    print("ItemWindowsManager::dumpModules:");
    for id, module in pairs(self.modules) do
        print(id, module)
    end
end

return iwm("ItemWindowsManager", "Managing item windows");
