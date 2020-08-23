
local p = { _properties = {} }

function p:__index(k)
    local getter = self['get'..k];
    if type(getter) == 'function' then
        return getter(self, k);
    else
        return rawget(self, k);
    end
end

function p:__newIndex(k, v)
    local fn = self['set' .. k]
    if type(fn) == 'function' then
        fn(self, v)
    else
      rawset(self, k, v)
    end
end

return p;
