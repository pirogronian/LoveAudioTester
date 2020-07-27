
local iq = {
        messages = {};
    };

function iq:pushMessage(title, text)
    if text == nil then text = title; end
    local message = { title = title, text = text }
    table.insert(self.messages, message);
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
