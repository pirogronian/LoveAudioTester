
local utils = require('common/Utils');

local function di(decoder, lname)
    if lname == nil or lname == "" then
        lname = "DecoderInfoLayout";
    end
    Slab.BeginLayout(lname.."Layout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Bit depth:");
    Slab.Text("Channels:");
    Slab.Text("Sample rate:");
    Slab.Text("Duration:");
    Slab.SetLayoutColumn(2);
    Slab.Text(decoder:getBitDepth());
    Slab.Text(decoder:getChannelCount());
    Slab.Text(decoder:getSampleRate());
    Slab.Text(utils.TimeFormat(decoder:getDuration()));
    Slab.EndLayout();
end

return di;
