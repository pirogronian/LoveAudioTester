
local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

local Module = Class("Module");

function Module:initialize(id, title)
    self.id = id;
    self.title = title;
    self._stateChangd = false;
    self.loadPhase = false;
    self.stateChanged = Signal();
end

function Module:SetLoadPhase(loading)
    self.loadPhase = loading;
end

function Module:IsLoadPhase()
    return self.loadPhase;
end

function Module:LoadState()
    print("Module:LoadState() dummy");
end

function Module:DumpState()
    print("Module:SaveState() dummy");
end

function Module:StateChanged(force)
    if self.loadPhase == true and not force then return; end
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
