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
love.graphics.setDepthMode("less", true)
love.graphics.setBackgroundColor(.1, .1, .1)

local sw, sh = love.graphics.getDimensions()

local camera = {}
camera.xyz = {3/2, 1/2, 2}
camera.phi = math.rad(180)
camera.theta = math.rad(150)
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
  local input = love.filesystem.newFile("points.txt")
  for line in input:lines() do
    local x, y, z = string.match(line, "(.+) (.+) (.+)")
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    local r = .6*(.5+2*z)
    local g = .6*(.5+1.1*z)
    local b = (.5+1.1*z)
    points[#points+1] = {x, y, z, r, g, b, 1}
  end
  input:close()
end
local mesh = love.graphics.newMesh({{"VertexPosition", "float", 3}, {"VertexColor", "float", 4}}, points, "triangles", "static")
do
  local order = {}
  local input = love.filesystem.newFile("order.txt")
  for line in input:lines() do
    n = string.match(line, "(.+)")
    order[#order+1] = n
  end
  mesh:setVertexMap(order)
end

local eps = .003
local x_arrow = love.graphics.newMesh({{"VertexPosition", "float", 3}},
  {{0, -eps, -eps}, {0, -eps,  eps}, {0, eps, eps},
   {0, -eps, -eps}, {0,  eps, -eps}, {0, eps, eps},
   {1, -eps, -eps}, {1, -eps,  eps}, {1, eps, eps},
   {1, -eps, -eps}, {1,  eps, -eps}, {1, eps, eps},
   
   {0, -eps, -eps}, {1, -eps, -eps}, {0, -eps, eps},
   {0, -eps,  eps}, {1, -eps, -eps}, {1, -eps, eps},
   
   {0, -eps, -eps}, {1, -eps, -eps}, {0, eps, -eps},
   {0,  eps, -eps}, {1, -eps, -eps}, {1, eps, -eps},
   
   {0, -eps, eps}, {1, -eps, eps}, {0, eps, eps},
   {0,  eps, eps}, {1, -eps, eps}, {1, eps, eps},

   {0, eps, -eps}, {1, eps, -eps}, {0, eps, eps},
   {0, eps,  eps}, {1, eps, -eps}, {1, eps, eps}},
  "triangles", "static")

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
  love.graphics.draw(x_arrow)
  love.graphics.setShader()
end