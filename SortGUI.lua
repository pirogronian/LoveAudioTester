
local function SortMenu(container)
    if Slab.BeginMenu("Sort by") then
        for attrid, attr in pairs(container.attributes) do
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

local function SortedTree(container)
    if Slab.BeginTree(container.name) then
        local index = container:getIndex(container.currentAttr);
        for idx, item in ipairs(index) do
            if item.item.isSortableContainer == true then
                isLeaf = false;
            else
                isLeaf = true;
            end
            local ret = Slab.BeginTree(item.item.id, { IsLeaf = isLeaf, IsSelected = container:isSelected(item.item.id) });
            if Slab.IsControlClicked() then
                container:toggleSelection(item.item.id);
            end
            if not isLeaf and ret then
                SortedTree(item.item);
                Slab.EndTree();
            end
        end
        Slab.EndTree();
    end
end

return { SortMenu = SortMenu, SortedTree = SortedTree };
