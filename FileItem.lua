
local Utils = require('Utils');

local Item = require('Item');

local fi = Item:subclass("FileItem");

function fi:initialize(path, isFullPath)
    if isFullPath == true then
        localpath = Utils.getRelativePath(path);
        if localpath == nil then
            error("File with path \n\""..path.."\"\nis inaccessable!");
            return;
        end
    else
        localpath = path;
    end
    Item.initialize(self, localpath);
    self.attributes = { path = localpath };
    file = love.filesystem.getInfo(localpath);
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
