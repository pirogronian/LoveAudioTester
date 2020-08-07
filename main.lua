
Slab = require('thirdparty/Slab');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local SManager = require('StateManager');

local FPSModule = require('FileSourcesModule');

function love.load(args)
    InfoQueue.debug = true;
    Slab.Initialize(args);
    SlabQuit = love.quit;
    love.quit = onquit;
    SManager:RegisterModule(FPSModule);
--     SManager:RegisterModule(IWManager);
    SManager:LoadState();
end


function love.update(dt)
    windowW, windowH = love.window.getMode();

    Slab.Update(dt);

    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Program") then
            if Slab.MenuItem("Save state") then
                SManager:SaveState();
            end
            if Slab.MenuItem("Quit") then
                love.event.quit();
            end
            Slab.EndMenu();
        end
        FPSModule:UpdateMenu();

        MMBW, MMBH = Slab.GetControlSize();
        Slab.EndMainMenuBar();
    end

    if Slab.BeginWindow("MainWindow", 
                        { AutoSizeWindow = false,
                          AllowMove = false,
                          AllowResize = false,
                          AllowFocus = false,
                          NoSavedSettings = true,
                          X = 0, Y = MMBH,
                          W = windowW,
                          H = windowH - MMBH,
                          ContentW = windowW,
                          ContentH = windowH - MMBH,
                          NoOutline = true}) then
        FPSModule:UpdateTree();
    end
    Slab.EndWindow();

    IWManager:UpdateCurrentItemWindows();
    FPSModule:UpdateDialogs();
    InfoQueue:Update();

    if quitDialog then
        local result = Slab.MessageBox(
            "Are You sure?",
            "Save state before quit program?",
            { Buttons = { "Yes", "No", "Cancel" }});
        if result ~= "" then
            quitDialog = false;
            if result ~= "Cancel" then
                quitConfirmed = true;
                if result == "Yes" then
                    saveOnQuit = true;
                else
                    saveOnQuit = false;
                end
                love.event.quit();
            end
        end
    end
end

function love.draw()
    Slab.Draw();
end

function onquit()
    if not SManager:IsStateChanged() then
        quitConfirmed = true;
    end
    if quitConfirmed then
        SlabQuit();
        if saveOnQuit then
            SManager:SaveState();
        end
        return false;
    end
    quitDialog = true;
    return true;
end
