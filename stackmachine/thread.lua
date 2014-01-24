require "love.filesystem"
require "love.event"

local glove = require("stackmachine/glove")
local stackmachine = require("sparkle")
local json = require("stackmachine/json")

local thread = glove.thread.getThread()

local version = thread:demand('version')
local url = thread:demand('url')
local lovepath = thread:demand('lovepath')

local function statusCallback(finished, status, percent)
  thread:set('finished', finished)
  thread:set('message', status)
  thread:set('percent', percent)
end

stackmachine.update(lovepath, version, url, statusCallback)

