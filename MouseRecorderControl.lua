
require('GuiHelper')

local function mrc(item)
    Slab.BeginLayout("MouseRecorderLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Record from mouse");
    Slab.Text("Position scale:");
    Slab.Text("Velocity scale:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item.mouseRecorder.positionScale = 0.01;
        item.mouseRecorder.velocityScale = 50;
    end
    if Slab.ActiveDrag("MRPScale", item.mouseRecorder.positionScale * 100) then
        item.mouseRecorder.positionScale = Slab.GetInputNumber() / 100;
        item.changed:emit();
    end
    Slab.SameLine();
    Slab.Text("%");
    if Slab.ActiveDrag("MRVScale", item.mouseRecorder.velocityScale * 100) then
        item.mouseRecorder.velocityScale = Slab.GetInputNumber() / 100;
        item.changed:emit();
    end
    Slab.SameLine();
    Slab.Text("%");
    Slab.EndLayout();
    if item.mouseRecorder:isActive() then
        Slab.Text("Click anywhere to stop")
        if Slab.WasMousePressed() then
            item.mouseRecorder:setActive(false);
        end
    else
        if Slab.Button("Start") then
            item.mouseRecorder:setActive(true);
        end
    end
end

return mrc;
