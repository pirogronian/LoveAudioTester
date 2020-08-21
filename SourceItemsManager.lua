
local Set = require('Set');

local IQueue = require('InfoQueue');

local IManager = require('ItemsManager')

local SItem = require('SourceItem');

local IWidget = require('ItemWidget');

local FileInfoPanel = require('FileInfoPanel');

local DecoderInfoPanel = require('DecoderInfoPanel');

local SourceControlPanel = require('SourceControlPanel');

local sim = IManager:subclass("SourceItemsManager");

local function windowContent(item)
    IWidget.update(item);
    FileInfoPanel(item.parent.file, "FileInfo");
    Slab.Separator();
    DecoderInfoPanel(item.parent.decoder, "DecoderInfo");
    Slab.Separator();
    SourceControlPanel.update(item);
end

function sim:initialize()
    IManager.initialize(self, "filesources",
                        { name = "source", names = "sources", title = "Source", titles = "Sources" },
                        SItem, windowContent, true);
    self.activeRecorders = Set();
    self.container.itemAdded:connect(self.onNewItem, self);
    self.playing = 0;
end

function sim:onNewItem(item)
    item.played:connect(self.onPlayed, self);
    item.paused:connect(self.onPaused, self);
    item.changed:connect(self.StateChanged, self);
    if item.mouseRecorder then
        item.recordingStarted:connect(self.onRecordingStarted, self);
        item.recordingStopped:connect(self.onRecordingStopped, self);
    end
end

function sim:onPlayed()
    self.playing = self.playing + 1;
    self:StateChanged();
end

function sim:onPaused()
    self.playing = self.playing - 1;
    self:StateChanged();
end

function sim:onRecordingStarted(recorder)
    self.activeRecorders:addSingle(recorder);
end

function sim:onRecordingStopped(recorder)
    self.activeRecorders:removeSingle(recorder);
end

function sim:updateActiveRecorders()
    for _, r in pairs(self.activeRecorders:get()) do
        r:update();
    end
end

function sim:updateMainMenu()
    if Slab.BeginMenu(self.naming.titles) then
        self:updateMainMenuContent();
        if Slab.MenuItem("Pause all") then
            love.audio.pause();
            self.playing = 0;
        end
        Slab.EndMenu();
    end
end

return sim;
