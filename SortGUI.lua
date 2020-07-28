
local dT = require('DumpTable')

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

local function SortedTreeContent(container, options)
    if options == nil then
        options = {};
    end
    local index = container:getIndex(container.currentAttribute, options.groupid);
    for idx, item in ipairs(index) do
        if item.item.container == nil then
            isLeaf = true;
        else
            isLeaf = false;
        end
        local ret = Slab.BeginTree(item.item, { IsLeaf = isLeaf, IsSelected = container:isSelected(item.item.id) });
        if Slab.IsControlClicked() then
            container:toggleSelection(item.item.id);
            if options.clicked ~= nil then
                options.clicked(item.item, options.context);
            end
        end
        if not isLeaf and ret then
            SortedTreeContent(item.item.container, options);
            Slab.EndTree();
        end
    end
end

local function SortedTree(container, options)
    if Slab.BeginTree(container.name) then
        SortedTreeContent(container, options);
        Slab.EndTree();
    end
end

return { SortMenu = SortMenu, SortedTree = SortedTree };
