
local SContainer = require('SortableContainer');

local DConfirmator = require('DeleteConfirmator');

local SortGui = require('SortGUI');

local fps = {};

fps.paths = SContainer("fpathcontainer", "Filepath list");

fps.paths:addAttribute(SContainer.Attribute("path", "Path"));

fps.deleteConfirmator = DConfirmator(fps.paths, "filepaths");

function fps:addPaths(paths)
    for key, fpath in pairs(paths) do
        local item = { id = fpath, attributes = { path = fpath } };
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

function fps:UpdateDialogs()
    self.deleteConfirmator:update();
    self:UpdateOpenFileDialog();
end

return fps;
