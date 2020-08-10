
local IManager = require('ItemsManager')

local SItem = require('SourceItem');

local ItemInfoPanel = require('ItemInfoPanel');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local NSDialog = require('NewSourceDialog');

local sim = IManager:subclass("SourceItemManager");

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

function sim:initialize()
    IManager.initialize(self, "filesources", "source", "sources", SItem, windowContent);
end

function sim:OpenNewSourceDialog()
    if self.parent.currentItem == nil then return; end
--     print("Opening new source dialog for:", self.fileMan.currentItem);
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function sim:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    local closed, id = NSDialog(self.parent.currentItem);
    if closed then
        self.newSourceDialog = false;
        if id == nil then return; end
--         print("Creating source", id);
        self:createItem(id, self.parent.currentItem);
    end
end

function sim:update()
    IManager.update(self);
    self:UpdateNewSourceDialog();
end

return sim;
