
DeleteConfirmator = MiddleClass("DeleteConfirmator");

function DeleteConfirmator:initialize(container, itemname)
    self.container = container;
    self.itemName = itemname;
end

function DeleteConfirmator:update()
    local count = self.container:selectedNumber();
    if self.active then
        if count == 0 then
            self.active = false;
            return;
        end
        local result = Slab.MessageBox("Are You sure?", "Are You sure to delete "..count.." "..self.itemName.."?", { Buttons = { "Yes", "No" } });
        if result ~= "" then
            self.active = false;
            if result == "Yes" then
                self.container:deleteSelected();
            end
        end
    end
end
