local pShader = love.graphics.newShader([[
  uniform mat4 MVP;

	vec4 position(mat4 transform_projection, vec4 vertex_position){
		return MVP * vec4(vertex_position.xyz, 1.0);
	}
]])

local V, M = unpack(require "vector")

love.mouse.setRelativeMode(true)
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setPointSize(1)

local sw, sh = love.graphics.getDimensions()

local camera = {}
camera.xyz = {0.5, 0.5, 1}
camera.phi = 0
camera.theta = math.rad(179)
camera.speed = 1
function camera.dir()
  return V.spherical(1, camera.theta, camera.phi)
end
function camera.right()
  return V.unit(V.cross(camera.dir(), {0,0,1}))
end
function camera.up()
  return V.unit(V.cross(camera.right(), camera.dir()))
end
local projection_matrix = M.perspective(math.rad(30), sw/sh, .1, 100)
function camera.mvp()
  local view_matrix = M.lookAt(camera.xyz, V.add(camera.xyz, camera.dir()), camera.up())
  local mvp = M.mulm(projection_matrix, view_matrix)
  return mvp
end

local points = {}
do
  local input = love.filesystem.newFile("output.txt")
  for line in input:lines() do
    local x, y, z = string.match(line, "(.+) (.+) (.+)")
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    points[#points+1] = {x, y, z}
  end
  input:close()
end
local mesh = love.graphics.newMesh({{"VertexPosition", "float", 3}}, points, "points", "static")


function love.mousemoved(x, y, dx, dy, istouch)
  camera.phi = camera.phi - dx/200
  local new_theta = camera.theta + dy/200
  if 0 <= new_theta and new_theta <= math.rad(180) then camera.theta = new_theta end
end

local dt = 1/60
local t = 0

function love.update(Dt)
  dt = Dt
  t = t + dt
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end

  if love.keyboard.isDown("w") then
    camera.xyz = V.add(camera.xyz, V.mul(dt*camera.speed, camera.dir()))
  end
  if love.keyboard.isDown("s") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt*camera.speed, camera.dir()))
  end
  if love.keyboard.isDown("d") then
    camera.xyz = V.add(camera.xyz, V.mul(dt*camera.speed, camera.right()))
  end
  if love.keyboard.isDown("a") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt*camera.speed, camera.right()))
  end
  if love.keyboard.isDown("e") then
    camera.xyz = V.add(camera.xyz, V.mul(dt*camera.speed, camera.up()))
  end
  if love.keyboard.isDown("q") then
    camera.xyz = V.add(camera.xyz, V.mul(-dt*camera.speed, camera.up()))
  end
end

function love.draw()
  love.graphics.setShader(pShader)
  pShader:send("MVP", camera.mvp())
  love.graphics.draw(mesh)
  love.graphics.setShader()
end