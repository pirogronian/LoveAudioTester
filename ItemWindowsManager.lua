
local dTable = require('DumpTable');

local iwm = {
        modules = {};
    };

function iwm:registerModule(id, title, updateFunction, funcParam)
    self.modules[id] = {
            id = id,
            title = title,
            updateFunction = updateFunction,
            context = funcParam,
            items = {},
            currentItem = nil,
            currentWindow = false
        };
end

function iwm:getModule(id)
    local module = self.modules[id];
    if module == nil then
        if type(id) ~= 'string' then
            id = id.__tostring();
        end
        error("No such module: "..id);
    end
    return module;
end

function iwm:setCurrentItem(modid, item)
    local module = self:getModule(modid);
    module.currentItem = item;
end

function iwm:unsetCurrentItem(modid, id)
    local module = self:getModule(modid);
    if module.currentItem == nil then return; end
    if id ~= nil then
        if module.currentItem.id ~= id then return; end
    end
    module.currentItem = nil;
end

function iwm:showCurrentItemWindow(modid)
    local module = self:getModule(modid);
    module.currentWindow = true;
end

function iwm:addItem(modid, item)
    local module = self:getModule(modid);
    module.items[item.id] = item;
end

function iwm:delItem(modid, itemid, current)
    local module = self:getModule(modid);
    module.items[itemid] = nil;
    if current then
        self:unsetCurrentItem(modid, itemid);
    end
end

function iwm.getCurrentWindowId(module)
    return module.id.."CurrentItemWindow";
end

function iwm.UpdateCurrentItemWindow(module)
    if module.currentItem == nil or not module.currentWindow then return; end
    if Slab.BeginWindow(iwm.getCurrentWindowId(module),
                        {
                         Title = module.title,
                         IsOpen = module.currentWindow
                         }) then
        module.updateFunction(module.currentItem, module.context);
    else
        module.currentWindow = false;
    end
    Slab.EndWindow();
end

function iwm:UpdateCurrentItemWindows()
    for id, module in pairs(self.modules) do
        self.UpdateCurrentItemWindow(module);
    end
end

function iwm:dumpModules()
    print("ItemWindowsManager::dumpModules:");
    for id, module in pairs(self.modules) do
        print(id, module)
    end
end

return iwm;
