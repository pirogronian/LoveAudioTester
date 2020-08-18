
local fim = require('FileItemsManager');

local sm = require('SourcesModule');

local fm = fim();

sm:addParent(fm);

return fm;
