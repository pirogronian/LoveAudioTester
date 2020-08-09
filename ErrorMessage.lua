
local IQueue = require('InfoQueue')

local function ErrorMessage(value, title, text)
    if title == nil then
        title = "An error occured!";
    end
    if text == nil then
        text = "The following error occured:";
    end
    IQueue:pushMessage(title, text.."\n"..value);
end

local function OnErrorMessage(title, text, func, ...)
    local status, value = pcall(func, ...);
    if not status then
        ErrorMessage(value, title, text);
    end
    return status, value;
end

return OnErrorMessage, ErrorMessage;
