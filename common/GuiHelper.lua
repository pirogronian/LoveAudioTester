
function Slab.ActiveSlider(...)
    return Slab.InputNumberSlider(...) or (Slab.IsControlHovered() and Slab.IsMouseDragging(1));
end

function Slab.ActiveDrag(...)
    return Slab.InputNumberDrag(...) or (Slab.IsControlHovered() and Slab.IsMouseDragging(1));
end

function Slab.PercentageSlider(name, value, min, max, options)
    min = min or 0;
    max = max or 100;
    local ret = Slab.ActiveSlider(name, math.floor(value * 100), min, max, options);
    Slab.SameLine();
    Slab.Text("%");
    if ret then
        local nv = Slab.GetInputNumber();
--         print("Input number:", nv);
        return nv / 100;
    end
end

function Slab.PercentageDrag(name, value, min, max, options)
    local ret = Slab.ActiveDrag(name, math.floor(value * 100), min, max, options);
    Slab.SameLine();
    Slab.Text("%");
    if ret then
        local nv = Slab.GetInputNumber();
--         print("Input number:", nv);
        return nv / 100;
    end
end

function Slab.DegreeSlider(name, value, min, max, options)
    min = min or 0;
    max = max or 360;
    local ret = Slab.ActiveSlider(name, math.floor(math.deg(value)), min, max, options);
    Slab.SameLine();
    Slab.Text("°");
    if ret then
        return math.rad(Slab.GetInputNumber());
    end
end
