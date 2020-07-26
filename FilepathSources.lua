
local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

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
        local item = self:createPathItem(fpath);
        if self.paths.ids[item.id] == nil then
            self.paths:addItem(item);
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

function fps:UpdateNewSourceDialog()
    if Slab.BeginDialog("NewFpathSourceDialog") then
        Slab.BeginLayout("NewFpathSourceDialogLayout");
        Slab.Text("Id:");
        Slab.SameLine();
        Slab.Input("FpathSourceId");
        local id = Slab.GetInputText();
        Slab.EndLayout();
        if Slab.Button("Create") then
            print("Create"); --Debug only for now
        end
        Slab.EndDialog();
    end
end

function fps:UpdateDialogs()
    self.deleteConfirmator:update();
    self:UpdateOpenFileDialog();
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
