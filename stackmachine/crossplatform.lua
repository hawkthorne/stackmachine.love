require "love.timer"

local os = require "os"
local glove = require "stackmachine/glove"
local urllib = require "stackmachine/urllib"
local logging = require "stackmachine/logging"
local utils = require "stackmachine/utils"

local crossplatform = {}
local logger = logging.new('update')


function launchCommand(args)
  local command = ""

  if love._version == "0.8.0" then
    if #args >= 4 and args[3] == args[#args] then
      table.remove(args)
    end
  end

  if #args >= 2 and args[2] == "embedded boot.lua" then
    table.remove(args, 2)
  end

  for i,v in ipairs(args) do
    command = string.format("%s \"%s\"", command, v)
  end

  return command
end


function restartCommand(launch)
  if love._os == "OS X" or love._os == "Linux" then
    return string.format("(sleep 1; %s) & > /dev/null 2>&1", launch)
  elseif love._os == "Windows" then
    return 'cmd /C start "" ' .. launch
  end
  return ""
end


function crossplatform.getApplicationPath(args)
  if #args < 2 then
    return ""
  end
  return args[3]
end

-- no op
function crossplatform.cleanup()
  local updatedir = love.filesystem.getSaveDirectory() .. "/updates"
  local oldgame = updatedir .. "/oldgame.love"
  local update = updatedir .. "/update.love"

  love.filesystem.remove(oldgame)
  love.filesystem.remove(update)
end

function crossplatform.getDownload(item)
  for i, platform in ipairs(item.platforms) do
    if platform.name == "crossplatform" then
      return platform
    end
  end
  return nil
end

function crossplatform.replace(download, oldpath, args, callback)
  glove.filesystem.mkdir("updates")

  local destination = love.filesystem.getSaveDirectory() .. "/updates"
  local lovefile = destination .. "/update.love"
  local item = download.files[1]

  urllib.retrieve(item.url, lovefile, item.length, callback)

  -- Move the old lovefile
  os.rename(args[3], destination .. "/oldgame.love")
  callback(false, "Installing", 25)

  -- Move the new lovefile into the old one's place
  os.rename(lovefile, args[3])
  callback(false, "Installing", 100)

  local cmd = restartCommand(args)

  if cmd then
    logger:info(cmd)
    os.execute(cmd)
  end
end

return crossplatform
