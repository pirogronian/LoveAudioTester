
local Utils = require('Utils');

local function scp(source, name)
    Slab.BeginLayout(tostring(name).."InfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Current time:");
    Slab.SetLayoutColumn(2);
    Slab.Text(Utils.TimeFormat(source:tell()));
    Slab.EndLayout();
    Slab.BeginLayout(tostring(name).."ControlLayout", { Columns = 5 });
    Slab.SetLayoutColumn(1);
    if Slab.Button("[<<") then
        source:seek(0);
    end
    Slab.SetLayoutColumn(2);
    if Slab.Button("<") then
        local pos = source:tell() - 10;
        if pos < 0 then pos = 0; end
        source:seek(pos);
    end
    Slab.SetLayoutColumn(3);
    if source:isPlaying() then
        if Slab.Button("Pause") then
            source:pause();
        end
    else
        if Slab.Button("Play") then
            source:play();
        end
    end
    Slab.SetLayoutColumn(4);
    if Slab.Button("Stop") then
        source:stop();
    end
    Slab.SetLayoutColumn(5);
    if Slab.Button(">") then
        local pos = source:tell() + 10;
        if pos > source:getDuration() then pos = source:getDuration(); end
        source:seek(pos);
    end
    Slab.EndLayout();
end

return scp;
