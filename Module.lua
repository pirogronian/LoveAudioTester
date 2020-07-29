
local Comm = require('Communicator');

local Module = Comm:subclass("Module");

function Module:initialize(id, title)
    Comm.initialize(self);
    self.id = id;
    self.title = title;
    self.stateChangd = false;
    self:DeclareSignal("StateChanged");
end

function Module:LoadState()
    print("Module:LoadState() dummy");
end

function Module:SaveState()
    print("Module:SaveState() dummy");
end

function Module:StateChanged()
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
