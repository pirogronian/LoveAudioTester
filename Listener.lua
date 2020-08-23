
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
end

function l:DumpState()
end

return l("Listener");
