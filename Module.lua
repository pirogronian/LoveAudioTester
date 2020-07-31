
local Comm = require('Communicator');

local Module = Comm:subclass("Module");

function Module:initialize(id, title)
    Comm.initialize(self);
    self.id = id;
    self.title = title;
    self.stateChangd = false;
    self.loadPhase = false;
    self:DeclareSignal("StateChanged");
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
    self.stateChanged = true;
    self:EmitSignal("StateChanged")
end

function Module:StateClean()
    self.stateChanged = false;
end

function Module:IsStateChanged()
    return self.stateChanged;
end

return Module;
