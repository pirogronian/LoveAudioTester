
local Comm = require('Communicator');

local STree = Comm:subclass("SortableTree");

function STree:initialize(container)
    Comm.initialize(self);
    self:DeclareSignal("Clicked");
    self:DeclareSignal("ContextMenu");
    self.container = container;
end

function STree:SortedTreeContent(container, groupid)
    local index = container:getIndex(container.currentAttribute, groupid);
    for idx, item in ipairs(index) do
        if container.childContainer ~= nil and container.childContainer:getItemCount(item.item.id) > 0 then
--             print(item.id, options.childrenContainer:getItemCount(item.id));
            isLeaf = false;
        else
            isLeaf = true;
        end
        local ret = Slab.BeginTree(item.item, { IsLeaf = isLeaf, IsSelected = container:isSelected(item.item.id) });
        if Slab.IsControlClicked() then
            self:EmitSignal("Clicked", item.item)
        end
        if not isLeaf and ret then
            SortedTreeContent(container.childContainer, item.item.id);
        end
        if ret then
            Slab.EndTree();
        end
    end
end

function STree:Update()
    if Slab.BeginTree(self.container.name) then
        self:SortedTreeContent(self.container);
        Slab.EndTree();
    end
end

return STree;
