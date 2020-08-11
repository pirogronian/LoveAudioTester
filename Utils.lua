
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

function u.IsClassOrSubClass(class, class2)
    return class == class2 or class:isSubclassOf(class2);
end

local function VarInfo(var, str)
    if string.len(str) > 0 then
        str = str..": ";
    end
    print(str..tostring(var), "(", type(var) ,")");
end

function u.Dump(var, level, str, tname)
--     print(var, level, str, tname);
    if level == nil then level = 0; end
    if type(str) ~= 'string' then str = ""; end
    if tname ~= nil then
        if type(var) == tname then
            VarInfo(var, str);
        end
    else
        VarInfo(var, str);
    end
    if type(var) == 'table' and level ~= 0 then
        for key, val in pairs(var) do
            u.Dump(val, level - 1, str..tostring(key)..".", tname)
        end
    end
end

function u.DumpStr(var, level, str)
    if level == nil then level = 0; end
    if type(str) ~= 'string' then str = ""; end
    local ret = str..tostring(var).."  ("..type(var)..")";
    if type(var) == 'table' and level ~= 0 then
        for key, val in pairs(var) do
            ret = ret.."\n"..u.DumpStr(val, level - 1, str..tostring(key)..".");
        end
        ret = ret.."\n";
    end
    return ret;
end

function u.TryValue(val, defval, valtype, onerror)
    if onerror == nil then
        onerror = 'default';
    end
    if valtype ~= nil then
        if type(val) ~= valtype then
            if onerror == 'default' then return defval; end
            if onerror == 'error' then error("Wrong value type: "..type(val)); end
            if onerror == 'warning' then print("Warning: Wrong value type: "..type(val).." (should be "..valtype..")"); return defval; end
            error("Wrong on-error behaviour: "..tostring(onerror));
        else
            return val;
        end
    else
        if val == nil then
            return defval;
        else
            return val;
        end
    end
end

return u;
