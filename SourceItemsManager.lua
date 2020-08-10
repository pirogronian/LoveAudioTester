
local IManager = require('ItemsManager')

local SItem = require('SourceItem');

local ItemInfoPanel = require('ItemInfoPanel');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local fim = IManager:subclass("FileItemManager");

local function windowContent(item)
    ItemInfoPanel(item);
    FileInfoPanel(item.parent.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.parent.decoder, "DecoderInfo");
    Slab.Separator();
    if SourceControlPanel(item) then
        fps.StateChanged(fps);
    end
end

function fim:initialize()
    IManager.initialize(self, "filesources", "source", "sources", SItem, windowContent);
end

return fim;
