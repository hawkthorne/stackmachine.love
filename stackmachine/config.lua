local json = require 'stackmachine/json'

if love.filesystem.exists("stackmachine/config.json") then
  local contents, _ = love.filesystem.read("stackmachine/config.json")
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
