
local u = require('common/Utils')

local class = require('thirdparty/middleclass/middleclass');

local nid = class("NewItemDialog");

local function itemText(item)
    if item and item.class then
        return tostring(item.class).." : "..tostring(item);
    else
        return "";
    end
end

function nid:initialize(id, parent, list, title)
    if title == nil then
        title = "Create new item";
    end
    self.newItemData = { id = id, parent = parent };
    self._parentItemsList = list;
    self.open = true;
    self.canceled = false;
    self.title = title;
    Slab.OpenDialog("NewItemDialog");
end

function nid:parentItemSelection()
    local parent = self.newItemData.parent;
    if parent then
        Slab.Text("Parent");
        Slab.BeginLayout("ParentInfoLayout", { Columns = 2 });
        Slab.SetLayoutColumn(1);
        Slab.Text("Parent type:");
        Slab.Text("Parent id:");
        Slab.SetLayoutColumn(2);
        Slab.Text(parent.class.name);
        Slab.Text(tostring(parent));
        Slab.EndLayout();
        Slab.Separator();
    end
    local list = self._parentItemsList;
    if list ~= nil and #list > 0 then
        Slab.BeginLayout("ParentSelectionLayout", { Columns = 1 })
        Slab.SetLayoutColumn(1);
        if parent == nil then
            parent = list[1];
        end
        if Slab.BeginComboBox("ActiveParents", { Selected = itemText(parent) }) then
            for _, item in ipairs(list) do
                if type(item) == 'table' then
                    if Slab.TextSelectable(itemText(item)) then
                        parent = item;
                    end
                else
                    if Slab.TextSelectable(item) then
                        parent = nil;
                    end
                end
            end
            Slab.EndComboBox();
        end
        Slab.EndLayout();
    end
    self.newItemData.parent = parent;
end

function nid:idInput()
    Slab.BeginLayout("NewSourceDialogLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Name:");
    Slab.SetLayoutColumn(2);
    if Slab.Input("SourceId", { Text = self.newItemData.id, ReturnOnText = true }) then
        self.newItemData.id = Slab.GetInputText();
    end
    Slab.EndLayout();
end

function nid:buttons()
    Slab.BeginLayout("ButtonsLayout", { Columns = 2, AlignX = "center" });
    Slab.SetLayoutColumn(1);
    if Slab.Button("Create") then
        Slab.CloseDialog("NewItemDialog");
        self.open = false;
    end
    Slab.SetLayoutColumn(2);
    if Slab.Button("Cancel") then
        Slab.CloseDialog("NewItemDialog");
        self.open = false;
        self.canceled = true;
    end
    Slab.EndLayout();
end

function nid:update()
    if Slab.BeginDialog("NewItemDialog", { Title = self.title, AllowResize = true, IsOpen = self.open }) then
        self:parentItemSelection();
        Slab.Separator();
        self:idInput();
        Slab.Separator();
        self:buttons();
        Slab.EndDialog();
    end
end

return nid;
