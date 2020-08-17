
local u = require('Utils')

local function itemText(item)
    if item and item.class then
        return tostring(item.class).." : "..tostring(item);
    else
        return "";
    end
end

local function NewSourceDialog(parent, list)
    local closed = false;
    local id = nil;
    if Slab.BeginDialog("NewSourceDialog", { Title = "Create new source from file", AllowResize = true }) then
        if parent then
            Slab.BeginLayout("NewSourceParentInfoLayout", { Columns = 2 });
            Slab.SetLayoutColumn(1);
            Slab.Text("Parent type:");
            Slab.Text("Parent id:");
            Slab.SetLayoutColumn(2);
            Slab.Text(parent.class.name);
            Slab.Text(parent.id);
            Slab.EndLayout();
            Slab.Separator();
        end
        if list ~= nil and #list > 0 then
            if parent == nil then
                parent = list[1];
            end
            if Slab.BeginComboBox("ActiveParents", { Selected = itemText(parent) }) then
                for _, item in ipairs(list) do
                    if class ~= "n" then
--                         print(class, manager)
                        if Slab.TextSelectable(itemText(item)) then
                            parent = item;
                        end
                    end
                end
                Slab.EndComboBox();
            end
        end
        Slab.BeginLayout("NewSourceDialogLayout", { Columns = 2 });
        Slab.SetLayoutColumn(1);
        Slab.Text("Id:");
        Slab.SetLayoutColumn(2);
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
    return closed, id, parent;
end

return NewSourceDialog;
