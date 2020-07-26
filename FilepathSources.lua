
local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

local fps = {};

fps.paths = SContainer("fpathcontainer", "Filepath list");

fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.deleteConfirmator = DConfirmator(fps.paths, "filepaths");

function fps:createPathItem(fpath)
    local item = { id = fpath, attributes = { path = fpath } };
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
            print("Create");
        end
        Slab.EndDialog();
    end
end

function fps:UpdateDialogs()
    self.deleteConfirmator:update();
    self:UpdateOpenFileDialog();
end

return fps;
