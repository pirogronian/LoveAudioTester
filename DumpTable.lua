
local d = function(t, rec)
    print(t);
    local size = 0;
    for key, val in pairs(t) do
        print(key, val);
        if rec and type(val) == "table" then
            d(val, rec);
        end
        size = size +1;
    end
    print("Size:", size);
end

return d;
