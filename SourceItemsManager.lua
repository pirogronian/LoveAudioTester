
local IManager = require('ItemsManager')

local SItem = require('SourceItem');

local ItemInfoPanel = require('ItemInfoPanel');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local NSDialog = require('NewSourceDialog');

local sim = IManager:subclass("SourceItemsManager");

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
    self.container.itemAdded:connect(self.onNewItem, self);
    self.playing = 0;
end

function sim:OpenNewSourceDialog(parent)
    self.newSourceParent = parent;
    if self.newSourceParent == nil then
        self.newSourceParent = self.parent.currentItem;
    end
    if self.newSourceParent == nil then return; end
--     print("Opening new source dialog for:", self.fileMan.currentItem);
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function sim:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    local closed, id = NSDialog(self.newSourceParent);
    if closed then
        self.newSourceDialog = false;
        if id == nil then return; end
--         print("Creating source", id);
        local item = self:createItem(id, self.newSourceParent);
    end
end

function sim:onNewItem(item)
    item.played:connect(self.onPlayed, self);
    item.paused:connect(self.onPaused, self);
    item.changed:connect(self.StateChanged, self);
end

function sim:onPlayed()
    self.playing = self.playing + 1;
    self:StateChanged();
end

function sim:onPaused()
    self.playing = self.playing - 1;
    self:StateChanged();
end

function sim:update()
    IManager.update(self);
    self:UpdateNewSourceDialog();
end

return sim;
