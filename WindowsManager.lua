
local utils = require('Utils');

local Item = require('Item');

local SModule = require('StateModule');

local iwm = SModule:subclass("WindowsManager");

function iwm:initialize(id, name)
    SModule.initialize(self, id, name);
    self.modules = {};
    self._globalCurrent = false;
end

function iwm:register(manager)
    self.modules[manager.id] = {
            manager = manager,
            windowOpen = false
        };
--     self:dumpModules();
end

function iwm:getModule(id, noerr)
    local module = self.modules[id];
    if module == nil then
        if noerr then
            print(string.format("Warning: No such module: %s", utils.DumpStr(id)));
        else
            self:dumpModules();
            error(string.format("No such module: %s", utils.DumpStr(id)));
        end
    end
    return module;
end

function iwm:setGlobalCurrent(isglobal)
    self._globalCurrent = isglobal;
end

function iwm:isGlobalCurrent()
    return self._globalCurrent;
end

function iwm:setCurrentModule(id)
--     print("Set current item:", modid, item);
    local module = self:getModule(id);
    if self._currentModuleId ~= id then
        self._currentModuleId = id;
        self:StateChanged();
    end
end

function iwm:unsetCurrentModule(id)
    if self._currentModuleId == id then
        self._currentModuleId = nil;
        self:StateChanged();
    end
end

function iwm:showModuleWindow(id)
--     self:dumpModules();
    local module = self:getModule(id);
    module.windowOpen = true;
    self:StateChanged();
end

function iwm.getCurrentWindowId(module)
    return module.manager.id.."Window";
end

function iwm:UpdateModuleWindow(module, id)
    if not module.windowOpen then return; end
    if id == nil then id = iwm.getCurrentWindowId(module); end
    if Slab.BeginWindow(id,
                        {
                         Title = module.manager:windowTitle(),
                         IsOpen = module.windowOpen,
                         AutoSizeWindow = false,
                         W = 300,
                         H = 200
                         }) then
        module.manager:windowContent();
    else
        module.windowOpen = false;
        self:StateChanged();
    end
    Slab.EndWindow();
end

function iwm:UpdateWindows()
    if self._globalCurrent and self._currentModuleId  ~= nil then
        local module = self:getModule(self._currentModuleId);
        if module == nil then
            print("Warning: no such module:", self._currentModuleId);
            self._currentModuleId = nil;
        else
            self:UpdateModuleWindow(module, "GlobalWindow");
        end
    else
        for id, module in pairs(self.modules) do
            self:UpdateModuleWindow(module);
        end
    end
end

function iwm:UpdateMenu()
    if Slab.BeginMenu("Windows") then
        if Slab.MenuItemChecked("Single acitve window", self._globalCurrent) then
            self._globalCurrent = not self._globalCurrent;
            self:StateChanged();
        end
        if Slab.BeginMenu("Active windows") then
            for id, module in pairs(self.modules) do
                if Slab.MenuItemChecked(module.manager:windowTitle(), module.windowOpen) then
                    module.windowOpen = not module.windowOpen;
                    self:StateChanged();
                end
            end
            Slab.EndMenu();
        end
        Slab.EndMenu();
    end
end

function iwm:LoadState(data)
    if type(data) ~= "table" then return; end
    self:SetLoadPhase(true);
    local globMod = self:getModule(data.currentModuleId, true);
    if globMod ~= nil then
        self._currentModuleId = data.currentModuleId;
    end
    self._globalCurrent = data.globalCurrent;
    if type(data.modules) == "table" then
        for modid, moddata in pairs(data.modules) do
            local module = self:getModule(modid, true);
            if module ~= nil then
                module.windowOpen = moddata.windowOpen;
            end
        end
    end
    self:SetLoadPhase(false);
end

function iwm:DumpState()
    local data = {
        currentModuleId = self._currentModuleId,
        modules = {} };
    data.globalCurrent = self._globalCurrent;
    for modid, module in pairs(self.modules) do
        local moddata = {};
        if module.windowOpen == true then
            moddata.windowOpen = true;
        end
        data.modules[modid] = moddata;
    end
    return data;
end

function iwm:dumpModules()
    print("ItemWindowsManager::dumpModules:");
    for id, module in pairs(self.modules) do
        print(id, module.manager, module.currentItem)
    end
end

return iwm("ItemWindowsManager", "Managing item windows");
