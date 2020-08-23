
local u = require('Utils');

local SModule = require('StateModule');

local l = SModule:subclass("Listener");

local gc = require('ControlsGroups');

local lsc = require('ListenerSourceCommons')

local lscc = require('ListenerSourceCommonControls');

local WManager = require('WindowsManager');

local Signal = require('Signal');

local gci = gc();

gci.og.position = lscc.position;
gci.og.velocity = lscc.velocity;

l:include(lsc);

function l:initialize(id)
    SModule.initialize(self);
    self.id = id;
    self.visibility = {};
    self.changed = Signal();
    self.changed:connect(self.StateChanged, self);
    WManager:register(self);
end

function l:setVisible(option, show)
    if self.visibility[option] ~= show then
        self.visibility[option] = show;
        self.changed:emit();
    end
end

function l:getVisible(option)
    return self.visibility[option];
end

function l:windowTitle()
    return "Listener";
end

function l:windowContent()
    gci:optionsGroup(self, "position");
    gci:optionsGroup(self, "velocity");
end

function l:mainMenu()
    if Slab.BeginMenu("Listener") then
        if Slab.MenuItem("Properties") then
            WManager:setCurrentModule(self.id);
            WManager:showModuleWindow(self.id);
        end
        Slab.EndMenu();
    end
end

function l:LoadState(data)
    if type(data) ~= 'table' then return; end
    self:SetLoadPhase(true);
    self.visibility = data.visibility;
    local pos = u.TryValue(data.position, nil, 'table');
    if pos then
        local x = u.TryValue(pos.x, 0, 'number');
        local y = u.TryValue(pos.y, 0, 'number');
        local z = u.TryValue(pos.z, 0, 'number');
        self:setPosition(x, y, z);
    end
    local vel = u.TryValue(data.velocity, nil, 'table');
    if pos then
        local x = u.TryValue(vel.x, 0, 'number');
        local y = u.TryValue(vel.y, 0, 'number');
        local z = u.TryValue(vel.z, 0, 'number');
        self:setVelocity(x, y, z);
    end
    self:SetLoadPhase(false);
end

function l:DumpState()
    local data = {};
    data.visibility = self.visibility;
    local x, y, z = self:getPosition();
    data.position = { x = x, y = y, z = z };
    x, y, z = self:getVelocity();
    data.velocity = { x = x, y = y, z = z };

    return data;
end

return l("Listener");
