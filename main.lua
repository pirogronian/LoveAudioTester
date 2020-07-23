
Slab = require('thirdparty/Slab');

function love.load(args)
    Slab.Initialize(args);
end


function love.update(dt)
    Slab.Update(dt);
    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Program") then
            if Slab.MenuItem("Quit") then
                quitDialog = true;
            end
            Slab.EndMenu();
        end
        Slab.EndMainMenuBar();
    end
    if quitDialog then
        local result = Slab.MessageBox("Are You sure?", "Are You sure to quit program?", { Buttons = { "Yes", "No" }});
        if result ~= "" then
            print(result);
            quitDialog = false;
        end
        if result == "Yes" then
            love.event.quit();
        end
    end
end

function love.draw()
    Slab.Draw();
end

function love.quit()
end
