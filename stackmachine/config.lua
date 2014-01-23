local json = require 'sparkle/json'

if love.filesystem.exists("sparkle/config.json") then
  local contents, _ = love.filesystem.read("sparkle/config.json")
  return json.decode(contents)
end

return {
  ["version"] = "",
  ["links"] = {
    ["updates"] = "",
    ["metrics"] = "",
    ["errors"] = "",
  }
}
