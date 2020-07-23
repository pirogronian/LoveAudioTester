
Slab = require('thirdparty/Slab');

function love.load(args)
    Slab.Initialize(args);
    SlabQuit = love.quit;
    love.quit = onquit;
end


function love.update(dt)
    windowW, windowH = love.window.getMode();

    Slab.Update(dt);

    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Program") then
            if Slab.MenuItem("Quit") then
                love.event.quit();
            end
            Slab.EndMenu();
        end
        MMBW, MMBH = Slab.GetControlSize();
        Slab.EndMainMenuBar();
    end

    if Slab.BeginWindow("MainWindow", 
                        { AutoSizeWindow = false, 
                          X = 0, Y = MMBH, 
                          W = windowW, 
                          H = windowH - MMBH,
                          ContentW = windowW,
                          ContentH = windowH - MMBH,
                          NoOutline = true}) then
        if Slab.BeginTree("AudioData") then
            Slab.BeginTree("sample 1", { IsLeaf = true });
            Slab.BeginTree("sample 2", { IsLeaf = true });
            Slab.BeginTree("sample 3", { IsLeaf = true });
            Slab.BeginTree("sample 4", { IsLeaf = true });
            Slab.EndTree();
        end
    end
    Slab.EndWindow()

    if quitDialog then
        local result = Slab.MessageBox("Are You sure?", "Are You sure to quit program?", { Buttons = { "Yes", "No" }});
        if result ~= "" then
            quitDialog = false;
        end
        if result == "Yes" then
            quitConfirmed = true;
            love.event.quit();
        end
    end
end

function love.draw()
    Slab.Draw();
end

function onquit()
    if quitConfirmed then
        SlabQuit();
        return false;
    end
    quitDialog = true;
    return true;
end
