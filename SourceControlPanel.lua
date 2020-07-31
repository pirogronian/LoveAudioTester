
local Utils = require('Utils');

local function scp(source, name)
    Slab.BeginLayout(name.."InfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Current time:");
    Slab.SetLayoutColumn(2);
    Slab.Text(Utils.TimeFormat(source:getPosition()));
    Slab.EndLayout();
    Slab.BeginLayout(name.."ControlLayout", { Columns = 5 });
    Slab.SetLayoutColumn(1);
    if Slab.Button("[<<") then
    end
    Slab.SetLayoutColumn(2);
    if Slab.Button("<") then
        source:rewind(source:getPosition() - 10);
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
        source:rewind(source:getPosition() + 10);
    end
    Slab.EndLayout();
end
