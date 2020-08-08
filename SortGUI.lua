
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

local function SortedTreeContent(container, options, groupid)
    if options == nil then
        options = {};
    end
    local index = container:getIndex(container.currentAttribute, groupid);
    for idx, item in ipairs(index) do
        if options.childrenContainer ~= nil and options.childrenContainer:getItemCount(item.item.id) > 0 then
--             print(item.id, options.childrenContainer:getItemCount(item.id));
            isLeaf = false;
        else
            isLeaf = true;
        end
        local ret = Slab.BeginTree(item.item, { IsLeaf = isLeaf, IsSelected = container:isSelected(item.item.id) });
        if Slab.IsControlClicked() then
            if options.clicked ~= nil then
                options.clicked(item.item, options.context);
            end
        end
        if not isLeaf and ret then
            SortedTreeContent(options.childrenContainer, options.childrenOptions, item.item.id);
        end
        if ret then
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
