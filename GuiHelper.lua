
function Slab.ActiveSlider(...)
    return Slab.InputNumberSlider(...) or (Slab.IsControlHovered() and Slab.IsMouseDragging(1));
end

function Slab.ActiveDrag(...)
    return Slab.InputNumberDrag(...) or (Slab.IsControlHovered() and Slab.IsMouseDragging(1));
end
