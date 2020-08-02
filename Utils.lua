
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


function u.MemorySizeFormat(bytes)
    local units = "B";
    if bytes >= 1024 then
        bytes = bytes / 1024;
        units = "KB";
        if bytes >= 1024 then
            bytes = bytes / 1024;
            units = "MB";
            if bytes >= 1024 then
                bytes = bytes / 1024;
                units = "GB";
            end
        end
    end
    return string.format("%.2f %s", bytes, units);
end

function u.TimeFormat(seconds)
    seconds = math.floor(seconds);
    local minutes = math.floor(seconds / 60);
    local hours = math.floor(minutes / 60);
    return string.format("%u:%02u:%02u", hours, minutes, seconds);
end

function u.VariableInfoString(var)
    local t = type(var);
    local val = tostring(var);
    return string.format("%s (%s)", val, t);
end

function u.IsClassOrSubClass(class, name)
    return class.name == name or class:isSubclassOf(name);
end

function u.Dump(var, level, str)
    if type(str) ~= 'string' then str = ""; end
    print(str..tostring(var), "(", type(var) ,")");
    if type(var) == 'table' and level ~= 0 then
        for key, val in pairs(var) do
            u.Dump(val, level - 1, str..tostring(key)..".")
        end
    end
end

return u;
