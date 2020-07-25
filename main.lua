
MiddleClass = require ('thirdparty/middleclass/middleclass');

Slab = require('thirdparty/Slab');

require('SortableContainer');

require('SortGUI');

require('DeleteConfirmator');

StandardId = SortableAttribute("id", "Id");
PathAttr = SortableAttribute("path", "Path");
FilepathContainer = SortableContainer("fpathcontainer", "Filepath list");

FilepathContainer:addAttribute(PathAttr)

dpConfirmator = DeleteConfirmator(FilepathContainer, "filepaths");

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
        if Slab.BeginMenu("Filepaths") then
            SortMenu(FilepathContainer);
            if Slab.MenuItem("Add") then
                openFilepathDialog = true;
            end
            if Slab.MenuItem("Delete") then
                dpConfirmator.active = true;
            end
            Slab.EndMenu();
        end
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
        SortedTree(FilepathContainer);
    end
    Slab.EndWindow();

    AddFilepathDialog();
    dpConfirmator:update();

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

function AddFilepathDialog()
    if openFilepathDialog then
        local result = Slab.FileDialog({ Type = "openfile" })
        if result.Button == "OK" then
            for key, fpath in pairs(result.Files) do
                local item = { id = fpath, attributes = { path = fpath } };
                if FilepathContainer.ids[item.id] == nil then
                    FilepathContainer:addItem(item);
                end
            end
        end
        if result.Button ~= "" then openFilepathDialog = false; end
    end
end
