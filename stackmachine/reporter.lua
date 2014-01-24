local glove = require 'stackmachine/glove'
local json = require 'stackmachine/json'
local tasks = require 'stackmachine/tasks'
local config = require 'stackmachine/config'
local module = {}

-- Given a stack message, return a JSON-encoded string
function module.create_report(msg)
  return json.encode({
    ['message'] = msg,
    ['tags'] = {
      ['release'] = love._release or false,
      ['os'] = love._os,
      ['version'] = config.version,
    },
  })
end

function module.report_local(payload)
  local crashpath = string.format("crashlogs/crash-%d.json", os.time())
  glove.filesystem.mkdir("crashlogs")
  love.filesystem.write(crashpath, payload)
  return crashpath
end

function module.report_remote(msg)
  tasks.report(msg)
end

function module.send_report(msg)
  local payload = module.create_report(msg)
  local path = module.report_local(payload)
  local success = module.report_remote(msg)
  return path
end

local function stackmessage(msg, trace, version)
  local err = {}

  table.insert(err, msg.."\n\n")

  for l in string.gmatch(trace, "(.-)\n") do
    if not string.match(l, "boot.lua") then
      l = string.gsub(l, "stack traceback:", "Traceback [v" .. version .. "]\n")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "\n")

  p = string.gsub(p, "\t", "")
  p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

  return p
end


function module.log(msg)
  msg = tostring(msg)

  if not love.graphics or not love.event or not love.graphics.isCreated() then
    return
  end

  -- Load.
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 157, 220)
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.clear()

  local trace = debug.traceback()
  local p = stackmessage(msg, trace, config.version)

  local path = module.send_report(p)
  local savedir = love.filesystem.getSaveDirectory()

  p = p .. "\n\nCrash report logged to " .. savedir .. "/" .. path

  local function draw()
    love.graphics.clear()
    love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
    love.graphics.present()
  end

  draw()

  local e, a, b, c
  while true do
    e, a, b, c = love.event.wait()

    if e == "quit" then
      return
    end
    if e == "keypressed" and a == "escape" then
      return
    end

    draw()
  end
end

return module
