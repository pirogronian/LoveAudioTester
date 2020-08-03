
local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

local STree = Class("SortableTree");

function STree:initialize(container)
    self.clicked = Signal();
    self.contextMenu = Signal();
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
            self.clicked:emit(item.item);
        end
        if not isLeaf and ret then
            self:SortedTreeContent(container.childContainer, item.item.id);
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
