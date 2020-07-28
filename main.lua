
bitser = require('thirdparty/bitser/bitser');

Slab = require('thirdparty/Slab');

local InfoQueue = require('InfoQueue');

local IWManager = require('ItemWindowsManager');

local FPSModule = require('FileSourcesModule');

local function loadData()
    local status, value = pcall(bitser.loadLoveFile, 'LoveAudioTesterState.dat');
    if status == false then
        progData = nil;
    else
        progData = value;
    end
    if progData == nil then return; end
    if progData.modules ~= nil then
        FPSModule:LoadData(progData.modules.fpsmodule)
    end
end

local function saveData()
    local progData = { modules = {} };
    progData.modules.fpsmodule = FPSModule:SaveData();
    bitser.dumpLoveFile('LoveAudioTesterState.dat', progData);
end

function love.load(args)
    InfoQueue.debug = true;
    Slab.Initialize(args);
    SlabQuit = love.quit;
    love.quit = onquit;
    loadData();
end


function love.update(dt)
    windowW, windowH = love.window.getMode();

    Slab.Update(dt);

    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Program") then
            if Slab.MenuItem("Save state") then
                saveData();
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
    if quitConfirmed then
        SlabQuit();
        if saveOnQuit then
            saveData();
        end
        return false;
    end
    quitDialog = true;
    return true;
end
