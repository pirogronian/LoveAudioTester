
local IManager = require('ItemsManager')

local FItem = require('FileItem');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local fim = IManager:subclass("FileItemsManager");

local function windowContent(item)
    FileInfoPanel(item.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.decoder, "DecoderInfo");
end

function fim:initialize()
    IManager.initialize(self, "files",
                        { name = "file", names = "files", title = "File", titles = "Files"},
                        FItem, windowContent);
end

function fim:itemContextMenu(item)
    if Slab.MenuItem("New source") then
        self.child:openNewItemDialog(item);
    end
    IManager.itemContextMenu(self, item);
end

function fim:contextMenu()
    if Slab.MenuItem("Add files") then
        self:openFileDialog();
    end
end

function fim:addFiles(paths)
    for key, fpath in pairs(paths) do
        if fpath ~= nil then
            self:createItem(fpath, true);
        end
    end
end

function fim:openNewItemDialog()
    self:openFileDialog();
end

function fim:updateOpenFileDialog()
    if self._openFileDialog then
        local result = Slab.FileDialog({ Type = "openfile" })
        if result.Button == "OK" then
            self:addFiles(result.Files);
        end
        if result.Button ~= "" then self._openFileDialog = false; end
    end
end

function fim:openFileDialog()
    self._openFileDialog = true;
end

function fim:updateDialogs()
    IManager.updateDialogs(self);
    self:updateOpenFileDialog();
end

return fim;
