
local Utils = require('Utils');

local function spatialOptions(item)
    if (not item:isMono()) then
        Slab.Text("Spatial options are unavaliable for multi-channel sources.");
        return;
    end

    Slab.BeginLayout("AttenuationLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Volume falloff");
    Slab.Text("Reference distance:");
    Slab.Text("Maximal distance:");
    Slab.Text("Air absorbtion:");
    Slab.Text("Rolloff:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setAttenuationDistances(1, math.huge);
        item:setAirAbsorption(0);
        item:setRolloff(1);
    end
    local ref, max = item.source:getAttenuationDistances();
    local input = false;
    if Slab.InputNumberDrag("ReferenceDistance", ref, { Step = 0.1 }) then
        ref = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("MaximalDistance", max, { Step = 0.1 }) then
        max = Slab.GetInputNumber(); input = true;
    end
    if input then item:setAttenuationDistances(ref, max); end
    if Slab.InputNumberDrag("AirAbsorbtion", item.source:getAirAbsorption(), { Step = 0.1, MinNumber = 0}) then
        local aa = Slab.GetInputNumber();
        item:setAirAbsorption(aa);
    end
    if Slab.InputNumberDrag("Rolloff", item.source:getRolloff(), { Step = 0.1 }) then
        local rf = Slab.GetInputNumber();
        item:setRolloff(rf);
    end
    Slab.EndLayout();
    Slab.Separator();

    Slab.BeginLayout("PositionLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Position");
    Slab.Text("x:");
    Slab.Text("y:");
    Slab.Text("z:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setPosition(0, 0, 0);
    end
    local x, y, z = item.source:getPosition();
    input = false;
    if Slab.InputNumberDrag("PositionX", x, { Step = 0.1 }) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("PositionY", y, { Step = 0.1 }) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("PositionZ", z, { Step = 0.1 }) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setPosition(x, y, z); end
    Slab.EndLayout();
    Slab.Separator();

    Slab.BeginLayout("VelocityLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Velocity");
    Slab.Text("x:");
    Slab.Text("y:");
    Slab.Text("z:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setVelocity(0, 0, 0);
    end
    x, y, z = item.source:getVelocity();
    input = false;
    if Slab.InputNumberDrag("VelocityX", x, { Step = 0.1 }) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("VelocityY", y, { Step = 0.1 }) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("VelocityZ", z, { Step = 0.1 }) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setVelocity(x, y, z); end
    Slab.EndLayout();
    Slab.Separator();

    Slab.BeginLayout("DirectionLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Direction");
    Slab.Text("x:");
    Slab.Text("y:");
    Slab.Text("z:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setDirection(0, 0, 0);
    end
    local x, y, z = item.source:getDirection();
    input = false;
    if Slab.InputNumberDrag("DirectionX", x, { Step = 0.1 }) then
        x = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("DirectionY", y, { Step = 0.1 }) then
        y = Slab.GetInputNumber(); input = true;
    end
    if Slab.InputNumberDrag("DirectionZ", z, { Step = 0.1 }) then
        z = Slab.GetInputNumber(); input = true;
    end
    if input then item:setDirection(x, y, z); end
    Slab.EndLayout();
    Slab.Separator();

    Slab.BeginLayout("ConeLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Cone");
    Slab.Text("Inner angle:");
    Slab.Text("Outer angle:");
    Slab.Text("Outer volume:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setCone(math.rad(360), math.rad(360), 0);
    end
    local ia, oa, ov = item.source:getCone();
    local changed = false;
    if Slab.InputNumberSlider("InnerAngleSlider", math.floor(math.deg(ia)), 0, 360, { NoDrag = false}) then
        ia = math.rad(Slab.GetInputNumber());
        changed = true;
    end
    if Slab.InputNumberSlider("OuterAngleSlider", math.floor(math.deg(oa)), 0, 360, { NoDrag = false}) then
        oa = math.rad(Slab.GetInputNumber());
        changed = true;
    end
    if Slab.InputNumberSlider("OuterVolumeSlider", math.floor(ov * 100), 0, 100, { NoDrag = false}) then
        ov = Slab.GetInputNumber() / 100;
        changed = true;
    end
    if changed then item:setCone(ia, oa, ov); end
    Slab.EndLayout();
end

local function advancedOptions(item)
    spatialOptions(item);
    Slab.Separator();
    Slab.BeginLayout("VolumeLimitsLayout", { Columns = 2 });
    Slab.SetLayoutColumn(1);
    Slab.Text("Volume limits");
    Slab.Text("Minimal:");
    Slab.Text("Maximal:");
    Slab.SetLayoutColumn(2);
    if Slab.Button("Reset") then
        item:setVolumeLimits(0, 1);
    end
    local minv, maxv = item.source:getVolumeLimits();
    local changed = false;
    if Slab.InputNumberSlider("MinVolume", math.floor(minv * 100), 0, 100) then
        minv = Slab.GetInputNumber() / 100; changed = true;
    end
    if Slab.InputNumberSlider("MaxVolume", math.floor(maxv * 100), 0, 100) then
        maxv = Slab.GetInputNumber() / 100; changed = true;
    end
    if changed then item:setVolumeLimits(minv, maxv); end
    Slab.EndLayout();
end

local function scp(item)
    changed = false;
    if item:advancedVisible() then
        if Slab.Button("Hide advanced options") then
            item:setShowAdvanced(false);
        end
        advancedOptions(item);
        Slab.Separator();
    else
        if Slab.Button("Show advanced options") then
            item:setShowAdvanced(true);
        end
    end
    Slab.BeginLayout("PlaybackControlLayout", { Columns = 3, AlignX = 'center' });
    Slab.SetLayoutColumn(1);
    Slab.Text("Volume:");
    Slab.SameLine();
    local ov = item.source:getVolume();
    if Slab.InputNumberSlider("VolumeSlider", math.floor(ov * 100), 0, 100, { NoDrag = false}) then
        local nv = Slab.GetInputNumber();
        item:setVolume(nv / 100);
    end
    Slab.SetLayoutColumn(2);
    if Slab.CheckBox(item.source:isLooping(), "Looping") then
        item:toggleLooping();
    end
    Slab.SetLayoutColumn(3);
    Slab.Text("Time:");
    Slab.SameLine();
    Slab.Text(Utils.TimeFormat(item.source:tell()));
    Slab.EndLayout();
    Slab.BeginLayout("PlaybackButtonsLayout", { Columns = 5 });
    Slab.SetLayoutColumn(1);
    if Slab.Button("[<<") then
        item.source:seek(0);
    end
    Slab.SetLayoutColumn(2);
    if Slab.Button("<") then
        item:rewindBy(-10);
    end
    Slab.SetLayoutColumn(3);
    if item.source:isPlaying() then
        if Slab.Button("Pause") then
            item:pause();
        end
    else
        if Slab.Button("Play") then
            item:play();
        end
    end
    Slab.SetLayoutColumn(4);
    if Slab.Button("Stop") then
        item:stop();
    end
    Slab.SetLayoutColumn(5);
    if Slab.Button(">") then
        item:rewindBy(10);
    end
    Slab.EndLayout();
    return changed;
end

return scp;
