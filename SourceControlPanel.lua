
local Utils = require('Utils');

local function spatialOptions(item)
    if (not item:isMono()) then
        Slab.Text("Spatial options are unavaliable for multi-channel sources.");
        return;
    end
    Slab.BeginLayout("PositionLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Position:");
    Slab.SetLayoutColumn(2);
    local x, y, z = item.source:getPosition();
    input = false;
    if Slab.InputNumberDrag("PositionX", x) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("PositionY", y) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("PositionZ", z) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setPosition(x, y, z); end
    Slab.EndLayout();
end

local function scp(item)
    changed = false;
    if item:spatialVisible() then
        if Slab.Button("Hide spatial options") then
            item:setShowSpatial(false);
        end
        spatialOptions(item);
        Slab.Separator();
    else
        if Slab.Button("Show spatial options") then
            item:setShowSpatial(true);
        end
    end
    Slab.BeginLayout("InfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Current time:");
    Slab.SetLayoutColumn(2);
    Slab.Text(Utils.TimeFormat(item.source:tell()));
    Slab.EndLayout();
    Slab.BeginLayout("ParamsControlLayout", { Columns = 4 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Volume:");
    Slab.SetLayoutColumn(2);
    local ov = item.source:getVolume();
    if Slab.InputNumberSlider("VolumeSlider", math.floor(ov * 100), 0, 100, { NoDrag = false, ReturnOnText = true }) then
        local nv = Slab.GetInputNumber();
        item:setVolume(nv / 100);
    end
    Slab.SetLayoutColumn(3);
    if Slab.CheckBox(item.source:isLooping(), "Looping") then
        item:toggleLooping();
    end
    Slab.EndLayout();
    Slab.BeginLayout("PlaybackControlLayout", { Columns = 5 });
    Slab.SetLayoutColumn(1);
    if Slab.Button("[<<") then
        item.source:seek(0);
    end
    Slab.SetLayoutColumn(2);
    if Slab.Button("<") then
        item:rewindBy(-10);
    end
    Slab.SetLayoutColumn(3);
    if item.source:isPlaying() then
        if Slab.Button("Pause") then
            item:pause();
        end
    else
        if Slab.Button("Play") then
            item:play();
        end
    end
    Slab.SetLayoutColumn(4);
    if Slab.Button("Stop") then
        item:stop();
    end
    Slab.SetLayoutColumn(5);
    if Slab.Button(">") then
        item:rewindBy(10);
    end
    Slab.EndLayout();
    return changed;
end

return scp;
