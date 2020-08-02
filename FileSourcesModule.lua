
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

local dT = require('DumpTable');

local FileItem = require('FileItem');

local SourceItem = require('SourceItem');

local fps = Module("filesourcesmodule", "File sources");

fps.paths = SContainer("fpathcontainer", "Filepaths");
fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.fileDConfirmator = DConfirmator(fps.paths, "filepaths");

function fps:onFileDelete(id)
    if self.currentFile == id then
        self.currentFile = nil;
    end
    IWManager:delItem("File", id, true);
    self:StateChanged();
end

fps.sources = SContainer("filesourcescontainer", "Sources");
fps.sources:addAttribute(SContainer.Attribute("name", "Name"));

function fps:onSourceDelete(id)
    if self.currentSource == id then
        self.currentSource = nil;
    end
    IWManager:delItem("Source", id, true);
    self:StateChanged();
end

fps.sourceDConfirmator = DConfirmator(fps.sources, "sources");

function fps:addPathItem(item)
    if item ~= nil then
        if self.paths.ids[item.id] == nil then
            self.paths:addItem(item);
            self:StateChanged();
        end
    end
end

function fps:addPaths(paths)
    for key, fpath in pairs(paths) do
        if fpath ~= nil then
            local status, value = pcall(FileItem.new, FileItem, fpath, true);
            if status then
                self:addPathItem(value);
            else
                InfoQueue:pushMessage("Cannot load file!", "File could not be loaded!\n"..value);
            end
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
    local fileitem = self.paths.ids[self.currentFile];
    if fileitem == nil then print("Warning: current file", self.currentFile, "doesnt exists!"); return; end
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function fps:CreateSourceItem(id, path)
    local fitem = self.paths.ids[path];
    if fitem == nil then
        print(self, "Cannot create source: No such file item:", Utils.VariableInfoString(path))
        return;
    end
    local item = SourceItem(id, fitem);
    return item;
end

function fps:AddNewSource(id, path)
    local item = self:CreateSourceItem(id, path)
    self.sources:addItem(item, path);
end

function fps:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    if self.currentFile ~= nil then
        local closed, id = NSDialog(self.currentFile);
        if closed then
            self.newSourceDialog = false;
            if id == nil then return; end
            if self.sources.ids[id] ~= nil then
                InfoQueue:pushMessage("Id already exists!", "Source with id \""..id.."\" already exists.");
                self.newSourceDialog = true;
            else
                self:AddNewSource(id, self.currentFile);
--                 self.sources:dumpIds();
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
        Slab.Text(self.currentFile);
    else
        Slab.Text("Click on file item to make it active.");
    end
    if self.currentSource ~= nil then
        Slab.Text(self.currentSource);
    else
        Slab.Text("Click on source item to make it active.");
    end
    SortGui.SortedTree(fps.paths, { context = self, clicked = self.fileClicked, childrenContainer = self.sources, childrenOptions = { context = self, clicked = self.sourceClicked } });
end

function fps:DumpState()
    local data = {
        currentFile = self.currentFile,
        currentSource = self.currentSource,
        paths = self.paths:DumpState(),
        sources = self.sources:DumpState()
        };
    return data;
end

function fps:LoadState(data)
    if data == nil then return end
    self:SetLoadPhase(true);
    if self.paths:LoadState(data.paths, FileItem) then
        self:StateChanged(true);
    end
    if self.sources:LoadState(data.sources, SourceItem, self.paths) then
        self:StateChanged(true);
    end
--     self.paths:dumpIds();
--     self.paths:dumpAttributes();
--     self.paths:dumpIndexes(true);
--     self.sources:dumpIds();
--     self.sources:dumpGroups();
--     self.sources:dumpAttributes();
--     self.sources:dumpIndexes(true);
    if self.paths.ids[data.currentFile] ~= nil then
        self.currentFile = data.currentFile;
    end
    if self.sources.ids[data.currentSource] ~= nil then
        self.currentSource = data.currentSource;
    end
    self:SetLoadPhase(false);
end

function fps.getFileItem(id, context)
    return context.paths.ids[id];
end

function fps.fileClicked(item, context)
    context.currentFile = item.id;
    context.paths:toggleSelection(item.id);
    IWManager:setCurrentItem("File", item);
    context:StateChanged();
end

function fps.getSourceItem(id, context)
    return fps.sources.ids[id];
end

function fps.sourceClicked(item, context)
    context.currentSource = item.id;
    context.sources:toggleSelection(item.id);
    IWManager:setCurrentItem("FileSource", item);
    context:StateChanged();
end

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
    SourceControlPanel(item.source);
end

fps.paths:Connect("ItemRemoved", fps.onFileDelete, fps);

IWManager:registerModule("File", "File",
                         { onWindowUpdate = fps.fileItemWindowContent,
                           onItemLoad = fps.getFileItem, context = fps });

IWManager:registerModule("FileSource", "File source",
                         { onWindowUpdate = fps.sourceItemWindowContent,
                           onItemLoad = fps.getSourceItem, context = fps });

return fps;
