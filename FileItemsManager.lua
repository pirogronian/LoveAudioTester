
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
    IManager.initialize(self, "files", "file", "files", FItem, windowContent);
end

function fim:contextMenu(item)
    if Slab.MenuItem("New source") then
        self.child:OpenNewSourceDialog(item);
    end
    IManager.contextMenu(self, item);
end

return fim;
