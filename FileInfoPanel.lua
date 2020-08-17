
local Utils = require('Utils');

local function fip(file)
    Slab.BeginLayout("FileInfoLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Path:");
    if file.fullpath then
        Slab.Text("Full path:");
    end
    Slab.Text("Size:");
    Slab.SetLayoutColumn(2);
    Slab.Text(file.path);
    if file.fullpath then
        Slab.Text(file.fullpath);
    end
    Slab.Text(Utils.MemorySizeFormat(file.size));
    Slab.EndLayout();
end

return fip;
