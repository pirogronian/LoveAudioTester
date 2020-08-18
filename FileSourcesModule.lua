
local SModule = require('StateModule');

local Utils = require('Utils');

local SortMenu = require('SortMenu');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local FileItem = require('FileItem');

local SourceItem = require('SourceItem');

local IManager = require('ItemsManager');

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
    if Slab.BeginMenu("Files") then
        SortMenu(self.fileMan.container);
        self.fileMan:selectMenu();
        if Slab.MenuItem("Add") then
            self.fileMan:openFileDialog();
        end
        if Slab.MenuItem("Delete selected") then
            self.fileMan:confirmDeleteSelected();
        end
        if Slab.BeginMenu("Sources") then
            SortMenu(self.srcMan.container);
            self.srcMan:selectMenu();
            if Slab.MenuItem("New") then
                self.srcMan:openNewItemDialog();
            end
            if Slab.MenuItem("Delete selected") then
                self.srcMan:confirmDeleteSelected();
            end
            Slab.EndMenu();
        end
        Slab.EndMenu();
    end
end

function fps:UpdateDialogs()
    self.fileMan:update();
    self.srcMan:update();
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
--     for groupid, group in pairs(self.srcMan.container.groups) do
--         for key, item in pairs(group.ids) do
--             self:SourcePostCreation(item);
--         end
--     end
--    self.paths:dumpIds();
--    self.paths:dumpAttributes();
--    self.paths:dumpIndexes(true);
--    self.sources:dumpIds();
--     self.sources:dumpGroups();
--     self.sources:dumpAttributes();
--     self.sources:dumpIndexes(true);
    self:SetLoadPhase(false);
end

function fps:itemClicked(item)
    if item.class.name == "FileItem" then
        self.fileMan:onClick(item)
    else
        if item.class.name == "SourceItem" then
            self.srcMan:onClick(item);
        else
            print("Clicked unknown item!", item);
        end
    end
end

fps.tree.clicked:connect(fps.itemClicked, fps);

return fps;
