
local Module = require('Module');

local Utils = require('Utils');

local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

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

local STree = require('SortableTree');

local fps = Module("filesourcesmodule", "File sources");

fps.paths = SContainer("fpathcontainer", "Filepaths", FileItem);
fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.fileDConfirmator = DConfirmator(fps.paths, "filepaths");

function fps:onFileDelete(item)
    if self.currentFile == item.id then
        self.currentFile = nil;
    end
    IWManager:delItem("File", item.id, true);
    self:StateChanged();
end

fps.sources = SContainer("filesourcescontainer", "Sources", SourceItem);
fps.sources:addAttribute(SContainer.Attribute("name", "Name"));

fps.paths.childContainer = fps.sources;
fps.sources.parentContainer = fps.paths;

fps.tree = STree(fps.paths);

fps.playing = 0;

function fps:onSourceDelete(item)
    if self.currentSource == item.id then
        self.currentSource = nil;
    end
    IWManager:delItem("FileSource", item.id, true);
    self:StateChanged();
end

fps.sourceDConfirmator = DConfirmator(fps.sources, "sources");

function fps:addPaths(paths)
    for key, fpath in pairs(paths) do
        if fpath ~= nil then
            self.paths:createItem(fpath, true);
        end
    end
end

function fps:UpdateMenu()
    if Slab.BeginMenu("Filepaths") then
        SortGui.SortMenu(self.paths);
        if Slab.MenuItem("Info") then
            IWManager:showCurrentItemWindow("File");
        end
        if Slab.MenuItem("Add") then
            openFilepathDialog = true;
        end
        if Slab.MenuItem("Delete selected") then
            self.fileDConfirmator.active = true;
        end
        if Slab.BeginMenu("Sources") then
            if Slab.MenuItem("Info") then
                IWManager:showCurrentItemWindow("FileSource");
            end
            if Slab.MenuItem("New") then
                self:OpenNewSourceDialog();
            end
            if Slab.MenuItem("Delete selected") then
                self.sourceDConfirmator.active = true;
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
    if self.currentFile == nil then return; end
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function fps:SourcePostCreation(item)
    item.played:connect(self.onPlayed, self);
    item.paused:connect(self.onPaused, self);
end

function fps:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    if self.currentFile ~= nil then
        local closed, id = NSDialog(self.currentFile);
        if closed then
            self.newSourceDialog = false;
            if id == nil then return; end
            if self.sources:hasItemId(id, self.currentFile) then
                InfoQueue:pushMessage("Id already exists!", "Source with id \""..tostring(id).."\" already exists.");
                self.newSourceDialog = true;
            else
                self.sources:createItem(id, self.currentFile);
--                 self.sources:dumpIds(self.currentFile);
--                 self.sources:dumpGroups();
            end
        end
    end
end

function fps:UpdateDialogs()
    self.fileDConfirmator:update();
    self.sourceDConfirmator:update();
    self:UpdateOpenFileDialog();
    self:UpdateNewSourceDialog();
end

function fps:UpdateTree()
    if self.currentFile ~= nil then
        Slab.Text(tostring(self.currentFile));
    else
        Slab.Text("Click on file item to make it active.");
    end
    if self.currentSource ~= nil then
        Slab.Text(tostring(self.currentSource));
    else
        Slab.Text("Click on source item to make it active.");
    end
    self.tree:Update();
    Slab.Text("Playing now: "..tostring(self.playing));
end

function fps:DumpState()
    local currentFileData = nil;
    if self.currrentFile then
        currentFileData = Item.getSerializableData(self.currentFile);
    end
    local currentSourceData = nil;
    if self.currrentSource then
        currentSourceData = Item.getSerializableData(self.currentSource);
    end
    local data = {
        currentFile = currentFileData,
        currentSource = currentSourceData,
        paths = self.paths:DumpState(),
        sources = self.sources:DumpState()
        };
--     Utils.Dump(data.sources, 10);
    return data;
end

function fps:LoadState(data)
    if data == nil then return end
    self:SetLoadPhase(true);
    if self.paths:LoadState(data.paths, FileItem) then
        self:StateChanged(true);
    end
    if self.sources:LoadState(data.sources, SourceItem) then
        self:StateChanged(true);
    end
    for groupid, group in pairs(self.sources.groups) do
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
    if self.currentFile then
        if self.paths:hasItemId(data.currentFile) then
            self.currentSource = self.paths:getItem(data.currentFile.id);
        end
    end
    if data.currentSource then
        if self.sources:hasItemId(data.currentSource.id, data.currentSource.parent) then
            self.currentSource = self.sources:getItem(data.currentSource.id, data.currentSource.parent);
        end
    end
    self:SetLoadPhase(false);
end

function fps.getFileItem(id, unused, context)
    return context.paths:getItem(id);
end

function fps:fileClicked(item)
    self.currentFile = item;
    self.paths:toggleSelection(item);
    IWManager:setCurrentItem("File", item);
    self:StateChanged();
end

function fps.getSourceItem(id, parent, context)
    return fps.sources:getItem(id, parent);
end

function fps:sourceClicked(item)
    self.currentSource = item;
    self.sources:toggleSelection(item);
    IWManager:setCurrentItem("FileSource", item);
    self:StateChanged();
end

function fps:itemClicked(item)
    if item.container == self.paths then
        self:fileClicked(item)
    else
        if item.container == self.sources then
            self:sourceClicked(item);
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

function fps.fileItemWindowContent(item, module)
    FileInfoPanel(item.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.decoder, "DecoderInfo");
end

function fps.sourceItemWindowContent(item, module)
    ItemInfoPanel(item);
    FileInfoPanel(item.parent.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.parent.decoder, "DecoderInfo");
    Slab.Separator();
    SourceControlPanel(item);
end

function fps:onFileCreationFail(value)
    InfoQueue:pushMessage("Cannot load file!", "File could not be loaded!\n"..value);
end

function fps:onSourceCreationFail(value)
    InfoQueue:pushMessage("Cannot create source!", "Source could not be created!\n"..value);
end

fps.paths.itemRemoved:connect(fps.onFileDelete, fps);
fps.sources.itemRemoved:connect(fps.onSourceDelete, fps);

fps.paths.creationError:connect(fps.onFileCreationFail, fps);
fps.sources.creationError:connect(fps.onSourceCreationFail, fps);

IWManager:registerModule("File", "File",
                         { onWindowUpdate = fps.fileItemWindowContent,
                           onItemLoad = fps.getFileItem, context = fps });

IWManager:registerModule("FileSource", "File source",
                         { onWindowUpdate = fps.sourceItemWindowContent,
                           onItemLoad = fps.getSourceItem, context = fps });

return fps;
