
local Utils = require('Utils');

local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

local NSDialog = require('NewSourceDialog');

local InfoQueue = require('InfoQueue');

local fps = {};

fps.paths = SContainer("fpathcontainer", "Filepaths");
fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.deleteConfirmator = DConfirmator(fps.paths, "filepaths");

fps.sources = SContainer("fpathsourcescontainer", "Sources");
fps.sources:addAttribute(SContainer.Attribute("name", "Name"));

function fps:createPathItem(fpath)
    local item = { id = fpath, attributes = { path = fpath }, container = self.sources };
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
        local fpath = Utils.getRelativePath(fpath);
        if fpath ~= nil then
            local item = self:createPathItem(fpath);
            if self.paths.ids[item.id] == nil then
                self.paths:addItem(item);
            end
        end
    end
end

function fps:UpdateMenu()
    if Slab.BeginMenu("Filepaths") then
        SortGui.SortMenu(self.paths);
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

function fps:UpdateTree()
    SortGui.SortedTree(fps.paths);
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
        self.paths:addItem(self:createPathItem(key));
    end
    for key, val in pairs(paths.selected) do
        if val == true then
            self.paths:select(key);
        end
    end
end

return fps;
