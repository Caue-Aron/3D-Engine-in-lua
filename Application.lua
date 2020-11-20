Object = require "Object"

--[[ cube
    -- SOUTH
    triangle(vec3(0, 0, 0), vec3(0, 1, 0), vec3(1, 1, 0)),
    triangle(vec3(0, 0, 0), vec3(1, 1, 0), vec3(1, 0, 0)),

    -- EAST
    triangle(vec3(1, 0, 0), vec3(1, 1, 0), vec3(1, 1, 1)),
    triangle(vec3(1, 0, 0), vec3(1, 1, 1), vec3(1, 0, 1)),
    
    -- NORTH
    triangle(vec3(1, 0, 1), vec3(1, 1, 1), vec3(0, 1, 1)),
    triangle(vec3(1, 0, 1), vec3(0, 1, 1), vec3(0, 0, 1)),
    
    -- WEST
    triangle(vec3(0, 0, 1), vec3(0, 1, 1), vec3(0, 1, 0)),
    triangle(vec3(0, 0, 1), vec3(0, 1, 0), vec3(0, 0, 0)), 
    
    -- TOP
    triangle(vec3(0, 1, 0), vec3(0, 1, 1), vec3(1, 1, 1)),
    triangle(vec3(0, 1, 0), vec3(1, 1, 1), vec3(1, 1, 0)),
    
    -- BOTTOM
    triangle(vec3(1, 0, 1), vec3(0, 0, 1), vec3(0, 0, 0)),
    triangle(vec3(1, 0, 1), vec3(0, 0, 0), vec3(1, 0, 0))    
--]]

--[[ pyramid
    triangle(vec3(-1.0,  0.0,  0.0), vec3( 1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5)),
    triangle(vec3(-1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5), vec3( 0.0,  0.0,  1.0)),
    triangle(vec3(-1.0,  0.0,  0.0), vec3( 1.0,  0.0,  0.0), vec3( 0.0,  0.0,  1.0)),
    triangle(vec3( 1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5), vec3( 0.0,  0.0,  1.0))    
--]]

Structures = require "Structures"
vec3 = Structures.vec3
triangle = Structures.triangle
mesh = Structures.mesh
mat4x4 = Structures.mat4x4

---@class Application : Object
Application = Object:extend()


