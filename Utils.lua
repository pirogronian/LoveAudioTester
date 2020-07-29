
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

return u;
