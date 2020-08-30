
local u = require('common/Utils');

local SModule = require('StateModule');

local l = SModule:subclass("Scene");

local p = require('Properties');

local gc = require('ControlsGroups');

local mr = require('MouseRecorder');

local mrc = require('MouseRecorderControl');

local lsc = require('ListenerSourceCommons')

local lscc = require('ListenerSourceCommonControls');

local WManager = require('WindowsManager');

local Signal = require('Signal');

local gci = gc();

gci.og.position = lscc.position;
gci.og.velocity = lscc.velocity;

l:include(p);

l:include(lsc);

function l:initialize(id)
    SModule.initialize(self);
    self.id = id;
    self.visibility = {};
    self.changed = Signal();
    self.recordingStarted = Signal();
    self.recordingStopped = Signal();
    self.mouseRecorder = mr(self);
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

function l:getOrientation()
    return love.audio.getOrientation();
end

function l:windowTitle()
    return "Scene";
end

function l:windowContent()
    Slab.BeginLayout("Limits", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Max effects per scene:");
    Slab.Text("Max effects per source:");
    Slab.SetLayoutColumn(2);
    Slab.Text(love.audio.getMaxSceneEffects());
    Slab.Text(love.audio.getMaxSourceEffects());
    Slab.EndLayout();
    Slab.Text("Listener");
    gci:optionsGroup(self, "position");
    gci:optionsGroup(self, "velocity");
    mrc(self);
    local ov = self:getVolume();
    local nv = Slab.PercentageSlider("VolumeSlider", ov);
    if nv then
        self.Volume = nv;
    end
end

function l:mainMenu()
    if Slab.BeginMenu("Scene") then
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
    love.audio.setVolume(u.TryValue(data.volume, 1, 'number'));
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
    self.mouseRecorder:load(data.mouseRecorder);
    self:SetLoadPhase(false);
end

function l:DumpState()
    local data = {};
    data.visibility = self.visibility;
    data.volume = love.audio.getVolume();
    local x, y, z = self:getPosition();
    data.position = { x = x, y = y, z = z };
    x, y, z = self:getVelocity();
    data.velocity = { x = x, y = y, z = z };
    data.mouseRecorder = self.mouseRecorder:getSerializableData();

    return data;
end

return l("Scene");
