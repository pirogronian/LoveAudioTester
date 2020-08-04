
local function NewSourceDialog(parent)
    local closed = false;
    local id = nil;
    if Slab.BeginDialog("NewSourceDialog", { Title = "Create new source from file", AllowResize = true }) then
        Slab.BeginLayout("NewSourceDialogLayout", { Columns = 2 });
        Slab.SetLayoutColumn(1);
        Slab.Text("Parent object:");
        Slab.Text("Id:");
        Slab.SetLayoutColumn(2);
        Slab.Text(parent.id);
        Slab.Input("SourceId", { ReturnOnText = false });
        id = Slab.GetInputText();
        Slab.EndLayout();
        Slab.BeginLayout("NewSourceDialogButtonsLayout", { Columns = 2, AlignX = "center" });
        if Slab.Button("Create") then
            Slab.CloseDialog("NewSourceDialog");
            closed = true;
        end
        Slab.SameLine();
        if Slab.Button("Cancel") then
            Slab.CloseDialog("NewSourceDialog");
            closed = true;
            id = nil;
        end
        Slab.EndLayout();
        Slab.EndDialog();
    end
    return closed, id;
end

return NewSourceDialog;
