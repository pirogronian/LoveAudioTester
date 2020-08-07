
local Utils = require('Utils');

local function scp(item, name)
    changed = false;
    Slab.BeginLayout(tostring(name).."InfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Current time:");
    Slab.SetLayoutColumn(2);
    Slab.Text(Utils.TimeFormat(item.source:tell()));
    Slab.EndLayout();
    Slab.BeginLayout(tostring(name).."ParamsControlLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Volume:");
    Slab.SetLayoutColumn(2);
    local oldv = item.source:getVolume();
    oldv = math.floor(oldv * 100) / 100;
    Slab.InputNumberSlider("VolumeSlider", oldv, 0, 1, { NoDrag = false, ReturnOnText = false });
    local newv = Slab.GetInputNumber();
    if newv ~= oldv then
        changed = true;
        item:setVolume(newv);
        print("New volume:", newv, oldv)
    end
    Slab.EndLayout();
    Slab.BeginLayout(tostring(name).."PlaybackControlLayout", { Columns = 5 });
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
