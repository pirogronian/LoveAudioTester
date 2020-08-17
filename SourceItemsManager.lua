
local IQueue = require('InfoQueue');

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
    IManager.initialize(self, "filesources",
                        { name = "source", names = "sources", title = "Source", titles = "Sources" },
                        SItem, windowContent);
    self.container.itemAdded:connect(self.onNewItem, self);
    self.playing = 0;
end

function sim:OpenNewSourceDialog(parent)
    self.newSourceParent = parent;
    if self.newSourceParent == nil then
        self.newSourceActiveParents = self:getActiveParents();
        if self.newSourceActiveParents.n == 0 then
            IQueue:pushMessage("No parent item!", "Cannot create new source without parent item!");
            return;
        end
    end
    Slab.OpenDialog("NewSourceDialog");
    self.newSourceDialog = true;
end

function sim:UpdateNewSourceDialog()
    if not self.newSourceDialog then return; end
    local closed, id, parent = NSDialog(self.newSourceParent, self.newSourceActiveParents);
    if closed then
        self.newSourceDialog = false;
        self.newSourceParent = nil;
        self.newSourceActiveParents = nil;
        if id == nil then return; end
--         print("Creating source", id);
        local item = self:createItem(id, parent);
        return;
    end
    if parent then
        self.newSourceParent = parent;
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
