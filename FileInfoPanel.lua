
local Utils = require('Utils');

local function fip(file, name)
    Slab.BeginLayout(name.."Layout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Path:");
    Slab.Text("Full path:");
    Slab.Text("Size:");
    Slab.SetLayoutColumn(2);
    Slab.Text(file.path);
    Slab.Text(file.fullpath);
    Slab.Text(Utils.MemorySizeFormat(file.size));
    Slab.EndLayout();
end

return fip;
