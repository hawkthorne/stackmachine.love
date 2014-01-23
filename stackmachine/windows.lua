local logging = require "sparkle/logging"
local os = require "os"
local url = require "socket.url"
local urllib = require "sparkle/urllib"
local utils = require "sparkle/utils"
local glove = require "sparkle/glove"

local windows = {}
local logger = logging.new('update')

-- splits a string on a pattern, returns a table
local function split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end


local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function execute(command, msg)
  local code = os.execute(command)
    
  if code ~= 0 then
    error(msg)
  end
end

function windows.getApplicationPath(lovepath)
  if love._exe then
    return ""
  end
  return lovepath
end

function windows.getDownload(item)
  local cwd = love.filesystem.getWorkingDirectory()

  for i, platform in ipairs(item.platforms) do
    if platform.name == "windows" then
      return platform
    end
  end

  return nil
end

function windows.basename(link)
  local parsed_url = url.parse(link)
  local parts = split(parsed_url.path, "/")
  return table.remove(parts)
end

function windows.split(path)
  local parts = split(path, "\\")
  local basename = table.remove(parts)
  return path:sub(0, (2 + string.len(basename)) * -1), basename
end


-- Remove all files in a directory. The directory must be in the game save
-- folder
function windows.removeRecursive(path)
  if love.filesystem.isFile(path) then
    return love.filesystem.remove(path)
  end

  for k, file in ipairs(glove.filesystem.enumerate(path)) do
    local subpath = path .. "/" .. file

    if love.filesystem.isDirectory(subpath) then
      if not windows.removeRecursive(subpath) then
        return false
      end
    end

    if not love.filesystem.remove(subpath) then
      return false
    end
  end

  return love.filesystem.remove(path)
end

function windows.cleanup()
  windows.removeRecursive("winupdates")
end

function windows.replace(download, exepath, callback)
  -- Clean up previous updates
  windows.removeRecursive("winupdates")
  glove.filesystem.mkdir("winupdates")

  local destination = love.filesystem.getSaveDirectory() .. "/winupdates"

  local cwd, exebase = windows.split(exepath)

  -- Download new files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)
    urllib.retrieve(file.url, destination .. "/" .. base, file.length, callback)
  end

  -- Rename current files
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)

    if utils.endswith(base, ".dll") then
      os.rename(cwd .. "/" .. base, destination .. "/old_" .. base)
    end
  end

  -- Move the old executable
  os.rename(exepath, destination .. "/old_" .. exebase)

  -- Move new files into place
  for _, file in ipairs(download.files) do
    local base = windows.basename(file.url)

    if utils.endswith(base, ".dll") then
      os.rename(destination .. "/" .. base, cwd .. "/" .. base)
    end

    if utils.endswith(base, ".exe") then
      os.rename(destination .. "/" .. base, exepath)
    end
  end

  -- http://stackoverflow.com/questions/154075/using-the-dos-start-command-with-parameters-passed-to-the-started-program
  local cmd = 'cmd /C start "" "' .. exepath .. '"'
  logger:info(cmd)
  os.execute(cmd)
end

return windows
