--[[
    file to handle all structures such as
    3d vectors, traingles, objects made of
    triangles (mesh)
--]]
local Object = require "Object"

---@class points
-- handle the points to form vector
local vec3 = Object:extend()

---@param x number
---@param y number
---@param z number
function vec3:new(x, y ,z)
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        error("Only 3 nubmbers allows vec3 initialization")
    end

    self.x = x
    self.y = y
    self.z = z
end


-----------------------------------------------------------------------------------------------
---@class triangle
-- handle 3 points
local triangle = Object:extend()

---@param point1 vec3
---@param point2 vec3
---@param point3 vec3
function triangle:new(point1, point2, point3)
    if not point1:is(vec3) or not point2:is(vec3) or not point3:is(vec3) then
        error("Only 3 vec3 allows traingle initialization")
    end
    self.point = {}

    self.point[1] = point1
    self.point[2] = point2
    self.point[3] = point3
end


-----------------------------------------------------------------------------------------------
---@class mesh
-- handle 3 points
local mesh = Object:extend()

---@param triangles table
function mesh:new(triangles)
    ---[[
    for key, value in ipairs(triangles) do
        if not value:is(triangle) then
            error("Only traingles allows mesh initialization")
        end
    end
    --]]

    self.tri_s = triangles
end

-----------------------------------------------------------------------------------------------
---@class mat4x4
-- handle 3 points
local mat4x4 = Object:extend()

function mat4x4:new()
    self.m = {}
    for i = 1, 4 do
        self.m[i] = {}
        for j = 1, 4, 1 do
            self.m[i][j] = 0
        end
    end
end

return {vec3 = vec3, triangle = triangle, mesh = mesh, mat4x4 = mat4x4}