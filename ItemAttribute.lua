
local Class = require('thirdparty/middleclass/middleclass')

local ItemAttribute = Class("ItemAttribute");

function ItemAttribute.sortAsc(sitem1, sitem2)
    return sitem1.attribute < sitem2.attribute;
end

function ItemAttribute.sortDesc(sitem1, sitem2)
    return sitem1.attribute > sitem2.attribute;
end

function ItemAttribute:initialize(id, name)
    self.id = id;
    self.name = name;
end

function ItemAttribute:dump()
    print(self.class.name..":\n  id: "..self.id.."\n  name: "..self.name)
end

return ItemAttribute;
