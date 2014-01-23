local glove = require 'sparkle/glove'
local utils = require 'sparkle/utils'
local config = require 'sparkle/config'
local json = require "sparkle/json"
local http = require "socket.http"
local ltn12 = require "ltn12"

local thread = nil

local tasks = {}

function tasks.report(message, data)
  local data = data or {}

  data["version"] = config.version
  data["os"] = love._os
  data["distinct_id"] = utils.distinctId()

  if thread == nil then
    thread = glove.thread.newThread("tasks", "sparkle/task_thread.lua")
    thread:start()
  end

  local msg = string.gsub(message, "\'", "\"")

  local request = {
    ["url"] = config.links.errors,
    ["payload"] = {
      ["errors"] = {
        {["message"] = msg, ["tags"] = data},
      }
    }
  }

  thread:set('request', json.encode(request))
end

function tasks.track(event, data)
  if thread == nil then
    thread = glove.thread.newThread("tasks", "sparkle/task_thread.lua")
    thread:start()
  end

  local data = data or {}

  data["version"] = config.version
  data["os"] = love._os
  data["distinct_id"] = utils.distinctId()

  local request = {
    ["url"] = config.links.metrics,
    ["payload"] = {
      ["metrics"] = {
        { ["event"] = event, ["properties"] = data },
      },
    },
  }

  thread:set("request", json.encode(request))
end


return tasks

