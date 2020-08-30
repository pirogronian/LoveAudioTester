
local p = {};

function p:__index(k)
--     print(self, k);
    local gn = 'get' .. k;
    local getter = self.class.__instanceDict[gn];
--     print("getter:", gn, fn);
--     local sn = 'get' .. k;
--     local setter = self.class.__instanceDict[sn];
--     print("is setter visible?", gn, fn);
    if type(getter) == 'function' then
--         print("call getter");
        return getter(self);
    else
--         print("call rawget");
        return rawget(self, k);
    end
end

function p:__newindex(k, v)
--     print(self, k, v);
    local sn = 'set' .. k;
    local fn = self.class.__instanceDict[sn]
--     print("setter:", sn, fn);
    if type(fn) == 'function' then
--         print("call setter");
        fn(self, v)
    else
--         local gn = 'get' .. k;
--         local getter = self.class.__instanceDict[gn];
--         print("is getter still visible?:", gn, fn);
--         print("call rawset");
        rawset(self, k, v)
    end
end

return p;