---@param title string
---@param width number
---@param height number
---@param flags table
function Application:new(title, width, height, flags)
    ---[[
        love.window.setMode(width, height, flags)
        love.window.setTitle(title)
    --]]

    self.vCamera = vec3(1, 1, 1)

    self.cube = mesh({
        triangle(vec3(-1.0,  0.0,  0.0), vec3( 1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5)),
        triangle(vec3(-1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5), vec3( 0.0,  0.0,  1.0)),
        triangle(vec3(-1.0,  0.0,  0.0), vec3( 1.0,  0.0,  0.0), vec3( 0.0,  0.0,  1.0)),
        triangle(vec3( 1.0,  0.0,  0.0), vec3( 0.0,  1.0,  0.5), vec3( 0.0,  0.0,  1.0))      
    })

    function self:drawCube(finalCube)
        for key, value in pairs(finalCube.tri_s) do
            love.graphics.setColor((key * 10) / 275, (key * 20) / 275, (key * 30) / 275, 1)

            love.graphics.polygon('fill', {
                value.point[1].x, value.point[1].y,
                value.point[2].x, value.point[2].y,
                value.point[3].x, value.point[3].y
            })
        end
    end

    -- projection matrix
    do
        self.matProj = mat4x4()
        local fNear = 0.1
        local fFar = 1000.0
        local fFov = 90.0
        local fAspectRatio = love.graphics.getWidth() / love.graphics.getHeight()
        local fFovRad = 1.0 / math.tan(fFov * 0.5 / 180.0 * math.pi)

        self.matProj.m[1][1] = fAspectRatio * fFovRad
        self.matProj.m[2][2] = fFovRad
        self.matProj.m[3][3] = fFar / (fFar - fNear)
        self.matProj.m[4][3] = (-fFar * fNear) / (fFar - fNear)
        self.matProj.m[3][4] = 1.0
        self.matProj.m[4][4] = 0.0 
    end

    function self.MultiplyMatrixVector(vec, out, mat)
        if not vec:is(vec3) then
            error("First argument in MultiplyMatrixVector must be a vec3")
        end
        if not mat:is(mat4x4) then
            error("Second argument in MultiplyMatrixVector must be a mat4x4")
        end        
        out.x = vec.x * mat.m[1][1] + vec.y * mat.m[2][1] + vec.z * mat.m[3][1] + mat.m[4][1]
        out.y = vec.x * mat.m[1][2] + vec.y * mat.m[2][2] + vec.z * mat.m[3][2] + mat.m[4][2]
        out.z = vec.x * mat.m[1][3] + vec.y * mat.m[2][3] + vec.z * mat.m[3][3] + mat.m[4][3]
     local w  = vec.x * mat.m[1][4] + vec.y * mat.m[2][4] + vec.z * mat.m[3][4] + mat.m[4][4]

        if w ~= 0 then
            out.x = out.x / w
            out.y = out.y / w
            out.z = out.z / w
        end
    end

    self.theta = love.timer.getDelta()

    function self.calculate()
        self.theta = self.theta + 1.0 * love.timer.getDelta()

        local matRotZ = mat4x4()
        local matRotX = mat4x4()

        matRotZ.m[1][1] = math.cos(self.theta)
        matRotZ.m[1][2] = math.sin(self.theta)
        matRotZ.m[2][1] = -math.sin(self.theta)
        matRotZ.m[2][2] = math.cos(self.theta)
        matRotZ.m[3][3] = 1
        matRotZ.m[4][4] = 1

        matRotX.m[1][1] = 1
        matRotX.m[2][2] = math.cos(self.theta * 0.5)
        matRotX.m[2][3] = math.sin(self.theta * 0.5)
        matRotX.m[3][2] = -math.sin(self.theta * 0.5)
        matRotX.m[3][3] = math.cos(self.theta * 0.5)
        matRotX.m[4][4] = 1

        local finalCube = {}

        for key, tri in pairs(self.cube.tri_s) do
            local triProjected  = triangle(vec3(0, 0, 0), vec3(0, 0, 0), vec3(0, 0, 0))
            local triRotateZ    = triangle(vec3(0, 0, 0), vec3(0, 0, 0), vec3(0, 0, 0))
            local triRotateZX   = triangle(vec3(0, 0, 0), vec3(0, 0, 0), vec3(0, 0, 0))
            local triTranslated = triangle(vec3(0, 0, 0), vec3(0, 0, 0), vec3(0, 0, 0))
            
            
            self.MultiplyMatrixVector(tri.point[1], triRotateZ.point[1], matRotZ)
            self.MultiplyMatrixVector(tri.point[2], triRotateZ.point[2], matRotZ)
            self.MultiplyMatrixVector(tri.point[3], triRotateZ.point[3], matRotZ)
            
            self.MultiplyMatrixVector(triRotateZ.point[1], triRotateZX.point[1], matRotX)
            self.MultiplyMatrixVector(triRotateZ.point[2], triRotateZX.point[2], matRotX)
            self.MultiplyMatrixVector(triRotateZ.point[3], triRotateZX.point[3], matRotX)

            triTranslated = triRotateZX
            triTranslated.point[1].z = triRotateZX.point[1].z + 3.0
            triTranslated.point[2].z = triRotateZX.point[2].z + 3.0
            triTranslated.point[3].z = triRotateZX.point[3].z + 3.0


            local normal = vec3(1, 1, 1)
            local line1 = vec3(1, 1, 1)
            local line2 = vec3(1, 1, 1)

            line1.x = triTranslated.point[2].x - triTranslated.point[1].x
            line1.y = triTranslated.point[2].y - triTranslated.point[1].y
            line1.z = triTranslated.point[2].z - triTranslated.point[1].z
            
            line2.x = triTranslated.point[3].x - triTranslated.point[1].x
            line2.y = triTranslated.point[3].y - triTranslated.point[1].y
            line2.z = triTranslated.point[3].z - triTranslated.point[1].z
            
            normal.x = line1.y * line2.z - line1.z * line2.y
            normal.y = line1.z * line2.x - line1.x * line2.z
            normal.z = line1.x * line2.y - line1.y * line2.x


            local l = math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
            normal.x = normal.x / l
            normal.y = normal.y / l
            normal.z = normal.z / l
            
            if normal.z < 0 then
                self.MultiplyMatrixVector(triTranslated.point[1], triProjected.point[1], self.matProj)
                self.MultiplyMatrixVector(triTranslated.point[2], triProjected.point[2], self.matProj)
                self.MultiplyMatrixVector(triTranslated.point[3], triProjected.point[3], self.matProj)
                
                var = 1.0

                triProjected.point[1].x = triProjected.point[1].x + var
                triProjected.point[1].y = triProjected.point[1].y + var
                
                triProjected.point[2].x = triProjected.point[2].x + var
                triProjected.point[2].y = triProjected.point[2].y + var

                triProjected.point[3].x = triProjected.point[3].x + var
                triProjected.point[3].y = triProjected.point[3].y + var

                

                triProjected.point[1].x = triProjected.point[1].x * 0.5 * love.graphics.getWidth()
                triProjected.point[1].y = triProjected.point[1].y * 0.5 * love.graphics.getHeight()

                triProjected.point[2].x = triProjected.point[2].x * 0.5 * love.graphics.getWidth()
                triProjected.point[2].y = triProjected.point[2].y * 0.5 * love.graphics.getHeight()

                triProjected.point[3].x = triProjected.point[3].x * 0.5 * love.graphics.getWidth()
                triProjected.point[3].y = triProjected.point[3].y * 0.5 * love.graphics.getHeight()
                
                finalCube[key] = triProjected
            end
        end
        _finalCube = mesh(finalCube)
        return _finalCube
    end
end

return Application