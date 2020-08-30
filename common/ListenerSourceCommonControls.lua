
local cg = require('common/ControlsGroups');

local lscc = {};

function lscc.position(item, ogr)
    Slab.BeginLayout("PositionLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    cg.hideButton(item, "position")
    Slab.Text("x:");
    Slab.Text("y:");
    Slab.Text("z:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setPosition(0, 0, 0);
    end
    local x, y, z = item:getPosition();
    input = false;
    if Slab.ActiveDrag("PositionX", x, { Step = 0.1 }) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.ActiveDrag("PositionY", y, { Step = 0.1 }) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.ActiveDrag("PositionZ", z, { Step = 0.1 }) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setPosition(x, y, z); end
    Slab.EndLayout();
end

function lscc.velocity(item, ogr)
    Slab.BeginLayout("VelocityLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    cg.hideButton(item, ogr)
    Slab.Text("x:");
    Slab.Text("y:");
    Slab.Text("z:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setVelocity(0, 0, 0);
    end
    x, y, z = item:getVelocity();
    input = false;
    if Slab.ActiveDrag("VelocityX", x, { Step = 0.1 }) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.ActiveDrag("VelocityY", y, { Step = 0.1 }) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.ActiveDrag("VelocityZ", z, { Step = 0.1 }) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setVelocity(x, y, z); end
    Slab.EndLayout();
end

return lscc;
