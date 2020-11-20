Application = require "Application"

function love.load()
    app = Application("3D App", 800, 600)
    pause = false
end

function love.update()
    function love.keyreleased(k)
        if k == 'space' then
            pause = not pause
        end
    end

    if pause then
        return
    else
        finalCube = app:calculate()
    end
end

function love.draw()
    app:drawCube(finalCube)
end