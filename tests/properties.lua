
local class = require('../thirdparty/middleclass/middleclass');

local props = require('../Properties');

local propclass = class('PropClass'):include(props);

function propclass:setVar1(a)
    self._var1 = a;
end

function propclass:getVar1(a)
    return self._var1;
end

local pci = propclass();

pci.Var1 = 13;

assert(pci.Var1 == 13);

pci.Var1 = "a";

assert(pci.Var1 == "a");
