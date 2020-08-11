
local Utils = require('Utils');

local function scp(item, name)
    name = tostring(name);
    changed = false;
    Slab.BeginLayout("InfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Current time:");
    Slab.SetLayoutColumn(2);
    Slab.Text(Utils.TimeFormat(item.source:tell()));
    Slab.EndLayout();
    Slab.BeginLayout("ParamsControlLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Looping:");
    Slab.Text("Volume:");
    Slab.SetLayoutColumn(2);
    if Slab.CheckBox(item.source:isLooping()) then
        item:toggleLooping();
    end
    local ov = item.source:getVolume();
    if Slab.InputNumberSlider("VolumeSlider", math.floor(ov * 100), 0, 100, { NoDrag = false, ReturnOnText = true }) then
        local nv = Slab.GetInputNumber();
        item:setVolume(nv / 100);
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
