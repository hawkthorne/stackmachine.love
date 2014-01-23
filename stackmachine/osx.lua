require "love.timer"

local os = require "os"
local glove = require "sparkle/glove"
local urllib = require "sparkle/urllib"
local logging = require "sparkle/logging"
local utils = require "sparkle/utils"

local osx = {}
local logger = logging.new('update')

local function execute(command, msg)
  local code = os.execute(command .. " > /dev/null 2>&1")

  logger:info(command)
    
  if code ~= 0 then
    error(msg)
  end
end

function osx.getApplicationPath(applicationPath)
  -- Remove /Contents/MacOS/love from the working directory
  local path = applicationPath:sub(0, -20)

  if path:find(".app") then
    return path
  end

  return ""
end

-- no op
function osx.cleanup()
  for _, filename in ipairs(glove.filesystem.enumerate("updates")) do
    if filename == "oldgame.app" then
      love.timer.sleep(2)
    end
  end

  local destination = love.filesystem.getSaveDirectory() .. "/updates"

  execute(string.format("rm -rf \"%s\"", destination),
          string.format("Error removing \"%s\"", destination))
end

function osx.getDownload(item)
  for i, platform in ipairs(item.platforms) do
    if platform.name == "macosx" then
      return platform
    end
  end
  return nil
end

function osx.replace(download, oldpath, callback)
  glove.filesystem.mkdir("updates")

  local destination = love.filesystem.getSaveDirectory() .. "/updates"
  local zipfile = destination .. "/game_update_osx.zip"
  local item = download.files[1]

  urllib.retrieve(item.url, zipfile, item.length, callback)

  callback(false, "Installing", 25)

  execute(string.format("unzip -q -d \"%s\" \"%s\"", destination, zipfile),
          string.format("Error unzipping %s", zipfile))

  local newpath = nil

  for _, filename in ipairs(glove.filesystem.enumerate("updates")) do
    if utils.endswith(filename, ".app") then
      newpath = destination .. "/" .. filename
    end
  end

  if newpath == nil then
    error("Could not find new app to download")
  end

  callback(false, "Installing", 50)

  execute(string.format("mv \"%s\" \"%s\"", oldpath, destination .. "/oldgame.app"),
          string.format("Error moving previous install %s", oldpath))

  callback(false, "Installing", 75)

  execute(string.format("mv \"%s\" \"%s\"", newpath, oldpath),
          string.format("Error moving new app %s to %s", newpath, oldpath))

  os.remove(zipfile)

  callback(false, "Installing", 100)

  execute(string.format("(sleep 1; open \"%s\") &", oldpath),
          string.format("Can't open %s", oldpath))
end

return osx
