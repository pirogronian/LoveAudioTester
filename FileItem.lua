
local Utils = require('Utils');

local Item = require('Item');

local fi = Item:subclass("FileItem");

fi.static.attributes = {};

fi:addAttribute(Item.Attribute("path", "Path"));

function fi:initialize(data, isFullPath)
    local localpath = data;
    local fullpath = data;
    if type(data) == 'table' then
        localpath = data.id;
        fullpath = data.fullpath;
    else
        if isFullPath == true then
            localpath = Utils.getRelativePath(fullpath);
            if localpath == nil then
                error("File with path \n\""..fullpath.."\"\nis inaccessable!");
                return;
            end
        end
    end
    Item.initialize(self, localpath);
    self.attributes = { path = localpath };
    local file = love.filesystem.getInfo(localpath);
    if file == nil then
        error("Cannot get info of file: "..tostring(localpath));
    end
    file.path = localpath;
    file.fullpath = fullpath;
    self.file = file;
    local status, value = pcall(love.sound.newDecoder, localpath);
    if not status then
        error("Cannot create decoder from file\n\""..localpath.."\"!\nError: \""..value.."\"");
        return;
    end
    self.decoder = value;
end

function fi:getSerializableData()
    local data = Item.getSerializableData(self);
    data.fullpath = self.file.fullpath;
    return data;
end

function fi:destroy()
    self.decoder:release();
end

return fi;
