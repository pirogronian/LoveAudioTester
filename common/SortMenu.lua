
local function SortMenu(container)
    if Slab.BeginMenu("Sort by") then
        for attrid, attr in pairs(container.ItemClass.attributes) do
            if Slab.BeginMenu(attr.name) then
                if Slab.MenuItem("Ascending") then
                    container:sort(attrid, "asc");
                end
                if Slab.MenuItem("Descending") then
                    container:sort(attrid, "desc");
                end
                Slab.EndMenu();
            end
        end
        Slab.EndMenu();
    end
end

return SortMenu;
