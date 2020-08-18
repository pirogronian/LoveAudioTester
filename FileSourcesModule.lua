
local SModule = require('StateModule');

local Utils = require('Utils');

local fm = require("FilesModule");

local sm = require("SourcesModule");

local STree = require('SortableTree');

local fps = SModule("filesourcesmodule", "File sources");

fps.tree = STree(fm);

fps.playing = 0;

function fps:UpdateTree()
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

function fps:DumpState()
    local data = self:DumpSubmodulesState();
--     Utils.Dump(data.sources, 10);
    return data;
end

function fps:LoadState(data)
    if data == nil then return end
    self:SetLoadPhase(true);
    self:LoadSubmodulesState(data);
    self:SetLoadPhase(false);
end

return fps;
