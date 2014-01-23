local module = {}

local Logger = {}
Logger.__index = Logger

function module.new(name)
  local l = {}
  setmetatable(l, Logger)
  l.filename = name .. ".log"
  return l
end

-- We could eventually do this in a thread, but for now it's fine
function Logger:log(level, line)
  local file = love.filesystem.newFile(self.filename)
  file:open("a")
  file:write(string.format("%s %s %s\r\n", os.date("%c"), level, tostring(line)))
  file:close()
end

function Logger:debug(line)
  print(string.format("%s %s %s\r\n", os.date("%c"), "DEBUG", tostring(line)))
end

function Logger:info(line)
  self:log('INFO', line)
end

function Logger:warn(line)
  self:log('WARN', line)
end

function Logger:error(line)
  self:log('ERROR', line)
end

return module
