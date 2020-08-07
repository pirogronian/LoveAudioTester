
local SModule = require('StateModule');

local Utils = require('Utils');

local SContainer = require('SortableContainer');

local SortGui = require('SortGUI');

local NSDialog = require('NewSourceDialog');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local ItemInfoPanel = require('ItemInfoPanel');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local FileItem = require('FileItem');

local SourceItem = require('SourceItem');

local IManager = require('ItemsManager');

local STree = require('SortableTree');

local fps = SModule("filesourcesmodule", "File sources");

function fps.fileItemWindowContent(item)
    FileInfoPanel(item.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.decoder, "DecoderInfo");
end

function fps.sourceItemWindowContent(item)
    ItemInfoPanel(item);
    FileInfoPanel(item.parent.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.parent.decoder, "DecoderInfo");
    Slab.Separator();
    SourceControlPanel(item);
end

fps.fileMan = IManager("files", "Files", FileItem, fps.fileItemWindowContent);
fps.fileMan.container:addAttribute(SContainer.Attribute("path", "Path"));

fps.srcMan = IManager("filesources", "Sources", SourceItem, fps.sourceItemWindowContent);
fps.srcMan.container:addAttribute(SContainer.Attribute("name", "Name"));

fps.srcMan:setParent(fps.fileMan);

fps:AddSubmodule(fps.fileMan);
fps:AddSubmodule(fps.srcMan);

fps.tree = STree(fps.fileMan.container);

fps.playing = 0;

function fps:addPaths(paths)
    for key, fpath in pairs(paths) do
        if fpath ~= nil then
            self.fileMan:createItem(fpath, true);
        end
    end
end

function fps:UpdateMenu()
    if Slab.BeginMenu("Filepaths") then
        SortGui.SortMenu(self.fileMan.container);
        if Slab.MenuItem("Info") then
            IWManager:showCurrentItemWindow(self.fileMan:windowsManagerId());
        end
        if Slab.MenuItem("Add") then
            openFilepathDialog = true;
        end
        if Slab.MenuItem("Delete selected") then
            self.fileMan:onDeleteSelectedConfirm();
        end
        if Slab.BeginMenu("Sources") then
            if Slab.MenuItem("Info") then
                IWManager:showCurrentItemWindow(self.srcMan:windowsManagerId());
            end
            if Slab.MenuItem("New") then
                self:OpenNewSourceDialog();
            end
            if Slab.MenuItem("Delete selected") then
                self.srcMan:onDeleteSelectedConfirm();
            end
            Slab.EndMenu();
        end
        Slab.EndMenu();
    end
end

function fps:UpdateOpenFileDialog()
    if openFilepathDialog then
        local result = Slab.FileDialog({ Type = "openfile" })
        if result.Button == "OK" then
            self:addPaths(result.Files);
        end
        if result.Button ~= "" then openFilepathDialog = false; end
    end
end

function fps:OpenNewSourceDialog()
    if self.fileMan.currentItem == nil then return; end
    print("Opening new source dialog for:", self.fileMan.currentItem);
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function fps:SourcePostCreation(item)
    item.played:connect(self.onPlayed, self);
    item.paused:connect(self.onPaused, self);
end

function fps:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    local closed, id = NSDialog(self.fileMan.currentItem);
    if closed then
        self.newSourceDialog = false;
        if id == nil then return; end
        print("Creating source", id);
        self.srcMan:createItem(id, self.fileMan.currentItem);
    end
end

function fps:UpdateDialogs()
    self.fileMan:update();
    self.srcMan:update();
    self:UpdateOpenFileDialog();
    self:UpdateNewSourceDialog();
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
    Slab.Text("Playing now: "..tostring(self.playing));
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
    for groupid, group in pairs(self.srcMan.container.groups) do
        for key, item in pairs(group.ids) do
            self:SourcePostCreation(item);
        end
    end
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

function fps:onPlayed()
    self.playing = self.playing + 1;
    self:StateChanged();
end

function fps:onPaused()
    self.playing = self.playing - 1;
    self:StateChanged();
end

fps.tree.clicked:connect(fps.itemClicked, fps);

return fps;
