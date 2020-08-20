
local function mrc(item)
    Slab.BeginLayout("MouseRecorderLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Record from mouse");
    if item.mouseRecorder.active then
        Slab.Text("Click anywhere to stop")
        if Slab.WasMousePressed() then
            item.mouseRecorder.active = false;
            item.recordingStopped:emit(item.mouseRecorder);
        end
    else
        if Slab.Button("Start") then
            item.mouseRecorder.active = true;
            item.recordingStarted:emit(item.mouseRecorder);
        end
    end
    Slab.EndLayout();
end

return mrc;
