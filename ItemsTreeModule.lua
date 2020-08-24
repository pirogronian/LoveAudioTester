
local SModule = require('StateModule');

local Utils = require('Utils');

local fm = require("FilesModule");

local sm = require("SourcesModule");

local WManager = require('WindowsManager');

local STree = require('SortableTree');

local itm = SModule:subclass("ItemsTree");

itm.tree = STree(fm);

itm.playing = 0;

function itm:initialize(id)
    SModule.initialize(self);
    self.id = id;
    WManager:register(self);
end

function itm:windowContent()
    if fm.currentItem ~= nil then
        Slab.Text(tostring(fm.currentItem));
    else
        Slab.Text("Click on file item to make it active.");
    end
    if sm.currentItem ~= nil then
        Slab.Text(tostring(sm.currentItem));
    else
        Slab.Text("Click on source item to make it active.");
    end
    self.tree:Update();
    Slab.Text("Playing now: "..tostring(sm.playing));
end

function itm:windowTitle()
    return "Items tree";
end

function itm:DumpState()
    local data = self:DumpSubmodulesState();
--     Utils.Dump(data.sources, 10);
    return data;
end

function itm:LoadState(data)
    if data == nil then return end
    self:SetLoadPhase(true);
    self:LoadSubmodulesState(data);
    self:SetLoadPhase(false);
end

return itm("ItemsTree");
