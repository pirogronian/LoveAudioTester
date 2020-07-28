
local function msf(bytes)
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

return msf;
