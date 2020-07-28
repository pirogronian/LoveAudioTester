
local Utils = require('Utils');

local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

local NSDialog = require('NewSourceDialog');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local MemSizeFormat = require('MemorySizeFormat');

local dT = require('DumpTable');

local fps = {};

fps.paths = SContainer("fpathcontainer", "Filepaths");
fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.deleteConfirmator = DConfirmator(fps.paths, "filepaths");

function fps.onFileDelete(id)
    IWManager:delItem("File", id, true);
end

fps.paths.onDelete = fps.onFileDelete;

fps.sources = SContainer("filesourcescontainer", "Sources");
fps.sources:addAttribute(SContainer.Attribute("name", "Name"));

function fps:createPathItem(fpath, isFullPath)
    local localpath = "";
    if isFullPath == nil or isFullPath == true then
        localpath = Utils.getRelativePath(fpath);
        if localpath == nil then
            InfoQueue:pushMessage("File doesnt exist!", "File with path \n\""..fpath.."\"\nis inaccessable!");
            return;
        end
    else
        localpath = fpath;
    end
    local status, value = pcall(love.sound.newDecoder, localpath);
    if not status then
        InfoQueue:pushMessage("Cannot create decoder!", "Cannot create decoder from file\n\""..localpath.."\"!\nError: \""..value.."\"");
        return;
    end
    local item = {
        id = localpath,
        attributes = { path = localpath },
        fullpath = fpath,
        fileinfo = love.filesystem.getInfo(localpath);
        decoder = value,
        container = self.sources };
    local mt = getmetatable(item);
    if mt == nil then
        mt = {};
    end
    mt.__tostring = function(item)
        return item.id;
    end
    setmetatable(item, mt);
    return item;
end

function fps:addPaths(paths)
    for key, fpath in pairs(paths) do
        if fpath ~= nil then
            local item = self:createPathItem(fpath);
            if item ~= nil then
                if self.paths.ids[item.id] == nil then
                    self.paths:addItem(item);
                end
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
    local source = love.audio.newSource(path, "static");
    local item = { id = id, attributes = { id = id }, source = source };
    local mt = {};
    mt.__tostring = function(item) return item.id; end
    setmetatable(item, mt);
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
--             self.sources:dumpIds();
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
    SortGui.SortedTree(fps.paths, { clicked = self.fileClicked });
end

function fps:SaveData()
    local data = { paths = { currentAttribute = self.paths.currentAttribute, selected =  self.paths.selected, ids = {}}};
    for id, path in pairs(self.paths.ids) do
        data.paths.ids[id] = {};
    end
    return data;
end

function fps:LoadData(data)
    if data == nil then return end
    local paths = data.paths;
    self.paths.currentAttribute = paths.currentAttribute;
    for key, val in pairs(paths.ids) do
        local item = self:createPathItem(key, false);
        if item ~= nil then
            self.paths:addItem(item);
        end
    end
    for key, val in pairs(paths.selected) do
        if val == true then
            self.paths:select(key);
        end
    end
end

function fps.fileClicked(item, context)
    IWManager:setCurrentItem("File", item);
end

function fps.fileItemWindowContent(item, module)
    Slab.BeginLayout("FileItemWindowLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Path:");
    Slab.Text("Full path:");
    Slab.Text("Size:");
    Slab.SetLayoutColumn(2);
    Slab.Text(item.id);
    Slab.Text(item.fullpath);
    Slab.Text(MemSizeFormat(item.fileinfo.size));
    Slab.EndLayout();
end

IWManager:registerModule("File", "File", fps.fileItemWindowContent, fps);

return fps;
