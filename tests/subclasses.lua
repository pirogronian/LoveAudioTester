
local class = require('../thirdparty/middleclass/middleclass')

local u = require('../Utils');

local class1 = class("class1");

local class2 = class1:subclass("class2");

local class3 = class2:subclass("class3");

assert(class2:isSubclassOf(class1));

assert(class3:isSubclassOf(class2));

assert(class3:isSubclassOf(class1));

assert(u.IsClassOrSubClass(class2, class1))

assert(u.IsClassOrSubClass(class3, class2))

assert(u.IsClassOrSubClass(class3, class1))


