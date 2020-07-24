
Slab = require('thirdparty/Slab');

FilepathArray = {};

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
            if Slab.MenuItem("Add") then
                openFilepathDialog = true;
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
        if Slab.BeginTree("Filepaths") then
            for name, path in pairs(FilepathArray) do
                if Slab.BeginTree(name, { IsLeaf = true, IsSelected = path.isSelected }) then
                    if Slab.IsControlClicked() then
                        print("Leaf clicked:", name);
                        path.isSelected = not path.isSelected;
                    end
                end
            end
            Slab.EndTree();
        end
    end
    Slab.EndWindow();

    AddFilepathDialog();
    FnameidExistsDialog();

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
                if FilepathArray[fpath] ~= nil then
                    fnameidExistsDialog = true;
                else
                    FilepathArray[fpath] = { isSelected = false };
                end
            end
        end
        if result.Button ~= "" then openFilepathDialog = false; end
    end
end

function FnameidExistsDialog()
    if fnameidExistsDialog then
        local result = Slab.MessageBox("Existing item!", "This item already exists!", { Buttons = { "OK" } });
        if result ~= "" then
            fnameidExistsDialog = false;
        end
    end
end
