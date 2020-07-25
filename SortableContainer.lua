
SortableAttribute = MiddleClass("SortableAttribute");

function SortableAttribute.sortAsc(sitem1, sitem2)
    return sitem1.attribute < sitem2.attribute;
end

function SortableAttribute.sortDesc(sitem1, sitem2)
    return sitem1.attribute > sitem2.attribute;
end

function SortableAttribute:initialize(id, name)
    self.id = id;
    self.name = name;
end

function SortableAttribute:dump()
    print(self.class.name..":\n  id: "..self.id.."\n  name: "..self.name)
end

SortableContainer = MiddleClass("SortableContainer");

function SortableContainer:initialize(id, name)
    self.ids = {};
    self.indexes = {};
    self.attributes = {};
    self.selected = {};
    self.id = id;
    self.name = name;
    self.isSortableContainer = true;
end

function SortableContainer:addAttribute(attr)
    self.attributes[attr.id] = attr;
    self.indexes[attr.id] = {};
    if self.currentAttr == nil then
        self.currentAttr = attr.id;
    end
end

function SortableContainer:delAttribute(id)
    table.remove(self.attributes, id);
    table.remove(self.indexes, id);
end

function SortableContainer:getIndex(id)
    local index = self.indexes[id];
    if type(index) ~= 'table' then
        error(self.class.name..": attribute \""..id.."\" not found in indexes.");
    end
    return index;
end

function SortableContainer:getAttr(id)
    local attr = self.attributes[id];
    if type(attr) ~= 'table' then
        error(self.class.name..": attribute \""..id.."\" not found in attributes.");
    end
    return attr;
end

function SortableContainer:addItem(item, selected)
    if self.ids[item.id] ~= nil then
        error(self.class.name..":addItem("..item.id.."): item already exists!");
    end
    self.ids[item.id] = item;
    for id, attr in pairs(self.attributes) do
        local index = self:getIndex(id);
        table.insert(index, { attribute = item.attributes[id], item = item });
    end
    if selected == true then
        self:select(item.id);
    end
end

function SortableContainer:delItem(id)
    for attrid, index in pairs(self.indexes) do
        for sid, item in ipairs(index) do
            if item.item.id == id then
                table.remove(index, sid);
                return;
            end
        end
    end
    table.remove(self.selected, id);
    table.remove(self.ids, id);
end

function SortableContainer:select(id)
    self.selected[id] = true;
end

function SortableContainer:deselect(id)
    self.selected[id] = false;
end

function SortableContainer:isSelected(id)
    return self.selected[id] == true;
end

function SortableContainer:toggleSelection(id)
    self.selected[id] = not self.selected[id];
end

function SortableContainer:sort(attrid, dir)
    local attr = self:getAttr(attrid);
    local comp = nil;
    if dir == "asc" then
        comp = attr.sortAsc;
    else
        comp = attr.sortDesc;
    end
    local index = self:getIndex(attrid);
    table.sort(index, comp);
    self.currentAttr = attrid;
end

function SortableContainer:dumpAttrs()
    print("Attributes ("..table.getn(self.attributes).."):");
    for id, attr in pairs(self.attributes) do
        attr:dump();
    end
end

function SortableContainer.dumpIndexArray(array)
    for idx, item in ipairs(array) do
        print("["..idx.."] => { id: "..item.item.id..", attribute: "..item.attribute.." }");
    end
end

function SortableContainer:dumpIndex(id)
    local index = self:getIndex(id);
    print("Index ("..table.getn(index)..":");
    self.dumpIndexArray(index);
end
