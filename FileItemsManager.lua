
local IManager = require('ItemsManager')

local FItem = require('FileItem');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local fim = IManager:subclass("FileItemManager");

local function windowContent(item)
    FileInfoPanel(item.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.decoder, "DecoderInfo");
end

function fim:initialize()
    IManager.initialize(self, "files", "file", "files", FItem, windowContent);
end

return fim;
