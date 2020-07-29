
local Class = require('thirdparty/middleclass/middleclass');

local Utils = require('Utils');

local c = Class("Communicator");

function c:initialize()
    self._signals = {};
end

function c:_getSlots(signame)
    local slots = self._signals[signame];
    if slots == nil then
        error("Communicator: no such signal: "..Utils.VariableInfoString(signame));
    end
    return slots;
end

function c:DeclareSignal(signame)
    if self._signals[signame] == nil then
        self._signals[signame] = {};
    end
end

function c:UndeclareSignal(signame)
    self._signals[signame] = nil;
end

function c:Connect(signame, slot, receiver, sender)
    local slots = self:_getSlots(signame);
    if slots[slot] == nil then
        slots[slot] = { };
    end
    if type(receiver) ~= 'table' then
        receiver = 1;
    end
    slots[slot][receiver] = { sender = sender };
end

function c:Disconnect(signame, slot, receiver)
    if slot == nil then
        self._signals[signame] = nil;
        return;
    end
    local slots = self:_getSlots(signame);
    if receiver == nil then
        slots[slot] = nil;
        return;
    end
    local recs = slots[slot];
    if recs == nil then
        print("Warning: Disconecting nonexisting slot: "..Utils.VariableInfoString(slot));
        return;
    end
    recs[receiver] = nil;
end

function c:EmitSignal(signame, ...)
    local slots = self:_getSlots(signame);
    for slot, receivers in pairs(slots) do
        for receiver, entry in pairs(receivers) do
            if entry.sender == nil then
                sender = self;
            else
                sender = entry.sender;
            end
            if type(receiver) == 'table' then
                if type(sender) == 'table' then
                    slot(receiver, sender, ...);
                else
                    slot(receiver, ...);
                end
            else
                if type(sender) == 'table' then
                    slot(sender, ...);
                else
                    slot(...);
                end
            end
        end
    end
end

function c:DumpSignals()
    for signame, slots in pairs(self._signals) do
        print(signame, slots);
        for slot, receivers in pairs(slots) do
            print("  `", slot, receivers);
            for receiver, entry in pairs(receivers) do
                print("    `", receiver, entry.sender);
            end
        end
    end
end

return c;
