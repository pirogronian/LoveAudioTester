
local SModule = require('StateModule');

local Utils = require('Utils');

local FIManager = require("FileItemsManager");

local SIManager = require("SourceItemsManager");

local STree = require('SortableTree');

local fps = SModule("filesourcesmodule", "File sources");

fps.fileMan = FIManager();

fps.srcMan = SIManager();

fps.srcMan:addParent(fps.fileMan);

fps:AddSubmodule(fps.fileMan);
fps.fileMan:AddSubmodule(fps.srcMan);

fps.tree = STree(fps.fileMan);

fps.playing = 0;

function fps:UpdateMenu()
    self.fileMan:updateMainMenu();
    self.srcMan:updateMainMenu();
end

function fps:UpdateDialogs()
    self.fileMan:updateDialogs();
    self.srcMan:updateDialogs();
end

function fps:UpdateTree()
    if self.fileMan.currentItem ~= nil then
        Slab.Text(tostring(self.fileMan.currentItem));
    else
        Slab.Text("Click on file item to make it active.");
    end
    if self.srcMan.currentItem ~= nil then
        Slab.Text(tostring(self.srcMan.currentItem));
    else
        Slab.Text("Click on source item to make it active.");
    end
    self.tree:Update();
    Slab.Text("Playing now: "..tostring(self.srcMan.playing));
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
