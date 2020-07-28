
local iq = {
        messages = {};
        debug = false;
    };

function iq:pushMessage(title, text)
    if text == nil then text = title; end
    local message = { title = title, text = text }
    table.insert(self.messages, message);
    if self.debug then
        print("InfoQueue: New message:");
        print("  ", title);
        print("  ", text);
    end
end

function iq:Update()
    if table.getn(self.messages) > 0 then
        local message = self.messages[1];
        local result = Slab.MessageBox(message.title, message.text);
        if result ~= "" then
            table.remove(self.messages, 1);
        end
    end
end

return iq;
