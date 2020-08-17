
local Class = require('thirdparty/middleclass/middleclass');

local Signal = require('Signal');

local STree = Class("SortableTree");

function STree:initialize(manager)
    self.clicked = Signal();
    self.contextMenu = Signal();
    self.manager = manager;
end

function STree:SortedTreeContent(manager, groupid)
    local index = manager.container:getIndex(manager.container.currentAttribute, groupid);
    for idx, item in ipairs(index) do
        if manager.child ~= nil and manager.child.container:getItemCount(item.item) > 0 then
            isLeaf = false;
        else
            isLeaf = true;
        end
        local ret = Slab.BeginTree(item.item, { IsLeaf = isLeaf, IsSelected = manager.container:isSelected(item.item) });
        if Slab.IsControlClicked() then
            self.clicked:emit(item.item);
        end
        if Slab.BeginContextMenuItem() then
            manager:itemContextMenu(item.item);
            Slab.EndContextMenu();
        end
        if not isLeaf and ret then
            self:SortedTreeContent(manager.child, item.item);
        end
        if ret then
            Slab.EndTree();
        end
    end
end

function STree:Update()
    if Slab.BeginTree(self.manager.naming.titles) then
        if self.manager.contextMenu and Slab.BeginContextMenuItem() then
            self.manager:contextMenu();
            Slab.EndContextMenu();
        end
        self:SortedTreeContent(self.manager);
        Slab.EndTree();
    end
end

return STree;
