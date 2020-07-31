
local Module = require('Module');

local Utils = require('Utils');

local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

local NSDialog = require('NewSourceDialog');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local dT = require('DumpTable');

local FileItem = require('FileItem');

local SourceItem = require('SourceItem');

local fps = Module("filesourcesmodule", "File sources");

fps.paths = SContainer("fpathcontainer", "Filepaths");
fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.deleteConfirmator = DConfirmator(fps.paths, "filepaths");

function fps:onFileDelete(id)
    IWManager:delItem("File", id, true);
    self:StateChanged();
end

fps.sources = SContainer("filesourcescontainer", "Sources");
fps.sources:addAttribute(SContainer.Attribute("name", "Name"));

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
        if Slab.MenuItem("Delete") then
            self.deleteConfirmator.active = true;
        end
        if Slab.BeginMenu("Sources") then
            if Slab.MenuItem("New") then
                self:OpenNewSourceDialog();
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

function fps:getCurrentPath()
    return self.paths.lastSelected;
end

function fps:OpenNewSourceDialog()
    
    local path = self:getCurrentPath();
    if path == nil then return; end
    self.currentPath = path;
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function fps:CreateSourceItem(id, path)
    local fitem = self.getFileItem(path, self);
    if fitem == nil then
        print(self, "Cannot create source: No such file item:", Utils.VariableInfoString(path))
        return;
    end
--[[    local source = love.audio.newSource(path, "static");
    local item = { id = id, attributes = { id = id }, source = source, parent = fitem };
    local mt = {};
    mt.__tostring = function(item) return item.id; end
    setmetatable(item, mt);]]
    local item = SourceItem(id, fitem);
    return item;
end

function fps:AddNewSource(id, path)
    local item = self:CreateSourceItem(id, path)
    self.sources:addItem(item, path);
end

function fps:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    if self.currentPath ~= nil then
        local closed, id = NSDialog(self.currentPath);
        if closed then
            self.newSourceDialog = false;
            if id == nil then return; end
            if self.sources.ids[id] ~= nil then
                InfoQueue:pushMessage("Id already exists!", "Source with id \""..id.."\" already exists.");
                self.newSourceDialog = true;
            else
                self:AddNewSource(id, self.currentPath);
--                 self.sources:dumpIds();
            end
        end
    end
end

function fps:UpdateDialogs()
    self.deleteConfirmator:update();
    self:UpdateOpenFileDialog();
    self:UpdateNewSourceDialog();
end

function fps:UpdateTree()
    local cpath = self:getCurrentPath();
    if cpath ~= nil then
        Slab.Text(cpath);
    else
        Slab.Text("Click on item to make it active.");
    end
    SortGui.SortedTree(fps.paths, { clicked = self.fileClicked, childrenContainer = self.sources });
end

function fps:DumpState()
    local data = {
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
    self:SetLoadPhase(false);
end

function fps.fileClicked(item, context)
    context.paths:toggleSelection(item.id);
    IWManager:setCurrentItem("File", item);
    context:StateChanged();
end

function fps.getFileItem(id, context)
    return context.paths.ids[id];
end

function fps.fileClicked(item, context)
    fps.paths:toggleSelection(item.id);
    IWManager:setCurrentItem("File", item);
    fps:StateChanged();
end

function fps.getSourceItem(id, context)
    return fps.sources.ids[id];
end

function fps.fileItemWindowContent(item, module)
    FileInfoPanel(item.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.decoder, "DecoderInfo");
end

function fps.sourceItemWindowContent(item, module)
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
