
bitser = require('thirdparty/bitser/bitser');

local utils = require('Utils');

local function defaultFpath()
    return "state.dat"
end

local ss = {
        _modules = {},
        _modsOrder = {};
        _state = nil,
        _stateChanged = false,
        defaultPath = defualtFpath,
        _filepath = defaultFpath()
    };

function ss:RegisterModule(mod)
    if not utils.IsClassOrSubClass("Module") then
        error("Not a module:"..tostring(mod));
        return;
    end
    if self._modules[mod.id] ~= nil then
        error(string.format("Module %s already registered!", mod.id));
        return;
    end
    self._modules[mod.id] = mod;
    mod:Connect("StateChanged", self.OnStateChanged, self);
    table.insert(self._modsOrder, mod.id);
end

function ss:UnregisterModule(id)
    if self._modules[mod.id] == nil then
        print("Warning: no such module:", id);
        return;
    end
    local mod = _modules[id];
    mod:Disconnect("StateChanged", self.OnStateChanged, self);
    self._modules[id] = nil;
    for key, modid in ipairs(self._modsOrder) do
        if modid == id then
            table.remove(self._modsOrder, key);
            break;
        end
    end
end

function ss:SetPath(path)
    self._filepath = path;
end

function ss:GetPath()
    return self._filepath;
end

function ss:OnStateChanged()
    self._stateChanged = true;
end

function ss:IsStateChanged()
    return self._stateChanged;
end

function ss:LoadState()
    local status, value = pcall(bitser.loadLoveFile, self._filepath);
    if status == false then
        self._state = nil;
    else
        self._state = value;
    end
    if self._state == nil then return; end
    if self._state.modules == nil then return; end
    for key, modid in ipairs(self._modsOrder) do
        local mod = self._modules[modid];
        mod:LoadState(self._state.modules[modid]);
    end
end

function ss:SaveState(force)
    if self._state == nil then
        self._state = { modules = {} };
    end
    for id, mod in pairs(self._modules) do
--         print("Checking module", id);
        if force or mod:IsStateChanged() then
--             print("Saving module", id);
            self._state.modules[id] = mod:DumpState();
            mod:StateClean();
        end
    end
    bitser.dumpLoveFile(self._filepath, self._state);
    self._stateChanged = false;
end

return ss;
