
local Utils = require('Utils');

local Item = require('Item');

local fi = Item:subclass("FileItem");

function fi:initialize(data, isFullPath)
    local path = data;
    if type(data) == 'table' then
        path = data.id;
        isFullPath = data.isFullPath;
    end
    local localpath = path;
    if isFullPath == true then
        localpath = Utils.getRelativePath(path);
        if localpath == nil then
            error("File with path \n\""..path.."\"\nis inaccessable!");
            return;
        end
    end
    Item.initialize(self, localpath);
    self.attributes = { path = localpath };
    local file = love.filesystem.getInfo(localpath);
    if file == nil then
        error("Cannot get info of file: "..tostring(localpath));
    end
    file.path = localpath;
    file.fullpath = path;
    self.file = file;
    local status, value = pcall(love.sound.newDecoder, localpath);
    if not status then
        error("Cannot create decoder from file\n\""..localpath.."\"!\nError: \""..value.."\"");
        return;
    end
    self.decoder = value;
end

return fi;
