
Slab = require('thirdparty/Slab');

local InfoQueue = require('InfoQueue');

local WManager = require('WindowsManager');

local SManager = require('StateManager');

local ITModule = require('ItemsTreeModule');

local SModule = require('SourcesModule');

local FModule = require('FilesModule');

local Scene = require('Scene');

local Diagram = require('Diagram');

local Diag = Diagram("Diagram");

local MouseRecorder = require('MouseRecorder');

function love.load(args)
    InfoQueue.debug = true;
    Slab.Initialize(args);
    SlabQuit = love.quit;
    love.quit = onquit;
    Diag:setScene(Scene);
    SModule.container.itemAdded:connect(Diag.addSourceItem, Diag);
    SManager:RegisterModule(FModule);
    SManager:RegisterModule(SModule);
    SManager:RegisterModule(ITModule);
    SManager:RegisterModule(Scene);
    SManager:RegisterModule(WManager);
    SManager:LoadState();
end


function love.update(dt)
    MouseRecorder:updateActiveRecorders();
    if not love.window.isVisible() then return end
    windowW, windowH = love.window.getMode();

    Slab.Update(dt);

    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Program") then
            if Slab.MenuItem("Save state") then
                SManager:SaveState();
            end
            if Slab.MenuItem("Items tree") then
                WManager:setCurrentModule(ITModule.id);
                WManager:showModuleWindow(ITModule.id);
            end
            if Slab.MenuItem("Quit") then
                love.event.quit();
            end
            Slab.EndMenu();
        end
        WManager:UpdateMenu();
        FModule:updateMainMenu();
        SModule:updateMainMenu();
        Scene:mainMenu();

        MMBW, MMBH = Slab.GetControlSize();
        Slab.EndMainMenuBar();
    end

    WManager:UpdateWindows();
    FModule:updateDialogs();
    SModule:updateDialogs();
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
    if not love.window.isVisible() then return end
    Diag:draw();
    Slab.Draw();
end

function love.mousepressed(x, y, button, istouch, pressess)
--     print("mousepressed:", x, y, button, istouch, pressess);
    Slab.MousePressed(x, y, button, istouch, pressess);
end

function love.mousereleased(x, y, button, istouch, pressess)
--     print("mousereleased:", x, y, button, istouch, pressess);
    Slab.MouseReleased(x, y, button, istouch, pressess);
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
