
local Class = require('thirdparty/middleclass/middleclass');

local Utils = require('Utils');

local s = Class("Signal");

function s:initialize()
    self._slots = {};
end

function s:connect(slot, receiver, sender)
    if self._slots[slot] == nil then
        self._slots[slot] = { };
    end
    if type(receiver) ~= 'table' then
        receiver = 1;
    end
    self._slots[slot][receiver] = { sender = sender };
end

function s:disconnect(slot, receiver)
    if slot == nil then
        self._slots = { };
        return;
    end
    if receiver == nil then
        self._slots[slot] = nil;
        return;
    end
    local recs = self._slots[slot];
    if recs == nil then
        print("Warning: Disconecting nonexisting slot: "..Utils.DumpStr(slot));
        return;
    end
    recs[receiver] = nil;
end

function s:emit(...)
    for slot, receivers in pairs(self._slots) do
        for receiver, entry in pairs(receivers) do
            if type(receiver) == 'table' then
                if sender ~= nil then
--                     print("Receiver with sender");
                    slot(receiver, sender, ...);
                else
--                     print("Receiver only");
                    slot(receiver, ...);
                end
            else
                if sender ~= nil then
--                     print("Sender only");
                    slot(sender, ...);
                else
--                     print("Just callback");
                    slot(...);
                end
            end
        end
    end
end

function s:dump()
    for slot, receivers in pairs(self._slots) do
        print("  `", slot, receivers);
        for receiver, entry in pairs(receivers) do
            print("    `", receiver, entry.sender);
        end
    end
end

return s;
