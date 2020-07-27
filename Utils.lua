
local u = {};

function u.getSuffix(str, prefix)
    if string.find(str, prefix) == 1 then
        return string.sub(str, string.len(prefix) + 1);
    end
end

function u.getRelativePath(path)
    local rel = u.getSuffix(path, love.filesystem.getSaveDirectory());
    if rel == nil then
        rel = u.getSuffix(path, love.filesystem.getSource());
    end
    return rel;
end

return u;
