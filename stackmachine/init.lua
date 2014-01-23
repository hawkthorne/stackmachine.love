require "love.filesystem"

local glove = require "sparkle/glove"
local http = require "socket.http"
local ltn12 = require "ltn12"
local os = require "os"

local middle = require 'sparkle/middleclass'
local json = require 'sparkle/json'
local logging = require 'sparkle/logging'
local osx = require 'sparkle/osx'
local windows = require 'sparkle/windows'
local utils = require 'sparkle/utils'

local Updater = middle.class('Updater')
local logger = logging.new("update")

function Updater:initialize(args, version, url)
  self.thread = nil
  self.version = version
  -- FIXME: Remove
  self.lovepath = utils.getLow(args)
  self.url = url
  self._finished = url == ""

  logger:info("LOVEPATH: " .. self.lovepath)
end

function Updater:done()
  return self._finished
end

-- All paths must be absolute
function Updater:start()
  if self.url == "" then
    return
  end

  if not self.thread then
    self.thread = glove.thread.newThread("sparkle", "sparkle/thread.lua")
    self.thread:start()
    self.thread:set('version', self.version)
    self.thread:set('lovepath', self.lovepath)
    self.thread:set('url', self.url)
  end
end

function Updater:progress()
  if not self.thread then
    logger:info("Waiting to start")
    return "Waiting to start", 0
  end

  local ok = true
  local percent = self.thread:get('percent') or 0
  local status = self.thread:get('message')
  local finished = self.thread:get('finished') or false
  local err = self.thread:get('error')
  
  if status ~= nil and status ~= "Downloading" and status ~= "Installing" then
    logger:info(status)
  end

  if err ~= nil then
    logger:error("Updater failed")
    logger:error(err)
  end

  if err ~= nil or finished then
    self._finished = true
  end

  if err ~= nil then
    return err, percent, false
  end

  if status ~= nil then
    return status, percent, ok
  end

  if self:done() then
    return "Finished updating", 100, ok
  end

  return "", 0, ok
end

local sparkle = {}

function sparkle.newUpdater(args, version, url)
  return Updater(args, version, url)
end

function sparkle.parseVersion(version)
  local a, b, c = string.match(version, '^(%d+)%.(%d+)%.(%d+)$')
  if a == nil or b == nil or c == nil then
    return nil, nil, nil
  end
  return tonumber(a), tonumber(b), tonumber(c)
end

-- Returns nil if no update is found
function sparkle.findItem(version, appcast)
  local item = appcast.items[1] or {}
  local newestVersion = item.version or ""
  if sparkle.isNewer(version, newestVersion) then
    return item
  else
    return nil
  end
end

function sparkle.isNewer(version, other)
  local major1, minor1, fix1 = sparkle.parseVersion(version)
  local major2, minor2, fix2 = sparkle.parseVersion(other)

  if major1 == nil or major2 == nil then
    return false
  end

  if major1 < major2 then
    return true
  end

  if major1 == major2 and minor1 < minor2 then
    return true
  end

  if major1 == major2 and minor1 == minor2 and fix1 < fix2 then
    return true
  end

  return false
end

function sparkle.getPlatform()
  if love._os == "OS X" then
    return osx
  elseif love._os == "Windows" then
    return windows
  else
    return nil
  end
end

-- This method blocks and should never be called directly, use the updater object
function sparkle.update(lovepath, version, url, callback)
  local callback = callback or function(s, p) end
  local platform = sparkle.getPlatform()

  if platform == nil then
    error("Current platform doesn't support automatic updates")
  end

  -- Clean up after old updates
  platform.cleanup()

  local oldpath = platform.getApplicationPath(lovepath)

  if oldpath == "" then
    logger:info("Can't find application directory")
    error("Can't find application directory")
  end

  pcall(callback, false, "Checking for updates", 0)
  
  -- Download appcast
  local b, c, h = http.request(url)

  if c >= 400 then
    error("Can't fetch appcast.json, returned HTTP " .. tostring(c))
  end

  -- Parse appcast
  local appcast = json.decode(b)
  local item = sparkle.findItem(version, appcast)

  if item == nil then
    pcall(callback, true, "Current version is up to date", 100)
    return
  end

  local download = platform.getDownload(item)

  if download == nil then
    error("Can't find download for in appcast item")
  end

  -- Replace the current app with the download application
  platform.replace(download, oldpath, callback)

  -- Quit the current program
  love.event.push("quit")
end

return sparkle
