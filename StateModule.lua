
local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

local Utils = require('Utils');

local Module = Class("StateModule");

function Module:initialize(id)
    self.id = id;
    self._stateChangd = false;
    self.loadPhase = false;
    self._submodules = {};
    self.stateChanged = Signal();
end

function Module:SetLoadPhase(loading)
    self.loadPhase = loading;
    for id, module in pairs(self._submodules) do
        module:SetLoadPhase(loading);
    end
end

function Module:IsLoadPhase()
    return self.loadPhase;
end

function Module:AddSubmodule(module)
    if not Utils.IsClassOrSubClass(module.class, Module) then
        error("Module "..tostring(module).." is not from class "..Module.name);
    end
    self._submodules[module.id] = module;
    module.stateChanged:connect(self.StateChanged, self);
end

function Module:RemoveSubmodule(module)
    self._submodules[module.id] = nil;
    module.stateChanged:disconnect(self.StateChanged, self);
end

function Module:LoadSubmodulesState(data)
    if type(data) ~= 'table' then return; end
    for id, module in pairs(self._submodules) do
        module:LoadState(data[module.id]);
    end
end

function Module:DumpSubmodulesState()
    local data = {};
    for id, module in pairs(self._submodules) do
        data[id] = module:DumpState();
    end
    return data;
end

function Module:StateChanged(force)
--     print(self, "on loading:", self.loadPhase, force)
    if self._stateChanged or self.loadPhase == true and not force then return; end
    self._stateChanged = true;
    self.stateChanged:emit();
end

function Module:StateClean()
    self._stateChanged = false;
end

function Module:IsStateChanged()
    return self._stateChanged;
end

return Module;
