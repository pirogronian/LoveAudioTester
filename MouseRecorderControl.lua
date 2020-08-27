
require('GuiHelper')

local axes = { "x", "y", "z" };

local function mrc(item)
    Slab.BeginLayout("MouseRecorderLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Record from mouse");
    Slab.Text("Map x:");
    Slab.Text("Map y:");
    Slab.Text("Position scale:");
    Slab.Text("Velocity scale:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item.mouseRecorder.positionScale = 0.01;
        item.mouseRecorder.velocityScale = 500;
    end
    local maxis = item.mouseRecorder._mapper:getSingleMap(1);
    if Slab.BeginComboBox("MapX", { Selected = axes[maxis] }) then
        for key, val in ipairs(axes) do
            if key ~= maxis then
                if Slab.TextSelectable(val) then
                    item.mouseRecorder._mapper:setSingleMap(1, key);
                end
            end
        end
        Slab.EndComboBox();
    end
    maxis = item.mouseRecorder._mapper:getSingleMap(2);
    if Slab.BeginComboBox("MapY", { Selected = axes[maxis] }) then
        for key, val in ipairs(axes) do
            if key ~= maxis then
                if Slab.TextSelectable(val) then
                    item.mouseRecorder._mapper:setSingleMap(2, key);
                end
            end
        end
        Slab.EndComboBox();
    end
    local scale = Slab.PercentageDrag("MRPScale", item.mouseRecorder.positionScale);
    if scale ~= nil then
        item.mouseRecorder.positionScale = scale;
        item.changed:emit();
    end
    scale = Slab.PercentageDrag("MRVScale", item.mouseRecorder.velocityScale);
    if scale ~= nil then
        item.mouseRecorder.velocityScale = scale;
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
